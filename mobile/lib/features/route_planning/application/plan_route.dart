import '../domain/planned_route.dart';
import '../domain/route_planning_repository.dart';
import '../domain/route_point.dart';

class PlanRoute {
  const PlanRoute(this._repository);

  final RoutePlanningRepository _repository;

  Future<PlannedRoute> call({
    required RoutePoint origin,
    required RoutePoint destination,
  }) => _repository.planRoute(origin: origin, destination: destination);
}
