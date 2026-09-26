import 'route_point.dart';

class PlannedRoute {
  const PlannedRoute({
    required this.origin,
    required this.destination,
    required this.distanceMeters,
    required this.durationSeconds,
    required this.geometry,
  });

  final RoutePoint origin;
  final RoutePoint destination;
  final double distanceMeters;
  final double durationSeconds;
  final List<RoutePoint> geometry;
}
