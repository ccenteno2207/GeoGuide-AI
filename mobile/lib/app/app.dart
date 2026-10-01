import 'package:flutter/material.dart';

import '../core/network/backend_configuration.dart';
import '../core/network/geoguide_http_client.dart';
import '../features/discovery/infrastructure/dio_route_discovery_repository.dart';
import '../features/map/presentation/base_map_page.dart';
import '../features/discovery/application/discover_route.dart';
import '../features/location/application/request_current_location.dart';
import '../features/location/domain/location_repository.dart';
import '../features/location/infrastructure/geolocator_location_repository.dart';
import '../features/route_planning/infrastructure/dio_route_planning_repository.dart';
import 'theme/geoguide_theme.dart';
import '../features/route_planning/application/plan_route.dart';

class GeoGuideApp extends StatelessWidget {
  GeoGuideApp({
    super.key,
    LocationRepository? locationRepository,
    PlanRoute? planRoute,
    DiscoverRoute? discoverRoute,
    String? backendBaseUrl,
  }) : _requestCurrentLocation = RequestCurrentLocation(
         locationRepository ?? GeolocatorLocationRepository(),
       ),
       planRoute = planRoute ?? _createPlanRoute(backendBaseUrl),
       discoverRoute = discoverRoute ?? _createDiscoverRoute(backendBaseUrl);

  final RequestCurrentLocation _requestCurrentLocation;
  final PlanRoute? planRoute;
  final DiscoverRoute? discoverRoute;

  static const _backendBaseUrl = String.fromEnvironment('BACKEND_BASE_URL');

  static BackendConfiguration? _backendConfiguration(String? value) =>
      BackendConfiguration.tryParse(value ?? _backendBaseUrl);

  static PlanRoute? _createPlanRoute(String? backendBaseUrl) {
    final configuration = _backendConfiguration(backendBaseUrl);
    if (configuration == null) return null;

    return PlanRoute(
      DioRoutePlanningRepository(
        GeoGuideHttpClient(configuration: configuration),
      ),
    );
  }

  static DiscoverRoute? _createDiscoverRoute(String? backendBaseUrl) {
    final configuration = _backendConfiguration(backendBaseUrl);
    if (configuration == null) return null;

    return DiscoverRoute(
      DioRouteDiscoveryRepository(
        GeoGuideHttpClient(configuration: configuration),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoGuide AI',
      theme: GeoGuideTheme.light(),
      home: BaseMapPage(
        requestCurrentLocation: _requestCurrentLocation,
        planRoute: planRoute,
        discoverRoute: discoverRoute,
      ),
    );
  }
}
