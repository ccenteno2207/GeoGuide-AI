import '../../route_planning/domain/route_point.dart';
import 'discovery_poi.dart';

abstract interface class RouteDiscoveryRepository {
  Future<List<DiscoveryPoi>> discover({
    required RoutePoint origin,
    required RoutePoint destination,
  });
}
