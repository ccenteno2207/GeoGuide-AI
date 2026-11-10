import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';
import 'package:geoguide_ai/features/map/presentation/rutea_location_marker.dart';

class FakeLocationRepository
    implements LocationRepository, LocationStreamSource {
  FakeLocationRepository(this.result);

  final CurrentLocationResult result;
  int calls = 0;
  int watchCalls = 0;

  @override
  Future<CurrentLocationResult> requestCurrentLocation() async {
    calls++;
    return result;
  }

  @override
  Stream<LocationSample> watchLocation() {
    watchCalls++;
    return const Stream<LocationSample>.empty();
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
