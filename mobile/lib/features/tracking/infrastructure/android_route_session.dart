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
  void Function(RouteSessionStatus)? onState;
  RouteSessionStatus _status = RouteSessionStatus.stopped;
  void _update(Object? value) {
    final data = value is Map ? value : null;
    active = data == null ? value == true : data['active'] == true;
    _status = active && data?['starting'] == true
        ? RouteSessionStatus.starting
        : active
        ? RouteSessionStatus.active
        : data?['interrupted'] == true
        ? RouteSessionStatus.interrupted
        : RouteSessionStatus.stopped;
    onState?.call(_status);
  }

  AndroidRouteSession() {
    channel.setMethodCallHandler((call) async {
      if (call.method == 'sample') {
        onSample?.call(
          decodeSample(Map<Object?, Object?>.from(call.arguments as Map)),
        );
      }
      if (call.method == 'state') {
        _update(call.arguments);
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
    onState?.call(RouteSessionStatus.starting);
    try {
      await channel.invokeMethod<void>('start', bytes);
      _update(true);
    } catch (_) {
      _update({'active': false, 'interrupted': true});
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    await channel.invokeMethod<void>('stop');
    _update(false);
  }

  @override
  Future<void> refresh() async {
    _update(await channel.invokeMethod<Object?>('active'));
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
