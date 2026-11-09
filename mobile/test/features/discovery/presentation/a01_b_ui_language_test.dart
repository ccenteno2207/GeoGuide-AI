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
import 'package:geoguide_ai/features/discovery/presentation/poi_presentation.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_result_card.dart';

import '../../tracking/b1_widget_test.dart' show FakeSession;
import '../offline_cache_test.dart' as fixtures;
import '../offline_ui_test.dart' show MemoryStore;
import '../ui2_experience_test.dart' show CountingSource, syntheticSnapshot;
import 'a01_preview_actions_test.dart'
    show factualPoi, expectNoSpanishOverride, activateSemantically;

void expectSpanishSegment(SemanticsNode node, String text) {
  final data = node.getSemanticsData();
  final attributes = data.attributedLabel.attributes
      .whereType<ui.LocaleStringAttribute>()
      .where((attribute) => attribute.locale == const Locale('es', 'PE'));
  var start = data.label.indexOf(text);
  var covered = false;
  while (start >= 0) {
    covered |= attributes.any(
      (attribute) =>
          attribute.range.start <= start &&
          attribute.range.end >= start + text.length,
    );
    start = data.label.indexOf(text, start + text.length);
  }
  expect(
    covered,
    isTrue,
    reason: 'Missing Spanish range for "$text" in ${data.label}',
  );
}

List<SemanticsNode> semanticNodes(WidgetTester tester) {
  final nodes = <SemanticsNode>[];
  void visit(SemanticsNode node) {
    nodes.add(node);
    node.visitChildren((child) {
      visit(child);
      return true;
    });
  }

  visit(
    tester.binding.renderViews.single.owner!.semanticsOwner!.rootSemanticsNode!,
  );
  return nodes;
}

void expectSpanishButton(WidgetTester tester, String label) {
  final data = tester.getSemantics(find.text(label)).getSemanticsData();
  expect(data.label, label);
  expect(data.locale, const Locale('es', 'PE'));
  expect(data.flagsCollection.isButton, isTrue);
  expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
  expect(
    semanticNodes(tester).where((node) => node.label == label),
    hasLength(1),
  );
}

