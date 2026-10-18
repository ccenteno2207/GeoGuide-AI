import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/app/theme/geoguide_theme.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/domain/route_snapshot.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_preview_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';
import 'package:geoguide_ai/features/map/presentation/base_map_page.dart';

import '../discovery/offline_cache_test.dart' as fixtures;

class _MemoryStore implements RouteDiscoverySnapshotStore {
  _MemoryStore(this.value);

  final RouteSnapshot? value;

  @override
  Future<RouteSnapshot?> readEligible() async => value;

  @override
  Future<void> replaceValidated(
    RouteSnapshot snapshot, {
    required bool Function() stillCurrent,
  }) async {}

  @override
  Future<void> delete() async {}

  @override
  Future<void> close() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('geoguide/route_session'),
        (call) async => false,
      );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => Directory.systemTemp.path,
      );

  testWidgets('default exploration keeps at least half its safe area as map', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      GeoGuideApp(locationRepository: _LocationRepository()),
    );
    await tester.pumpAndSettle();

    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    final mapRect = tester.getRect(find.byType(FlutterMap));
    final statusRect = tester.getRect(
      find.byKey(const ValueKey('exploration-status')),
    );
    final actionsRect = tester.getRect(
      find.byKey(const ValueKey('exploration-floating-actions')),
    );
    expect(actionsRect.height, lessThanOrEqualTo(64));
    final safeAreaHeight = screen.height - 48;
    final unoccludedMapHeight =
        mapRect.height - statusRect.height - actionsRect.height;
    expect(unoccludedMapHeight / safeAreaHeight, greaterThanOrEqualTo(0.5));
    expect(find.text('GeoGuide AI'), findsNothing);
    expect(find.text('Exploración'), findsNothing);
    expect(find.byTooltip('Usar ubicación actual'), findsOneWidget);
    expect(find.byTooltip('Activar seguimiento de ubicación'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final size in const [
    Size(360, 640),
    Size(360, 800),
    Size(640, 360),
    Size(800, 360),
  ]) {
    for (final scale in const [1.0, 2.0]) {
      testWidgets(
        'responsive shell ${size.width}x${size.height} scale $scale',
        (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(GeoGuideApp(offlineDiscovery: _offline()));
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.byType(FlutterMap), findsOneWidget);
          expect(find.byTooltip('Usar ubicación actual'), findsOneWidget);
          expect(
            find.byTooltip('Activar seguimiento de ubicación'),
            findsOneWidget,
          );
          for (final control in find.byType(IconButton).evaluate()) {
            final size = tester.getSize(find.byWidget(control.widget));
            expect(size.width, greaterThanOrEqualTo(48));
            expect(size.height, greaterThanOrEqualTo(48));
          }
          expect(
            MediaQuery.textScalerOf(tester.element(find.byType(FlutterMap)))
                .scale(10),
            scale * 10,
          );
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }

  testWidgets('viewport resize preserves BaseMapPage state and data calls', (
    tester,
  ) async {
    final source = fixtures.Source();
    final offline = OfflineDiscovery(
      source: source,
      store: _MemoryStore(fixtures.snapshot()),
      backendContext: fixtures.query().backendContext,
      now: () => fixtures.captured,
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(GeoGuideApp(offlineDiscovery: offline));
    await tester.pumpAndSettle();
    final state = tester.state(find.byType(BaseMapPage));
    final calls = source.calls;
    addTearDown(tester.view.resetPhysicalSize);

    for (final size in const [Size(360, 640), Size(800, 360)]) {
      tester.view.physicalSize = size;
      await tester.pumpAndSettle();
      expect(tester.state(find.byType(BaseMapPage)), same(state));
      expect(source.calls, calls);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('preview and Driving retain the baseline app theme', (
    tester,
  ) async {
    final offline = _offline();
    await tester.pumpWidget(GeoGuideApp(offlineDiscovery: offline));
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(FlutterMap))).colorScheme.primary,
      GeoGuideTheme.explorationShell().colorScheme.primary,
    );
    await tester.tap(find.text('Ver lista'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const ValueKey('discovery-list-00000000-0000-4000-8000-000000000001'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PoiPreviewSheet), findsOneWidget);
    expect(
      Theme.of(tester.element(find.byType(PoiPreviewSheet)))
          .colorScheme
          .primary,
      GeoGuideTheme.light().colorScheme.primary,
    );
    Navigator.of(tester.element(find.byType(PoiPreviewSheet))).pop();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('close-discovery-list')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byTooltip('Entrar en modo conducción'));
    await tester.tap(find.byTooltip('Entrar en modo conducción'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.text('Modo conducción reducido')))
          .colorScheme
          .primary,
      GeoGuideTheme.light().colorScheme.primary,
    );
    expect(find.byType(PoiDetailSheet), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}

OfflineDiscovery _offline() => OfflineDiscovery(
  source: fixtures.Source(),
  store: _MemoryStore(fixtures.snapshot()),
  backendContext: fixtures.query().backendContext,
  now: () => fixtures.captured,
);

class _LocationRepository implements LocationRepository {
  @override
  Future<CurrentLocationResult> requestCurrentLocation() async =>
      const CurrentLocationResult.withAvailability(
        LocationAvailability.unavailable,
      );
}
