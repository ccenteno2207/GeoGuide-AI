import '../../route_planning/domain/route_point.dart';
import '../domain/discovery_poi.dart';
import '../domain/route_discovery_repository.dart';

class DiscoverRoute {
  const DiscoverRoute(this._repository);

  final RouteDiscoveryRepository _repository;

  Future<List<DiscoveryPoi>> call({
    required RoutePoint origin,
    required RoutePoint destination,
    Set<String> categories = const {},
  }) => _repository.discover(
    origin: origin,
    destination: destination,
    categories: categories,
  );
}