void main() {
  for (final (name, description) in [
    ('Museo Ñandú', 'Descripción española del río.'),
    ('Café 日本 / Amber Museum', 'Historical facts, unchanged.'),
  ]) {
    testWidgets(
      'A01-B fixed Spanish ranges never cover external fields: $name',
      (tester) async {
        final semantics = tester.ensureSemantics();
        final poi = factualPoi(name, description);
        for (final surface in <Widget>[
          PoiResultCard(poi: poi, onPressed: () {}),
          PoiDetailSheet(poi: poi),
        ]) {
          await tester.pumpWidget(MaterialApp(home: Scaffold(body: surface)));
          await tester.pumpAndSettle();
          final nameNode = tester.getSemantics(find.text(name));
          expectNoSpanishOverride(nameNode, name);
          expectNoSpanishOverride(
            tester.getSemantics(find.text(description)),
            description,
          );
          expectNoSpanishOverride(
            tester.getSemantics(find.text(poi.attribution!)),
            poi.attribution!,
          );
          final sourceLabel = surface is PoiResultCard
              ? 'Fuente: ${poi.sourceLabel}'
              : poi.sourceLabel!;
          expectNoSpanishOverride(
            tester.getSemantics(find.text(sourceLabel)),
            poi.sourceLabel!,
          );
          expectSpanishSegment(
            tester.getSemantics(find.text('A 140 m del trazado')),
            'A 140 m del trazado',
          );
          if (surface is PoiResultCard) {
            expectSpanishSegment(nameNode, 'Museo');
            expectSpanishSegment(nameNode, 'Fuente: ');
            final data = nameNode.getSemanticsData();
            expect(data.flagsCollection.isButton, isTrue);
            expect(data.hasAction(ui.SemanticsAction.tap), isTrue);
            expect(
              data.attributedLabel.attributes
                  .whereType<ui.LocaleStringAttribute>()
                  .map(
                    (attribute) => data.label.substring(
                      attribute.range.start,
                      attribute.range.end,
                    ),
                  ),
              unorderedEquals(['Museo', 'A 140 m del trazado', 'Fuente: ']),
            );
          } else {
            expectSpanishSegment(nameNode, 'Detalle de ');
            expectSpanishSegment(nameNode, 'Categoría: Museo');
            expectSpanishSegment(nameNode, 'Cerca del trazado');
            expectSpanishSegment(nameNode, 'Fuente');
            final urlNode = tester.getSemantics(find.text(poi.sourceUrl!));
            expectNoSpanishOverride(urlNode, poi.sourceUrl!);
            final linkNode = semanticNodes(tester).singleWhere(
              (node) => node.getSemanticsData().flagsCollection.isLink,
            );
            expectSpanishSegment(linkNode, 'URL de la fuente');
            expect(linkNode.getSemanticsData().locale, isNull);
            expectSpanishButton(tester, 'Volver');
          }
        }
        semantics.dispose();
      },
    );
  }

  testWidgets(
    'A01-B all category labels and fallback come from Spanish UI mappings',
    (tester) async {
      final semantics = tester.ensureSemantics();
      for (final code in [...discoveryCategoryCodes, 'UNKNOWN_EXTERNAL_CODE']) {
        final original = factualPoi('Amber Museum', 'External facts.');
        final poi = DiscoveryPoi(
          id: original.id,
          name: original.name,
          category: code,
          location: original.location,
          distanceToRouteMeters: original.distanceToRouteMeters,
          routeProgress: original.routeProgress,
          reasonCodes: const [],
        );
        final label = friendlyPoiCategory(code);
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PoiResultCard(poi: poi, onPressed: () {}),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expectSpanishSegment(tester.getSemantics(find.text(label)), label);
        expectNoSpanishOverride(
          tester.getSemantics(find.text(poi.name)),
          poi.name,
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(body: PoiDetailSheet(poi: poi)),
          ),
        );
        await tester.pumpAndSettle();
        expectSpanishSegment(
          tester.getSemantics(find.text('Categoría: $label')),
          'Categoría: $label',
        );
        expectNoSpanishOverride(
          tester.getSemantics(find.text(poi.name)),
          poi.name,
        );
      }
      semantics.dispose();
    },
  );

  testWidgets(
    'A01-B list/map toggle, Preview and Detail return keep semantics, focus and query',
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
      expectSpanishButton(tester, 'Ver lista');
      Focus.of(tester.element(find.text('Ver lista'))).requestFocus();
      await tester.pump();
      expect(
        Focus.of(tester.element(find.text('Ver lista'))).hasPrimaryFocus,
        isTrue,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(
        Focus.of(tester.element(find.text('Conducción'))).hasPrimaryFocus,
        isTrue,
      );
      activateSemantically(tester, 'Ver lista');
      await tester.pumpAndSettle();
      // The shell hides status controls while the list is open. Its existing
      // close icon returns to the map; no navigation structure is changed.
      expect(find.text('Ver lista'), findsNothing);
      final closeList = tester.getSemantics(
        find.byKey(const ValueKey('close-discovery-list')),
      );
      expect(
        closeList.getSemanticsData().hasAction(ui.SemanticsAction.tap),
        isTrue,
      );
      tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
        closeList.id,
        ui.SemanticsAction.tap,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('discovery-list-panel')), findsNothing);
      expectSpanishButton(tester, 'Ver lista');
      activateSemantically(tester, 'Ver lista');
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('poi-local-search')),
        'Ámbar',
      );
      await tester.pumpAndSettle();
      final card = tester.getSemantics(find.text('Museo Ámbar'));
      expect(card.getSemanticsData().flagsCollection.isButton, isTrue);
      expect(card.getSemanticsData().hasAction(ui.SemanticsAction.tap), isTrue);
      tester.binding.renderViews.single.owner!.semanticsOwner!.performAction(
        card.id,
        ui.SemanticsAction.tap,
      );
      await tester.pumpAndSettle();
      expectSpanishButton(tester, 'Cerrar');
      expectSpanishButton(tester, 'Ver detalle');
      activateSemantically(tester, 'Ver detalle');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Volver'));
      await tester.pumpAndSettle();
      expectSpanishButton(tester, 'Volver');
      Focus.of(tester.element(find.text('Volver'))).requestFocus();
      await tester.pump();
      expect(
        Focus.of(tester.element(find.text('Volver'))).hasPrimaryFocus,
        isTrue,
      );
      activateSemantically(tester, 'Volver');
      await tester.pumpAndSettle();
      expect(find.byType(PoiDetailSheet), findsNothing);
      expect(
        tester
            .widget<TextField>(find.byKey(const ValueKey('poi-local-search')))
            .controller!
            .text,
        'Ámbar',
      );
      await tester.tap(find.byKey(const ValueKey('close-discovery-list')));
      await tester.pumpAndSettle();
      final after = tester.getSemantics(marker).getSemanticsData();
      expect(after.tooltip, before.tooltip);
      expect(after.locale, before.locale);
      expect(after.attributedLabel, before.attributedLabel);
      expect(source.calls, 0);
      expect(offline.snapshot, same(snapshot));
      await tester.pumpWidget(const SizedBox());
      semantics.dispose();
    },
  );
}
