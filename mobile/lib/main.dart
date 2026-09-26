import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/network/backend_configuration.dart';
import 'core/network/geoguide_http_client.dart';
import 'features/discovery/application/discover_route.dart';
import 'features/discovery/infrastructure/dio_route_discovery_repository.dart';
import 'features/route_planning/application/plan_route.dart';
import 'features/route_planning/infrastructure/dio_route_planning_repository.dart';

void main() {
  final configuration = BackendConfiguration.fromEnvironment();
  final client = configuration == null
      ? null
      : GeoGuideHttpClient(configuration: configuration);

  runApp(
    GeoGuideApp(
      planRoute: client == null
          ? null
          : PlanRoute(DioRoutePlanningRepository(client)),
      discoverRoute: client == null
          ? null
          : DiscoverRoute(DioRouteDiscoveryRepository(client)),
    ),
  );
}
