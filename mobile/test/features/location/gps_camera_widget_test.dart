import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';
import 'package:geoguide_ai/features/map/presentation/rutea_location_marker.dart';

class StreamRepository implements LocationRepository, LocationStreamSource {
  StreamRepository({this.result, this.pendingRequest});

  final controller = StreamController<LocationSample>.broadcast();
  final CurrentLocationResult? result;
  final Future<CurrentLocationResult> Function(bool requestPermission)?
  pendingRequest;
  final permissionRequests = <bool>[];
  int watchCalls = 0;

  @override
  Future<CurrentLocationResult> requestCurrentLocation({
    bool requestPermission = true,
  }) {
    permissionRequests.add(requestPermission);
    final pending = pendingRequest;
    if (pending != null) return pending(requestPermission);
    return Future.value(
      result ??
          const CurrentLocationResult.available(
            LocationPoint(latitude: -12, longitude: -77),
          ),
    );
  }

  @override
  Stream<LocationSample> watchLocation() {
    watchCalls++;
    return controller.stream;
  }
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
    'startup uses one permitted point fix and centers without subscribing to tracking',
    (tester) async {
      final source = StreamRepository(
        result: CurrentLocationResult.available(
          const LocationPoint(latitude: -11.47, longitude: -76.62),
          accuracyMeters: 8,
          timestamp: DateTime.now(),
        ),
      );
      await tester.pumpWidget(GeoGuideApp(locationRepository: source));
      await tester.pumpAndSettle();

      MapController camera() =>
          tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;
      expect(source.permissionRequests, [false]);
      expect(source.watchCalls, 0);
      expect(camera().camera.center.latitude, closeTo(-11.47, .00001));
      expect(camera().camera.center.longitude, closeTo(-76.62, .00001));
      expect(find.byType(RuteaLocationMarker), findsOneWidget);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(source.permissionRequests, [false]);
      expect(source.watchCalls, 0);
      await tester.pumpWidget(const SizedBox());
      await source.controller.close();
    },
  );

  testWidgets('denied or unavailable startup GPS preserves initial map', (
    tester,
  ) async {
    for (final availability in [
      LocationAvailability.denied,
      LocationAvailability.unavailable,
    ]) {
      final source = StreamRepository(
        result: CurrentLocationResult.withAvailability(availability),
      );
      await tester.pumpWidget(GeoGuideApp(locationRepository: source));
      await tester.pumpAndSettle();
      final camera = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .mapController!;
      expect(source.permissionRequests, [false]);
      expect(source.watchCalls, 0);
      expect(camera.camera.center.latitude, closeTo(-12.0464, .00001));
      expect(camera.camera.center.longitude, closeTo(-77.0428, .00001));
      expect(find.byType(RuteaLocationMarker), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await source.controller.close();
    }
  });

  testWidgets('user map gesture wins over a late initial GPS response', (
    tester,
  ) async {
    final response = Completer<CurrentLocationResult>();
    final source = StreamRepository(pendingRequest: (_) => response.future);
    await tester.pumpWidget(GeoGuideApp(locationRepository: source));
    await tester.pump();
    expect(source.permissionRequests, [false]);

    await tester.drag(find.byType(FlutterMap), const Offset(90, 30));
    await tester.pumpAndSettle();
    final camera = tester
        .widget<FlutterMap>(find.byType(FlutterMap))
        .mapController!;
    final userCenter = camera.camera.center;
    response.complete(
      CurrentLocationResult.available(
        const LocationPoint(latitude: -11.47, longitude: -76.62),
        accuracyMeters: 5,
        timestamp: DateTime.now(),
      ),
    );
    await tester.pumpAndSettle();
    expect(camera.camera.center, userCenter);
    expect(source.watchCalls, 0);
    await tester.pumpWidget(const SizedBox());
    await source.controller.close();
  });

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
