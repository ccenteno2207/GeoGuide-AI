import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/domain/route_snapshot.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_detail_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_preview_sheet.dart';
import 'package:geoguide_ai/features/discovery/presentation/poi_thumbnail.dart';
import 'package:geoguide_ai/features/route_planning/domain/planned_route.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';

import '../tracking/b1_widget_test.dart' show FakeSession;
import 'offline_cache_test.dart' as fixtures;
import 'offline_ui_test.dart' show MemoryStore;

// TEST_ONLY: fictional names, factual fields and route coordinates; no media assets.
RouteSnapshot syntheticSnapshot({bool long = false, int? capturedAt}) {
  const origin = RoutePoint(latitude: -12.0464, longitude: -77.0428);
  const destination = RoutePoint(latitude: -12.025, longitude: -77.012);
  return RouteSnapshot(
    query: DiscoveryQuery(
      backendContext: 'https://example.test',
      origin: origin,
      destination: destination,
      categories: {'MUSEUM'},
    ),
    route: const PlannedRoute(
      origin: origin,
      destination: destination,
      distanceMeters: 4200,
      durationSeconds: 720,
      geometry: [origin, destination],
    ),
    pois: [
      DiscoveryPoi(
        id: 'synthetic-1',
        name: long
            ? 'Museo Ámbar de las montañas y memorias del valle de prueba'
            : 'Museo Ámbar',
        category: 'MUSEUM',
        location: origin,
        distanceToRouteMeters: 140,
        routeProgress: .4,
        reasonCodes: const ['NEAR_ROUTE'],
        description: long
            ? 'Descripción sintética extensa. ' * 12
            : 'Descripción sintética para probar la ficha.',
        sourceLabel: 'Fuente sintética de prueba',
        attribution: 'Atribución de prueba',
      ),
      const DiscoveryPoi(
        id: 'synthetic-2',
        name: 'Mirador Ñandú',
        category: 'VIEWPOINT',
        location: destination,
        distanceToRouteMeters: 50,
        routeProgress: .9,
        reasonCodes: [],
      ),
    ],
    algorithmVersion: 'TEST_ONLY',
    generatedAt: '2026-01-01T00:00:00Z',
    capturedAtUtcMs: capturedAt ?? fixtures.captured,
  );
}

class CountingSource implements DiscoverySnapshotSource {
  int calls = 0;
  @override
  Future<RouteSnapshot> discover(DiscoveryQuery query) async {
    calls++;
    return syntheticSnapshot();
  }
}

const searchKey = ValueKey('poi-local-search');
const resultsKey = ValueKey('poi-results-scroll');
const captureKey = ValueKey('ui2-renderer-boundary');

