import '../application/route_session_client.dart';

import 'dart:async';

import 'package:flutter/services.dart';

import '../../discovery/domain/route_snapshot.dart';
import '../application/selected_poi_session.dart';
import 'selected_poi_session_codec.dart';
import '../../location/domain/location_repository.dart';

class AndroidRouteSession implements RouteSessionClient {
  static final instance = AndroidRouteSession();
  static const channel = MethodChannel('geoguide/route_session');
  int _revision = 0;
  @override
  bool active = false;
  @override
  bool voiceEnabled = false;
  @override
  Future<void> setVoiceConsent(bool enabled) async {
    final revision = ++_revision;
    if (!enabled) voiceEnabled = false;
    final result = await channel.invokeMethod<bool>('voiceConsent', enabled);
    if (revision == _revision) voiceEnabled = result == true;
  }

  void Function(LocationSample)? onSample;
  void Function(RouteSessionStatus)? onState;
  RouteSessionStatus _status = RouteSessionStatus.stopped;
  void _update(Object? value) {
    final data = value is Map ? value : null;
    active = data == null ? value == true : data['active'] == true;
    if (!active) voiceEnabled = false;
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
        ++_revision;
        _update(call.arguments);
      }
    });
  }
  @override
  Future<void> requestPermissions() async {
    await channel.invokeMethod<void>("permissions");
  }

  @override
  Future<void> start(
    RouteSnapshot snapshot, {
    Set<String> chosenIds = const {},
  }) async {
    final revision = ++_revision;
    final now = DateTime.now().millisecondsSinceEpoch;
    final bytes = const SelectedPoiSessionCodec().encode(
      SelectedPoiSession(snapshot, chosenIds, now),
      now,
    );
    onState?.call(RouteSessionStatus.starting);
    try {
      await channel.invokeMethod<void>('start', bytes);
      if (revision == _revision) _update(true);
    } catch (_) {
      if (revision == _revision) {
        _update({'active': false, 'interrupted': true});
      }
      rethrow;
    }
  }

  @override
  Future<void> stop() async {
    final revision = ++_revision;
    voiceEnabled = false;
    await channel.invokeMethod<void>('stop');
    if (revision == _revision) _update(false);
  }

  @override
  Future<void> refresh() async {
    final revision = ++_revision;
    final state = await channel.invokeMethod<Object?>('active');
    if (revision != _revision) throw StateError('Superseded ownership check');
    final consent = await channel.invokeMethod<bool>('voiceState') == true;
    if (revision != _revision) throw StateError('Superseded ownership check');
    _update(state);
    voiceEnabled = consent;
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
