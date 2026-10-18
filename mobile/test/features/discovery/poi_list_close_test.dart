import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/domain/route_snapshot.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_preview_sheet.dart';
import 'package:geoguide_ai/features/tracking/application/route_session_client.dart';

import '../tracking/b1_widget_test.dart' show FakeSession;
import 'offline_cache_test.dart' as fixtures;
import 'offline_ui_test.dart' show MemoryStore;

RouteSnapshot longSnapshot() {
  final base = fixtures.snapshot(q: fixtures.query(categories: {'MUSEUM'}));
  final poi = base.pois.first;
  return RouteSnapshot(
    query: base.query,
    route: base.route,
    algorithmVersion: base.algorithmVersion,
    generatedAt: base.generatedAt,
    capturedAtUtcMs: base.capturedAtUtcMs,
    pois: List.generate(
      20,
      (i) => DiscoveryPoi(
        id: '00000000-0000-4000-8000-${(i + 1).toString().padLeft(12, '0')}',
        name: 'Fixture ${i + 1}',
        category: poi.category,
        location: poi.location,
        distanceToRouteMeters: poi.distanceToRouteMeters,
        routeProgress: poi.routeProgress,
        reasonCodes: poi.reasonCodes,
        description: poi.description,
      ),
    ),
  );
}

OfflineDiscovery offline(RouteSnapshot snapshot) => OfflineDiscovery(
  source: fixtures.Source(),
  store: MemoryStore()..value = snapshot,
  backendContext: snapshot.query.backendContext,
  now: () => fixtures.captured,
);

void main() {
  for (final size in [
    const Size(320, 480),
    const Size(360, 640),
    const Size(640, 360),
  ]) {
    testWidgets('long POI list closes at $size without changing route', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final snapshot = longSnapshot();
      final app = offline(snapshot);
      await tester.pumpWidget(GeoGuideApp(offlineDiscovery: app));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Ver lista'));
      await tester.tap(find.text('Ver lista'));
      await tester.pumpAndSettle();
      final close = find.byKey(const ValueKey('close-discovery-list'));
      expect(close.hitTestable(), findsOneWidget);
      final list = find.descendant(
        of: find.byKey(const ValueKey('discovery-list-panel')),
        matching: find.byType(ListView),
      );
      await tester.scrollUntilVisible(
        find.text('Fixture 20'),
        300,
        scrollable: find.descendant(
          of: list,
          matching: find.byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Fixture 20'), findsOneWidget);
      expect(close.hitTestable(), findsOneWidget);
      await tester.tap(close);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('discovery-list-panel')), findsNothing);
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('Ver lista'), findsOneWidget);
      expect(app.snapshot, same(snapshot));
      expect(app.snapshot!.query.categories, ['MUSEUM']);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('detail and list close preserve an active route session', (
    tester,
  ) async {
    final snapshot = longSnapshot();
    final app = offline(snapshot);
    final session = FakeSession()..active = true;
    await tester.pumpWidget(
      GeoGuideApp(offlineDiscovery: app, routeSession: session),
    );
    await tester.pumpAndSettle();
    session.onState?.call(RouteSessionStatus.active);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver lista'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fixture 1'));
    await tester.pumpAndSettle();
    expect(find.byType(PoiPreviewSheet), findsOneWidget);
    await tester.tap(find.text('Ver detalle'));
    await tester.pumpAndSettle();
    expect(find.byType(PoiDetailSheet), findsOneWidget);
    await tester.tap(find.text('Volver'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('close-discovery-list')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('discovery-list-panel')), findsNothing);
    expect(session.active, isTrue);
    expect(session.starts, 0);
    expect(session.permissions, 0);
    expect(app.snapshot, same(snapshot));
    expect(find.byTooltip('Detener recorrido GPS'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
