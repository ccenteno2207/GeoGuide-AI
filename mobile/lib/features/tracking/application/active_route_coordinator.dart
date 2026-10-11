import 'dart:async';

import '../../discovery/domain/route_snapshot.dart';
import '../../location/domain/location_repository.dart';
import 'tracking_session_manager.dart';
import 'poi_proximity_evaluator.dart';
import 'cefi_alert_delivery_coordinator.dart';
export 'cefi_alert_delivery_coordinator.dart' show SilentAlertSink;

class ActiveRouteCoordinator {
  ActiveRouteCoordinator(
    this.manager,
    this.evaluator,
    CEFIAlertDeliveryPort sink, {
    DateTime Function()? clock,
  }) : now = clock ?? DateTime.now,
       delivery = CEFIAlertDeliveryCoordinator(
         sink,
         cooldown: evaluator.config.cooldown,
         validity: evaluator.config.maxAge,
         clock: clock,
       );
  final TrackingSessionManager manager;
  final POIProximityEvaluator evaluator;
  final CEFIAlertDeliveryCoordinator delivery;
  int _revision = 0;
  final DateTime Function() now;
  RouteSnapshot? _snapshot;
  Future<void> start(
    RouteSnapshot snapshot, {
    required bool consent,
    required bool prerequisites,
    required void Function(LocationSample) onSample,
    Set<String> chosenIds = const {},
  }) async {
    if (_snapshot != null ||
        (manager.state != TrackingState.off &&
            manager.state != TrackingState.interrupted)) {
      throw StateError('Session already owned');
    }
    if (!snapshot.eligible(now().millisecondsSinceEpoch)) {
      throw StateError('Route unavailable');
    }
    _snapshot = snapshot;
    evaluator.reset();
    delivery.open(
      'snapshot-${++_revision}',
      DateTime.fromMillisecondsSinceEpoch(snapshot.expiresAtUtcMs),
    );
    final selected = Set<String>.unmodifiable(chosenIds);
    try {
      await manager.start(
        TrackingMode.activeRoute,
        consent: consent,
        prerequisites: prerequisites,
        continuousGate: false,
        onSample: (sample) {
          final current = _snapshot;
          if (current == null ||
              !current.eligible(now().millisecondsSinceEpoch)) {
            unawaited(stop());
            return;
          }
          onSample(sample);
          final candidates = evaluator.evaluateCandidates(
            snapshot: current,
            sample: sample,
            now: now(),
            chosenIds: selected,
            categories: current.pois.map((p) => p.category).toSet(),
          );
          if (sample.accuracyMeters <= evaluator.config.maxAccuracyMeters &&
              !sample.timestamp.isAfter(now()) &&
              now().difference(sample.timestamp) <= evaluator.config.maxAge) {
            delivery.consider(candidates, sample.timestamp);
          }
        },
      );
    } catch (_) {
      _snapshot = null;
      delivery.stop();
      evaluator.reset();
      rethrow;
    }
  }

  Future<void> stop() async {
    _snapshot = null;
    delivery.stop();
    evaluator.reset();
    await manager.stop();
  }

  Future<void> revoke() => stop();
}
