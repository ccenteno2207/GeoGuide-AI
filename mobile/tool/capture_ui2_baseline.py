"""Render the frozen baseline for UI2-AC-01 without changing any checkout.

Exports only mobile/ into a new ignored build directory. Retains the export for
inspection. Uses the current synthetic fixture verbatim and the SDK cache fonts.
"""

import hashlib
import io
from pathlib import Path
import shutil
import subprocess
import tempfile
import zipfile

BASELINE = "597950decddecef38dd4f6c44595b807a4087f14"


def main():
    mobile = Path(__file__).resolve().parent.parent
    root = mobile.parent
    build = (mobile / "build").resolve()
    build.mkdir(exist_ok=True)
    exported = Path(tempfile.mkdtemp(prefix="ui2-baseline-", dir=build)).resolve()
    assert exported.is_relative_to(build)
    archive = subprocess.check_output(
        ["git", "archive", "--format=zip", BASELINE, "mobile"], cwd=root
    )
    with zipfile.ZipFile(io.BytesIO(archive)) as zipped:
        for entry in zipped.namelist():
            assert (exported / entry).resolve().is_relative_to(exported)
        zipped.extractall(exported)
    project = exported / "mobile"
    current_test = (mobile / "test/features/discovery/ui2_experience_test.dart").read_text(encoding="utf-8")
    fixture = current_test[current_test.index("RouteSnapshot syntheticSnapshot("):current_test.index("class CountingSource")]
    print("BASELINE", BASELINE, flush=True)
    print("FIXTURE_FUNCTION_SHA256", hashlib.sha256(fixture.encode()).hexdigest(), flush=True)
    harness = r'''
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/discovery/application/offline_discovery.dart';
import 'package:geoguide_ai/features/discovery/domain/discovery_poi.dart';
import 'package:geoguide_ai/features/discovery/domain/route_snapshot.dart';
import 'package:geoguide_ai/features/route_planning/domain/planned_route.dart';
import 'package:geoguide_ai/features/route_planning/domain/route_point.dart';
import 'features/tracking/b1_widget_test.dart' show FakeSession;
import 'features/discovery/offline_cache_test.dart' as fixtures;
import 'features/discovery/offline_ui_test.dart' show MemoryStore;
FIXTURE
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'), (call) async => Directory.systemTemp.path);
  });
  setUpAll(() async {
    final sdk = Platform.environment['FLUTTER_ROOT']!;
    for (final (family, file) in [('Roboto', 'roboto-regular.ttf'), ('MaterialIcons', 'materialicons-regular.otf')]) {
      final loader = FontLoader(family)..addFont(Future.value(ByteData.sublistView(
        await File('$sdk/bin/cache/artifacts/material_fonts/$file').readAsBytes())));
      await loader.load();
    }
  });
  for (final size in const [Size(360, 640), Size(360, 800)]) {
    testWidgets('baseline map/list $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final snapshot = syntheticSnapshot(long: true);
      final offline = OfflineDiscovery(source: fixtures.Source(), store: MemoryStore()..value = snapshot,
        backendContext: snapshot.query.backendContext, now: () => fixtures.captured);
      const key = ValueKey('baseline-renderer');
      await tester.pumpWidget(RepaintBoundary(key: key, child: GeoGuideApp(
        routeSession: FakeSession(), offlineDiscovery: offline,
        locationClock: () => DateTime.fromMillisecondsSinceEpoch(fixtures.captured))));
      await tester.pumpAndSettle();
      Future<void> capture(String state) async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          image.dispose();
          final output = const String.fromEnvironment('UI2_OUTPUT');
          await File('$output/FLUTTER_RENDERER_TEST-comparison-before-$state-${size.width.toInt()}x${size.height.toInt()}.png')
              .writeAsBytes(bytes!.buffer.asUint8List());
        });
        await tester.pump();
      }
      await capture('map');
      await tester.ensureVisible(find.text('Ver lista'));
      await tester.tap(find.text('Ver lista'));
      await tester.pumpAndSettle();
      await capture('list');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}
'''.replace("FIXTURE", fixture)
    (project / "test/ui2_baseline_capture_test.dart").write_text(harness, encoding="utf-8")
    original_lock = (project / "pubspec.lock").read_bytes()
    flutter = shutil.which("flutter")
    subprocess.run([flutter, "pub", "get"], cwd=project, check=True)
    assert (project / "pubspec.lock").read_bytes() == original_lock
    output = root / "docs/11-Master-Documentation/11-Implementation-Plan/UI-2-Visual-Evidence"
    subprocess.run([flutter, "test", "--no-pub", "test/ui2_baseline_capture_test.dart",
                    f"--dart-define=UI2_OUTPUT={output.as_posix()}", "--reporter", "expanded"], cwd=project, check=True)
    print("PASS: baseline captured without modifying a checkout; lockfile unchanged", flush=True)


if __name__ == "__main__":
    main()
