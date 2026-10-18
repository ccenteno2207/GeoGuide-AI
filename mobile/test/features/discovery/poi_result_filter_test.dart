import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/domain/route_snapshot.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_result_filter.dart';
import 'package:geoguide_ai/features/discovery/presentation/unicode_name_normalization.dart';

import 'offline_cache_test.dart' as fixtures;

RouteSnapshot results() {
  final base = fixtures.snapshot();
  return RouteSnapshot(
    query: base.query,
    route: base.route,
    pois: [
      for (final (index, name) in [
        'Museo ÁÉÍÓÚ Ñandú',
        'Iglesia',
        'Museo Segundo',
      ].indexed)
        DiscoveryPoi(
          id: '$index',
          name: name,
          category: 'MUSEUM',
          location: base.pois.first.location,
          distanceToRouteMeters: 1,
          routeProgress: .5,
          reasonCodes: const [],
        ),
    ],
    algorithmVersion: base.algorithmVersion,
    generatedAt: base.generatedAt,
    capturedAtUtcMs: fixtures.captured,
  );
}

void main() {
  test(
    'NFD then marks removal and case/whitespace; no compatibility folding',
    () {
      expect(normalizePoiName('  MÚSEO\t  ÑANDÚ  '), 'museo nandu');
      expect(normalizePoiName('Mu\u0301seo N\u0303andu\u0301'), 'museo nandu');
      expect(
        normalizePoiName('Ǻ ộ ḉ Ώ Й 가 각 神'),
        normalizePoiName('A o c Ω И 가 각 神'),
      );
      expect(normalizePoiName('a\u1AB0\u1DC0\uFE20'), 'a');
      expect(normalizePoiName('① ﬁ'), '① ﬁ');
    },
  );

  test('only name substring; preserves snapshot identity, contents and backend order', () {
    final snapshot = results();
    final filter = PoiResultFilter()..bind(snapshot, fixtures.captured);
    filter.query = '  MUSEO  ';
    expect(filter.visible(fixtures.captured).map((p) => p.id), ['0', '2']);
    expect(snapshot.pois.map((p) => p.id), ['0', '1', '2']);
    filter.query = 'nandu';
    expect(filter.visible(fixtures.captured).single, same(snapshot.pois.first));
    filter.query = 'MUSEUM';
    expect(filter.visible(fixtures.captured), isEmpty); // No category matching.
    filter.query = '   ';
    expect(filter.visible(fixtures.captured), same(snapshot.pois));
  });

  test(
    'same identity retains query; replacement, expiry and exit clear it',
    () {
      final snapshot = results();
      final filter = PoiResultFilter()..bind(snapshot, fixtures.captured);
      filter.query = 'museo';
      expect(filter.bind(snapshot, fixtures.captured + 1), isFalse);
      expect(filter.query, 'museo');
      expect(filter.bind(results(), fixtures.captured + 1), isTrue);
      expect(filter.query, isEmpty);
      filter.query = 'museo';
      filter.bind(snapshot, snapshot.expiresAtUtcMs);
      expect(filter.query, isEmpty);
      expect(filter.visible(snapshot.expiresAtUtcMs), isEmpty);
      filter.bind(snapshot, fixtures.captured);
      filter.query = 'museo';
      filter.clear();
      expect(filter.query, isEmpty);
    },
  );
}
