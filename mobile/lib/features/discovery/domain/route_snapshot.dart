import '../../route_planning/domain/planned_route.dart';
import '../../route_planning/domain/route_point.dart';
import 'discovery_poi.dart';

class DiscoveryQuery {
  DiscoveryQuery({
    required this.backendContext,
    required this.origin,
    required this.destination,
    Set<String> categories = const {},
    this.corridorMeters = 5000,
    this.limit = 20,
  }) : categories = List.unmodifiable(
         categories.map((e) => e.trim()).toSet().toList()..sort(),
       );
  final String backendContext;
  final RoutePoint origin, destination;
  final List<String> categories;
  final int corridorMeters, limit;
  bool sameAs(DiscoveryQuery other) =>
      backendContext == other.backendContext &&
      samePoint(origin, other.origin) &&
      samePoint(destination, other.destination) &&
      corridorMeters == other.corridorMeters &&
      limit == other.limit &&
      categories.join('\u0000') == other.categories.join('\u0000');
  static bool samePoint(RoutePoint a, RoutePoint b) =>
      a.latitude == b.latitude && a.longitude == b.longitude;
}

class RouteSnapshot {
  RouteSnapshot({
    required this.query,
    required this.route,
    required List<DiscoveryPoi> pois,
    required this.algorithmVersion,
    required this.generatedAt,
    required this.capturedAtUtcMs,
  }) : pois = List.unmodifiable(pois);
  static const ttlMs = 86400000;
  static const maxPayloadBytes = 5242880;
  final DiscoveryQuery query;
  final PlannedRoute route;
  final List<DiscoveryPoi> pois;
  final String algorithmVersion, generatedAt;
  final int capturedAtUtcMs;
  int get expiresAtUtcMs => capturedAtUtcMs + ttlMs;
  bool eligible(int now) => capturedAtUtcMs <= now && now < expiresAtUtcMs;
}

abstract interface class RouteDiscoverySnapshotStore {
  Future<RouteSnapshot?> readEligible();
  Future<void> replaceValidated(
    RouteSnapshot value, {
    required bool Function() stillCurrent,
  });
  Future<void> delete();
  Future<void> close();
}

abstract interface class DiscoverySnapshotSource {
  Future<RouteSnapshot> discover(DiscoveryQuery query);
}

class CacheFailure implements Exception {
  const CacheFailure(this.message);
  final String message;
}
