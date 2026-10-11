import 'dart:math' as math;

import '../../discovery/domain/route_snapshot.dart';
import '../../location/domain/location_repository.dart';

class ProximityConfig {
  ProximityConfig({
    required this.enterMeters,
    required this.exitMeters,
    required this.maxAccuracyMeters,
    required this.maxAge,
    required this.cooldown,
    required this.maxBearingDifference,
    required this.maxSpeedAccuracy,
  }) {
    if ([
          enterMeters,
          exitMeters,
          maxAccuracyMeters,
          maxBearingDifference,
          maxSpeedAccuracy,
        ].any((v) => !v.isFinite || v < 0) ||
        exitMeters <= enterMeters ||
        maxBearingDifference > 180 ||
        maxAge <= Duration.zero ||
        cooldown < Duration.zero) {
      throw ArgumentError('Invalid proximity configuration');
    }
  }
  final double enterMeters, exitMeters, maxAccuracyMeters, maxBearingDifference;
  final double maxSpeedAccuracy;
  final Duration maxAge, cooldown;
}

class PoiAlert {
  const PoiAlert(this.poiId, this.name, this.chosen);
  final String poiId, name;
  final bool chosen;
}

/// Values only: no output, audio, network or persistence adapter.
class POIProximityEvaluator {
  POIProximityEvaluator(this.config);
  final ProximityConfig config;
  final Set<String> _inside = {};
  RouteSnapshot? _snapshot;
  DateTime? _lastSample;
  void reset() {
    _inside.clear();
    _snapshot = null;
    _lastSample = null;
  }

  List<PoiAlert> evaluateCandidates({
    required RouteSnapshot snapshot,
    required LocationSample sample,
    required DateTime now,
    required Set<String> chosenIds,
    required Set<String> categories,
  }) {
    if (!snapshot.eligible(now.millisecondsSinceEpoch) ||
        !sample.isUsable ||
        sample.accuracyMeters > config.maxAccuracyMeters ||
        sample.timestamp.isAfter(now) ||
        now.difference(sample.timestamp) > config.maxAge ||
        (_snapshot != null &&
            snapshot.query.sameAs(_snapshot!.query) &&
            _lastSample != null &&
            !sample.timestamp.isAfter(_lastSample!))) {
      return const [];
    }
    if (_snapshot == null || !snapshot.query.sameAs(_snapshot!.query)) {
      reset();
      _snapshot = snapshot;
    }
    _lastSample = sample.timestamp;
    final candidates =
        <({String id, String name, bool chosen, double distance})>[];
    for (final poi in snapshot.pois) {
      if (!poi.location.isValid ||
          !poi.distanceToRouteMeters.isFinite ||
          poi.distanceToRouteMeters < 0 ||
          poi.distanceToRouteMeters > snapshot.query.corridorMeters) {
        continue;
      }
      final chosen = chosenIds.contains(poi.id);
      if (!chosen && !categories.contains(poi.category)) continue;
      final lat = sample.position.latitude * math.pi / 180,
          otherLat = poi.location.latitude * math.pi / 180;
      final dlat = otherLat - lat,
          dlon =
              (poi.location.longitude - sample.position.longitude) *
              math.pi /
              180;
      final a =
          math.pow(math.sin(dlat / 2), 2) +
          math.cos(lat) * math.cos(otherLat) * math.pow(math.sin(dlon / 2), 2);
      final distance = 6371000 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
      if (distance - sample.accuracyMeters > config.exitMeters) {
        _inside.remove(poi.id);
      }
      if (distance + sample.accuracyMeters > config.enterMeters &&
          !_inside.contains(poi.id)) {
        continue;
      }
      _inside.add(poi.id);
      if (!chosen) {
        final h = sample.headingDegrees,
            q = sample.headingAccuracyDegrees,
            v = sample.speedMetersPerSecond,
            speedQuality = sample.speedAccuracyMetersPerSecond;
        if (h == null ||
            !h.isFinite ||
            h < 0 ||
            h >= 360 ||
            q == null ||
            !q.isFinite ||
            q < 0 ||
            q > config.maxBearingDifference ||
            v == null ||
            !v.isFinite ||
            v <= 0 ||
            speedQuality == null ||
            !speedQuality.isFinite ||
            speedQuality < 0 ||
            speedQuality > config.maxSpeedAccuracy) {
          continue;
        }
        final bearing =
            (math.atan2(
                      math.sin(dlon) * math.cos(otherLat),
                      math.cos(lat) * math.sin(otherLat) -
                          math.sin(lat) * math.cos(otherLat) * math.cos(dlon),
                    ) *
                    180 /
                    math.pi +
                360) %
            360;
        if (((bearing - h + 540) % 360 - 180).abs() >
            config.maxBearingDifference) {
          continue;
        }
      }
      candidates.add((
        id: poi.id,
        name: poi.name,
        chosen: chosen,
        distance: distance,
      ));
    }
    if (candidates.isEmpty) {
      return const [];
    }
    candidates.sort((a, b) {
      final p = (a.chosen ? 0 : 1).compareTo(b.chosen ? 0 : 1);
      if (p != 0) return p;
      final d = a.distance.compareTo(b.distance);
      return d != 0 ? d : a.id.compareTo(b.id);
    });
    return candidates
        .map((s) => PoiAlert(s.id, s.name, s.chosen))
        .toList(growable: false);
  }

  PoiAlert? evaluate({
    required RouteSnapshot snapshot,
    required LocationSample sample,
    required DateTime now,
    required Set<String> chosenIds,
    required Set<String> categories,
  }) {
    final values = evaluateCandidates(
      snapshot: snapshot,
      sample: sample,
      now: now,
      chosenIds: chosenIds,
      categories: categories,
    );
    return values.isEmpty ? null : values.first;
  }
}
