import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/isolate.dart' show DriftRemoteException;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../domain/route_snapshot.dart';
import 'snapshot_codec.dart';
import 'snapshot_database.dart';

class SqliteSnapshotStore implements RouteDiscoverySnapshotStore {
  SqliteSnapshotStore({required this.directory, int Function()? now})
    : now = now ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);
  static Future<Directory> androidDirectory() async {
    if (!Platform.isAndroid) {
      throw const CacheFailure('Copia local disponible solo en Android');
    }
    final path = await const MethodChannel('geoguide/offline')
        .invokeMethod<String>('noBackupDirectory');
    if (path == null || path.isEmpty) {
      throw const CacheFailure('Almacenamiento privado no disponible');
    }
    return Directory(path);
  }

  final Future<Directory> Function() directory;
  final int Function() now;
  final SnapshotCodec codec = const SnapshotCodec();
  SnapshotDatabase? _db;
  Directory? _directory;
  Future<void> _tail = Future.value();
  int _generation = 0;
  bool _blocked = false;
  int? _capture, _initialAge;
  final Stopwatch _elapsed = Stopwatch();
  Future<T> _serial<T>(Future<T> Function() action) {
    final next = _tail.then((_) => action());
    _tail = next.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return next;
  }

  Future<Directory> _dir() async {
    final d = _directory ??= await directory();
    if (await FileSystemEntity.type(d.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const CacheFailure('Directorio no seguro');
    }
    await d.create(recursive: true);
    return d;
  }

  File _file(Directory d, String name) =>
      File('${d.path}${Platform.pathSeparator}$name');
  static void setup(Database db) {
    final version = db.select('PRAGMA user_version').first.values.first as int;
    if (version != 0 && version != 1) throw const FormatException('schema');
    if (version == 0 &&
        db
            .select(
              "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
            )
            .isNotEmpty) {
      throw const FormatException('unversioned schema');
    }
    final check = db.select('PRAGMA quick_check');
    if (check.length != 1 || check.first.values.first != 'ok') {
      throw const FormatException('integrity');
    }
    for (final entry in {
      'page_size': 4096,
      'journal_mode': 'DELETE',
      'synchronous': 'EXTRA',
      'secure_delete': 'ON',
      'temp_store': 'MEMORY',
      'busy_timeout': 2000,
      'max_page_count': 1536,
    }.entries) {
      db.execute('PRAGMA ${entry.key}=${entry.value}');
    }
    for (final entry in {
      'page_size': 4096,
      'journal_mode': 'delete',
      'synchronous': 3,
      'secure_delete': 1,
      'temp_store': 2,
      'busy_timeout': 2000,
      'max_page_count': 1536,
    }.entries) {
      if (db.select('PRAGMA ${entry.key}').first.values.first != entry.value) {
        throw const CacheFailure('Configuración segura de caché no disponible');
      }
    }
  }

  Future<SnapshotDatabase> _open() async {
    if (_blocked) {
      throw const CacheFailure(
        'Borrado pendiente; reintenta eliminar la copia',
      );
    }
    final d = await _dir();
    if (await _file(d, 'delete_pending').exists()) await _purge();
    if (_db != null) return _db!;
    final file = _file(d, 'snapshot.sqlite');
    if (await file.exists() && await file.length() > 6 * 1024 * 1024) {
      await _purge();
    }
    final db = SnapshotDatabase(
      NativeDatabase.createInBackground(file, setup: setup),
    );
    _db = db;
    await db.customSelect('SELECT 1').get();
    return db;
  }

  Future<void> _purge() async {
    final d = await _dir();
    final marker = _file(d, 'delete_pending');
    _blocked = true;
    await marker.writeAsBytes([1], flush: true);
    final db = _db;
    _db = null;
    if (db != null) {
      try {
        await db.delete(db.routeDiscoverySnapshot).go();
      } catch (_) {
        /* Corrupt database is unlinked below. */
      }
      await db.close();
    }
    for (final name in [
      'snapshot.sqlite',
      'snapshot.sqlite-journal',
      'snapshot.sqlite-wal',
      'snapshot.sqlite-shm',
    ]) {
      final f = _file(d, name);
      if (await f.exists()) await f.delete();
    }
    await marker.delete();
    _blocked = false;
    _capture = null;
    _elapsed.reset();
  }

  bool _eligible(RouteSnapshot s, int time, int last) {
    if (_capture != s.capturedAtUtcMs) {
      _capture = s.capturedAtUtcMs;
      _initialAge = time - s.capturedAtUtcMs;
      _elapsed
        ..reset()
        ..start();
    }
    return s.eligible(time) &&
        time >= last &&
        _initialAge! + _elapsed.elapsedMilliseconds < RouteSnapshot.ttlMs;
  }

  @override
  Future<RouteSnapshot?> readEligible() {
    final generation = _generation;
    return _serial(() async {
      try {
        final db = await _open();
        final version = await db
            .customSelect('PRAGMA user_version')
            .getSingle();
        if (version.read<int>('user_version') != 1) {
          throw const FormatException('schema');
        }
        final rows = await db.select(db.routeDiscoverySnapshot).get();
        if (rows.isEmpty) return null;
        if (rows.length != 1) throw const FormatException('slots');
        final row = rows.single;
        late final RouteSnapshot s;
        try {
          s = codec.decode(row.payload);
        } catch (_) {
          throw const FormatException('payload');
        }
        final time = now();
        if (row.slot != 1 ||
            row.formatVersion != 1 ||
            row.payloadBytes != row.payload.length ||
            row.payloadSha256.toString() !=
                sha256.convert(row.payload).bytes.toString() ||
            row.capturedAtUtcMs != s.capturedAtUtcMs ||
            row.expiresAtUtcMs != s.expiresAtUtcMs ||
            row.lastObservedUtcMs < s.capturedAtUtcMs ||
            !_eligible(s, time, row.lastObservedUtcMs)) {
          throw const FormatException('ineligible');
        }
        await (db.update(db.routeDiscoverySnapshot)).write(
          RouteDiscoverySnapshotCompanion(lastObservedUtcMs: Value(time)),
        );
        if (generation != _generation) return null;
        return s;
      } on CacheFailure {
        rethrow;
      } on DriftRemoteException catch (error) {
        final cause = error.remoteCause;
        if (cause is FormatException ||
            (cause is SqliteException &&
                (cause.resultCode == 11 || cause.resultCode == 26))) {
          await _purge();
          return null;
        }
        throw const CacheFailure(
          'Almacenamiento offline no disponible; reintenta',
        );
      } on SqliteException catch (error) {
        if (error.resultCode != 11 && error.resultCode != 26) {
          throw const CacheFailure('No se pudo leer la copia; reintenta');
        }
        await _purge();
        return null;
      } catch (_) {
        await _purge();
        return null;
      }
    });
  }

  @override
  Future<void> replaceValidated(
    RouteSnapshot value, {
    required bool Function() stillCurrent,
  }) {
    final generation = _generation;
    final bytes = codec.encode(value);
    return _serial(() async {
      if (generation != _generation ||
          !stillCurrent() ||
          !value.eligible(now())) {
        throw const CacheFailure('Captura cancelada o vencida');
      }
      final db = await _open();
      await db.transaction(() async {
        await db
            .into(db.routeDiscoverySnapshot)
            .insertOnConflictUpdate(
              RouteDiscoverySnapshotCompanion.insert(
                slot: const Value(1),
                formatVersion: 1,
                payload: bytes,
                payloadBytes: bytes.length,
                payloadSha256: Uint8List.fromList(sha256.convert(bytes).bytes),
                capturedAtUtcMs: value.capturedAtUtcMs,
                expiresAtUtcMs: value.expiresAtUtcMs,
                lastObservedUtcMs: now(),
              ),
            );
        if (generation != _generation ||
            !stillCurrent() ||
            !value.eligible(now())) {
          throw const CacheFailure('Captura cancelada');
        }
      });
    });
  }

  @override
  Future<void> delete() {
    _generation++;
    return _serial(_purge);
  }

  @override
  Future<void> close() => _serial(() async {
    await _db?.close();
    _db = null;
  });
}
