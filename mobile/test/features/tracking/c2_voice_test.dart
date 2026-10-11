import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/tracking/application/cefi_alert_delivery_coordinator.dart';
import 'package:geoguide_ai/features/tracking/application/poi_proximity_evaluator.dart';
import 'package:geoguide_ai/features/tracking/infrastructure/android_cefi_voice.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('geoguide/c2_test');
  late CEFIAlertDeliveryCoordinator delivery;
  late DateTime time;
  late List<Map<String, dynamic>> sent;
  late List<Completer<Map<String, dynamic>>> completions;
  late List<String> cancellations;
  Future<void> settle() => Future<void>.delayed(Duration.zero);
  void offer(List<PoiAlert> candidates, [int seconds = 0]) {
    time = time.add(Duration(seconds: seconds));
    delivery.consider(candidates, time);
  }

  void ack(int index, String state, {bool wrong = false}) =>
      completions[index].complete({
        'eventId': wrong ? 'wrong' : sent[index]['eventId'],
        'generation': sent[index]['generation'],
        'snapshotRevision': sent[index]['snapshotRevision'],
        'state': state,
      });
  const chosen = PoiAlert('chosen', 'Museo', true),
      suggested = PoiAlert('suggested', 'Plaza', false);
  setUp(() {
    time = DateTime.utc(2026, 10, 10);
    sent = [];
    completions = [];
    cancellations = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'voiceCancel') {
            cancellations.add(call.arguments as String);
            return null;
          }
          final data = Map<String, dynamic>.from(call.arguments as Map);
          sent.add(data);
          final completion = Completer<Map<String, dynamic>>();
          completions.add(completion);
          return completion.future;
        });
    delivery = CEFIAlertDeliveryCoordinator(
      AndroidCEFIAlertDelivery(channel),
      cooldown: const Duration(seconds: 30),
      validity: const Duration(seconds: 10),
      clock: () => time,
    );
    delivery.open('route-1', time.add(const Duration(hours: 1)));
  });
  tearDown(() async {
    delivery.stop();
    await settle();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });
  test(
    'native completion only consumes eligible chosen event and starts cooldown',
    () async {
      offer([suggested, chosen]);
      await settle();
      expect(sent.single['name'], 'Museo');
      expect(
        sent.single.keys,
        unorderedEquals([
          'eventId',
          'generation',
          'snapshotRevision',
          'expiresAt',
          'name',
        ]),
      );
      expect(delivery.inFlight!.state, AlertDeliveryState.accepted);
      ack(0, 'DELIVERED');
      await settle();
      expect(delivery.lastOutcome!.state, AlertDeliveryState.delivered);
      expect(sent.length, 1);
      offer([chosen, suggested], 1);
      await settle();
      expect(sent.length, 1);
      offer([chosen, suggested], 30);
      await settle();
      expect(sent.length, 2);
      expect(sent.last['name'], 'Plaza');
    },
  );
  for (final state in ['SUPPRESSED', 'FAILED']) {
    test('$state never consumes or retries automatically', () async {
      offer([chosen]);
      await settle();
      ack(0, state);
      await settle();
      expect(delivery.lastOutcome!.state.name.toUpperCase(), state);
      expect(sent.length, 1);
      offer([chosen], 31);
      await settle();
      expect(sent.length, 2);
    });
  }
  test(
    'consent revocation cancels flight and pending without replay',
    () async {
      offer([chosen, suggested]);
      await settle();
      final old = delivery.inFlight!, pending = delivery.pending!;
      delivery.cancelOutstanding();
      await settle();
      expect(cancellations.single, old.eventId);
      expect(old.state, AlertDeliveryState.cancelled);
      expect(pending.state, AlertDeliveryState.cancelled);
      ack(0, 'DELIVERED');
      await settle();
      expect(delivery.inFlight, isNull);
      expect(sent.length, 1);
    },
  );
  test('stop cancels native speech and ignores late completion', () async {
    offer([chosen]);
    await settle();
    final old = delivery.inFlight!;
    delivery.stop();
    await settle();
    ack(0, 'DELIVERED');
    await settle();
    offer([chosen], 31);
    await settle();
    expect(cancellations.single, old.eventId);
    expect(sent.length, 1);
    expect(old.state, AlertDeliveryState.cancelled);
  });
  test('wrong correlated completion is failed', () async {
    offer([chosen]);
    await settle();
    ack(0, 'DELIVERED', wrong: true);
    await settle();
    expect(delivery.lastOutcome!.state, AlertDeliveryState.failed);
  });
  test(
    'native cancelled and expired terminal results remain distinct',
    () async {
      offer([chosen]);
      await settle();
      ack(0, 'CANCELLED');
      await settle();
      expect(delivery.lastOutcome!.state, AlertDeliveryState.cancelled);
      offer([chosen], 31);
      await settle();
      ack(1, 'EXPIRED');
      await settle();
      expect(delivery.lastOutcome!.state, AlertDeliveryState.expired);
    },
  );
}
