import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/infrastructure/offline/snapshot_codec.dart';

import '../discovery/offline_cache_test.dart' as fixtures;
import '../discovery/offline_ui_test.dart' as stores;
import 'b1_widget_test.dart' show FakeSession;

Finder iconControl(String tooltip) => find.byWidgetPredicate(
  (widget) => widget is IconButton && widget.tooltip == tooltip,
);

void expectBlockedIcon(WidgetTester tester, String tooltip) {
  final control = iconControl(tooltip);
  expect(control, findsOneWidget);
  expect(tester.widget<IconButton>(control).onPressed, isNull);
}

void main() {
  testWidgets(
    'blocking assertion rejects an enabled real IconButton and accepts disabled',
    (tester) async {
      const tooltip = 'Iniciar recorrido GPS';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconButton(
              tooltip: tooltip,
              onPressed: () {},
              icon: const Icon(Icons.route),
            ),
          ),
        ),
      );
      expect(
        () => expectBlockedIcon(tester, tooltip),
        throwsA(isA<TestFailure>()),
      );
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: IconButton(
              tooltip: tooltip,
              onPressed: null,
              icon: Icon(Icons.route),
            ),
          ),
        ),
      );
      expectBlockedIcon(tester, tooltip);
    },
  );
  testWidgets(
    'localized selector fails for misdecoded UTF-8; key and exact text detect it',
    (tester) async {
      const label = 'Categorías: 0 categorías';
      final misdecoded = latin1.decode(utf8.encode(label));
      const key = ValueKey('category-diagnostic');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilledButton(
              key: key,
              onPressed: null,
              child: Text(misdecoded),
            ),
          ),
        ),
      );
      final localized = find.widgetWithText(FilledButton, label);
      expect(localized, findsNothing);
      expect(() => tester.widget<FilledButton>(localized), throwsStateError);
      expect(find.byKey(key), findsOneWidget);
      expect(
        find.descendant(of: find.byKey(key), matching: find.text(label)),
        findsNothing,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilledButton(
              key: key,
              onPressed: null,
              child: const Text(label),
            ),
          ),
        ),
      );
      expect(
        find.descendant(of: find.byKey(key), matching: find.text(label)),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'explicit selection reaches B1; inspection and voice consent do not select; stop clears',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final time = DateTime.now();
      final s = const SnapshotCodec().fromEnvelope(
        fixtures.envelope(),
        fixtures.query(),
        time.millisecondsSinceEpoch,
      );
      final offline = OfflineDiscovery(
        source: fixtures.Source(),
        store: stores.MemoryStore()..value = s,
        backendContext: s.query.backendContext,
        now: () => time.millisecondsSinceEpoch,
      );
      final session = FakeSession();
      await tester.pumpWidget(
        GeoGuideApp(
          offlineDiscovery: offline,
          routeSession: session,
          locationClock: () => time,
        ),
      );
      await tester.pumpAndSettle();
      Future<void> preview() async {
        await tester.tap(find.text('Ver lista'));
        await tester.pumpAndSettle();
        await tester.tap(find.text(s.pois.first.name));
        await tester.pumpAndSettle();
      }

      final filter = find.byKey(const ValueKey('route-category-filter'));
      expect(
        find.descendant(
          of: filter,
          matching: find.text('Categorías: 0 categorías'),
        ),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(filter).onPressed, isNotNull);
      await tester.tap(filter);
      await tester.pumpAndSettle();
      expect(find.text('Filtrar lugares'), findsOneWidget);
      expect(
        tester
            .widgetList<CheckboxListTile>(find.byType(CheckboxListTile))
            .every((w) => w.value == false),
        isTrue,
      );
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(session.lastChosen, isEmpty);
      await preview();
      expect(find.text('Elegir para este recorrido'), findsOneWidget);
      expect(session.lastChosen, isEmpty);
      await tester.tap(find.text('Ver detalle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('close-discovery-list')));
      await tester.pumpAndSettle();
      await preview();
      await tester.tap(find.text('Elegir para este recorrido'));
      await tester.pumpAndSettle();
      expect(find.text('Quitar de este recorrido'), findsOneWidget);
      await tester.tap(find.text('Quitar de este recorrido'));
      await tester.pumpAndSettle();
      expect(find.text('Elegir para este recorrido'), findsOneWidget);
      await tester.tap(find.text('Elegir para este recorrido'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('close-discovery-list')));
      await tester.pumpAndSettle();
      for (final saving in [false, true]) {
        offline.busy = !saving;
        offline.saving = saving;
        offline.onChanged?.call();
        await tester.pump();
        expectBlockedIcon(tester, 'Iniciar recorrido GPS');
        expect(session.starts, 0);
        offline.busy = false;
        offline.saving = false;
        offline.onChanged?.call();
        await tester.pump();
      }
      await tester.tap(find.byTooltip('Iniciar recorrido GPS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Iniciar recorrido'));
      await tester.pumpAndSettle();
      expect(session.lastChosen, {s.pois.first.id});
      expect(session.voiceEnabled, isFalse);
      expectBlockedIcon(tester, 'Gestionar copia offline');
      await preview();
      final selected = find.widgetWithText(
        TextButton,
        'Quitar de este recorrido',
      );
      expect(tester.widget<TextButton>(selected).onPressed, isNull);
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('close-discovery-list')));
      await tester.pumpAndSettle();
      final category = find.byKey(const ValueKey('route-category-filter'));
      expect(category, findsOneWidget);
      expect(
        find.descendant(
          of: category,
          matching: find.text('Categorías: 0 categorías'),
        ),
        findsOneWidget,
      );
      expect(tester.widget<FilledButton>(category).onPressed, isNull);
      await tester.tap(find.byTooltip('Detener recorrido GPS'));
      await tester.pumpAndSettle();
      await preview();
      expect(find.text('Elegir para este recorrido'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );
}
