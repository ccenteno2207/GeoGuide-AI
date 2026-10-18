import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';

import '../discovery/offline_cache_test.dart' as fixtures;
import '../discovery/offline_ui_test.dart' show MemoryStore;
import '../discovery/ui2_experience_test.dart'
    show CountingSource, syntheticSnapshot;
import '../tracking/b1_widget_test.dart' show FakeSession;

const _boundary = ValueKey('ui231-renderer');
const _attribution = '© OpenStreetMap contributors';

Future<void> _capture(WidgetTester tester, String name) async {
  const label = String.fromEnvironment('UI231_CAPTURE_LABEL');
  if (label.isEmpty) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundary),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 1);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final directory = Directory(
      '../docs/11-Master-Documentation/11-Implementation-Plan/UI-2.3.1-Renderer-Evidence',
    );
    await directory.create(recursive: true);
    await File('${directory.path}/FLUTTER_RENDERER_TEST_UI231-$label-$name.png')
        .writeAsBytes(data!.buffer.asUint8List());
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => Directory.systemTemp.path,
        );
  });
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    for (final (family, path) in [
      ('Roboto', '$sdk/bin/cache/artifacts/material_fonts/roboto-regular.ttf'),
      (
        'MaterialIcons',
        '$sdk/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
      ),
    ]) {
      await (FontLoader(family)..addFont(
            Future.value(ByteData.sublistView(await File(path).readAsBytes())),
          ))
          .load();
    }
  });
  for (final size in const [
    Size(360, 640),
    Size(360, 800),
    Size(640, 360),
    Size(800, 360),
  ]) {
    for (final scale in [1.0, 2.0]) {
      // No bottom reservation, gesture-style inset, larger three-button-style inset.
      for (final bottom in [0.0, 24.0, 48.0]) {
        testWidgets('system insets $size text $scale bottom $bottom', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          final side = size.width > size.height ? 24.0 : 0.0;
          tester.view.devicePixelRatio = 1;
          tester.view.physicalSize = size;
          tester.view.viewPadding = FakeViewPadding(
            top: 24,
            bottom: bottom,
            left: side,
            right: side,
          );
          tester.view.padding = FakeViewPadding(
            top: 24,
            bottom: bottom,
            left: side,
            right: side,
          );
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.view.reset);
          addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
          final snapshot = syntheticSnapshot();
          final offline = OfflineDiscovery(
            source: CountingSource(),
            store: MemoryStore()..value = snapshot,
            backendContext: snapshot.query.backendContext,
            now: () => fixtures.captured,
          );
          await tester.pumpWidget(
            RepaintBoundary(
              key: _boundary,
              child: GeoGuideApp(
                routeSession: FakeSession(),
                offlineDiscovery: offline,
              ),
            ),
          );
          await tester.pumpAndSettle();
          if (scale == 1 &&
              ((size == const Size(360, 800) && bottom == 48) ||
                  (size == const Size(800, 360) && bottom == 24))) {
            await _capture(
              tester,
              '${size.width.toInt()}x${size.height.toInt()}-bottom${bottom.toInt()}',
            );
          }
          final safeBottom = size.height - bottom;
          final attribution = tester.getRect(find.text(_attribution));
          expect(
            attribution.bottom,
            lessThanOrEqualTo(safeBottom),
            reason: 'Attribution must avoid system navigation',
          );
          expect(attribution.left, greaterThanOrEqualTo(side));
          expect(attribution.right, lessThanOrEqualTo(size.width - side));
          expect(find.bySemanticsLabel(_attribution), findsOneWidget);
          final panel = tester.getRect(
            find.byKey(const ValueKey('exploration-status-scroll')),
          );
          expect(
            panel.bottom,
            lessThanOrEqualTo(attribution.top),
            reason: 'Panel viewport and attribution must not overlap',
          );
          expect(panel.left, greaterThanOrEqualTo(side));
          expect(panel.right, lessThanOrEqualTo(size.width - side));
          if (size == const Size(360, 800) && scale == 1) {
            final card = tester.getRect(
              find.byKey(const ValueKey('exploration-status')),
            );
            expect(
              card.intersect(panel).height,
              closeTo(card.height, .01),
              reason: 'Normal route card must remain fully visible after reserving insets',
            );
          }
          expect(find.byType(PolylineLayer), findsOneWidget);
          expect(find.byTooltip('Vista previa de Museo Ámbar'), findsOneWidget);
          expect(
            tester
                .getRect(find.byType(FlutterMap))
                .overlaps(
                  tester.getRect(find.byTooltip('Vista previa de Museo Ámbar')),
                ),
            isTrue,
          );
          for (final label in [
            'Calcular ruta',
            'Categorías',
            'Ver lista',
            'Conducción',
          ]) {
            final action = find.text(label);
            await tester.ensureVisible(action);
            await tester.pumpAndSettle();
            expect(action.hitTestable(), findsOneWidget, reason: label);
            final rect = tester.getRect(action);
            expect(rect.bottom, lessThanOrEqualTo(safeBottom));
          }
          await tester.ensureVisible(find.text('Ver lista'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Ver lista'));
          await tester.pumpAndSettle();
          final list = tester.getRect(
            find.byKey(const ValueKey('discovery-list-panel')),
          );
          final map = tester.getRect(find.byType(FlutterMap));
          expect(list.bottom, lessThanOrEqualTo(safeBottom));
          expect(map.overlaps(list), isFalse);
          final camera = tester
              .widget<FlutterMap>(find.byType(FlutterMap))
              .mapController!
              .camera;
          for (final point in snapshot.route.geometry) {
            expect(
              (Offset.zero & map.size).contains(
                camera.latLngToScreenOffset(
                  LatLng(point.latitude, point.longitude),
                ),
              ),
              isTrue,
              reason: 'Route remains inside the map after list and insets reserve space',
            );
          }
          expect(
            list.overlaps(tester.getRect(find.text(_attribution))),
            isFalse,
          );
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          semantics.dispose();
        });
      }
    }
  }
}
