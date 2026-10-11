import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/tracking/application/cefi_alert_delivery_coordinator.dart';
import 'package:geoguide_ai/features/tracking/application/poi_proximity_evaluator.dart';
import 'package:geoguide_ai/features/tracking/application/active_route_coordinator.dart';
import 'package:geoguide_ai/features/tracking/application/tracking_session_manager.dart';

import '../discovery/offline_cache_test.dart' as fixtures;
import 'accelerated_core_test.dart' as core;

class FakeDelivery implements CEFIAlertDeliveryPort {
  Completer<void>? cancellation;
  bool cancelFails = false;
  final events = <CEFIAlertEvent>[],
      acks = <Completer<CEFIAlertAck>>[],
      cancelled = <String>[];
  @override
  Future<CEFIAlertAck> deliver(CEFIAlertEvent e) {
    events.add(e);
    final c = Completer<CEFIAlertAck>();
    acks.add(c);
    return c.future;
  }

  @override
  Future<void> cancel(String id) async {
    cancelled.add(id);
    if (cancelFails) throw StateError('cancel failure');
    await cancellation?.future;
  }

  void ack(int i, AlertDeliveryState state, {bool wrong = false}) {
    final e = events[i];
    acks[i].complete(
      CEFIAlertAck(
        wrong ? 'wrong' : e.eventId,
        e.generation,
        e.snapshotRevision,
        state,
      ),
    );
  }
}

