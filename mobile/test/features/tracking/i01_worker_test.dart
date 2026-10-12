import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/tracking/infrastructure/route_session_worker.dart';
import 'package:geoguide_ai/features/tracking/infrastructure/android_route_session.dart';
import 'package:geoguide_ai/features/tracking/application/selected_poi_session.dart';
import 'package:geoguide_ai/features/tracking/infrastructure/selected_poi_session_codec.dart';
import 'package:geoguide_ai/features/discovery/infrastructure/offline/snapshot_codec.dart';

import '../discovery/offline_cache_test.dart' as fixtures;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  Future<void> native(
    MethodChannel channel,
    String method, [
    Object? value,
  ]) async {
    final done = Completer<void>();
    messenger.handlePlatformMessage(
      channel.name,
      const StandardMethodCodec().encodeMethodCall(MethodCall(method, value)),
      (_) => done.complete(),
    );
    await done.future;
    await Future<void>.delayed(Duration.zero);
  }

  for (final chosen in [false, true]) {
    test(
      'real worker receives selected IDs and stop rejects late samples chosen=$chosen',
      () async {
        const channel = MethodChannel('geoguide/i01_worker');
        final time = DateTime.now();
        final s = const SnapshotCodec().fromEnvelope(
          fixtures.envelope(),
          fixtures.query(),
          time.millisecondsSinceEpoch,
        );
        final bytes = const SelectedPoiSessionCodec().encode(
          SelectedPoiSession(
            s,
            chosen ? {s.pois.first.id} : {},
            time.millisecondsSinceEpoch,
          ),
          time.millisecondsSinceEpoch,
        );
        final calls = <String>[];
        final events = <Map>[];
        messenger.setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          if (call.method == 'snapshot') return bytes;
          if (call.method == 'voiceDeliver') {
            final e = Map.from(call.arguments as Map);
            events.add(e);
            return {...e, 'state': 'DELIVERED'};
          }
          return null;
        });
        await runRouteSessionWorker(channel: channel, clock: () => time);
        expect(calls, containsAll(['snapshot', 'begin', 'ready']));
        final sample = {
          'latitude': 10.0,
          'longitude': 20.0,
          'timestamp': time.millisecondsSinceEpoch,
          'accuracy': 2.0,
        };
        await native(channel, 'sample', sample);
        expect(
          events.length,
          chosen ? 1 : 0,
        ); // No course: suggested remains gated.
        if (chosen) expect(events.single['name'], s.pois.first.name);
        await native(channel, 'voiceConsent');
        await native(channel, 'stop');
        expect(calls, containsAll(['end', 'finish']));
        await native(channel, 'sample', sample);
        expect(events.length, chosen ? 1 : 0);
        messenger.setMockMethodCallHandler(channel, null);
        channel.setMethodCallHandler(null);
      },
    );
  }
  test('Android session transports canonical context as original ByteArray contract', () async {
    final time = DateTime.now().millisecondsSinceEpoch;
    final s = const SnapshotCodec().fromEnvelope(
      fixtures.envelope(),
      fixtures.query(),
      time,
    );
    Object? payload;
    messenger.setMockMethodCallHandler(AndroidRouteSession.channel, (
      call,
    ) async {
      if (call.method == 'start') payload = call.arguments;
      return null;
    });
    final client = AndroidRouteSession();
    await client.start(s, chosenIds: {s.pois.first.id});
    final context = const SelectedPoiSessionCodec().decode(
      payload as dynamic,
      time,
    );
    expect(context.chosenIds, {s.pois.first.id});
    expect(context.snapshot.query.sameAs(s.query), isTrue);
    await client.stop();
    messenger.setMockMethodCallHandler(AndroidRouteSession.channel, null);
    AndroidRouteSession.channel.setMethodCallHandler(null);
  });
}
