import '../../route_planning/domain/route_point.dart';

class DiscoveryPoi {
  const DiscoveryPoi({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.distanceToRouteMeters,
    required this.routeProgress,
    required this.reasonCodes,
  });

  final String id;
  final String name;
  final String category;
  final RoutePoint location;
  final double distanceToRouteMeters;
  final double routeProgress;
  final List<String> reasonCodes;
}
