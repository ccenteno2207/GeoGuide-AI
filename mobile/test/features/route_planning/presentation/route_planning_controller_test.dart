import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/route_planning/application/plan_route.dart';
import 'package:geoguide_ai/features/route_planning/domain/planned_route.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_planning_repository.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';
import 'package:geoguide_ai/features/route_planning/presentation/route_planning_controller.dart';

class FakeRoutePlanningRepository implements RoutePlanningRepository {
  @override
  Future<PlannedRoute> planRoute({
    required RoutePoint origin,
    required RoutePoint destination,
  }) async => PlannedRoute(
    origin: origin,
    destination: destination,
    distanceMeters: 100,
    durationSeconds: 30,
    geometry: [origin, destination],
  );
}

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
    'search destination preserves existing origin and awaits explicit plan',
    () {
      final controller = RoutePlanningController(
        planRoute: PlanRoute(FakeRoutePlanningRepository()),
      );
      const origin = RoutePoint(latitude: -12, longitude: -77);
      const destination = RoutePoint(latitude: -11, longitude: -76);
      controller.origin = origin;

      controller.selectDestinationFromSearch(destination);

      expect(controller.origin, origin);
      expect(controller.destination, destination);
      expect(controller.route, isNull);
      expect(controller.canPlan, isTrue);
    },
  );

  test('manual map tap after search destination fills missing origin', () {
    final controller = RoutePlanningController();
    const destination = RoutePoint(latitude: -11, longitude: -76);
    const origin = RoutePoint(latitude: -12, longitude: -77);

    controller.selectDestinationFromSearch(destination);
    controller.selectPoint(origin);

    expect(controller.origin, origin);
    expect(controller.destination, destination);
  });

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
