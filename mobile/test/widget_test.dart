import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';

class FakeLocationRepository implements LocationRepository {
  FakeLocationRepository(this.result);

  final CurrentLocationResult result;

  @override
  Future<CurrentLocationResult> requestCurrentLocation() async => result;
}

void main() {
  testWidgets('renders the GeoGuide AI base map shell', (tester) async {
    await tester.pumpWidget(
      GeoGuideApp(
        locationRepository: FakeLocationRepository(
          const CurrentLocationResult.withAvailability(
            LocationAvailability.unavailable,
          ),
        ),
      ),
    );

    expect(find.text('GeoGuide AI'), findsOneWidget);
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('OpenStreetMap contributors'), findsOneWidget);
    expect(find.text('Ubicación no solicitada'), findsOneWidget);
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

      await tester.tap(find.byTooltip('Usar ubicación actual'));
      await tester.pumpAndSettle();

      expect(find.text('Ubicación actual visible'), findsOneWidget);
      expect(find.byIcon(Icons.my_location), findsNWidgets(2));
      expect(find.text('Selecciona el origen en el mapa'), findsOneWidget);
    },
  );

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

    await tester.tap(find.byTooltip('Usar ubicación actual'));
    await tester.pump();

    expect(
      find.text('Permiso de ubicación bloqueado en ajustes'),
      findsOneWidget,
    );
  });
}
