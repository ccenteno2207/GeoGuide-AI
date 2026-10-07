import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/app/theme/geoguide_theme.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/domain/route_snapshot.dart';
import 'package:geoguide_ai/features/discovery/presentation/offline_cache_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_preview_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';

import 'offline_cache_test.dart' as fixtures;

class MemoryStore implements RouteDiscoverySnapshotStore {
  RouteSnapshot? value;
  @override
  Future<RouteSnapshot?> readEligible() async => value;
  @override
  Future<void> replaceValidated(
    RouteSnapshot s, {
    required bool Function() stillCurrent,
  }) async {
    if (stillCurrent()) value = s;
  }

  @override
  Future<void> delete() async {
    value = null;
  }

  @override
  Future<void> close() async {}
}

void main() {
  testWidgets(
    'offline shell at 360px and scale 2.0 has readable state and route summary',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final app = OfflineDiscovery(
        source: fixtures.Source(),
        store: MemoryStore()..value = fixtures.snapshot(),
        backendContext: fixtures.query().backendContext,
        now: () => fixtures.captured,
      );
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: GeoGuideApp(offlineDiscovery: app),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Corredor:'), findsOneWidget);
      expect(
        MediaQuery.textScalerOf(
          tester.element(find.textContaining('Corredor:')),
        ).scale(10),
        20,
      );
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'expiry removes visible cached detail without resurrecting stale POI',
    (tester) async {
      var now = fixtures.captured;
      final app = OfflineDiscovery(
        source: fixtures.Source(),
        store: MemoryStore()..value = fixtures.snapshot(),
        backendContext: fixtures.query().backendContext,
        now: () => now,
      );
      await tester.pumpWidget(GeoGuideApp(offlineDiscovery: app));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver lista'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey('discovery-list-00000000-0000-4000-8000-000000000001'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ver detalle'));
      await tester.pumpAndSettle();
      now += RouteSnapshot.ttlMs;
      await app.revalidate();
      await tester.pumpAndSettle();
      expect(find.byType(PoiDetailSheet), findsNothing);
      expect(app.snapshot, isNull);
      expect(find.textContaining('Copia vencida'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'restart copy has no modal, Map/List Preview Detail preserve context',
    (tester) async {
      final store = MemoryStore()..value = fixtures.snapshot();
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final app = OfflineDiscovery(
        source: fixtures.Source(),
        store: store,
        backendContext: fixtures.query().backendContext,
        now: () => fixtures.captured,
      );
      await tester.pumpWidget(GeoGuideApp(offlineDiscovery: app));
      await tester.pumpAndSettle();
      expect(find.byType(PoiPreviewSheet), findsNothing);
      expect(find.byType(PoiDetailSheet), findsNothing);
      expect(find.textContaining('Copia offline'), findsWidgets);
      await tester.tap(find.text('Ver lista'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(
          const ValueKey('discovery-list-00000000-0000-4000-8000-000000000001'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PoiPreviewSheet), findsOneWidget);
      await tester.tap(find.text('Ver detalle'));
      await tester.pumpAndSettle();
      expect(find.byType(PoiDetailSheet), findsOneWidget);
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();
      expect(app.snapshot!.query.sameAs(fixtures.query()), isTrue);
      expect(find.text('Ver mapa'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('consent sheet scales 2.0, accessible labels and 48px targets', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final app = OfflineDiscovery(
      source: fixtures.Source(),
      store: MemoryStore(),
      backendContext: fixtures.query().backendContext,
      now: () => fixtures.captured,
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: GeoGuideTheme.light(),
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            textScaler: TextScaler.linear(2),
          ),
          child: Scaffold(body: OfflineCacheSheet(controller: app)),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    final consent = find.text('Permitir copia offline durante esta sesión');
    await tester.ensureVisible(consent);
    expect(
      tester.getSize(find.byType(FilledButton)).height,
      greaterThanOrEqualTo(48),
    );
    expect(find.textContaining('24 horas'), findsOneWidget);
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.byType(FilledButton)).label,
      contains('Permitir copia offline'),
    );
    semantics.dispose();
    await app.dispose();
  });
  test('theme contrast satisfies normal text and action thresholds', () {
    final c = GeoGuideTheme.light().colorScheme;
    double ratio(Color a, Color b) {
      final x = a.computeLuminance(), y = b.computeLuminance();
      return (x > y ? x + .05 : y + .05) / (x > y ? y + .05 : x + .05);
    }

    expect(ratio(c.onSurface, c.surface), greaterThanOrEqualTo(4.5));
    expect(ratio(c.onPrimary, c.primary), greaterThanOrEqualTo(4.5));
    expect(ratio(c.primary, c.surface), greaterThanOrEqualTo(3));
  });
}
