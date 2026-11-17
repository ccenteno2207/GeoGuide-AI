import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  testWidgets('card keeps factual fields compact without changing source data', (
    tester,
  ) async {
    const name =
        'Nombre largo del atractivo turístico que supera dos líneas visibles';
    const description =
        'Descripción turística existente que debe acortarse visualmente en la tarjeta sin modificar el texto original.';
    const poi = DiscoveryPoi(
      id: 'compact-card-test',
      name: name,
      category: 'MUSEUM',
      location: RoutePoint(latitude: -12, longitude: -77),
      distanceToRouteMeters: 140,
      routeProgress: .5,
      reasonCodes: [],
      description: description,
      sourceLabel: 'Fuente disponible',
      sourceUrl: 'https://example.test/source',
      attribution: 'Atribución disponible',
    );
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PoiResultCard(poi: poi, onPressed: () {}, onViewDetails: () {}),
        ),
      ),
    );

    final title = tester.widget<Text>(find.text(name));
    final descriptionText = tester.widget<Text>(find.text(description));
    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(descriptionText.maxLines, 2);
    expect(find.text('Museo'), findsOneWidget);
    expect(find.text('A 140 m del trazado'), findsOneWidget);
    expect(find.textContaining('Fuente: Fuente disponible'), findsOneWidget);
    expect(find.text('Atribución disponible'), findsOneWidget);
    expect(poi.name, name);
    expect(poi.description, description);
  });

  testWidgets(
    'card Preview and Ver detalles are independent and keyboard accessible',
    (tester) async {
      final semantics = tester.ensureSemantics();
      var previews = 0;
      var details = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoiResultCard(
              poi: minimal,
              onPressed: () => previews++,
              onViewDetails: () => details++,
            ),
          ),
        ),
      );

      final button = find.byKey(const ValueKey('poi-card-view-details'));
      expect(find.text('Ver detalles'), findsOneWidget);
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      final detailSemantics = tester
          .getSemantics(find.text('Ver detalles'))
          .getSemanticsData();
      expect(detailSemantics.flagsCollection.isButton, isTrue);
      expect(detailSemantics.locale, const Locale('es', 'PE'));
      await tester.tap(find.text('Nombre de prueba'));
      await tester.pump();
      expect(previews, 1);
      expect(details, 0);

      final focus = Focus.of(tester.element(find.text('Ver detalles')));
      focus.requestFocus();
      await tester.pump();
      expect(focus.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(details, 1);
      expect(previews, 1);
      semantics.dispose();
    },
  );

  testWidgets(
    'optional fields and internal codes are absent; placeholder is stable and informative',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          theme: GeoGuideTheme.explorationShell(),
          home: Scaffold(
            body: PoiResultCard(
              poi: minimal,
              onPressed: () {},
              onViewDetails: () {},
            ),
          ),
        ),
      );
      expect(find.text('Lugar de interés'), findsOneWidget);
      expect(
        tester
            .widget<Icon>(
              find.byKey(const ValueKey('poi-category-card-icon-UNKNOWN_CODE')),
            )
            .icon,
        Icons.category,
      );
      expect(find.textContaining('Fuente:'), findsNothing);
      expect(find.textContaining('m del trazado'), findsNothing);
      expect(find.textContaining('UNKNOWN_CODE'), findsNothing);
      expect(find.textContaining('not-for-display'), findsNothing);
      expect(tester.getSize(find.byType(PoiThumbnail)), const Size(72, 54));
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
      expect(
        tester.getSize(
          find.byKey(const ValueKey('poi-detail-thumbnail-frame')),
        ),
        const Size(160, 90),
      );
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );
}
