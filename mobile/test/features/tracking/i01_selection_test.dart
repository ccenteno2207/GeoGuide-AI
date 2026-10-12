import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/discovery/domain/route_snapshot.dart';
import 'package:geoguide_ai/features/discovery/infrastructure/offline/snapshot_codec.dart';
import 'package:geoguide_ai/features/tracking/application/selected_poi_session.dart';
import 'package:geoguide_ai/features/tracking/infrastructure/selected_poi_session_codec.dart';

import '../discovery/offline_cache_test.dart' as fixtures;

RouteSnapshot snapshot([int? time, String description = '']) =>
    const SnapshotCodec().fromEnvelope(
      fixtures.envelope(description: description),
      fixtures.query(),
      time ?? fixtures.captured,
    );
void main() {
  const now = fixtures.captured;
  const codec = SelectedPoiSessionCodec();
  test('choose/remove and empty selection; unknown ID rejected', () {
    final s = snapshot();
    final draft = SelectedPoiDraft()..bind(s, now);
    final id = s.pois.first.id;
    expect(draft.ids, isEmpty);
    draft.toggle(id, now);
    expect(draft.ids, {id});
    draft.toggle(id, now);
    expect(draft.ids, isEmpty);
    expect(() => draft.toggle('missing', now), throwsStateError);
  });
  test(
    'equal criteria new snapshot invalidates; route null and expiry clear',
    () {
      final first = snapshot();
      final second = snapshot();
      expect(first.query.sameAs(second.query), isTrue);
      final draft = SelectedPoiDraft()
        ..bind(first, now)
        ..toggle(first.pois.first.id, now);
      draft.bind(second, now);
      expect(draft.ids, isEmpty);
      draft.toggle(second.pois.first.id, now);
      draft.bind(second, second.expiresAtUtcMs);
      expect(draft.ids, isEmpty);
      draft.bind(first, now);
      draft.toggle(first.pois.first.id, now);
      draft.bind(null, now);
      expect(draft.ids, isEmpty);
    },
  );
  test('freeze immutable and no silent restoration after clear', () {
    final s = snapshot();
    final draft = SelectedPoiDraft()
      ..bind(s, now)
      ..toggle(s.pois.first.id, now);
    final context = draft.freeze(s, now);
    expect(() => draft.toggle(s.pois.first.id, now), throwsStateError);
    expect(() => context.chosenIds.clear(), throwsUnsupportedError);
    draft.bind(snapshot(), now);
    expect(draft.ids, context.chosenIds);
    draft.clear();
    expect(draft.ids, isEmpty);
    expect(draft.frozen, isFalse);
    expect(context.chosenIds, {s.pois.first.id});
  });
  test('valid context and empty set preserve canonical offline bytes', () {
    for (final selected in [false, true]) {
      final s = snapshot();
      final original = const SnapshotCodec().encode(s);
      final context = SelectedPoiSession(
        s,
        selected ? {s.pois.first.id} : {},
        now,
      );
      final bytes = codec.encode(context, now);
      final decoded = codec.decode(bytes, now);
      expect(decoded.chosenIds, context.chosenIds);
      expect(const SnapshotCodec().encode(decoded.snapshot), original);
    }
  });
  for (final defect in [
    'version',
    'unknown',
    'duplicate',
    'hash',
    'extra',
    'expired',
    'innerExtra',
    'innerHash',
  ]) {
    test('context rejects $defect without partial rescue', () {
      final s = snapshot();
      final data = jsonDecode(
        utf8.decode(codec.encode(SelectedPoiSession(s, {}, now), now)),
      ) as Map<String, dynamic>;
      switch (defect) {
        case 'version':
          data['sessionVersion'] = 2;
        case 'unknown':
          data['chosenIds'] = ['missing'];
        case 'duplicate':
          data['chosenIds'] = [s.pois.first.id, s.pois.first.id];
        case 'hash':
          data['snapshotSha256'] = 'wrong';
        case 'extra':
          data['extra'] = true;
        case 'innerExtra':
        case 'innerHash':
          final inner = jsonDecode(
            utf8.decode(base64Decode(data['snapshot'] as String)),
          ) as Map;
          if (defect == 'innerExtra') {
            inner['extra'] = true;
          } else {
            inner['queryKeySha256'] = 'wrong';
          }
          final bytes = utf8.encode(jsonEncode(inner));
          data['snapshot'] = base64Encode(bytes);
          data['snapshotSha256'] = sha256.convert(bytes).toString();
        case 'expired':
          break;
      }
      expect(
        () => codec.decode(
          Uint8List.fromList(utf8.encode(jsonEncode(data))),
          defect == 'expired' ? s.expiresAtUtcMs : now,
        ),
        throwsA(anything),
      );
    });
  }
  test('malformed and oversized total frame rejected', () {
    expect(
      () => codec.decode(Uint8List.fromList([255]), now),
      throwsA(anything),
    );
    expect(
      () => codec.decode(Uint8List(RouteSnapshot.maxPayloadBytes + 1), now),
      throwsFormatException,
    );
    final large = snapshot(null, 'a' * 4000000);
    expect(
      const SnapshotCodec().encode(large).length,
      lessThan(RouteSnapshot.maxPayloadBytes),
    );
    expect(
      () => codec.encode(SelectedPoiSession(large, {}, now), now),
      throwsFormatException,
    );
  });
}
