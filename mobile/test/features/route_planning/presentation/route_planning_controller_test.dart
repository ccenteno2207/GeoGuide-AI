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
  test('selects origin and destination with two explicit map points', () {
    final controller = RoutePlanningController();

    controller.selectPoint(const RoutePoint(latitude: 10, longitude: 20));
    controller.selectPoint(const RoutePoint(latitude: 11, longitude: 21));

    expect(controller.origin?.latitude, 10);
    expect(controller.destination?.latitude, 11);
    expect(controller.status, contains('backend esté configurado'));
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
