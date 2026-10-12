import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';

import 'selected_poi_session_codec.dart';
import '../../location/domain/location_repository.dart';
import '../application/active_route_coordinator.dart';
import '../application/tracking_session_manager.dart';
import '../application/poi_proximity_evaluator.dart';
import 'android_route_session.dart';
import 'android_cefi_voice.dart';

class NativeLocationPort implements TrackingServicePort {
  final MethodChannel channel;
  void Function(LocationSample)? callback;
  NativeLocationPort(this.channel);
  @override
  Future<void> start(
    TrackingMode mode,
    void Function(LocationSample) onSample,
  ) async {
    if (mode != TrackingMode.activeRoute) throw StateError('Mode unavailable');
    callback = onSample;
    await channel.invokeMethod<void>('begin');
  }

  @override
  Future<void> stop() async {
    callback = null;
    await channel.invokeMethod<void>('end');
  }
}

Future<void> runRouteSessionWorker({
  MethodChannel channel = const MethodChannel('geoguide/route_worker'),
  DateTime Function()? clock,
}) async {
  WidgetsFlutterBinding.ensureInitialized();
  final now = clock ?? DateTime.now;
  final port = NativeLocationPort(channel);
  final coordinator = ActiveRouteCoordinator(
    TrackingSessionManager(port),
    POIProximityEvaluator(
      ProximityConfig(
        enterMeters: 100,
        exitMeters: 200,
        maxAccuracyMeters: 30,
        maxAge: const Duration(seconds: 10),
        cooldown: const Duration(seconds: 30),
        maxBearingDifference: 45,
        maxSpeedAccuracy: 3,
      ),
    ),
    AndroidCEFIAlertDelivery(channel),
    clock: now,
  );
  Timer? expiry;
  var finished = false;
  Future<void> finish() async {
    if (finished) return;
    finished = true;
    expiry?.cancel();
    try {
      await coordinator.stop();
    } finally {
      try {
        await channel.invokeMethod<void>('finish');
      } on PlatformException {
        /* Native owner already terminated. */
      }
    }
  }

  channel.setMethodCallHandler((call) async {
    if (finished) return;
    if (call.method == 'sample') {
      port.callback?.call(
        AndroidRouteSession.decodeSample(
          Map<Object?, Object?>.from(call.arguments as Map),
        ),
      );
    }
    if (call.method == 'voiceConsent') coordinator.delivery.cancelOutstanding();
    if (call.method == 'stop') await finish();
  });
  try {
    final bytes = await channel.invokeMethod<Uint8List>('snapshot');
    if (bytes == null) throw StateError('Route unavailable');
    final context = const SelectedPoiSessionCodec().decode(
      bytes,
      now().millisecondsSinceEpoch,
    );
    final snapshot = context.snapshot;
    await coordinator.start(
      snapshot,
      chosenIds: context.chosenIds,
      consent: true,
      prerequisites: true,
      onSample: (sample) {
        unawaited(
          channel
              .invokeMethod<void>('publish', {
                'latitude': sample.position.latitude,
                'longitude': sample.position.longitude,
                'timestamp': sample.timestamp.millisecondsSinceEpoch,
                'accuracy': sample.accuracyMeters,
                'heading': sample.headingDegrees,
                'headingAccuracy': sample.headingAccuracyDegrees,
                'speed': sample.speedMetersPerSecond,
                'speedAccuracy': sample.speedAccuracyMetersPerSecond,
              })
              .catchError((Object _) async {
                await finish();
              }),
        );
      },
    );
    await channel.invokeMethod<void>('ready');
    expiry = Timer(
      Duration(
        milliseconds: snapshot.expiresAtUtcMs - now().millisecondsSinceEpoch,
      ),
      () {
        unawaited(finish());
      },
    );
  } catch (_) {
    await finish();
  }
}
