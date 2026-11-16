import '../../../core/network/app_failure.dart';
import '../../route_planning/domain/route_point.dart';
import '../application/discover_route.dart';
import '../domain/discovery_poi.dart';

class RouteDiscoveryController {
  RouteDiscoveryController({this.discoverRoute});

  final DiscoverRoute? discoverRoute;
  int _revision = 0;

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
    if (discoverRoute == null || isDiscovering) return;

    final revision = ++_revision;
    isDiscovering = true;
    hasError = false;
    status = 'Buscando lugares en la ruta';
    this.origin = origin;
    this.destination = destination;
    appliedCategories = Set.unmodifiable(categories);
    try {
      final result = await discoverRoute(
        origin: origin,
        destination: destination,
        categories: categories,
      );
      if (revision != _revision) return;
      pois = result;
      status = pois.isEmpty
          ? 'No se encontraron lugares utilizables en la ruta'
          : '${pois.length} lugares visibles en la ruta';
    } on AppFailure catch (failure) {
      if (revision != _revision) return;
      hasError = true;
      status = failure.userMessage;
    } finally {
      if (revision == _revision) isDiscovering = false;
    }
  }

  /// Invalidates an in-flight response after the route selection changes.
  void invalidatePending() {
    _revision++;
    isDiscovering = false;
    hasError = false;
    status = null;
    origin = null;
    destination = null;
  }
}
