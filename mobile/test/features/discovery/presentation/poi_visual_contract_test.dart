import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/theme/geoguide_theme.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_result_card.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_thumbnail.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

void main() {
  const minimal = DiscoveryPoi(
    id: 'not-for-display',
    name: 'Nombre de prueba',
    category: 'UNKNOWN_CODE',
    location: RoutePoint(latitude: 0, longitude: 0),
    distanceToRouteMeters: double.nan,
    routeProgress: .4444,
    reasonCodes: ['RAW_REASON'],
    description: '  ',
    sourceLabel: '',
    sourceUrl: ' ',
    attribution: '\n',
  );

  testWidgets(
    'optional fields and internal codes are absent; placeholder is stable and informative',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: GeoGuideTheme.explorationShell(),
          home: Scaffold(
            body: PoiResultCard(poi: minimal, onPressed: () {}),
          ),
        ),
      );
      expect(find.text('Lugar de interés'), findsOneWidget);
      expect(find.textContaining('Fuente:'), findsNothing);
      expect(find.textContaining('m del trazado'), findsNothing);
      expect(find.textContaining('UNKNOWN_CODE'), findsNothing);
      expect(find.textContaining('not-for-display'), findsNothing);
      expect(tester.getSize(find.byType(PoiThumbnail)), const Size(96, 72));
      expect(
        find.bySemanticsLabel(RegExp('Imagen no disponible')),
        findsWidgets,
      );
      expect(find.byType(Image), findsNothing);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PoiDetailSheet(poi: minimal)),
        ),
      );
      expect(find.text('Fuente'), findsNothing);
      expect(find.textContaining('RAW_REASON'), findsNothing);
      expect(find.textContaining('null'), findsNothing);
      expect(find.textContaining('44%'), findsNothing);
      expect(find.textContaining('N/A'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );
}
