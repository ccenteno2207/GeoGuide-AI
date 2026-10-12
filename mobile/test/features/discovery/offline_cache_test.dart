import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:drift/isolate.dart' show DriftRemoteException;
import 'package:geoguide_ai/core/network/app_failure.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/domain/route_snapshot.dart';
import 'package:geoguide_ai/features/discovery/infrastructure/offline/snapshot_codec.dart';
import 'package:geoguide_ai/features/discovery/infrastructure/offline/sqlite_snapshot_store.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

const captured = 1800000000000;
DiscoveryQuery query({
  Set<String> categories = const {},
  int corridor = 5000,
  int limit = 20,
}) => DiscoveryQuery(
  backendContext: 'https://example.test:443/api/v1/routes/discover',
  origin: const RoutePoint(latitude: 10, longitude: 20),
  destination: const RoutePoint(latitude: 11, longitude: 21),
  categories: categories,
  corridorMeters: corridor,
  limit: limit,
);
Map<String, Object?> envelope({String description = '', bool empty = false}) =>
    {
      'route': {
        'origin': {'latitude': 10.0, 'longitude': 20.0},
        'destination': {'latitude': 11.0, 'longitude': 21.0},
        'distanceMeters': 100.0,
        'durationSeconds': 50.0,
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            [20.0, 10.0],
            [21.0, 11.0],
          ],
        },
      },
      'results': empty
          ? []
          : [
              {
                'id': '00000000-0000-4000-8000-000000000001',
                'name': 'Fixture',
                'category': 'MUSEUM',
                'location': {'latitude': 10.0, 'longitude': 20.0},
                'distanceToRouteMeters': 10.0,
                'routeProgress': 0.4,
                'reasonCodes': ['NEAR_ROUTE'],
                'description': description,
                'score': 99,
              },
            ],
      'algorithmVersion': 'DISCOVERY_V1',
      'generatedAt': '2026-01-01T00:00:00Z',
    };
RouteSnapshot snapshot({
  DiscoveryQuery? q,
  String description = 'fixture',
  bool empty = false,
  int capturedAtUtcMs = captured,
}) => const SnapshotCodec().fromEnvelope(
  envelope(description: description, empty: empty),
  q ?? query(),
  capturedAtUtcMs,
);

class Source implements DiscoverySnapshotSource {
  int calls = 0;
  Future<RouteSnapshot> Function(DiscoveryQuery)? response;
  @override
  Future<RouteSnapshot> discover(DiscoveryQuery q) {
    calls++;
    return response?.call(q) ?? Future.value(snapshot(q: q));
  }
}

