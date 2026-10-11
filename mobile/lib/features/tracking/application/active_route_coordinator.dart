import 'dart:async';

import '../../discovery/domain/route_snapshot.dart';
import '../../location/domain/location_repository.dart';
import 'tracking_session_manager.dart';
import 'poi_proximity_evaluator.dart';

abstract interface class AlertSink {
  void accept(PoiAlert alert);
}

class SilentAlertSink implements AlertSink {
  @override
  void accept(PoiAlert alert) {}
}

class ActiveRouteCoordinator {
  ActiveRouteCoordinator(
    this.manager,
    this.evaluator,
    this.sink, {
    DateTime Function()? clock,
  }) : now = clock ?? DateTime.now;
  final TrackingSessionManager manager;
  final POIProximityEvaluator evaluator;
  final AlertSink sink;
  final DateTime Function() now;
  RouteSnapshot? _snapshot;
  Future<void> start(
    RouteSnapshot snapshot, {
    required bool consent,
    required bool prerequisites,
    required void Function(LocationSample) onSample,
  }) async {
    if (manager.state != TrackingState.off &&
        manager.state != TrackingState.interrupted) {
      throw StateError('Session already owned');
    }
    if (!snapshot.eligible(now().millisecondsSinceEpoch)) {
      throw StateError('Route unavailable');
    }
    _snapshot = snapshot;
    evaluator.reset();
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
          final alert = evaluator.evaluate(
            snapshot: current,
            sample: sample,
            now: now(),
            chosenIds: const {},
            categories: current.pois.map((p) => p.category).toSet(),
          );
          if (alert != null) sink.accept(alert);
        },
      );
    } catch (_) {
      _snapshot = null;
      evaluator.reset();
      rethrow;
    }
  }

  Future<void> stop() async {
    _snapshot = null;
    evaluator.reset();
    await manager.stop();
  }

  Future<void> revoke() => stop();
}
