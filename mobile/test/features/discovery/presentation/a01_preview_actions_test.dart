import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_preview_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_result_card.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

import '../../tracking/b1_widget_test.dart' show FakeSession;
import '../offline_cache_test.dart' as fixtures;
import '../offline_ui_test.dart' show MemoryStore;
import '../ui2_experience_test.dart' show CountingSource, syntheticSnapshot;

DiscoveryPoi factualPoi(String name, String description) => DiscoveryPoi(
  id: 'TEST_ONLY_A01',
  name: name,
  description: description,
  category: 'MUSEUM',
  location: const RoutePoint(latitude: -12, longitude: -77),
  distanceToRouteMeters: 140,
  routeProgress: .4,
  reasonCodes: const ['NEAR_ROUTE'],
  sourceLabel: 'Original source / Fuente original',
  sourceUrl: 'https://example.test/Amber-Museum',
  attribution: 'OpenStreetMap contributors',
);

void expectNoSpanishOverride(SemanticsNode node, String factualText) {
  final data = node.getSemanticsData();
  expect(data.locale?.languageCode, isNot('es'));
  var occurrences = 0;
  // Fixed UI segments may carry Spanish in a merged label. No such range may
  // overlap any occurrence of the factual text, including repeated names.
  for (final text in [data.attributedLabel, data.attributedValue]) {
    var start = text.string.indexOf(factualText);
    while (start >= 0) {
      occurrences++;
      final end = start + factualText.length;
      expect(
        text.attributes.whereType<ui.LocaleStringAttribute>().where(
          (attribute) =>
              attribute.locale.languageCode == 'es' &&
              attribute.range.start < end &&
              start < attribute.range.end,
        ),
        isEmpty,
      );
      start = text.string.indexOf(factualText, end);
    }
  }
  expect(occurrences, greaterThan(0));
}

void activateSemantically(WidgetTester tester, String label) {
  final node = tester.getSemantics(find.text(label));
  expect(node.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
  tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
    node.id,
    ui.SemanticsAction.tap,
  );
}

