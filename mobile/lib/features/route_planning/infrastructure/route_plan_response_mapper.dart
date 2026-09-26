import '../../../core/network/app_failure.dart';
import '../domain/planned_route.dart';
import '../domain/route_point.dart';

class RoutePlanResponseMapper {
  const RoutePlanResponseMapper();

  PlannedRoute fromJson(Map<String, Object?> json) {
    final origin = _routePoint(json['origin']);
    final destination = _routePoint(json['destination']);
    final distanceMeters = _finiteNumber(json['distanceMeters']);
    final durationSeconds = _finiteNumber(json['durationSeconds']);
    final geometry = _geometry(json['geometry']);

    if (origin == null ||
        destination == null ||
        distanceMeters == null ||
        durationSeconds == null ||
        geometry == null) {
      throw const AppFailure(AppFailureType.invalidResponse);
    }

    return PlannedRoute(
      origin: origin,
      destination: destination,
      distanceMeters: distanceMeters,
      durationSeconds: durationSeconds,
      geometry: geometry,
    );
  }

  RoutePoint? _routePoint(Object? value) {
    if (value is! Map) return null;
    final latitude = _finiteNumber(value['latitude']);
    final longitude = _finiteNumber(value['longitude']);
    if (latitude == null || longitude == null) return null;
    final point = RoutePoint(latitude: latitude, longitude: longitude);
    return point.isValid ? point : null;
  }

  List<RoutePoint>? _geometry(Object? value) {
    if (value is! Map || value['type'] != 'LineString') return null;
    final coordinates = value['coordinates'];
    if (coordinates is! List || coordinates.length < 2) return null;

    final points = <RoutePoint>[];
    for (final coordinate in coordinates) {
      if (coordinate is! List || coordinate.length != 2) return null;
      final longitude = _finiteNumber(coordinate[0]);
      final latitude = _finiteNumber(coordinate[1]);
      if (longitude == null || latitude == null) return null;
      final point = RoutePoint(latitude: latitude, longitude: longitude);
      if (!point.isValid) return null;
      points.add(point);
    }
    return points;
  }

  double? _finiteNumber(Object? value) {
    if (value is! num || !value.isFinite) return null;
    return value.toDouble();
  }
}
