import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';

class StreamRepository implements LocationRepository, LocationStreamSource {
  final controller = StreamController<LocationSample>.broadcast();
  @override
  Future<CurrentLocationResult> requestCurrentLocation() async =>
      const CurrentLocationResult.available(
        LocationPoint(latitude: -12, longitude: -77),
      );
  @override
  Stream<LocationSample> watchLocation() => controller.stream;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cache = Directory.systemTemp.createTempSync(
    'geoguide-camera-regression-',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async => cache.path,
      );
  // These foreground tests explicitly model a resolved, inactive native owner.
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('geoguide/route_session'),
        (call) async => false,
      );

  testWidgets(
    'camera course zoom gesture pause and explicit resume use real map controller',
    (tester) async {
      final source = StreamRepository();
      await tester.pumpWidget(GeoGuideApp(locationRepository: source));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Activar seguimiento de ubicación'));
      await tester.pumpAndSettle();
      MapController camera() =>
          tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;
      void emit(double longitude, {DateTime? timestamp}) =>
          source.controller.add(
            LocationSample(
              position: LocationPoint(latitude: -12, longitude: longitude),
              timestamp: timestamp ?? DateTime.now(),
              accuracyMeters: 2,
              headingDegrees: 90,
              headingAccuracyDegrees: 2,
              speedMetersPerSecond: 20,
              speedAccuracyMetersPerSecond: 1,
            ),
          );
      emit(-78, timestamp: DateTime.now().add(const Duration(hours: 1)));
      await tester.pump();
      expect(camera().camera.center.longitude, closeTo(-77, .000001));
      emit(-77.001);
      await tester.pump();
      expect(camera().camera.rotation, closeTo(337.5, .001));
      expect(camera().camera.zoom, closeTo(14.8, .001));
      expect(camera().camera.center.longitude, closeTo(-77.001, .000001));
      await tester.drag(find.byType(FlutterMap), const Offset(80, 0));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Reanudar seguimiento de cámara'), findsOneWidget);
      final pausedCenter = camera().camera.center;
      final pausedRotation = camera().camera.rotation;
      emit(-77.002);
      await tester.pump();
      expect(camera().camera.center, pausedCenter);
      expect(camera().camera.rotation, pausedRotation);
      await tester.tap(find.byTooltip('Reanudar seguimiento de cámara'));
      await tester.pump();
      emit(-77.003);
      await tester.pump();
      expect(camera().camera.center.longitude, closeTo(-77.003, .000001));
      expect(find.byTooltip('Reanudar seguimiento de cámara'), findsNothing);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      final backgroundCenter = camera().camera.center;
      emit(-77.004);
      await tester.pump();
      expect(camera().camera.center, backgroundCenter);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pumpAndSettle();
      expect(source.controller.hasListener, isTrue);
      emit(-77.005);
      await tester.pump();
      await tester.pump();
      expect(camera().camera.center.longitude, closeTo(-77.005, .000001));
      await tester.tap(find.byTooltip('Detener seguimiento de ubicación'));
      await tester.pump();
      final stopped = camera().camera.center;
      emit(-77.004);
      await tester.pump();
      expect(camera().camera.center, stopped);
      await tester.pumpWidget(const SizedBox());
      await source.controller.close();
    },
  );
}
