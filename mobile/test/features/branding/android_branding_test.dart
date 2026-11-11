import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'Android launcher exposes Rutea without changing application identity',
    () {
      final manifest = File('android/app/src/main/AndroidManifest.xml')
          .readAsStringSync();
      final strings = File('android/app/src/main/res/values/strings.xml')
          .readAsStringSync();
      final gradle = File('android/app/build.gradle.kts').readAsStringSync();

      expect(manifest, contains('android:label="@string/app_name"'));
      expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
      expect(strings, contains('<string name="app_name">Rutea</string>'));
      expect(gradle, contains('applicationId = "com.geoguideai.geoguide_ai"'));
      expect(File('assets/branding/rutea_launcher.svg').existsSync(), isTrue);
      expect(
        File('assets/branding/rutea_location_marker.svg').existsSync(),
        isTrue,
      );
      expect(
        File('android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml')
            .readAsStringSync(),
        contains('@drawable/ic_launcher_foreground'),
      );
      expect(
        File('android/app/src/main/res/mipmap-anydpi-v33/ic_launcher.xml')
            .readAsStringSync(),
        contains('@drawable/ic_launcher_foreground'),
      );
    },
  );

  test('adaptive launcher follows the approved gradient icon artwork', () {
    final adaptiveV26 = File(
      'android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml',
    ).readAsStringSync();
    final adaptiveV33 = File(
      'android/app/src/main/res/mipmap-anydpi-v33/ic_launcher.xml',
    ).readAsStringSync();
    final background = File(
      'android/app/src/main/res/drawable/ic_launcher_background.xml',
    ).readAsStringSync();
    final master = File('assets/branding/rutea_launcher.svg')
        .readAsStringSync();
    final foreground = File(
      'android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png',
    );

    expect(adaptiveV26, contains('@drawable/ic_launcher_background'));
    expect(adaptiveV33, contains('@drawable/ic_launcher_background'));
    expect(background, contains('android:type="linear"'));
    expect(background, contains('android:angle="270"'));
    expect(background, contains('android:startColor="#27A9D8"'));
    expect(background, contains('android:endColor="#39BCA5"'));
    expect(adaptiveV33, isNot(contains('<monochrome')));
    expect(master, contains('<image'));
    expect(master, contains('data:image/png;base64,'));
    expect(master, isNot(contains('<text')));
    expect(foreground.existsSync(), isTrue);
    final bytes = foreground.readAsBytesSync();
    expect(bytes.sublist(0, 8), <int>[137, 80, 78, 71, 13, 10, 26, 10]);
    final dimensions = ByteData.sublistView(bytes);
    expect(dimensions.getUint32(16), 432);
    expect(dimensions.getUint32(20), 432);
  });

  test(
    'adaptive launcher artwork has a transparent edge safety margin',
    () async {
      final bytes = File(
        'android/app/src/main/res/drawable-xxxhdpi/ic_launcher_foreground.png',
      ).readAsBytesSync();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final pixels = (await frame.image.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      ))!;

      expect(frame.image.width, 432);
      expect(frame.image.height, 432);
      for (var y = 0; y < 432; y++) {
        for (var x = 0; x < 432; x++) {
          if (x >= 48 && x < 384 && y >= 48 && y < 384) continue;
          expect(pixels.getUint8((y * 432 + x) * 4 + 3), 0);
        }
      }
      frame.image.dispose();
      codec.dispose();
    },
  );

  test('legacy launcher PNGs match Android density dimensions', () {
    const densities = <String, int>{
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };
    for (final entry in densities.entries) {
      final file = File(
        'android/app/src/main/res/mipmap-${entry.key}/ic_launcher.png',
      );
      final bytes = file.readAsBytesSync();
      expect(bytes.sublist(0, 8), <int>[137, 80, 78, 71, 13, 10, 26, 10]);
      final data = ByteData.sublistView(bytes);
      expect(data.getUint32(16), entry.value, reason: entry.key);
      expect(data.getUint32(20), entry.value, reason: entry.key);
    }
  });
}
