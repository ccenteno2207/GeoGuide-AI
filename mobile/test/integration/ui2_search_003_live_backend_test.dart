import 'dart:io';

import 'package:geoguide_ai/core/network/backend_configuration.dart';
import 'package:geoguide_ai/core/network/geoguide_http_client.dart';
import 'package:geoguide_ai/features/destination_search/application/search_destinations.dart';
import 'package:geoguide_ai/features/destination_search/infrastructure/dio_destination_search_repository.dart';
import 'package:geoguide_ai/features/route_planning/application/plan_route.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';
import 'package:geoguide_ai/features/route_planning/infrastructure/dio_route_planning_repository.dart';
import 'package:geoguide_ai/features/route_planning/presentation/route_planning_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final backendUrl = Platform.environment['UI2_SEARCH_LIVE_BACKEND_URL'] ?? '';

  test(
    'live PostGIS result is selected and explicitly planned through the API',
    () async {
      final configuration = BackendConfiguration(Uri.parse(backendUrl));
      final client = GeoGuideHttpClient(configuration: configuration);
      final search = SearchDestinations(DioDestinationSearchRepository(client));

      final results = await search('Canta');
      expect(results, hasLength(1));
      final selected = results.single;
      expect(selected.name, 'Plaza De Armas De Canta');
      expect(selected.geographicContext, 'Lima, Canta, CANTA');
      expect(selected.provenanceLabel, contains('MINCETUR'));
      expect(selected.verifiedPoint, isNotNull);
      expect(selected.verifiedPoint!.latitude, closeTo(-11.4669625, 1e-8));
      expect(selected.verifiedPoint!.longitude, closeTo(-76.6247746, 1e-8));

      const origin = RoutePoint(
        latitude: -12.045947477780945,
        longitude: -77.03060082209015,
      );
      final planner = PlanRoute(DioRoutePlanningRepository(client));
      final controller = RoutePlanningController(planRoute: planner);
      controller.selectPoint(origin);
      controller.selectDestinationFromSearch(selected.verifiedPoint!);

      expect(controller.origin, origin);
      expect(controller.destination, selected.verifiedPoint);
      expect(controller.route, isNull);
      expect(controller.canPlan, isTrue);

      await controller.calculate();

      expect(controller.hasError, isFalse);
      expect(controller.status, 'Ruta visible');
      expect(controller.route, isNotNull);
      expect(controller.route!.origin.latitude, closeTo(origin.latitude, 1e-8));
      expect(
        controller.route!.origin.longitude,
        closeTo(origin.longitude, 1e-8),
      );
      expect(
        controller.route!.destination.latitude,
        closeTo(selected.verifiedPoint!.latitude, 1e-8),
      );
      expect(
        controller.route!.destination.longitude,
        closeTo(selected.verifiedPoint!.longitude, 1e-8),
      );
      expect(controller.route!.distanceMeters, greaterThan(0));
      expect(controller.route!.geometry.length, greaterThan(2));
    },
    skip: backendUrl.isEmpty,
  );
}
