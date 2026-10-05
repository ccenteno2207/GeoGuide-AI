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
    expect(find.text('A 150 m del trazado'), findsOneWidget);
    expect(find.text('Cerca del trazado'), findsOneWidget);
    expect(find.textContaining('25%'), findsNothing);
    expect(find.text('NEAR_ROUTE'), findsNothing);
  });

  testWidgets('renders factual description and reduced provenance', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PoiDetailSheet(
      poi: DiscoveryPoi(
        id: 'poi-1', name: 'Museum', category: 'MUSEUM',
        location: const RoutePoint(latitude: 10, longitude: 20),
        distanceToRouteMeters: 150, routeProgress: .25,
        reasonCodes: const ['CATEGORY_MATCH'], description: 'Factual text',
        sourceLabel: 'MINCETUR', sourceUrl: 'https://example.test', attribution: 'Mincetur',
      ),
    ))));
    expect(find.text('Factual text'), findsOneWidget);
    expect(find.text('Fuente'), findsOneWidget);
    expect(find.text('MINCETUR'), findsOneWidget);
    expect(find.text('Mincetur'), findsOneWidget);
    expect(find.text('https://example.test'), findsOneWidget);
    expect(find.text('Coincide con la categoría seleccionada'), findsOneWidget);
  });

  testWidgets('omits absent optional detail and provenance sections', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: PoiDetailSheet(
      poi: DiscoveryPoi(
        id: 'poi-1', name: 'Museum', category: 'MUSEUM',
        location: const RoutePoint(latitude: 10, longitude: 20),
        distanceToRouteMeters: 150, routeProgress: .25, reasonCodes: const [],
      ),
    ))));
    expect(find.text('Fuente'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
    expect(find.textContaining('N/A'), findsNothing);
  });
}
