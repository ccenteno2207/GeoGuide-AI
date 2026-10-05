import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/discovery/application/discover_route.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/domain/route_discovery_repository.dart';
import 'package:geoguide_ai/features/discovery/presentation/route_discovery_controller.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

class FakeRouteDiscoveryRepository implements RouteDiscoveryRepository {
  @override
  Future<List<DiscoveryPoi>> discover({
    required RoutePoint origin,
    required RoutePoint destination,
    Set<String> categories = const {},
  }) async => [
    DiscoveryPoi(
      id: 'poi-1',
      name: 'Museum',
      category: 'CULTURE',
      location: origin,
      distanceToRouteMeters: 10,
      routeProgress: 0.5,
      reasonCodes: const ['NEAR_ROUTE'],
    ),
  ];
}

void main() {
  test(
    'represents usable POIs returned for the selected route points',
    () async {
      final controller = RouteDiscoveryController(
        discoverRoute: DiscoverRoute(FakeRouteDiscoveryRepository()),
      );
      const origin = RoutePoint(latitude: 10, longitude: 20);
      const destination = RoutePoint(latitude: 11, longitude: 21);

      await controller.discover(origin: origin, destination: destination);

      expect(controller.pois, hasLength(1));
      expect(controller.status, '1 lugares visibles en la ruta');
    },
  );
}
