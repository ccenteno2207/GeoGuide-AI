import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/tracking/application/active_route_coordinator.dart';
import 'package:geoguide_ai/features/tracking/application/route_session_client.dart';
import 'package:geoguide_ai/features/tracking/application/poi_proximity_evaluator.dart';
import 'package:geoguide_ai/features/tracking/application/tracking_session_manager.dart';
import 'package:geoguide_ai/features/tracking/infrastructure/android_route_session.dart';
import 'package:geoguide_ai/features/tracking/infrastructure/route_session_worker.dart';

import '../discovery/offline_cache_test.dart' as fixtures;
import 'accelerated_core_test.dart' as core;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  ActiveRouteCoordinator coordinator(
    core.FakeService port, {
    DateTime Function()? clock,
  }) => ActiveRouteCoordinator(
    TrackingSessionManager(port),
    POIProximityEvaluator(
      ProximityConfig(
        enterMeters: 100,
        exitMeters: 200,
        maxAccuracyMeters: 30,
        maxAge: const Duration(seconds: 10),
        cooldown: Duration.zero,
        maxBearingDifference: 45,
        maxSpeedAccuracy: 3,
      ),
    ),
    SilentAlertSink(),
    clock: clock ?? () => core.now,
  );
  test('route consent missing never starts producer', () async {
    final port = core.FakeService();
    final c = coordinator(port);
    await expectLater(
      c.start(
        fixtures.snapshot(),
        consent: false,
        prerequisites: true,
        onSample: (_) {},
      ),
      throwsStateError,
    );
    expect(port.starts, 0);
  });
  test('expired route never starts producer', () async {
    final port = core.FakeService();
    final c = coordinator(
      port,
      clock: () => core.now.add(const Duration(days: 1)),
    );
    await expectLater(
      c.start(
        fixtures.snapshot(),
        consent: true,
        prerequisites: true,
        onSample: (_) {},
      ),
      throwsStateError,
    );
    expect(port.starts, 0);
  });
  test('route stop releases producer and rejects late samples', () async {
    final port = core.FakeService();
    final c = coordinator(port);
    var received = 0;
    await c.start(
      fixtures.snapshot(),
      consent: true,
      prerequisites: true,
      onSample: (_) => received++,
    );
    final late = port.callback!;
    late(core.sample());
    expect(received, 1);
    await c.stop();
    late(core.sample());
    expect(received, 1);
    expect(c.manager.state, TrackingState.off);
  });
  test(
    'route expiry during session stops rather than evaluating stale snapshot',
    () async {
      var now = core.now;
      final port = core.FakeService();
      final c = coordinator(port, clock: () => now);
      await c.start(
        fixtures.snapshot(),
        consent: true,
        prerequisites: true,
        onSample: (_) => fail('Expired sample leaked'),
      );
      now = now.add(const Duration(days: 1));
      port.callback!(core.sample(time: now));
      await Future<void>.delayed(Duration.zero);
      expect(c.manager.state, TrackingState.off);
    },
  );
  test('native port stop nulls callback before awaited teardown', () async {
    const channel = MethodChannel('test/b1_worker');
    final calls = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return null;
        });
    final port = NativeLocationPort(channel);
    await port.start(TrackingMode.activeRoute, (_) {});
    expect(port.callback, isNotNull);
    await port.stop();
    expect(port.callback, isNull);
    expect(calls, ['begin', 'end']);
    await expectLater(
      port.start(TrackingMode.continuous, (_) {}),
      throwsStateError,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test('platform denial propagates without claiming active session', () async {
    final client = AndroidRouteSession();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidRouteSession.channel, (call) async {
          throw PlatformException(code: 'START_DENIED');
        });
    await expectLater(
      client.start(
        fixtures.snapshot(
          capturedAtUtcMs: DateTime.now().millisecondsSinceEpoch,
        ),
      ),
      throwsA(isA<PlatformException>()),
    );
    expect(client.active, isFalse);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(AndroidRouteSession.channel, null);
  });
  test(
    'native status separates interruption from voluntary stop across refresh',
    () async {
      final client = AndroidRouteSession();
      final states = <RouteSessionStatus>[];
      client.onState = states.add;
      Object reply = {'active': true, 'interrupted': false};
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            AndroidRouteSession.channel,
            (call) async => call.method == 'active' ? reply : null,
          );
      await client.start(
        fixtures.snapshot(
          capturedAtUtcMs: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      expect(states, [RouteSessionStatus.starting, RouteSessionStatus.active]);
      reply = {'active': true, 'starting': true, 'interrupted': false};
      await client.refresh();
      expect(client.active, isTrue);
      expect(states.last, RouteSessionStatus.starting);
      reply = {'active': false, 'interrupted': true};
      await client.refresh();
      expect(client.active, isFalse);
      expect(states.last, RouteSessionStatus.interrupted);
      await client.stop();
      expect(states.last, RouteSessionStatus.stopped);
      reply = {'active': false, 'interrupted': false};
      await client.refresh();
      expect(states.last, RouteSessionStatus.stopped);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(AndroidRouteSession.channel, null);
    },
  );
}
