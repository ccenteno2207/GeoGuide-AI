import '../../../core/network/app_failure.dart';
import '../../route_planning/domain/route_point.dart';
import '../application/discover_route.dart';
import '../domain/discovery_poi.dart';

class RouteDiscoveryController {
  RouteDiscoveryController({this.discoverRoute});

  final DiscoverRoute? discoverRoute;

  List<DiscoveryPoi> pois = const [];
  bool isDiscovering = false;
  bool hasError = false;
  String? status;
  RoutePoint? origin;
  RoutePoint? destination;
  Set<String> appliedCategories = const {};
  bool get hasActiveFilter =>
      appliedCategories.length != discoveryCategoryCodes.length;

  Future<void> discover({
    required RoutePoint origin,
    required RoutePoint destination,
    Set<String> categories = const {},
  }) async {
    final discoverRoute = this.discoverRoute;
    if (discoverRoute == null) return;

    isDiscovering = true;
    hasError = false;
    status = 'Buscando lugares en la ruta';
    this.origin = origin;
    this.destination = destination;
    appliedCategories = Set.unmodifiable(categories);
    try {
      pois = await discoverRoute(
        origin: origin,
        destination: destination,
        categories: categories,
      );
      status = pois.isEmpty
          ? 'No se encontraron lugares utilizables en la ruta'
          : '${pois.length} lugares visibles en la ruta';
    } on AppFailure catch (failure) {
      hasError = true;
      status = failure.userMessage;
    } finally {
      isDiscovering = false;
    }
  }
}