void main() {
  late Directory directory;
  late SqliteSnapshotStore store;
  late int time;
  setUp(() async {
    time = captured;
    directory = await Directory.systemTemp.createTemp('geoguide-cache-test-');
    store = SqliteSnapshotStore(
      directory: () async => directory,
      now: () => time,
    );
  });
  tearDown(() async {
    await store.close();
    await directory.delete(recursive: true);
  });
  test(
    'zero/one slot, replacement, empty result, restart and deletion',
    () async {
      expect(await store.readEligible(), isNull);
      await store.replaceValidated(snapshot(), stillCurrent: () => true);
      expect((await store.readEligible())!.pois.single.name, 'Fixture');
      await store.replaceValidated(
        snapshot(empty: true),
        stillCurrent: () => true,
      );
      expect((await store.readEligible())!.pois, isEmpty);
      await store.close();
      store = SqliteSnapshotStore(
        directory: () async => directory,
        now: () => time,
      );
      expect((await store.readEligible())!.capturedAtUtcMs, captured);
      await store.delete();
      expect(await store.readEligible(), isNull);
    },
  );
  for (final age in [86399999, 86400000, 86400001]) {
    test('TTL boundary $age, restart never renews', () async {
      await store.replaceValidated(snapshot(), stillCurrent: () => true);
      await store.close();
      time = captured + age;
      store = SqliteSnapshotStore(
        directory: () async => directory,
        now: () => time,
      );
      expect(await store.readEligible(), age < 86400000 ? isNotNull : isNull);
    });
  }
  test('read does not renew TTL and clock rollback invalidates', () async {
    await store.replaceValidated(snapshot(), stillCurrent: () => true);
    time += 100;
    expect(await store.readEligible(), isNotNull);
    time--;
    expect(await store.readEligible(), isNull);
  });
  test(
    'cancelled transaction preserves previous and delete blocks late capture',
    () async {
      await store.replaceValidated(snapshot(), stillCurrent: () => true);
      var checks = 0;
      await expectLater(
        store.replaceValidated(
          snapshot(empty: true),
          stillCurrent: () => ++checks < 2,
        ),
        throwsA(isA<CacheFailure>()),
      );
      expect((await store.readEligible())!.pois, hasLength(1));
      final pending = store.replaceValidated(
        snapshot(),
        stillCurrent: () => true,
      );
      final deleting = store.delete();
      await expectLater(pending, throwsA(isA<CacheFailure>()));
      await deleting;
      expect(await store.readEligible(), isNull);
    },
  );
  for (final mutation in ['digest', 'format', 'schema', 'corrupt', 'pending']) {
    test('rejects/reclaims $mutation on startup', () async {
      await store.replaceValidated(snapshot(), stillCurrent: () => true);
      await store.close();
      final file = File('${directory.path}/snapshot.sqlite');
      if (mutation == 'corrupt') {
        await file.writeAsString('not sqlite');
      } else if (mutation == 'pending') {
        await File('${directory.path}/delete_pending')
            .writeAsString('1', flush: true);
      } else {
        final db = sqlite3.open(file.path);
        db.execute(switch (mutation) {
          'digest' =>
            "UPDATE route_discovery_snapshot SET payload_sha256=x'00'",
          'format' => 'UPDATE route_discovery_snapshot SET format_version=2',
          _ => 'PRAGMA user_version=2',
        });
        db.close();
      }
      store = SqliteSnapshotStore(
        directory: () async => directory,
        now: () => time,
      );
      expect(await store.readEligible(), isNull);
    });
  }
  for (final size in [5242879, 5242880, 5242881]) {
    test(
      'UTF8 payload exact boundary $size preserves old when oversized',
      () async {
        const codec = SnapshotCodec();
        final initial = codec.encode(snapshot(description: 'x')).length;
        final s = snapshot(description: 'é${'x' * (size - initial - 1)}');
        await store.replaceValidated(snapshot(), stillCurrent: () => true);
        if (size > 5242880) {
          expect(() => codec.encode(s), throwsA(isA<CacheFailure>()));
        } else {
          expect(codec.encode(s).length, size);
          await store.replaceValidated(s, stillCurrent: () => true);
          expect(
            (await store.readEligible())!.pois.single.description!.startsWith(
              'é',
            ),
            isTrue,
          );
        }
      },
    );
  }
  test('physical cap and required pragmas are applied', () async {
    await store.replaceValidated(snapshot(), stillCurrent: () => true);
    final db = sqlite3.open('${directory.path}/snapshot.sqlite');
    expect(db.select('PRAGMA page_size').first.values.first, 4096);
    expect(db.select('PRAGMA journal_mode').first.values.first, 'delete');
    expect(
      db
          .select('SELECT count(*) FROM route_discovery_snapshot')
          .first
          .values
          .first,
      1,
    );
    expect(
      File('${directory.path}/snapshot.sqlite').lengthSync(),
      lessThanOrEqualTo(6 * 1024 * 1024),
    );
    db.close();
  });
  test('abrupt SQLite worker interruption leaves previous complete snapshot recoverable', () async {
    await store.replaceValidated(snapshot(), stillCurrent: () => true);
    await store.close();
    final ready = ReceivePort(), exited = ReceivePort();
    final worker = await Isolate.spawn(_interruptedWrite, [
      '${directory.path}/snapshot.sqlite',
      ready.sendPort,
    ], onExit: exited.sendPort);
    await ready.first.timeout(const Duration(seconds: 10));
    worker.kill(priority: Isolate.immediate);
    await exited.first.timeout(const Duration(seconds: 10));
    ready.close();
    exited.close();
    expect((await store.readEligible())!.pois.single.name, 'Fixture');
  });
  test(
    'SQLite FULL at physical cap rolls back without destroying old row',
    () async {
      await store.replaceValidated(snapshot(), stillCurrent: () => true);
      await store.close();
      final db = sqlite3.open('${directory.path}/snapshot.sqlite');
      SqliteSnapshotStore.setup(db);
      expect(db.select('PRAGMA max_page_count').first.values.first, 1536);
      expect(db.select('PRAGMA synchronous').first.values.first, 3);
      expect(db.select('PRAGMA secure_delete').first.values.first, 1);
      expect(db.select('PRAGMA temp_store').first.values.first, 2);
      expect(db.select('PRAGMA busy_timeout').first.values.first, 2000);
      expect(
        () => db.execute(
          'UPDATE route_discovery_snapshot SET payload=zeroblob(7340032)',
        ),
        throwsA(
          isA<SqliteException>().having((e) => e.resultCode, 'SQLITE_FULL', 13),
        ),
      );
      db.close();
      expect((await store.readEligible())!.pois.single.name, 'Fixture');
    },
  );
  test(
    'real exclusive lock causes bounded write failure preserving previous',
    () async {
      await store.replaceValidated(snapshot(), stillCurrent: () => true);
      final db = sqlite3.open('${directory.path}/snapshot.sqlite');
      db.execute('BEGIN EXCLUSIVE');
      await expectLater(
        store.replaceValidated(snapshot(empty: true), stillCurrent: () => true),
        throwsA(
          isA<DriftRemoteException>().having(
            (e) => e.remoteCause,
            'SQLITE_BUSY',
            isA<SqliteException>().having((e) => e.resultCode, 'code', 5),
          ),
        ),
      );
      db.execute('ROLLBACK');
      db.close();
      expect((await store.readEligible())!.pois, hasLength(1));
    },
  );
  test('read near expiry never extends original deadline', () async {
    await store.replaceValidated(snapshot(), stillCurrent: () => true);
    time = captured + 86399999;
    expect(await store.readEligible(), isNotNull);
    time++;
    expect(await store.readEligible(), isNull);
  });
  test('late consent cannot renew expired online response', () async {
    final app = OfflineDiscovery(
      source: Source(),
      store: store,
      backendContext: query().backendContext,
      now: () => time,
    );
    await app.discover(query());
    time += 86400000;
    await app.enableCapture();
    expect(await store.readEligible(), isNull);
    await app.dispose();
  });
  test('invalid envelope rejects missing metadata, wrong route and invalid UUID without partial rescue', () {
    const codec = SnapshotCodec();
    for (final field in [
      'algorithmVersion',
      'generatedAt',
      'route',
      'results',
    ]) {
      final data = envelope()..remove(field);
      expect(
        () => codec.fromEnvelope(data, query(), captured),
        throwsA(anything),
      );
    }
    final wrong = envelope();
    ((wrong['route'] as Map)['origin'] as Map)['latitude'] = 12.0;
    expect(
      () => codec.fromEnvelope(wrong, query(), captured),
      throwsA(anything),
    );
    final invalid = envelope();
    ((invalid['results'] as List).single as Map)['id'] = 'bad';
    expect(
      () => codec.fromEnvelope(invalid, query(), captured),
      throwsA(anything),
    );
  });
  test(
    'no cache plus network failure is unavailable, valid empty is online',
    () async {
      final source = Source()
        ..response = (_) =>
            Future.error(const AppFailure(AppFailureType.timeout));
      final app = OfflineDiscovery(
        source: source,
        store: store,
        backendContext: query().backendContext,
        now: () => time,
      );
      await app.discover(query());
      expect(app.availability, DiscoveryAvailability.unavailable);
      source.response = (q) async => snapshot(q: q, empty: true);
      await app.retry();
      expect(app.availability, DiscoveryAvailability.online);
      expect(app.snapshot!.pois, isEmpty);
      await app.dispose();
    },
  );
  test('query fields and canonical whitelist preserve order without score', () {
    const codec = SnapshotCodec();
    final a = query(categories: {' FOREST ', 'MUSEUM'}),
        b = query(categories: {'MUSEUM', 'FOREST'});
    expect(a.sameAs(b), isTrue);
    expect(codec.key(a), codec.key(b));
    for (final q in [
      query(categories: {'FOREST'}),
      query(corridor: 6000),
      query(limit: 21),
    ]) {
      expect(codec.key(query()), isNot(codec.key(q)));
    }
    final bytes = codec.encode(snapshot());
    expect(utf8.decode(bytes), isNot(contains('score')));
    expect(codec.decode(bytes).pois.single.routeProgress, 0.4);
  });
  test(
    'consent defaults off, session enable, restart reset, delete disables',
    () async {
      final source = Source();
      final app = OfflineDiscovery(
        source: source,
        store: store,
        backendContext: query().backendContext,
        now: () => time,
      );
      await app.discover(query());
      expect(await store.readEligible(), isNull);
      await app.enableCapture();
      expect(await store.readEligible(), isNotNull);
      await app.dispose();
      store = SqliteSnapshotStore(
        directory: () async => directory,
        now: () => time,
      );
      final restarted = OfflineDiscovery(
        source: source,
        store: store,
        backendContext: query().backendContext,
        now: () => time,
      );
      await restarted.initialize();
      expect(restarted.captureEnabled, isFalse);
      expect(restarted.availability, DiscoveryAvailability.cached);
      await restarted.delete();
      expect(restarted.snapshot, isNull);
      expect(restarted.captureEnabled, isFalse);
      await restarted.dispose();
    },
  );
  for (final failure in [
    AppFailureType.backendUnavailable,
    AppFailureType.timeout,
    AppFailureType.security,
    AppFailureType.invalidResponse,
  ]) {
    test(
      'offline failure $failure is classified without silent security fallback',
      () async {
        await store.replaceValidated(snapshot(), stillCurrent: () => true);
        final source = Source()
          ..response = (_) => Future.error(AppFailure(failure));
        final app = OfflineDiscovery(
          source: source,
          store: store,
          backendContext: query().backendContext,
          now: () => time,
        );
        await app.discover(query());
        expect(
          app.availability,
          (failure == AppFailureType.timeout ||
                  failure == AppFailureType.backendUnavailable)
              ? DiscoveryAvailability.cached
              : DiscoveryAvailability.error,
        );
        source.response = null;
        await app.retry();
        expect(app.availability, DiscoveryAvailability.online);
        expect(source.calls, 2);
        await app.dispose();
      },
    );
  }
  test('late response, duplicate retry, delete cannot recapture', () async {
    final pending = Completer<RouteSnapshot>();
    final source = Source()..response = (_) => pending.future;
    final app = OfflineDiscovery(
      source: source,
      store: store,
      backendContext: query().backendContext,
      now: () => time,
    );
    await app.enableCapture();
    final call = app.discover(query());
    await app.retry();
    expect(source.calls, 1);
    await app.delete();
    pending.complete(snapshot());
    await call;
    expect(app.snapshot, isNull);
    expect(await store.readEligible(), isNull);
    await app.dispose();
  });
  test(
    'failed query B retains criteria A, foreground expiry removes data',
    () async {
      final source = Source();
      final app = OfflineDiscovery(
        source: source,
        store: store,
        backendContext: query().backendContext,
        now: () => time,
      );
      await app.discover(query());
      source.response = (_) =>
          Future.error(const AppFailure(AppFailureType.timeout));
      await app.discover(query(categories: {'FOREST'}));
      expect(app.snapshot!.query.categories, isEmpty);
      time += 86400000;
      await app.revalidate();
      expect(app.snapshot, isNull);
      await app.dispose();
    },
  );
}

void _interruptedWrite(List<Object> args) {
  final db = sqlite3.open(args[0] as String);
  SqliteSnapshotStore.setup(db);
  db.execute('BEGIN IMMEDIATE');
  db.execute('UPDATE route_discovery_snapshot SET payload=zeroblob(4096)');
  (args[1] as SendPort).send(true);
  ReceivePort().listen((_) => db.execute('SELECT 1'));
}
