import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';
import 'package:geoguide_ai/features/destination_search/application/search_destinations.dart';
import 'package:geoguide_ai/features/destination_search/domain/destination_search_repository.dart';
import 'package:geoguide_ai/features/destination_search/domain/destination_search_result.dart';
import 'package:geoguide_ai/features/route_planning/application/plan_route.dart';
import 'package:geoguide_ai/features/route_planning/domain/planned_route.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_planning_repository.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';
import 'package:geoguide_ai/features/map/presentation/rutea_location_marker.dart';
import 'package:geoguide_ai/features/discovery/application/discover_route.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/domain/route_discovery_repository.dart';

class FakeLocationRepository
    implements LocationRepository, LocationStreamSource {
  FakeLocationRepository(this.result);

  final CurrentLocationResult result;
  int calls = 0;
  final permissionRequests = <bool>[];
  int watchCalls = 0;

  @override
  Future<CurrentLocationResult> requestCurrentLocation({
    bool requestPermission = true,
  }) async {
    calls++;
    permissionRequests.add(requestPermission);
    return result;
  }

  @override
  Stream<LocationSample> watchLocation() {
    watchCalls++;
    return const Stream<LocationSample>.empty();
  }
}

class FakeDestinationSearchRepository implements DestinationSearchRepository {
  final queries = <String>[];

  @override
  Future<List<DestinationSearchResult>> searchByName(String query) async {
    queries.add(query);
    return const [
      DestinationSearchResult(
        id: 'catalog-fixture-canta',
        name: 'Plaza de Armas de Canta',
        typeLabel: 'Plaza',
        geographicContext: 'Lima, Canta',
        provenanceLabel: 'MINCETUR',
        verifiedPoint: RoutePoint(
          latitude: -11.4669625,
          longitude: -76.6247746,
        ),
        sourceUrl: 'https://example.test/canta',
        license: 'ODC-BY-1.0',
        attribution: 'MINCETUR test fixture',
      ),
    ];
  }
}

class FakeRoutePlanningRepository implements RoutePlanningRepository {
  FakeRoutePlanningRepository({this.failure});

  final Object? failure;
  final requests = <(RoutePoint, RoutePoint)>[];

  @override
  Future<PlannedRoute> planRoute({
    required RoutePoint origin,
    required RoutePoint destination,
  }) async {
    requests.add((origin, destination));
    if (failure != null) throw failure!;
    return PlannedRoute(
      origin: origin,
      destination: destination,
      distanceMeters: 12345,
      durationSeconds: 3600,
      geometry: [
        origin,
        RoutePoint(
          latitude: (origin.latitude + destination.latitude) / 2,
          longitude: (origin.longitude + destination.longitude) / 2,
        ),
        destination,
      ],
    );
  }
}

class FakeRouteDiscoveryRepository implements RouteDiscoveryRepository {
  final requests = <(RoutePoint, RoutePoint, Set<String>)>[];

  @override
  Future<List<DiscoveryPoi>> discover({
    required RoutePoint origin,
    required RoutePoint destination,
    Set<String> categories = const {},
  }) async {
    requests.add((origin, destination, categories));
    return [
      DiscoveryPoi(
        id: 'poi-test-1',
        name: 'POI de prueba de Canta',
        category: 'MONUMENT',
        location: destination,
        distanceToRouteMeters: 25,
        routeProgress: 0.5,
        reasonCodes: const ['NEAR_ROUTE'],
      ),
    ];
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // These foreground tests explicitly model a resolved, inactive native owner.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('geoguide/route_session'),
        (call) async => false,
      );

