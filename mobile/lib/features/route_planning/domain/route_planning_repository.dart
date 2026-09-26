import 'planned_route.dart';
import 'route_point.dart';

abstract interface class RoutePlanningRepository {
  Future<PlannedRoute> planRoute({
    required RoutePoint origin,
    required RoutePoint destination,
  });
}
