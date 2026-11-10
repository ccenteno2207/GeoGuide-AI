import 'dart:io';
import 'dart:typed_data';

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
        contains(
          '<monochrome android:drawable="@drawable/ic_launcher_monochrome"',
        ),
      );
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
