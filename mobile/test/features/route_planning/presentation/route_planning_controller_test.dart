import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/core/network/app_failure.dart';
import 'package:geoguide_ai/features/route_planning/application/plan_route.dart';
import 'package:geoguide_ai/features/route_planning/domain/planned_route.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_planning_repository.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';
import 'package:geoguide_ai/features/route_planning/presentation/route_planning_controller.dart';

class FakeRoutePlanningRepository implements RoutePlanningRepository {
  final requests = <(RoutePoint, RoutePoint)>[];

  @override
  Future<PlannedRoute> planRoute({
    required RoutePoint origin,
    required RoutePoint destination,
  }) async {
    requests.add((origin, destination));
    return plannedRoute(origin, destination);
  }
}

class ControlledRoutePlanningRepository implements RoutePlanningRepository {
  final requests = <(RoutePoint, RoutePoint)>[];
  final pending = <Completer<PlannedRoute>>[];

  @override
  Future<PlannedRoute> planRoute({
    required RoutePoint origin,
    required RoutePoint destination,
  }) {
    requests.add((origin, destination));
    final result = Completer<PlannedRoute>();
    pending.add(result);
    return result.future;
  }
}

PlannedRoute plannedRoute(RoutePoint origin, RoutePoint destination) =>
    PlannedRoute(
      origin: origin,
      destination: destination,
      distanceMeters: 100,
      durationSeconds: 30,
      geometry: [origin, destination],
    );

