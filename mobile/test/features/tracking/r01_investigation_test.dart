import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/app/app.dart';
import 'package:geoguide_ai/features/location/application/gps_camera_policy.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';
import 'package:geoguide_ai/features/tracking/infrastructure/android_route_session.dart';
import 'package:geoguide_ai/features/tracking/application/route_session_client.dart';

import '../location/gps_camera_widget_test.dart' as gps;
import 'b1_widget_test.dart' as b1;
import '../discovery/offline_cache_test.dart' as fixtures;

class CancellationGateRepository
    implements LocationRepository, LocationStreamSource {
  final gate = Completer<void>();
  late final controller = StreamController<LocationSample>(
    onCancel: () => gate.future,
  );
  int requests = 0;
  @override
  Future<CurrentLocationResult> requestCurrentLocation() async {
    requests++;
    return const CurrentLocationResult.available(
      LocationPoint(latitude: -12, longitude: -77),
    );
  }

  @override
  Stream<LocationSample> watchLocation() => controller.stream;
}

// Acceptance regressions converted from the original defect characterization.
// All locations and platform responses are synthetic, never a device producer.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('geoguide/route_session');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final cache = Directory.systemTemp.createTempSync('geoguide-r01-map-');
  messenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => cache.path,
  );
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('fixed clock control rejects sample after freshness limit', () {
    final time = DateTime.utc(2026, 10, 11, 12);
    final sample = LocationSample(
      position: const LocationPoint(latitude: -12, longitude: -77),
      timestamp: time,
      accuracyMeters: 2,
    );
    final policy = GPSCameraPolicy();
    expect(
      policy.evaluate(sample, now: time, currentZoom: 15, currentRotation: 0),
      isNotNull,
    );
    expect(
      policy.evaluate(
        sample,
        now: time.add(const Duration(seconds: 11)),
        currentZoom: 15,
        currentRotation: 0,
      ),
      isNull,
    );
  });

  for (final routeOwned in [false, true]) {
    testWidgets(
      'silent stream expires and recovers with controlled clock route=$routeOwned',
      (tester) async {
        final source = gps.StreamRepository();
        final session = b1.FakeSession();
        var clock = DateTime.utc(2026, 10, 11, 12);
        await tester.pumpWidget(
          GeoGuideApp(
            locationRepository: source,
            routeSession: session,
            locationClock: () => clock,
          ),
        );
        await tester.pumpAndSettle();
        if (routeOwned) {
          session.active = true;
          session.onState?.call(RouteSessionStatus.active);
          await tester.pump();
        } else {
          await tester.tap(find.byTooltip('Activar seguimiento de ubicación'));
          await tester.pumpAndSettle();
        }
        final time = clock;
        final sample = LocationSample(
          position: const LocationPoint(latitude: -12, longitude: -77),
          timestamp: time,
          accuracyMeters: 2,
        );
        if (routeOwned) {
          session.onSample?.call(sample);
        } else {
          source.controller.add(sample);
        }
        await tester.pump();
        expect(find.text('Seguimiento de ubicación activo'), findsOneWidget);
        clock = clock.add(const Duration(seconds: 11));
        await tester.pump(const Duration(seconds: 11));
        expect(source.controller.hasListener, routeOwned ? isFalse : isTrue);
        expect(
          find.text('Sin actualización reciente de ubicación'),
          findsOneWidget,
        );
        expect(session.active, routeOwned);
        final fresh = LocationSample(
          position: sample.position,
          timestamp: clock,
          accuracyMeters: 2,
        );
        if (routeOwned) {
          session.onSample?.call(fresh);
        } else {
          source.controller.add(fresh);
        }
        await tester.pump();
        await tester.pump();
        expect(find.text('Seguimiento de ubicación activo'), findsOneWidget);
        await tester.pumpWidget(const SizedBox());
        await source.controller.close();
      },
    );
  }

  testWidgets(
    'pending refresh blocks both normal producers under native ownership',
    (tester) async {
      final reply = Completer<Object>();
      const nativeRouteOwned = true;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (call.method == 'active') return reply.future;
        if (call.method == 'voiceState') return false;
        throw MissingPluginException();
      });
      final session = AndroidRouteSession();
      final source = gps.StreamRepository();
      await tester.pumpWidget(
        GeoGuideApp(locationRepository: source, routeSession: session),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Activar seguimiento de ubicación'));
      await tester.pumpAndSettle();
      expect(nativeRouteOwned, isTrue);
      expect(source.controller.hasListener, isFalse);
      reply.complete({'active': true, 'starting': false});
      await tester.pumpAndSettle();
      expect(session.active, isTrue);
      expect(source.controller.hasListener, isFalse);
      await tester.pumpWidget(const SizedBox());
      await source.controller.close();
    },
  );

  test('late refresh cannot resurrect active state after stop', () async {
    final reply = Completer<Object>();
    final requested = Completer<void>();
    var nativeActive = true;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'active') {
        requested.complete();
        return reply.future;
      }
      if (call.method == 'voiceState') return false;
      if (call.method == 'stop') {
        nativeActive = false;
        return null;
      }
      throw MissingPluginException();
    });
    final session = AndroidRouteSession();
    final pending = session.refresh();
    await requested.future;
    await session.stop();
    expect(session.active, isFalse);
    reply.complete({'active': true, 'starting': false});
    await expectLater(pending, throwsStateError);
    expect(nativeActive, isFalse);
    expect(session.active, isFalse);
  });

  testWidgets('control resolved active state blocks normal location stream', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'active') return {'active': true, 'starting': false};
      if (call.method == 'voiceState') return false;
      throw MissingPluginException();
    });
    final source = gps.StreamRepository();
    await tester.pumpWidget(
      GeoGuideApp(
        locationRepository: source,
        routeSession: AndroidRouteSession(),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.byWidgetPredicate(
      (w) => w is IconButton && w.tooltip == 'Seguimiento normal no disponible: el recorrido GPS controla la ubicación',
    );
    expect(button, findsOneWidget);
    expect(tester.widget<IconButton>(button).onPressed, isNull);
    expect(source.controller.hasListener, isFalse);
    await tester.pumpWidget(const SizedBox());
    await source.controller.close();
  });
  test('late start completion cannot overwrite stop', () async {
    final reply = Completer<void>();
    final requested = Completer<void>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'start') {
        requested.complete();
        await reply.future;
        return null;
      }
      if (call.method == 'stop') return null;
      throw MissingPluginException();
    });
    final session = AndroidRouteSession();
    final pending = session.start(fixtures.snapshot());
    await requested.future;
    await session.stop();
    reply.complete();
    await pending;
    expect(session.active, isFalse);
    expect(session.voiceEnabled, isFalse);
  });

  test('late voice-state refresh cannot restore consent after stop', () async {
    final consent = Completer<bool>();
    final requested = Completer<void>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'active') return true;
      if (call.method == 'voiceState') {
        requested.complete();
        return consent.future;
      }
      if (call.method == 'stop') return null;
      throw MissingPluginException();
    });
    final session = AndroidRouteSession();
    final pending = session.refresh();
    await requested.future;
    await session.stop();
    consent.complete(true);
    await expectLater(pending, throwsStateError);
    expect(session.active, isFalse);
    expect(session.voiceEnabled, isFalse);
  });

  test('late consent acceptance cannot undo revocation', () async {
    final reply = Completer<bool>();
    final requested = Completer<void>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'voiceConsent' && call.arguments == true) {
        requested.complete();
        return reply.future;
      }
      return false;
    });
    final session = AndroidRouteSession();
    final pending = session.setVoiceConsent(true);
    await requested.future;
    await session.setVoiceConsent(false);
    reply.complete(true);
    await pending;
    expect(session.voiceEnabled, isFalse);
  });

  test('newer refresh wins when replies arrive in reverse order', () async {
    final old = Completer<Object>();
    final requested = Completer<void>();
    var queries = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'active') {
        if (++queries == 1) {
          requested.complete();
          return old.future;
        }
        return false;
      }
      return false;
    });
    final session = AndroidRouteSession();
    final pending = session.refresh();
    await requested.future;
    await session.refresh();
    old.complete(true);
    await expectLater(pending, throwsStateError);
    expect(session.active, isFalse);
  });

  testWidgets(
    'failed refresh stays closed and recovers only after valid check',
    (tester) async {
      var fail = true;
      messenger.setMockMethodCallHandler(channel, (call) async {
        if (fail) throw PlatformException(code: 'UNAVAILABLE');
        return false;
      });
      final source = gps.StreamRepository();
      await tester.pumpWidget(
        GeoGuideApp(
          locationRepository: source,
          routeSession: AndroidRouteSession(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Estado GPS sin confirmar; vuelve a la app para comprobarlo'),
        findsOneWidget,
      );
      final button = find.byWidgetPredicate(
        (w) =>
            w is IconButton && w.tooltip == 'Activar seguimiento de ubicación',
      );
      expect(tester.widget<IconButton>(button).onPressed, isNull);
      expect(source.controller.hasListener, isFalse);
      fail = false;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(tester.widget<IconButton>(button).onPressed, isNotNull);
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(source.controller.hasListener, isTrue);
      await tester.pumpWidget(const SizedBox());
      await source.controller.close();
    },
  );

  testWidgets(
    'late point request cannot move camera after native ownership transfer',
    (tester) async {
      final source = b1.PendingLocation();
      final session = b1.FakeSession();
      await tester.pumpWidget(
        GeoGuideApp(locationRepository: source, routeSession: session),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Usar ubicación actual'));
      await tester.pump();
      session.active = true;
      session.onState?.call(RouteSessionStatus.active);
      await tester.pumpAndSettle();
      source.pending.complete(
        const CurrentLocationResult.available(
          LocationPoint(latitude: -13, longitude: -78),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ubicación actual visible'), findsNothing);
      expect(source.controller.hasListener, isFalse);
      expect(session.active, isTrue);
      await tester.pumpWidget(const SizedBox());
      await source.controller.close();
    },
  );

  testWidgets('dispose detaches callbacks and discards pending recovery', (
    tester,
  ) async {
    final reply = Completer<Object>();
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'active') return reply.future;
      return false;
    });
    final session = AndroidRouteSession();
    final source = gps.StreamRepository();
    await tester.pumpWidget(
      GeoGuideApp(locationRepository: source, routeSession: session),
    );
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    reply.complete(true);
    await tester.pumpAndSettle();
    expect(session.onState, isNull);
    expect(session.onSample, isNull);
    expect(source.controller.hasListener, isFalse);
    expect(tester.takeException(), isNull);
    await source.controller.close();
  });
  for (final routeOwned in [false, true]) {
    testWidgets('silence before first sample also expires route=$routeOwned', (
      tester,
    ) async {
      final source = gps.StreamRepository();
      final session = b1.FakeSession();
      var clock = DateTime.utc(2026, 10, 11, 12);
      await tester.pumpWidget(
        GeoGuideApp(
          locationRepository: source,
          routeSession: session,
          locationClock: () => clock,
        ),
      );
      await tester.pumpAndSettle();
      if (routeOwned) {
        session.active = true;
        session.onState?.call(RouteSessionStatus.active);
      } else {
        await tester.tap(find.byTooltip('Activar seguimiento de ubicación'));
      }
      await tester.pumpAndSettle();
      clock = clock.add(const Duration(seconds: 11));
      await tester.pump(const Duration(seconds: 11));
      expect(
        find.text('Sin actualización reciente de ubicación'),
        findsOneWidget,
      );
      expect(session.active, routeOwned);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 20));
      expect(tester.takeException(), isNull);
      await source.controller.close();
    });
  }

  testWidgets(
    'expired future invalid and duplicate samples cannot move camera or postpone expiry',
    (tester) async {
      final source = gps.StreamRepository();
      var clock = DateTime.utc(2026, 10, 11, 12);
      await tester.pumpWidget(
        GeoGuideApp(
          locationRepository: source,
          routeSession: b1.FakeSession(),
          locationClock: () => clock,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Activar seguimiento de ubicación'));
      await tester.pumpAndSettle();
      MapController camera() =>
          tester.widget<FlutterMap>(find.byType(FlutterMap)).mapController!;
      final time = clock;
      void emit(DateTime stamp, double latitude) => source.controller.add(
        LocationSample(
          position: LocationPoint(latitude: latitude, longitude: -77),
          timestamp: stamp,
          accuracyMeters: 2,
        ),
      );
      emit(time, -12.1);
      await tester.pump();
      await tester.pump();
      final center = camera().camera.center;
      clock = clock.add(const Duration(seconds: 5));
      await tester.pump(const Duration(seconds: 5));
      emit(time, -12.2);
      emit(clock.add(const Duration(seconds: 1)), -12.3);
      emit(clock, double.nan);
      await tester.pump();
      await tester.pump();
      expect(camera().camera.center, center);
      clock = clock.add(const Duration(seconds: 6));
      await tester.pump(const Duration(seconds: 6));
      expect(
        find.text('Sin actualización reciente de ubicación'),
        findsOneWidget,
      );
      emit(time, -12.4);
      await tester.pump();
      await tester.pump();
      expect(camera().camera.center, center);
      await tester.drag(find.byType(FlutterMap), const Offset(50, 0));
      await tester.pumpAndSettle();
      final paused = camera().camera.center;
      await tester.tap(find.byTooltip('Reanudar seguimiento de cámara'));
      await tester.pump();
      expect(camera().camera.center, paused);
      await tester.pumpWidget(const SizedBox());
      await source.controller.close();
    },
  );

  testWidgets(
    'recovery waits for real stream cancellation before resolving ownership',
    (tester) async {
      final source = CancellationGateRepository();
      final session = b1.FakeSession();
      await tester.pumpWidget(
        GeoGuideApp(locationRepository: source, routeSession: session),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Activar seguimiento de ubicación'));
      await tester.pumpAndSettle();
      expect(source.requests, 1);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      final button = find.byWidgetPredicate(
        (w) => w is IconButton && w.tooltip == 'Usar ubicación actual',
      );
      expect(tester.widget<IconButton>(button).onPressed, isNull);
      session.active = true;
      session.onState?.call(RouteSessionStatus.active);
      await tester.pumpAndSettle();
      final owned = find.byWidgetPredicate(
        (w) =>
            w is IconButton &&
            w.tooltip ==
                'Ubicación puntual no disponible durante el recorrido GPS',
      );
      expect(tester.widget<IconButton>(owned).onPressed, isNull);
      source.gate.complete();
      await tester.pumpAndSettle();
      expect(source.requests, 1);
      expect(source.controller.hasListener, isFalse);
      expect(session.active, isTrue);
      await tester.pumpWidget(const SizedBox());
      unawaited(source.controller.close());
    },
  );
}