void main() {
  testWidgets('A01-T01/T02/T03: only fixed action nodes carry Spanish locale', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var activations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PoiPreviewSheet(
            poi: factualPoi('Amber Museum / Museo Ñandú', 'Original facts.'),
            onViewDetail: () => activations++,
            selectionControl: TextButton(
              onPressed: () {},
              child: const Text('Elegir para este recorrido'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final nodes = <SemanticsNode>[];
    void collect(SemanticsNode node) {
      nodes.add(node);
      node.visitChildren((child) {
        collect(child);
        return true;
      });
    }

    collect(tester.getSemantics(find.byType(PoiPreviewSheet)));
    for (final label in ['Cerrar', 'Ver detalle']) {
      expect(find.text(label), findsOneWidget);
      final data = tester.getSemantics(find.text(label)).getSemanticsData();
      expect(data.label, label);
      expect(data.locale, const Locale('es', 'PE'));
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
      expect(nodes.where((node) => node.label.contains(label)), hasLength(1));
    }
    expect(
      nodes
          .where(
            (node) => node.label == 'Cerrar' || node.label == 'Ver detalle',
          )
          .map((node) => node.label),
      ['Cerrar', 'Ver detalle'],
    );
    expectNoSpanishOverride(
      tester.getSemantics(find.text('Amber Museum / Museo Ñandú')),
      'Amber Museum / Museo Ñandú',
    );
    expectNoSpanishOverride(
      tester.getSemantics(find.text('Elegir para este recorrido')),
      'Elegir para este recorrido',
    );
    final closeFocus = Focus.of(tester.element(find.text('Cerrar')));
    closeFocus.requestFocus();
    await tester.pump();
    expect(closeFocus.hasPrimaryFocus, isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(
      Focus.of(tester.element(find.text('Ver detalle'))).hasPrimaryFocus,
      isTrue,
    );
    activateSemantically(tester, 'Ver detalle');
    await tester.pump();
    expect(activations, 1);
    semantics.dispose();
  });

  testWidgets(
    'A01-T03: disabled detail keeps button role without a tap action',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoiPreviewSheet(
              poi: factualPoi('Amber Museum', 'Historical facts.'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final data = tester
          .getSemantics(find.text('Ver detalle'))
          .getSemanticsData();
      expect(data.locale, const Locale('es', 'PE'));
      expect(data.label, 'Ver detalle');
      expect(data.flagsCollection.isButton, isTrue);
      expect(data.hasAction(ui.SemanticsAction.tap), isFalse);
      semantics.dispose();
    },
  );

  for (final (name, description) in [
    ('Museo Ámbar / Ñandú', 'Descripción histórica del río.'),
    ('Amber Museum', 'Historical description of the valley.'),
  ]) {
    testWidgets('A01-T05: factual fields stay untagged and intact: $name', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final poi = factualPoi(name, description);
      for (final surface in <Widget>[
        PoiResultCard(poi: poi, onPressed: () {}),
        PoiPreviewSheet(poi: poi, onViewDetail: () {}),
        PoiDetailSheet(poi: poi),
      ]) {
        await tester.pumpWidget(MaterialApp(home: Scaffold(body: surface)));
        await tester.pumpAndSettle();
        expect(find.text(name), findsOneWidget);
        expectNoSpanishOverride(tester.getSemantics(find.text(name)), name);
        if (surface is! PoiPreviewSheet) {
          for (final text in [description, poi.attribution!]) {
            expect(find.text(text), findsOneWidget);
            expectNoSpanishOverride(tester.getSemantics(find.text(text)), text);
          }
          final sourceText = surface is PoiResultCard
              ? 'Fuente: ${poi.sourceLabel}'
              : poi.sourceLabel!;
          expect(find.text(sourceText), findsOneWidget);
          expectNoSpanishOverride(
            tester.getSemantics(find.text(sourceText)),
            poi.sourceLabel!,
          );
          if (surface is PoiDetailSheet) {
            expect(find.text(poi.sourceUrl!), findsOneWidget);
            expectNoSpanishOverride(
              tester.getSemantics(find.text(poi.sourceUrl!)),
              poi.sourceUrl!,
            );
          }
        }
      }
      semantics.dispose();
    });
  }

  testWidgets(
    'A01-T04/T06: semantic actions use real Preview navigation and return',
    (tester) async {
      final semantics = tester.ensureSemantics();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('plugins.flutter.io/path_provider'),
            (call) async => Directory.systemTemp.path,
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
              const MethodChannel('plugins.flutter.io/path_provider'),
              null,
            ),
      );
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final snapshot = syntheticSnapshot();
      final source = CountingSource();
      final offline = OfflineDiscovery(
        source: source,
        store: MemoryStore()..value = snapshot,
        backendContext: snapshot.query.backendContext,
        now: () => fixtures.captured,
      );
      await tester.pumpWidget(
        GeoGuideApp(routeSession: FakeSession(), offlineDiscovery: offline),
      );
      await tester.pumpAndSettle();
      final marker = find.byTooltip('Vista previa de Museo Ámbar');
      final before = tester.getSemantics(marker).getSemanticsData();
      await tester.tap(marker);
      await tester.pumpAndSettle();
      activateSemantically(tester, 'Ver detalle');
      await tester.pumpAndSettle();
      expect(find.byType(PoiDetailSheet), findsOneWidget);
      expect(find.text(snapshot.pois.first.description!), findsOneWidget);
      await tester.ensureVisible(find.text('Volver'));
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();
      expect(find.byType(PoiDetailSheet), findsNothing);
      await tester.tap(marker);
      await tester.pumpAndSettle();
      activateSemantically(tester, 'Cerrar');
      await tester.pumpAndSettle();
      expect(find.byType(PoiPreviewSheet), findsNothing);
      final after = tester.getSemantics(marker).getSemanticsData();
      expect(after.tooltip, before.tooltip);
      expect(after.locale, before.locale);
      expect(after.attributedLabel, before.attributedLabel);
      expect(source.calls, 0);
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );
}
