import '../../../core/network/app_failure.dart';
import '../application/plan_route.dart';
import '../domain/planned_route.dart';
import '../domain/route_point.dart';

class RoutePlanningController {
  RoutePlanningController({this.planRoute});

  final PlanRoute? planRoute;

  RoutePoint? origin;
  RoutePoint? destination;
  PlannedRoute? route;
  bool isCalculating = false;
  String status = 'Selecciona el origen en el mapa';

  bool get canPlan =>
      origin != null &&
      destination != null &&
      !isCalculating &&
      planRoute != null;

  void selectPoint(RoutePoint point) {
    route = null;
    if (origin == null || destination != null) {
      origin = point;
      destination = null;
      status = 'Origen seleccionado; ahora selecciona el destino';
      return;
    }

    destination = point;
    status = planRoute == null
        ? 'Ruta lista para solicitar cuando el backend esté configurado'
        : 'Origen y destino seleccionados';
  }

  Future<void> calculate() async {
    final origin = this.origin;
    final destination = this.destination;
    final routePlanner = planRoute;
    if (origin == null || destination == null || routePlanner == null) return;

    isCalculating = true;
    status = 'Calculando ruta';
    try {
      route = await routePlanner(origin: origin, destination: destination);
      status = 'Ruta visible';
    } on AppFailure catch (failure) {
      status = failure.userMessage;
    } finally {
      isCalculating = false;
    }
  }
}
