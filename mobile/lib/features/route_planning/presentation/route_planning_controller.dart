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
  int _selectionRevision = 0;
  String status = 'Selecciona el origen en el mapa';

  bool get canPlan =>
      origin?.isValid == true &&
      destination?.isValid == true &&
      !isCalculating &&
      planRoute != null;

  void selectPoint(RoutePoint point) {
    _selectionRevision++;
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
    _selectionRevision++;
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
    if (isCalculating ||
        origin == null ||
        destination == null ||
        !origin.isValid ||
        !destination.isValid ||
        routePlanner == null) {
      return;
    }

    final selectionRevision = _selectionRevision;
    isCalculating = true;
    hasError = false;
    status = 'Calculando ruta';
    try {
      final plannedRoute = await routePlanner(
        origin: origin,
        destination: destination,
      );
      if (!_isCurrentSelection(selectionRevision, origin, destination)) return;
      route = plannedRoute;
      status = 'Ruta visible';
    } on AppFailure catch (failure) {
      if (!_isCurrentSelection(selectionRevision, origin, destination)) return;
      hasError = true;
      status = failure.userMessage;
    } finally {
      isCalculating = false;
    }
  }

  bool _isCurrentSelection(
    int revision,
    RoutePoint origin,
    RoutePoint destination,
  ) =>
      revision == _selectionRevision &&
      this.origin?.latitude == origin.latitude &&
      this.origin?.longitude == origin.longitude &&
      this.destination?.latitude == destination.latitude &&
      this.destination?.longitude == destination.longitude;
}