  testWidgets('starts with a clean map and does not request location', (
    tester,
  ) async {
    final location = FakeLocationRepository(
      const CurrentLocationResult.withAvailability(
        LocationAvailability.unavailable,
      ),
    );
    await tester.pumpWidget(GeoGuideApp(locationRepository: location));

    await tester.pumpAndSettle();
    expect(find.text('GeoGuide AI'), findsNothing);
    expect(tester.widget<MaterialApp>(find.byType(MaterialApp)).title, 'Rutea');
    expect(find.text('Exploración'), findsNothing);
    expect(
      find.byKey(const ValueKey('exploration-floating-actions')),
      findsOneWidget,
    );
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byKey(const ValueKey('open-destination-search')), findsNothing);
    expect(find.textContaining('OpenStreetMap contributors'), findsOneWidget);
    expect(find.byKey(const ValueKey('exploration-status')), findsNothing);
    expect(
      find.byKey(const ValueKey('exploration-bottom-panel')),
      findsNothing,
    );
    expect(find.text('Ubicación no solicitada'), findsNothing);
    expect(
      find.text('No encontramos lugares de estas categorías para esta ruta.'),
      findsNothing,
    );
    expect(location.calls, 0);
    expect(location.watchCalls, 0);
  });

  testWidgets('shows real search UI only when a search service is configured', (
    tester,
  ) async {
    final repository = FakeDestinationSearchRepository();
    final location = FakeLocationRepository(
      const CurrentLocationResult.withAvailability(
        LocationAvailability.unavailable,
      ),
    );
    await tester.pumpWidget(
      GeoGuideApp(
        locationRepository: location,
        searchDestinations: SearchDestinations(repository),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('open-destination-search')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('open-destination-search')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('destination-search-query')),
      'Canta',
    );
    expect(repository.queries, isEmpty);
    await tester.tap(find.byKey(const ValueKey('destination-search-submit')));
    await tester.pumpAndSettle();

    expect(repository.queries, ['Canta']);
    expect(find.text('Plaza de Armas de Canta'), findsOneWidget);
    expect(location.calls, 0);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'searched destination plan renders route geometry and a persistent summary',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final routeRepository = FakeRoutePlanningRepository();
      final discoveryRepository = FakeRouteDiscoveryRepository();
      final location = FakeLocationRepository(
        CurrentLocationResult.available(
          const LocationPoint(latitude: -12.05, longitude: -77.04),
          accuracyMeters: 10,
          timestamp: DateTime.now(),
        ),
      );
      await tester.pumpWidget(
        GeoGuideApp(
          locationRepository: location,
          searchDestinations: SearchDestinations(
            FakeDestinationSearchRepository(),
          ),
          planRoute: PlanRoute(routeRepository),
          discoverRoute: DiscoverRoute(discoveryRepository),
          backendBaseUrl: '',
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('open-destination-search')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('destination-search-query')),
        'Canta',
      );
      await tester.tap(find.byKey(const ValueKey('destination-search-submit')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Seleccionar'));
      await tester.pumpAndSettle();

      expect(routeRepository.requests, isEmpty);
      expect(find.text('Origen: Tu ubicación actual'), findsOneWidget);
      await tester.tap(find.text('Ver ruta'));
      await tester.pumpAndSettle();

      expect(routeRepository.requests, hasLength(1));
      expect(discoveryRepository.requests, hasLength(1));
      final (origin, destination) = routeRepository.requests.single;
      expect(discoveryRepository.requests.single.$1, origin);
      expect(discoveryRepository.requests.single.$2, destination);
      expect(origin.isValid, isTrue);
      expect(origin.latitude, -12.05);
      expect(location.permissionRequests, [false]);
      expect(destination.latitude, -11.4669625);
      expect(destination.longitude, -76.6247746);
      expect(find.byType(PolylineLayer), findsOneWidget);
      expect(find.text('Ruta: 12.3 km · 60 min'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('toggle-discovery-list')));
      await tester.pumpAndSettle();
      expect(find.text('POI de prueba de Canta'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('represents denied location permission', (tester) async {
    await tester.pumpWidget(
      GeoGuideApp(
        locationRepository: FakeLocationRepository(
          const CurrentLocationResult.withAvailability(
            LocationAvailability.denied,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Usar ubicación actual'));
    await tester.pump();

    expect(find.text('Permiso de ubicación denegado'), findsOneWidget);
  });

  testWidgets(
    'renders the returned current location marker without changing route state',
    (tester) async {
      await tester.pumpWidget(
        GeoGuideApp(
          locationRepository: FakeLocationRepository(
            const CurrentLocationResult.available(
              LocationPoint(latitude: -12.05, longitude: -77.04),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Usar ubicación actual'));
      await tester.pumpAndSettle();

      expect(find.byType(RuteaLocationMarker), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsOneWidget);
      expect(find.byType(CircleLayer), findsNothing);
    },
  );

  testWidgets('uses only provider accuracy for the location halo', (
    tester,
  ) async {
    await tester.pumpWidget(
      GeoGuideApp(
        locationRepository: FakeLocationRepository(
          const CurrentLocationResult.available(
            LocationPoint(latitude: -12.05, longitude: -77.04),
            accuracyMeters: 42,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Usar ubicación actual'));
    await tester.pumpAndSettle();

    final circle = tester.widget<CircleLayer>(find.byType(CircleLayer));
    expect(circle.circles.single.radius, 42);
    expect(circle.circles.single.useRadiusInMeter, isTrue);
    expect(find.byType(RuteaLocationMarker), findsOneWidget);
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(RuteaLocationMarker)).label,
      'Ubicación actual',
    );
    semantics.dispose();
  });

  testWidgets('represents unavailable location service', (tester) async {
    await tester.pumpWidget(
      GeoGuideApp(
        locationRepository: FakeLocationRepository(
          const CurrentLocationResult.withAvailability(
            LocationAvailability.serviceDisabled,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Usar ubicación actual'));
    await tester.pump();

    expect(find.text('Servicio de ubicación no disponible'), findsOneWidget);
  });

  testWidgets('represents permanently denied location permission', (
    tester,
  ) async {
    await tester.pumpWidget(
      GeoGuideApp(
        locationRepository: FakeLocationRepository(
          const CurrentLocationResult.withAvailability(
            LocationAvailability.deniedForever,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Usar ubicación actual'));
    await tester.pump();

    expect(
      find.text('Permiso de ubicación bloqueado en ajustes'),
      findsOneWidget,
    );
  });
}