void main() {
  test(
    'route calculation requires two valid points and a configured planner',
    () {
      final controller = RoutePlanningController(
        planRoute: PlanRoute(FakeRoutePlanningRepository()),
      );

      expect(controller.canPlan, isFalse, reason: 'no endpoints');

      controller.origin = const RoutePoint(latitude: 10, longitude: 20);
      expect(controller.canPlan, isFalse, reason: 'destination missing');

      controller.origin = null;
      controller.destination = const RoutePoint(latitude: 11, longitude: 21);
      expect(controller.canPlan, isFalse, reason: 'origin missing');

      controller.origin = const RoutePoint(latitude: 10, longitude: 20);
      expect(controller.canPlan, isTrue, reason: 'valid manual endpoints');
    },
  );

  test('invalid coordinates or missing planner keep calculation disabled', () {
    final noPlanner = RoutePlanningController();
    noPlanner.origin = const RoutePoint(latitude: 10, longitude: 20);
    noPlanner.destination = const RoutePoint(latitude: 11, longitude: 21);
    expect(noPlanner.canPlan, isFalse, reason: 'planner missing');

    final invalidPointController = RoutePlanningController(
      planRoute: PlanRoute(FakeRoutePlanningRepository()),
    );
    invalidPointController.origin = const RoutePoint(
      latitude: 91,
      longitude: 20,
    );
    invalidPointController.destination = const RoutePoint(
      latitude: 11,
      longitude: 21,
    );
    expect(invalidPointController.canPlan, isFalse);
  });

  test(
    'changing manual endpoints invalidates the old route until complete',
    () async {
      final controller = RoutePlanningController(
        planRoute: PlanRoute(FakeRoutePlanningRepository()),
      );
      controller.selectPoint(const RoutePoint(latitude: 10, longitude: 20));
      controller.selectPoint(const RoutePoint(latitude: 11, longitude: 21));
      await controller.calculate();
      expect(controller.route, isNotNull);

      controller.selectPoint(const RoutePoint(latitude: 12, longitude: 22));
      expect(controller.route, isNull);
      expect(controller.canPlan, isFalse);
      controller.selectPoint(const RoutePoint(latitude: 13, longitude: 23));
      expect(controller.canPlan, isTrue);
    },
  );

  test('selects origin and destination with two explicit map points', () {
    final controller = RoutePlanningController();

    controller.selectPoint(const RoutePoint(latitude: 10, longitude: 20));
    controller.selectPoint(const RoutePoint(latitude: 11, longitude: 21));

    expect(controller.origin?.latitude, 10);
    expect(controller.destination?.latitude, 11);
    expect(controller.status, contains('backend esté configurado'));
  });

  test(
    'case A: Lima origin survives search selection and plans only on request',
    () async {
      final repository = FakeRoutePlanningRepository();
      final controller = RoutePlanningController(
        planRoute: PlanRoute(repository),
      );
      const origin = RoutePoint(latitude: -12, longitude: -77);
      const destination = RoutePoint(latitude: -11, longitude: -76);
      controller.origin = origin;

      controller.selectDestinationFromSearch(destination);

      expect(controller.origin, origin);
      expect(controller.destination, destination);
      expect(controller.route, isNull);
      expect(repository.requests, isEmpty);
      expect(controller.canPlan, isTrue);

      await controller.calculate();
      expect(repository.requests, [(origin, destination)]);
      expect(controller.route?.origin, origin);
      expect(controller.route?.destination, destination);
    },
  );

  test(
    'case B: manually selected origin is sent with searched destination',
    () async {
      final repository = FakeRoutePlanningRepository();
      final controller = RoutePlanningController(
        planRoute: PlanRoute(repository),
      );
      const origin = RoutePoint(latitude: -12, longitude: -77);
      const destination = RoutePoint(latitude: -11, longitude: -76);

      controller.selectPoint(origin);
      controller.selectDestinationFromSearch(destination);
      await controller.calculate();

      expect(repository.requests, [(origin, destination)]);
      expect(controller.route?.origin, origin);
      expect(controller.route?.destination, destination);
    },
  );

  test('case C: changing destination replaces the previous route', () async {
    final repository = FakeRoutePlanningRepository();
    final controller = RoutePlanningController(
      planRoute: PlanRoute(repository),
    );
    const origin = RoutePoint(latitude: -12, longitude: -77);
    const firstDestination = RoutePoint(latitude: -11, longitude: -76);
    const nextDestination = RoutePoint(latitude: -10, longitude: -75);
    controller.selectPoint(origin);
    controller.selectDestinationFromSearch(firstDestination);
    await controller.calculate();
    expect(controller.route?.destination, firstDestination);

    controller.selectDestinationFromSearch(nextDestination);
    expect(controller.route, isNull);
    await controller.calculate();

    expect(repository.requests, [
      (origin, firstDestination),
      (origin, nextDestination),
    ]);
    expect(controller.route?.destination, nextDestination);
  });

  test('manual map tap after search destination fills missing origin', () {
    final controller = RoutePlanningController();
    const destination = RoutePoint(latitude: -11, longitude: -76);
    const origin = RoutePoint(latitude: -12, longitude: -77);

    controller.selectDestinationFromSearch(destination);
    controller.selectPoint(origin);

    expect(controller.origin, origin);
    expect(controller.destination, destination);
  });

  test(
    'a late successful response cannot replace a newer destination',
    () async {
      final repository = ControlledRoutePlanningRepository();
      final controller = RoutePlanningController(
        planRoute: PlanRoute(repository),
      );
      const origin = RoutePoint(latitude: -12, longitude: -77);
      const firstDestination = RoutePoint(latitude: -11, longitude: -76);
      const nextDestination = RoutePoint(latitude: -10, longitude: -75);
      controller.origin = origin;
      controller.selectDestinationFromSearch(firstDestination);

      final calculation = controller.calculate();
      expect(controller.isCalculating, isTrue);
      expect(repository.requests, [(origin, firstDestination)]);

      controller.selectDestinationFromSearch(nextDestination);
      repository.pending.single.complete(
        plannedRoute(origin, firstDestination),
      );
      await calculation;

      expect(controller.origin, origin);
      expect(controller.destination, nextDestination);
      expect(controller.route, isNull);
      expect(controller.hasError, isFalse);
      expect(
        controller.status,
        'Destino seleccionado; puedes calcular la ruta',
      );
    },
  );

  test('a late failure cannot mark a newer destination as failed', () async {
    final repository = ControlledRoutePlanningRepository();
    final controller = RoutePlanningController(
      planRoute: PlanRoute(repository),
    );
    const origin = RoutePoint(latitude: -12, longitude: -77);
    const firstDestination = RoutePoint(latitude: -11, longitude: -76);
    const nextDestination = RoutePoint(latitude: -10, longitude: -75);
    controller.origin = origin;
    controller.selectDestinationFromSearch(firstDestination);

    final calculation = controller.calculate();
    controller.selectDestinationFromSearch(nextDestination);
    repository.pending.single.completeError(
      const AppFailure(AppFailureType.backendUnavailable),
    );
    await calculation;

    expect(controller.destination, nextDestination);
    expect(controller.route, isNull);
    expect(controller.hasError, isFalse);
    expect(controller.status, 'Destino seleccionado; puedes calcular la ruta');
    expect(controller.isCalculating, isFalse);
  });

  test(
    'ignores duplicate calculate calls while one request is pending',
    () async {
      final repository = ControlledRoutePlanningRepository();
      final controller = RoutePlanningController(
        planRoute: PlanRoute(repository),
      );
      const origin = RoutePoint(latitude: -12, longitude: -77);
      const destination = RoutePoint(latitude: -11, longitude: -76);
      controller.selectPoint(origin);
      controller.selectPoint(destination);

      final first = controller.calculate();
      final duplicate = controller.calculate();
      expect(repository.requests, [(origin, destination)]);
      repository.pending.single.complete(plannedRoute(origin, destination));
      await Future.wait([first, duplicate]);

      expect(controller.route?.origin, origin);
      expect(controller.route?.destination, destination);
      expect(controller.isCalculating, isFalse);
    },
  );

  test(
    'changing manual origin invalidates a route selected from search',
    () async {
      final controller = RoutePlanningController(
        planRoute: PlanRoute(FakeRoutePlanningRepository()),
      );
      const initialOrigin = RoutePoint(latitude: -12, longitude: -77);
      const destination = RoutePoint(latitude: -11, longitude: -76);
      const changedOrigin = RoutePoint(latitude: -13, longitude: -78);
      controller.origin = initialOrigin;
      controller.selectDestinationFromSearch(destination);
      await controller.calculate();
      expect(controller.route, isNotNull);

      controller.selectPoint(changedOrigin);
      expect(controller.origin, changedOrigin);
      expect(controller.destination, isNull);
      expect(controller.route, isNull);
      expect(controller.canPlan, isFalse);
    },
  );

  test('draw-ready route is supplied only by the planning use case', () async {
    final controller = RoutePlanningController(
      planRoute: PlanRoute(FakeRoutePlanningRepository()),
    );
    controller.selectPoint(const RoutePoint(latitude: 10, longitude: 20));
    controller.selectPoint(const RoutePoint(latitude: 11, longitude: 21));

    await controller.calculate();

    expect(controller.route?.geometry, hasLength(2));
    expect(controller.status, 'Ruta visible');
  });
}
