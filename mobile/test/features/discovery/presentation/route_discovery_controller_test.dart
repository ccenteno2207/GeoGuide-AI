import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/core/network/app_failure.dart';
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

class ControlledRouteDiscoveryRepository implements RouteDiscoveryRepository {
  final requests = <(RoutePoint, RoutePoint, Set<String>)>[];
  final responses = <Completer<List<DiscoveryPoi>>>[];

  @override
  Future<List<DiscoveryPoi>> discover({
    required RoutePoint origin,
    required RoutePoint destination,
    Set<String> categories = const {},
  }) {
    requests.add((origin, destination, categories));
    final response = Completer<List<DiscoveryPoi>>();
    responses.add(response);
    return response.future;
  }
}

DiscoveryPoi poi(String id) => DiscoveryPoi(
  id: id,
  name: id,
  category: 'CULTURE',
  location: const RoutePoint(latitude: 10, longitude: 20),
  distanceToRouteMeters: 10,
  routeProgress: 0.5,
  reasonCodes: const ['NEAR_ROUTE'],
);

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

  test('ignores discovery responses invalidated by a route change', () async {
    final repository = ControlledRouteDiscoveryRepository();
    final controller = RouteDiscoveryController(
      discoverRoute: DiscoverRoute(repository),
    );
    const origin = RoutePoint(latitude: 10, longitude: 20);
    const oldDestination = RoutePoint(latitude: 11, longitude: 21);
    const newDestination = RoutePoint(latitude: 12, longitude: 22);

    final oldRequest = controller.discover(
      origin: origin,
      destination: oldDestination,
    );
    controller.invalidatePending();
    final newRequest = controller.discover(
      origin: origin,
      destination: newDestination,
    );

    expect(repository.requests, hasLength(2));
    expect(repository.requests.last.$2, newDestination);
    repository.responses[1].complete([poi('new-route-poi')]);
    await newRequest;
    repository.responses[0].complete([poi('stale-route-poi')]);
    await oldRequest;

    expect(controller.destination, newDestination);
    expect(controller.pois.map((item) => item.id), ['new-route-poi']);
    expect(controller.status, '1 lugares visibles en la ruta');
    expect(controller.isDiscovering, isFalse);
  });

  test(
    'ignores failures from discovery invalidated by a route change',
    () async {
      final repository = ControlledRouteDiscoveryRepository();
      final controller = RouteDiscoveryController(
        discoverRoute: DiscoverRoute(repository),
      );
      const origin = RoutePoint(latitude: 10, longitude: 20);
      const oldDestination = RoutePoint(latitude: 11, longitude: 21);
      const newDestination = RoutePoint(latitude: 12, longitude: 22);

      final oldRequest = controller.discover(
        origin: origin,
        destination: oldDestination,
      );
      controller.invalidatePending();
      final newRequest = controller.discover(
        origin: origin,
        destination: newDestination,
      );
      repository.responses[0].completeError(
        const AppFailure(AppFailureType.backendUnavailable),
      );
      await oldRequest;
      repository.responses[1].complete([poi('new-route-poi')]);
      await newRequest;

      expect(controller.destination, newDestination);
      expect(controller.hasError, isFalse);
      expect(controller.pois.map((item) => item.id), ['new-route-poi']);
      expect(controller.status, '1 lugares visibles en la ruta');
    },
  );

  test(
    'does not start duplicate discovery while a request is pending',
    () async {
      final repository = ControlledRouteDiscoveryRepository();
      final controller = RouteDiscoveryController(
        discoverRoute: DiscoverRoute(repository),
      );
      const origin = RoutePoint(latitude: 10, longitude: 20);
      const firstDestination = RoutePoint(latitude: 11, longitude: 21);
      const duplicateDestination = RoutePoint(latitude: 12, longitude: 22);

      final firstRequest = controller.discover(
        origin: origin,
        destination: firstDestination,
      );
      await controller.discover(
        origin: origin,
        destination: duplicateDestination,
      );

      expect(repository.requests, hasLength(1));
      expect(controller.destination, firstDestination);
      repository.responses.single.complete([poi('first-route-poi')]);
      await firstRequest;
      expect(controller.pois.map((item) => item.id), ['first-route-poi']);
    },
  );
}
