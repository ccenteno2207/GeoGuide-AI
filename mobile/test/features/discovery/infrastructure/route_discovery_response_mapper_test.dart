import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/discovery/infrastructure/route_discovery_response_mapper.dart';

void main() {
  const mapper = RouteDiscoveryResponseMapper();

  test('keeps only usable discovery POIs', () {
    final pois = mapper.fromJson({
      'results': [
        {
          'id': 'poi-1',
          'name': 'Museum',
          'category': 'CULTURE',
          'location': {'latitude': 10.0, 'longitude': 20.0},
          'distanceToRouteMeters': 50,
          'routeProgress': 0.25,
          'reasonCodes': ['NEAR_ROUTE'],
        },
        {'id': 'invalid'},
      ],
    });

    expect(pois, hasLength(1));
    expect(pois.single.name, 'Museum');
  });

  test('accepts optional detail and provenance fields', () {
    final pois = mapper.fromJson({
      'results': [
        {
          'id': 'poi-1', 'name': 'Museum', 'category': 'MUSEUM',
          'location': {'latitude': 10.0, 'longitude': 20.0},
          'distanceToRouteMeters': 50, 'routeProgress': 0.25,
          'reasonCodes': ['NEAR_ROUTE'], 'description': 'Facts',
          'sourceLabel': 'MINCETUR', 'sourceUrl': 'https://example.test',
          'attribution': 'Mincetur',
        },
      ],
    });
    expect(pois.single.description, 'Facts');
    expect(pois.single.sourceLabel, 'MINCETUR');
    expect(pois.single.sourceUrl, 'https://example.test');
    expect(pois.single.attribution, 'Mincetur');
  });

  test('keeps optional fields absent for backward-compatible payloads', () {
    final pois = mapper.fromJson({
      'results': [
        {
          'id': 'poi-1', 'name': 'Museum', 'category': 'MUSEUM',
          'location': {'latitude': 10.0, 'longitude': 20.0},
          'distanceToRouteMeters': 50, 'routeProgress': 0.25,
          'reasonCodes': ['NEAR_ROUTE'],
        },
      ],
    });
    expect(pois.single.description, isNull);
    expect(pois.single.sourceLabel, isNull);
  });
}
