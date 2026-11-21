import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/domain/poi_operational_info.dart';
import 'package:geoguide_ai/features/discovery/domain/poi_tourism_content.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

void main() {
  testWidgets(
    'shows basic POI facts and does not fabricate offline operations',
    (tester) async {
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
      expect(find.text('Categoría: Lugar de interés'), findsOneWidget);
      expect(
        tester
            .widget<Icon>(
              find.byKey(const ValueKey('poi-category-detail-icon-CULTURE')),
            )
            .icon,
        Icons.category,
      );
      expect(find.textContaining('CULTURE'), findsNothing);
      expect(find.text('A 150 m del trazado'), findsOneWidget);
      expect(find.text('Cerca del trazado'), findsOneWidget);
      expect(find.textContaining('25%'), findsNothing);
      expect(find.text('NEAR_ROUTE'), findsNothing);
      expect(
        find.text(
          'Esta información se consulta en línea y no está incluida en el modo sin conexión.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'loads published opening hours and activities for the detail sheet',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoiDetailSheet(
              poi: DiscoveryPoi(
                id: 'poi-1',
                name: 'Museo',
                category: 'MUSEUM',
                location: const RoutePoint(latitude: -12, longitude: -77),
                distanceToRouteMeters: 0,
                routeProgress: 0.5,
                reasonCodes: const [],
              ),
              loadOperationalInfo: (id) async {
                expect(id, 'poi-1');
                return PoiOperationalInfo.fromJson({
                  'timeZone': 'America/Lima',
                  'weeklyHours': [
                    {
                      'day': 'MONDAY',
                      'periods': [
                        {'opensAt': '09:00:00', 'closesAt': '17:00:00'},
                      ],
                    },
                  ],
                  'items': [
                    {
                      'id': 'item-1',
                      'type': 'PROMOTION',
                      'title': 'Entrada 2x1',
                      'description': 'Promoción de prueba',
                      'scheduleText': null,
                      'validFrom': null,
                      'validUntil': null,
                      'terms': null,
                      'active': true,
                    },
                  ],
                });
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Lunes: 09:00–17:00'), findsOneWidget);
      expect(find.text('Promoción · Entrada 2x1'), findsOneWidget);
      expect(find.text('Promoción de prueba'), findsOneWidget);
    },
  );

  testWidgets(
    'retries an online operational information request after an error',
    (tester) async {
      var calls = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoiDetailSheet(
              poi: DiscoveryPoi(
                id: 'poi-retry',
                name: 'POI',
                category: 'MUSEUM',
                location: const RoutePoint(latitude: -12, longitude: -77),
                distanceToRouteMeters: 0,
                routeProgress: 0,
                reasonCodes: const [],
              ),
              loadOperationalInfo: (_) async {
                calls++;
                if (calls == 1) throw Exception('synthetic network failure');
                return PoiOperationalInfo.fromJson({
                  'timeZone': 'America/Lima',
                  'weeklyHours': [],
                  'items': [],
                });
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text(
          'No se pudo consultar esta información en línea. Intenta de nuevo cuando tengas conexión.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Reintentar'));
      await tester.pumpAndSettle();
      expect(calls, 2);
      expect(
        find.text(
          'Este POI aún no tiene horarios, funciones o promociones publicados.',
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('renders factual description and reduced provenance', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PoiDetailSheet(
            poi: DiscoveryPoi(
              id: 'poi-1',
              name: 'Museum',
              category: 'MUSEUM',
              location: const RoutePoint(latitude: 10, longitude: 20),
              distanceToRouteMeters: 150,
              routeProgress: .25,
              reasonCodes: const ['CATEGORY_MATCH'],
              description: 'Factual text',
              sourceLabel: 'MINCETUR',
              sourceUrl: 'https://example.test',
              attribution: 'Mincetur',
            ),
          ),
        ),
      ),
    );
    expect(find.text('Factual text'), findsOneWidget);
    expect(
      tester
          .widget<Icon>(
            find.byKey(const ValueKey('poi-category-detail-icon-MUSEUM')),
          )
          .icon,
      Icons.museum,
    );
    expect(find.text('Fuente'), findsOneWidget);
    expect(find.text('MINCETUR'), findsOneWidget);
    expect(find.text('Mincetur'), findsOneWidget);
    expect(find.text('https://example.test'), findsOneWidget);
    expect(find.text('Coincide con la categoría seleccionada'), findsOneWidget);
  });

  testWidgets('omits absent optional detail and provenance sections', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PoiDetailSheet(
            poi: DiscoveryPoi(
              id: 'poi-1',
              name: 'Museum',
              category: 'MUSEUM',
              location: const RoutePoint(latitude: 10, longitude: 20),
              distanceToRouteMeters: 150,
              routeProgress: .25,
              reasonCodes: const [],
            ),
          ),
        ),
      ),
    );
    expect(find.text('Fuente'), findsNothing);
    expect(find.textContaining('null'), findsNothing);
    expect(find.textContaining('N/A'), findsNothing);
  });

  testWidgets(
    'loads published tourism text online in Detail without fabricating fields',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoiDetailSheet(
              poi: DiscoveryPoi(
                id: 'poi-1',
                name: 'Museum',
                category: 'MUSEUM',
                location: const RoutePoint(latitude: 10, longitude: 20),
                distanceToRouteMeters: 50,
                routeProgress: .4,
                reasonCodes: const [],
              ),
              loadTourismContent: (_) async => const PoiTourismContent(
                summary: 'A concise museum summary',
                description: 'Visitor description',
                history: 'Verified history',
                significance: null,
                visitorExperience: null,
                interestingFacts: ['A verified fact'],
                recommendations: [],
                practicalInfo: null,
                officialUrl: null,
                photos: [],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('A concise museum summary'), findsOneWidget);
      expect(find.text('Historia'), findsOneWidget);
      expect(find.text('Verified history'), findsOneWidget);
      expect(find.text('Datos interesantes'), findsOneWidget);
      expect(find.text('• A verified fact'), findsOneWidget);
      expect(find.text('Importancia'), findsNothing);
    },
  );
}
