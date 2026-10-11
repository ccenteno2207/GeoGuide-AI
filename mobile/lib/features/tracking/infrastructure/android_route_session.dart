import '../application/route_session_client.dart';

import 'dart:async';

import 'package:flutter/services.dart';

import '../../discovery/domain/route_snapshot.dart';
import '../../discovery/infrastructure/offline/snapshot_codec.dart';
import '../../location/domain/location_repository.dart';

class AndroidRouteSession implements RouteSessionClient {
  static final instance = AndroidRouteSession();
  static const channel = MethodChannel('geoguide/route_session');
  @override
  bool active = false;
  void Function(LocationSample)? onSample;
  void Function(bool)? onState;
  AndroidRouteSession() {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'sample') {
        onSample?.call(
          decodeSample(Map<Object?, Object?>.from(call.arguments as Map)),
        );
      }
      if (call.method == 'state') {
        active = call.arguments == true;
        onState?.call(active);
      }
    });
  }
  @override
  Future<void> requestPermissions() async {
    await channel.invokeMethod<void>("permissions");
  }

  @override
  Future<void> start(RouteSnapshot snapshot) async {
    final bytes = const SnapshotCodec().encode(snapshot);
    await channel.invokeMethod<void>('start', bytes);
    active = true;
    onState?.call(true);
  }

  @override
  Future<void> stop() async {
    await channel.invokeMethod<void>('stop');
    active = false;
    onState?.call(false);
  }

  @override
  Future<void> refresh() async {
    active = await channel.invokeMethod<bool>('active') ?? false;
    onState?.call(active);
  }

  static LocationSample decodeSample(Map<Object?, Object?> m) => LocationSample(
    position: LocationPoint(
      latitude: (m['latitude'] as num).toDouble(),
      longitude: (m['longitude'] as num).toDouble(),
    ),
    timestamp: DateTime.fromMillisecondsSinceEpoch(m['timestamp'] as int),
    accuracyMeters: (m['accuracy'] as num).toDouble(),
    headingDegrees: (m['heading'] as num?)?.toDouble(),
    headingAccuracyDegrees: (m['headingAccuracy'] as num?)?.toDouble(),
    speedMetersPerSecond: (m['speed'] as num?)?.toDouble(),
    speedAccuracyMetersPerSecond: (m['speedAccuracy'] as num?)?.toDouble(),
  );
}
