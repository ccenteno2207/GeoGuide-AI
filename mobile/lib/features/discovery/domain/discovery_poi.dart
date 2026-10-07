import '../../route_planning/domain/route_point.dart';

const discoveryCategoryCodes = <String>[
  'WATERFALL',
  'LAGOON',
  'MOUNTAIN',
  'FOREST',
  'BEACH',
  'MUSEUM',
  'ARCHAEOLOGICAL_SITE',
  'MONUMENT',
  'HISTORIC_CHURCH',
  'VIEWPOINT',
];

class DiscoveryPoi {
  const DiscoveryPoi({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.distanceToRouteMeters,
    required this.routeProgress,
    required this.reasonCodes,
    this.description,
    this.sourceLabel,
    this.sourceUrl,
    this.attribution,
  });

  final String id;
  final String name;
  final String category;
  final RoutePoint location;
  final double distanceToRouteMeters;
  final double routeProgress;
  final List<String> reasonCodes;
  final String? description;
  final String? sourceLabel;
  final String? sourceUrl;
  final String? attribution;
}
