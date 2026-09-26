import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/core/network/app_failure.dart';
import 'package:geoguide_ai/features/route_planning/infrastructure/route_plan_response_mapper.dart';

void main() {
  const mapper = RoutePlanResponseMapper();

  test(
    'maps a valid GeoJSON LineString preserving longitude-latitude input',
    () {
      final route = mapper.fromJson({
        'origin': {'latitude': 10.0, 'longitude': 20.0},
        'destination': {'latitude': 11.0, 'longitude': 21.0},
        'distanceMeters': 1200,
        'durationSeconds': 300,
        'geometry': {
          'type': 'LineString',
          'coordinates': [
            [20.0, 10.0],
            [21.0, 11.0],
          ],
        },
      });

      expect(route.geometry, hasLength(2));
      expect(route.geometry.first.latitude, 10.0);
      expect(route.geometry.first.longitude, 20.0);
    },
  );

  test('rejects invalid geometry', () {
    expect(
      () => mapper.fromJson({
        'origin': {'latitude': 10.0, 'longitude': 20.0},
        'destination': {'latitude': 11.0, 'longitude': 21.0},
        'distanceMeters': 1200,
        'durationSeconds': 300,
        'geometry': {'type': 'LineString', 'coordinates': []},
      }),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.type,
          'type',
          AppFailureType.invalidResponse,
        ),
      ),
    );
  });
}