Future<void> capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('UI2_CAPTURE')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(captureKey),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final file = File(
      '../docs/11-Master-Documentation/11-Implementation-Plan/UI-2-Visual-Evidence/FLUTTER_RENDERER_TEST-$name.png',
    );
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
  });
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    // Measure geometry with the SDK's real fonts, rather than Ahem blocks.
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    for (final (family, path) in [
      ('Roboto', '$sdk/bin/cache/artifacts/material_fonts/roboto-regular.ttf'),
      (
        'MaterialIcons',
        '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      ),
    ]) {
      final loader = FontLoader(family)
        ..addFont(
          Future.value(ByteData.sublistView(await File(path).readAsBytes())),
        );
      await loader.load();
    }
  });
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => Directory.systemTemp.path,
        );
  });

  Future<void> openList(WidgetTester tester) async {
    if (find
        .byKey(const ValueKey('discovery-list-panel'))
        .evaluate()
        .isNotEmpty) {
      return;
    }
    await tester.ensureVisible(find.text('Ver lista'));
    await tester.tap(find.text('Ver lista'));
    await tester.pumpAndSettle();
  }

  Future<void> pump(
    WidgetTester tester,
    OfflineDiscovery offline, {
    FakeSession? session,
  }) async {
    await tester.pumpWidget(
      RepaintBoundary(
        key: captureKey,
        child: GeoGuideApp(
          routeSession: session ?? FakeSession(),
          offlineDiscovery: offline,
          locationClock: () =>
              DateTime.fromMillisecondsSinceEpoch(offline.now()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'filter has zero source calls; map/list share IDs; preview/detail preserve query and context',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final snapshot = syntheticSnapshot();
      final source = CountingSource();
      final session = FakeSession();
      final offline = OfflineDiscovery(
        source: source,
        store: MemoryStore()..value = snapshot,
        backendContext: snapshot.query.backendContext,
        now: () => fixtures.captured,
      );
      await pump(tester, offline, session: session);
      final map = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!;
      final center = map.camera.center;
      final zoom = map.camera.zoom;
      expect(find.byTooltip('Vista previa de Museo Ámbar'), findsOneWidget);
      await capture(tester, 'map-route-360x800');
      await tester.tap(find.byTooltip('Vista previa de Museo Ámbar'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<PoiPreviewSheet>(find.byType(PoiPreviewSheet)).poi.id,
        'synthetic-1',
      );
      await tester.ensureVisible(find.text('Cerrar'));
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();
      await openList(tester);
      await tester.enterText(find.byKey(searchKey), '  MUSEO  AMBAR ');
      await tester.pumpAndSettle();
      expect(source.calls, 0);
      expect(offline.snapshot, same(snapshot));
      expect(find.byTooltip('Vista previa de Mirador Ñandú'), findsNothing);
      expect(
        find.byKey(const ValueKey('discovery-list-synthetic-2')),
        findsNothing,
      );
      await capture(tester, 'local-filter-match-360x800');
      await tester.ensureVisible(
        find.byKey(const ValueKey('discovery-list-synthetic-1')),
      );
      await tester.tap(find.text('Museo Ámbar'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<PoiPreviewSheet>(find.byType(PoiPreviewSheet)).poi.id,
        'synthetic-1',
      );
      expect(session.lastChosen, isEmpty);
      await capture(tester, 'preview-360x800');
      await tester.ensureVisible(find.text('Ver detalle'));
      await tester.tap(find.text('Ver detalle'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<PoiDetailSheet>(find.byType(PoiDetailSheet)).poi.id,
        'synthetic-1',
      );
      await capture(tester, 'detail-360x800');
      await tester.ensureVisible(find.text('Volver'));
      await tester.tap(find.text('Volver'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byKey(searchKey)).controller!.text,
        '  MUSEO  AMBAR ',
      );
      expect(offline.snapshot, same(snapshot));
      expect(snapshot.query.categories, ['MUSEUM']);
      expect(map.camera.center, center);
      expect(map.camera.zoom, zoom);
      expect(session.lastChosen, isEmpty);
      await tester.ensureVisible(find.byKey(searchKey));
      await tester.enterText(find.byKey(searchKey), 'localidad inexistente');
      await tester.pumpAndSettle();
      expect(
        find.text('No hay coincidencias en estos resultados'),
        findsOneWidget,
      );
      expect(find.byTooltip('Vista previa de Museo Ámbar'), findsNothing);
      expect(source.calls, 0);
      await capture(tester, 'local-filter-empty-360x800');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'replacement and expiry clear query; Driving never retains or queues search',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var now = fixtures.captured;
      final source = CountingSource();
      final offline = OfflineDiscovery(
        source: source,
        store: MemoryStore()..value = syntheticSnapshot(),
        backendContext: 'https://example.test',
        now: () => now,
      );
      await pump(tester, offline);
      await openList(tester);
      await tester.enterText(find.byKey(searchKey), 'ámbar');
      offline.snapshot = syntheticSnapshot();
      offline.onChanged?.call();
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byKey(searchKey)).controller!.text,
        isEmpty,
      );
      await tester.enterText(find.byKey(searchKey), 'museo');
      final staleEdit = tester
          .widget<TextField>(find.byKey(searchKey))
          .onChanged!;
      await tester.tap(find.byKey(const ValueKey('close-discovery-list')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Entrar en modo conducción'));
      await tester.tap(find.text('Entrar en modo conducción'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsNothing);
      expect(find.byType(PoiThumbnail), findsNothing);
      await tester.tap(find.text('Salir de modo conducción'));
      await tester.pumpAndSettle();
      await openList(tester);
      staleEdit('deferred forbidden edit');
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byKey(searchKey)).controller!.text,
        isEmpty,
      );
      expect(
        find.byKey(const ValueKey('discovery-list-synthetic-2')),
        findsOneWidget,
      );
      await tester.enterText(find.byKey(searchKey), 'ámbar');
      now += RouteSnapshot.ttlMs;
      await offline.revalidate();
      await tester.pumpAndSettle();
      expect(find.byKey(searchKey), findsNothing);
      expect(find.byTooltip('Vista previa de Museo Ámbar'), findsNothing);
      offline.snapshot = syntheticSnapshot(capturedAt: now);
      offline.onChanged?.call();
      await tester.pumpAndSettle();
      await openList(tester);
      expect(
        tester.widget<TextField>(find.byKey(searchKey)).controller!.text,
        isEmpty,
      );
      expect(source.calls, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'choosing new map endpoints hides previous filtered POIs without mutating the snapshot',
    (tester) async {
      final snapshot = syntheticSnapshot();
      final source = CountingSource();
      final offline = OfflineDiscovery(
        source: source,
        store: MemoryStore()..value = snapshot,
        backendContext: snapshot.query.backendContext,
        now: () => fixtures.captured,
      );
      await pump(tester, offline);
      await openList(tester);
      await tester.enterText(find.byKey(searchKey), 'ámbar');
      await tester.tap(find.byKey(const ValueKey('close-discovery-list')));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Vista previa de Museo Ámbar'), findsOneWidget);
      await tester.tapAt(
        tester.getTopLeft(find.byType(FlutterMap)) + const Offset(30, 30),
      );
      // flutter_map defers a single tap until the double-tap window closes.
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Vista previa de Museo Ámbar'), findsNothing);
      expect(find.byTooltip('Vista previa de Mirador Ñandú'), findsNothing);
      expect(find.byKey(searchKey), findsNothing);
      expect(offline.snapshot, same(snapshot));
      expect(source.calls, 0);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'editing at the online TTL boundary clears results without a new source call',
    (tester) async {
      var now = fixtures.captured;
      final source = CountingSource();
      final snapshot = syntheticSnapshot();
      final offline = OfflineDiscovery(
        source: source,
        store: MemoryStore()..value = snapshot,
        backendContext: snapshot.query.backendContext,
        now: () => now,
      );
      await pump(tester, offline);
      await offline.discover(snapshot.query);
      await tester.pumpAndSettle();
      expect(offline.availability, DiscoveryAvailability.online);
      final onlineSnapshot = offline.snapshot;
      expect(source.calls, 1);
      await openList(tester);
      await tester.enterText(find.byKey(searchKey), 'ámbar');
      now += RouteSnapshot.ttlMs;
      // The edit arrives before the scheduled expiration callback is pumped.
      await tester.enterText(find.byKey(searchKey), 'stale');
      await tester.pumpAndSettle();
      expect(find.byKey(searchKey), findsNothing);
      expect(find.byTooltip('Vista previa de Museo Ámbar'), findsNothing);
      expect(
        offline.snapshot,
        same(onlineSnapshot),
      ); // P9 online state is untouched.
      expect(
        find.text(
          'Resultados no disponibles. Reintenta para consultar datos nuevos.',
        ),
        findsOneWidget,
      );
      expect(source.calls, 1);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'renderer fixtures distinguish offline and error with existing messages',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final snapshot = syntheticSnapshot();
      final offline = OfflineDiscovery(
        source: CountingSource(),
        store: MemoryStore()..value = snapshot,
        backendContext: snapshot.query.backendContext,
        now: () => fixtures.captured,
      );
      await pump(tester, offline);
      await tester.ensureVisible(
        find.text('Copia offline · vigencia máxima 24 horas'),
      );
      await tester.pumpAndSettle();
      await capture(tester, 'offline-360x800');
      // Explicit synthetic presentation fixture; not a real server outage.
      offline.availability = DiscoveryAvailability.error;
      offline.message = 'Error: no se pudieron validar los datos recibidos';
      offline.onChanged?.call();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Error de actualización'));
      await tester.pumpAndSettle();
      expect(find.text('Reintentar'), findsOneWidget);
      await capture(tester, 'error-360x800');
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final keyboardSize in const [Size(360, 640), Size(640, 360)]) {
    testWidgets(
      'keyboard $keyboardSize keeps editing and dismissal reachable; query does not persist after disposal',
      (tester) async {
        tester.view.physicalSize = keyboardSize;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetViewInsets);
        final snapshot = syntheticSnapshot();
        final store = MemoryStore()..value = snapshot;
        OfflineDiscovery session() => OfflineDiscovery(
          source: CountingSource(),
          store: store,
          backendContext: snapshot.query.backendContext,
          now: () => fixtures.captured,
        );
        await pump(tester, session());
        await openList(tester);
        tester.view.viewInsets = const FakeViewPadding(bottom: 180);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final mapRect = tester.getRect(find.byType(FlutterMap));
        final panelRect = tester.getRect(
          find.byKey(const ValueKey('discovery-list-panel')),
        );
        expect(mapRect.overlaps(panelRect), isFalse);
        expect(
          find.byKey(const ValueKey('close-discovery-list')).hitTestable(),
          findsOneWidget,
        );
        await tester.ensureVisible(find.byKey(searchKey));
        await tester.enterText(find.byKey(searchKey), 'ámbar');
        await tester.testTextInput.receiveAction(TextInputAction.search);
        tester.view.resetViewInsets();
        await tester.pumpAndSettle();
        await tester.pumpWidget(const SizedBox());
        await pump(tester, session());
        await openList(tester);
        expect(
          tester.widget<TextField>(find.byKey(searchKey)).controller!.text,
          isEmpty,
        );
        expect(store.value, same(snapshot));
        await tester.pumpWidget(const SizedBox());
      },
    );
  }

  for (final size in const [
    Size(360, 640),
    Size(360, 800),
    Size(640, 360),
    Size(800, 360),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'list preview detail long fields ${size.width}x${size.height} text $scale',
        (tester) async {
          final semantics = tester.ensureSemantics();
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final snapshot = syntheticSnapshot(long: true);
          final offline = OfflineDiscovery(
            source: CountingSource(),
            store: MemoryStore()..value = snapshot,
            backendContext: snapshot.query.backendContext,
            now: () => fixtures.captured,
          );
          await pump(tester, offline);
          expect(find.byType(PolylineLayer), findsOneWidget);
          if (scale == 1 && size.width == 360) {
            await capture(
              tester,
              'comparison-after-map-360x${size.height.toInt()}',
            );
          }
          await openList(tester);
          if (scale == 1 && size.width == 360) {
            await capture(
              tester,
              'comparison-after-list-360x${size.height.toInt()}',
            );
          }
          final mapRect = tester.getRect(find.byType(FlutterMap));
          final panelRect = tester.getRect(
            find.byKey(const ValueKey('discovery-list-panel')),
          );
          final bodyRect = tester.getRect(
            find.byKey(const ValueKey('exploration-body')),
          );
          expect(
            panelRect.width *
                panelRect.height /
                (bodyRect.width * bodyRect.height),
            lessThan(.56),
          );
          expect(mapRect.overlaps(panelRect), isFalse);
          final camera = tester
              .widget<FlutterMap>(find.byType(FlutterMap))
              .mapController!
              .camera;
          for (final point in snapshot.route.geometry) {
            final offset = camera.latLngToScreenOffset(
              LatLng(point.latitude, point.longitude),
            );
            expect(
              Rect.fromLTWH(
                0,
                0,
                mapRect.width,
                mapRect.height,
              ).contains(offset),
              isTrue,
              reason: 'Fixture route geometry must remain inside the unoccluded map',
            );
          }
          expect(
            tester.getSize(find.byKey(const ValueKey('close-discovery-list'))),
            const Size(48, 48),
          );
          final list = find.byKey(resultsKey);
          await tester.scrollUntilVisible(
            find.text(snapshot.pois.first.name),
            100,
            scrollable: find.descendant(
              of: list,
              matching: find.byWidgetPredicate(
                (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          await capture(
            tester,
            'list-${size.width.toInt()}x${size.height.toInt()}-text$scale',
          );
          final visibleName = tester
              .getRect(find.text(snapshot.pois.first.name))
              .intersect(tester.getRect(list));
          expect(visibleName.height, greaterThan(0));
          await tester.tapAt(visibleName.center);
          await tester.pumpAndSettle();
          expect(find.byType(PoiPreviewSheet), findsOneWidget);
          expect(
            find.bySemanticsLabel(RegExp('Imagen no disponible')),
            findsWidgets,
          );
          await tester.ensureVisible(find.text('Ver detalle'));
          await tester.tap(find.text('Ver detalle'));
          await tester.pumpAndSettle();
          expect(find.byType(PoiDetailSheet), findsOneWidget);
          await tester.ensureVisible(find.text('Volver'));
          expect(find.text('Volver').hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Volver'));
          await tester.pumpAndSettle();
          await tester.tap(find.byKey(const ValueKey('close-discovery-list')));
          await tester.pumpAndSettle();
          expect(offline.snapshot, same(snapshot));
          await tester.pumpWidget(const SizedBox());
          semantics.dispose();
        },
      );
    }
  }
}
