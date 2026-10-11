import 'dart:io';

import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/main.dart' as entrypoint;

void main() {
  // This file runs in its own flutter_tester process. Do not initialize a test
  // binding: the production entrypoint must initialize its own channel owner.
  if (BindingBase.debugBindingType() != null) {
    throw StateError(
      'Startup regression requires a fresh uninitialized binding',
    );
  }
  // Isolate native map-cache setup without initializing a Flutter binding.
  final cache = Directory.systemTemp.createTempSync('geoguide-startup-test-');
  final provider = BuiltInMapCachingProvider.getOrCreateInstance(
    cacheDirectory: cache.path,
  );
  entrypoint.main();
  // Startup construction has completed. Replace the root before retaining a
  // map UI: this regression checks entrypoint ordering, not native plugins.
  runApp(const SizedBox.shrink());
  tearDownAll(() async {
    await provider.destroy();
    if (await cache.exists()) await cache.delete(recursive: true);
  });
  test('real entrypoint initializes binding before constructing channels', () {
    expect(BindingBase.debugBindingType(), WidgetsFlutterBinding);
  });
}