void main() {
  late DateTime time;
  late FakeDelivery port;
  late CEFIAlertDeliveryCoordinator c;
  const a = PoiAlert('a', 'A', false),
      b = PoiAlert('b', 'B', true),
      d = PoiAlert('c', 'C', false);
  void offer(List<PoiAlert> values, [int seconds = 0]) {
    time = time.add(Duration(seconds: seconds));
    c.consider(values, time);
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);
  setUp(() {
    time = core.now;
    port = FakeDelivery();
    c = CEFIAlertDeliveryCoordinator(
      port,
      cooldown: const Duration(seconds: 5),
      validity: const Duration(seconds: 10),
      clock: () => time,
    );
    c.open('r1', time.add(const Duration(hours: 1)));
  });
  tearDown(() => c.stop());
  test('priority bounded queue delivered dedup cooldown on ack', () async {
    offer([a, b, d]);
    expect(port.events.single.candidate.poiId, 'b');
    expect(c.pending!.candidate.poiId, 'a');
    expect(c.inFlight!.state, AlertDeliveryState.accepted);
    offer([a, b], 1);
    expect(port.events.length, 1);
    port.ack(0, AlertDeliveryState.delivered);
    await settle();
    expect(port.events[0].state, AlertDeliveryState.delivered);
    expect(port.events.length, 1);
    offer([a, b], 4);
    expect(port.events.length, 1);
    offer([a, b], 1);
    expect(port.events.length, 2);
    expect(port.events.last.candidate.poiId, 'a');
    port.ack(1, AlertDeliveryState.delivered);
    await settle();
    offer([a, b], 6);
    expect(port.events.length, 2);
  });
  for (final state in [
    AlertDeliveryState.failed,
    AlertDeliveryState.suppressed,
  ]) {
    test('$state no consumption or automatic retry', () async {
      offer([b]);
      port.ack(0, state);
      await settle();
      expect(port.events.single.state, state);
      offer([b], 1);
      expect(port.events.length, 1);
      time = time.add(const Duration(seconds: 10));
      await settle();
      expect(port.events.length, 1);
      c.consider([b], time);
      expect(port.events.length, 2);
    });
  }
  test('pending chosen replaces suggested', () {
    offer([a, d]);
    final old = c.pending!;
    offer([a, d, b], 1);
    expect(old.state, AlertDeliveryState.suppressed);
    expect(c.pending!.candidate.poiId, 'b');
    expect(port.events.length, 1);
  });
  test('expiry cancels output and rejects late ack', () async {
    offer([b]);
    final old = c.inFlight!;
    offer([], 11);
    expect(old.state, AlertDeliveryState.expired);
    expect(port.cancelled, contains(old.eventId));
    port.ack(0, AlertDeliveryState.delivered);
    await settle();
    expect(old.state, AlertDeliveryState.expired);
    offer([b], 1);
    expect(port.events.length, 2);
  });
  test('stop cancels both events and never restarts', () async {
    offer([b, a]);
    final old = c.inFlight!, pending = c.pending!;
    c.stop();
    port.ack(0, AlertDeliveryState.delivered);
    await settle();
    expect(old.state, AlertDeliveryState.cancelled);
    expect(pending.state, AlertDeliveryState.cancelled);
    offer([b], 20);
    expect(port.events.length, 1);
  });
  test('snapshot generation invalidates old ack and keys', () async {
    offer([b]);
    final old = c.inFlight!;
    c.open('r2', time.add(const Duration(hours: 1)));
    await settle();
    offer([b], 1);
    final current = c.inFlight!;
    expect(current.generation, isNot(old.generation));
    expect(current.eventId, isNot(old.eventId));
    expect(current.snapshotRevision, 'r2');
    port.ack(0, AlertDeliveryState.delivered);
    await settle();
    expect(c.inFlight, current);
    expect(old.state, AlertDeliveryState.cancelled);
    port.ack(1, AlertDeliveryState.delivered);
    await settle();
    expect(current.state, AlertDeliveryState.delivered);
  });
  test('wrong ack is never delivered', () async {
    offer([b]);
    port.ack(0, AlertDeliveryState.delivered, wrong: true);
    await settle();
    expect(port.events.single.state, AlertDeliveryState.failed);
  });
  test('pending outside corridor is suppressed not replayed', () async {
    offer([b, a]);
    final pending = c.pending!;
    port.ack(0, AlertDeliveryState.delivered);
    await settle();
    offer([b], 6);
    expect(pending.state, AlertDeliveryState.suppressed);
    expect(port.events.length, 1);
  });
  test('adapter exception is failed', () async {
    offer([b]);
    port.acks.single.completeError(StateError('fake'));
    await settle();
    expect(port.events.single.state, AlertDeliveryState.failed);
  });
  test('silent adapter technical ack only', () async {
    final e = CEFIAlertEvent(
      'id',
      1,
      'r',
      b,
      time.add(const Duration(seconds: 1)),
    );
    final ack = await SilentAlertSink().deliver(e);
    expect(ack.eventId, e.eventId);
    expect(ack.state, AlertDeliveryState.delivered);
  });
  test(
    'Dart route integration revoke invalidates GPS and delivery callbacks',
    () async {
      final gps = core.FakeService();
      final evaluator = POIProximityEvaluator(
        ProximityConfig(
          enterMeters: 1000,
          exitMeters: 1200,
          maxAccuracyMeters: 30,
          maxAge: const Duration(seconds: 10),
          cooldown: const Duration(seconds: 5),
          maxBearingDifference: 45,
          maxSpeedAccuracy: 3,
        ),
      );
      final route = ActiveRouteCoordinator(
        TrackingSessionManager(gps),
        evaluator,
        port,
        clock: () => time,
      );
      final snapshot = fixtures.snapshot();
      await route.start(
        snapshot,
        consent: true,
        prerequisites: true,
        onSample: (_) {},
        chosenIds: {snapshot.pois.first.id},
      );
      final late = gps.callback!;
      late(core.sample(time: time));
      expect(port.events.length, 1);
      await route.revoke();
      port.ack(0, AlertDeliveryState.delivered);
      await settle();
      expect(port.events.single.state, AlertDeliveryState.cancelled);
      expect(route.manager.state, TrackingState.off);
      late(core.sample(time: time.add(const Duration(seconds: 1))));
      expect(port.events.length, 1);
    },
  );
  test(
    'cancellation barrier prevents overlapping output across contexts',
    () async {
      offer([b]);
      port.cancellation = Completer<void>();
      c.open('r2', time.add(const Duration(hours: 1)));
      offer([b], 1);
      expect(port.events.length, 1);
      expect(c.outputBlocked, isTrue);
      port.cancellation!.complete();
      await settle();
      expect(port.events.length, 1); // Release never auto-delivers.
      offer([b], 1);
      expect(port.events.length, 2);
    },
  );
  test('cancel failure fails closed rather than overlapping output', () async {
    offer([b]);
    port.cancelFails = true;
    c.open('r2', time.add(const Duration(hours: 1)));
    await settle();
    offer([b], 1);
    expect(c.outputBlocked, isTrue);
    expect(port.events.length, 1);
  });
  test(
    'duplicate future and stale samples cannot reconsider failed output',
    () async {
      offer([b]);
      port.ack(0, AlertDeliveryState.failed);
      await settle();
      c.consider([b], time);
      expect(port.events.length, 1);
      c.consider([b], time.add(const Duration(seconds: 30)));
      expect(port.events.length, 1);
      time = time.add(const Duration(seconds: 20));
      c.consider([b], time.subtract(const Duration(seconds: 15)));
      expect(port.events.length, 1);
      c.consider([b], time);
      expect(port.events.length, 2);
    },
  );
  test('snapshot TTL expires context and cannot start new output', () async {
    c.open('short', time.add(const Duration(seconds: 2)));
    offer([b]);
    time = time.add(const Duration(seconds: 3));
    c.consider([b], time);
    expect(c.inFlight, isNull);
    expect(port.events.single.state, AlertDeliveryState.expired);
    port.ack(0, AlertDeliveryState.delivered);
    await settle();
    offer([b], 1);
    expect(port.events.length, 1);
  });
}
