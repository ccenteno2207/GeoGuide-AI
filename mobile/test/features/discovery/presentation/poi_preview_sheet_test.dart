import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_preview_sheet.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

DiscoveryPoi _poi({
  String category = 'WATERFALL',
  double distance = 320,
  List<String> reasons = const ['NEAR_ROUTE'],
}) => DiscoveryPoi(
  id: 'poi-123',
  name: 'Catarata de prueba',
  category: category,
  location: const RoutePoint(latitude: -12, longitude: -77),
  distanceToRouteMeters: distance,
  routeProgress: .4,
  reasonCodes: reasons,
);

void main() {
  Future<void> pumpPreview(WidgetTester tester, DiscoveryPoi poi) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PoiPreviewSheet(poi: poi, onViewDetail: () {}),
        ),
      ),
    );
  }

  testWidgets('renders approved preview fields and friendly mappings', (
    tester,
  ) async {
    await pumpPreview(tester, _poi());
    expect(find.text('Catarata de prueba'), findsOneWidget);
    expect(find.text('Categoría: Catarata'), findsOneWidget);
    expect(find.text('A 320 m del trazado'), findsOneWidget);
    expect(find.text('Cerca del trazado'), findsOneWidget);
    expect(find.text('poi-123'), findsNothing);
  });

  testWidgets('renders category match without raw reason code', (tester) async {
    await pumpPreview(tester, _poi(reasons: ['CATEGORY_MATCH']));
    expect(find.text('Coincide con la categoría seleccionada'), findsOneWidget);
    expect(find.text('CATEGORY_MATCH'), findsNothing);
  });

  testWidgets('hides unknown reasons and never renders forbidden fields', (
    tester,
  ) async {
    await pumpPreview(tester, _poi(reasons: ['UNSUPPORTED_REASON']));
    expect(find.text('UNSUPPORTED_REASON'), findsNothing);
    expect(find.textContaining('40%'), findsNothing);
    expect(find.textContaining('score'), findsNothing);
  });

  testWidgets('close dismisses the preview', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                builder: (_) => PoiPreviewSheet(poi: _poi()),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Catarata de prueba'), findsOneWidget);
    await tester.ensureVisible(find.text('Cerrar'));
    await tester.tap(find.text('Cerrar'));
    await tester.pumpAndSettle();
    expect(find.text('Catarata de prueba'), findsNothing);
  });
}
