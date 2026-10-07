import '../../../core/network/app_failure.dart';
import '../../route_planning/domain/route_point.dart';
import '../domain/discovery_poi.dart';

class RouteDiscoveryResponseMapper {
  const RouteDiscoveryResponseMapper();

  List<DiscoveryPoi> fromJson(Map<String, Object?> json) {
    final results = json['results'];
    if (results is! List) {
      throw const AppFailure(AppFailureType.invalidResponse);
    }

    final pois = <DiscoveryPoi>[];
    for (final result in results) {
      final poi = _poi(result);
      if (poi != null) pois.add(poi);
    }
    return pois;
  }

  DiscoveryPoi? _poi(Object? value) {
    if (value is! Map) return null;
    final id = value['id'];
    final name = value['name'];
    final category = value['category'];
    final location = _point(value['location']);
    final distance = _finiteNumber(value['distanceToRouteMeters']);
    final progress = _finiteNumber(value['routeProgress']);
    final reasonCodes = value['reasonCodes'];
    if (id is! String ||
        name is! String ||
        category is! String ||
        location == null ||
        distance == null ||
        distance < 0 ||
        progress == null ||
        progress < 0 ||
        progress > 1 ||
        reasonCodes is! List ||
        reasonCodes.any((code) => code is! String)) {
      return null;
    }

    return DiscoveryPoi(
      id: id,
      name: name,
      category: category,
      location: location,
      distanceToRouteMeters: distance,
      routeProgress: progress,
      reasonCodes: reasonCodes.cast<String>(),
      description: _optionalString(value['description']),
      sourceLabel: _optionalString(value['sourceLabel']),
      sourceUrl: _optionalString(value['sourceUrl']),
      attribution: _optionalString(value['attribution']),
    );
  }

  RoutePoint? _point(Object? value) {
    if (value is! Map) return null;
    final latitude = _finiteNumber(value['latitude']);
    final longitude = _finiteNumber(value['longitude']);
    if (latitude == null || longitude == null) return null;
    final point = RoutePoint(latitude: latitude, longitude: longitude);
    return point.isValid ? point : null;
  }

  double? _finiteNumber(Object? value) {
    if (value is! num || !value.isFinite) return null;
    return value.toDouble();
  }

  String? _optionalString(Object? value) =>
      value is String && value.trim().isNotEmpty ? value.trim() : null;
}
