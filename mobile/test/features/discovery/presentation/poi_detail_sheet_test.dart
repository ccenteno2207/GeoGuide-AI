import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

void main() {
  testWidgets('shows only the contractual basic POI fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PoiDetailSheet(
            poi: DiscoveryPoi(
              id: 'poi-1',
              name: 'Museum',
              category: 'CULTURE',
              location: const RoutePoint(latitude: 10, longitude: 20),
              distanceToRouteMeters: 150,
              routeProgress: 0.25,
              reasonCodes: const ['NEAR_ROUTE'],
            ),
          ),
        ),
      ),
    );

    expect(find.text('Museum'), findsOneWidget);
    expect(find.text('Categoría: CULTURE'), findsOneWidget);
    expect(find.text('Distancia a la ruta: 150 m'), findsOneWidget);
    expect(find.text('Progreso de ruta: 25%'), findsOneWidget);
    expect(find.text('Razones: NEAR_ROUTE'), findsOneWidget);
  });
}
