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
}
