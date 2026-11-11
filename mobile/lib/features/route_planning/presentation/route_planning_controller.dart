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
  bool hasError = false;
  bool _preserveSearchDestinationForNextMapTap = false;
  String status = 'Selecciona el origen en el mapa';

  bool get canPlan =>
      origin?.isValid == true &&
      destination?.isValid == true &&
      !isCalculating &&
      planRoute != null;

  void selectPoint(RoutePoint point) {
    hasError = false;
    route = null;
    if (_preserveSearchDestinationForNextMapTap && origin == null) {
      origin = point;
      _preserveSearchDestinationForNextMapTap = false;
      status = planRoute == null
          ? 'Origen y destino listos; configura el servicio para solicitar la ruta'
          : 'Origen y destino seleccionados';
      return;
    }
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

  void selectDestinationFromSearch(RoutePoint point) {
    hasError = false;
    route = null;
    destination = point;
    _preserveSearchDestinationForNextMapTap = origin == null;
    status = origin == null
        ? 'Destino seleccionado; elige el origen en el mapa'
        : 'Destino seleccionado; puedes calcular la ruta';
  }

  Future<void> calculate() async {
    final origin = this.origin;
    final destination = this.destination;
    final routePlanner = planRoute;
    if (origin == null ||
        destination == null ||
        !origin.isValid ||
        !destination.isValid ||
        routePlanner == null) {
      return;
    }

    isCalculating = true;
    hasError = false;
    status = 'Calculando ruta';
    try {
      route = await routePlanner(origin: origin, destination: destination);
      status = 'Ruta visible';
    } on AppFailure catch (failure) {
      hasError = true;
      status = failure.userMessage;
    } finally {
      isCalculating = false;
    }
  }
}
