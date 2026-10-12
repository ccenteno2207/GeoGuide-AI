import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../../discovery/domain/route_snapshot.dart';
import '../../discovery/infrastructure/offline/snapshot_codec.dart';
import '../application/selected_poi_session.dart';

/// Session-only bytes; never persisted or interpreted by the native owner.
class SelectedPoiSessionCodec {
  const SelectedPoiSessionCodec();
  Uint8List encode(SelectedPoiSession context, int now) {
    SelectedPoiSession(context.snapshot, context.chosenIds, now);
    final snapshot = const SnapshotCodec().encode(context.snapshot);
    final ids = context.chosenIds.toList()..sort();
    final bytes = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'sessionVersion': 1,
          'snapshot': base64Encode(snapshot),
          'snapshotSha256': sha256.convert(snapshot).toString(),
          'chosenIds': ids,
        }),
      ),
    );
    if (bytes.length > RouteSnapshot.maxPayloadBytes) {
      throw const FormatException('Session exceeds 5 MiB');
    }
    return bytes;
  }

  SelectedPoiSession decode(Uint8List bytes, int now) {
    if (bytes.isEmpty || bytes.length > RouteSnapshot.maxPayloadBytes) {
      throw const FormatException('Session size');
    }
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map ||
        data['sessionVersion'] != 1 ||
        data['snapshot'] is! String ||
        data['chosenIds'] is! List ||
        !(data['chosenIds'] as List).every((id) => id is String)) {
      throw const FormatException('Session format');
    }
    final internal = base64Decode(data['snapshot'] as String);
    if (sha256.convert(internal).toString() != data['snapshotSha256']) {
      throw const FormatException('Snapshot association');
    }
    final snapshot = const SnapshotCodec().decode(internal);
    final context = SelectedPoiSession(
      snapshot,
      (data['chosenIds'] as List).cast<String>(),
      now,
    );
    if (base64Encode(encode(context, now)) != base64Encode(bytes)) {
      throw const FormatException('Noncanonical session');
    }
    return context;
  }
}
