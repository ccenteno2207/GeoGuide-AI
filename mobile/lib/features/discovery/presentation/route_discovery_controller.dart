import '../../../core/network/app_failure.dart';
import '../../route_planning/domain/route_point.dart';
import '../application/discover_route.dart';
import '../domain/discovery_poi.dart';

class RouteDiscoveryController {
  RouteDiscoveryController({this.discoverRoute});

  final DiscoverRoute? discoverRoute;

  List<DiscoveryPoi> pois = const [];
  bool isDiscovering = false;
  String? status;

  Future<void> discover({
    required RoutePoint origin,
    required RoutePoint destination,
  }) async {
    final discoverRoute = this.discoverRoute;
    if (discoverRoute == null) return;

    isDiscovering = true;
    status = 'Buscando lugares en la ruta';
    try {
      pois = await discoverRoute(origin: origin, destination: destination);
      status = pois.isEmpty
          ? 'No se encontraron lugares utilizables en la ruta'
          : '${pois.length} lugares visibles en la ruta';
    } on AppFailure catch (failure) {
      pois = const [];
      status = failure.userMessage;
    } finally {
      isDiscovering = false;
    }
  }
}
