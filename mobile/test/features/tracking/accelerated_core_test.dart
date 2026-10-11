import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/location/application/gps_camera_policy.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';
import 'package:geoguide_ai/features/tracking/application/tracking_session_manager.dart';
import 'package:geoguide_ai/features/tracking/application/poi_proximity_evaluator.dart';

import '../discovery/offline_cache_test.dart' as fixtures;

import 'package:geoguide_ai/features/discovery/infrastructure/offline/snapshot_codec.dart';

final now = DateTime.fromMillisecondsSinceEpoch(fixtures.captured, isUtc: true);
LocationSample sample({
  DateTime? time,
  double? heading = 90,
  double? speed = 20,
  double accuracy = 2,
}) => LocationSample(
  position: const LocationPoint(latitude: 10, longitude: 20),
  timestamp: time ?? now,
  accuracyMeters: accuracy,
  headingDegrees: heading,
  headingAccuracyDegrees: 2,
  speedMetersPerSecond: speed,
  speedAccuracyMetersPerSecond: 1,
);

class FakeService implements TrackingServicePort {
  int starts = 0, stops = 0;
  void Function(LocationSample)? callback;
  Completer<void>? pending;
  bool failStop = false;
  @override
  Future<void> start(
    TrackingMode mode,
    void Function(LocationSample) onSample,
  ) async {
    starts++;
    callback = onSample;
    await pending?.future;
  }

  @override
  Future<void> stop() async {
    stops++;
    if (failStop) throw StateError("stop failed");
  }
}

void main() {
  test(
    'invalid different snapshot does not erase current session deduplication',
    () {
      final p = POIProximityEvaluator(
        ProximityConfig(
          enterMeters: 1000,
          exitMeters: 1200,
          maxAccuracyMeters: 30,
          maxAge: const Duration(seconds: 10),
          cooldown: Duration.zero,
          maxBearingDifference: 45,
          maxSpeedAccuracy: 3,
        ),
      );
      final current = fixtures.snapshot();
      final chosen = {current.pois.first.id};
      expect(
        p.evaluate(
          snapshot: current,
          sample: sample(),
          now: now,
          chosenIds: chosen,
          categories: {},
        ),
        isNotNull,
      );
      final future = fixtures.snapshot(q: fixtures.query(corridor: 1000));
      final before = now.subtract(const Duration(seconds: 1));
      expect(
        p.evaluate(
          snapshot: future,
          sample: sample(time: before),
          now: before,
          chosenIds: chosen,
          categories: {},
        ),
        isNull,
      );
      final later = now.add(const Duration(seconds: 1));
      expect(
        p.evaluate(
          snapshot: current,
          sample: sample(time: later),
          now: later,
          chosenIds: chosen,
          categories: {},
        ),
        isNull,
      );
    },
  );

  test(
    'proximity hysteresis retains a pending candidate in the boundary band',
    () {
      final data = fixtures.envelope();
      final first = Map<String, Object?>.from(
        (data['results'] as List).first as Map,
      );
      final second = Map<String, Object?>.from(first)
        ..['id'] = '00000000-0000-4000-8000-000000000002';
      data['results'] = [first, second];
      final snapshot = const SnapshotCodec().fromEnvelope(
        data,
        fixtures.query(),
        fixtures.captured,
      );
      final config = ProximityConfig(
        enterMeters: 100,
        exitMeters: 200,
        maxAccuracyMeters: 30,
        maxAge: const Duration(seconds: 10),
        cooldown: const Duration(seconds: 5),
        maxBearingDifference: 45,
        maxSpeedAccuracy: 3,
      );
      final evaluator = POIProximityEvaluator(config);
      final ids = {first['id'] as String, second['id'] as String};
      expect(
        evaluator
            .evaluate(
              snapshot: snapshot,
              sample: sample(),
              now: now,
              chosenIds: ids,
              categories: {},
            )
            ?.poiId,
        first['id'],
      );
      final later = now.add(const Duration(seconds: 5));
      final band = LocationSample(
        position: const LocationPoint(latitude: 10.001, longitude: 20),
        timestamp: later,
        accuracyMeters: 2,
      );
      expect(
        POIProximityEvaluator(config).evaluate(
          snapshot: snapshot,
          sample: band,
          now: later,
          chosenIds: ids,
          categories: {},
        ),
        isNull,
      );
      expect(
        evaluator
            .evaluate(
              snapshot: snapshot,
              sample: band,
              now: later,
              chosenIds: ids,
              categories: {},
            )
            ?.poiId,
        second['id'],
      );
    },
  );

  test('chosen candidates beat suggested candidates and cooldown does not lose pending POIs', () {
    final data = fixtures.envelope();
    final first = Map<String, Object?>.from(
      (data['results'] as List).first as Map,
    );
    first['location'] = {'latitude': 10.0, 'longitude': 20.001};
    final second = Map<String, Object?>.from(first);
    second['id'] = '00000000-0000-4000-8000-000000000002';
    second['location'] = {'latitude': 10.0, 'longitude': 20.002};
    data['results'] = [first, second];
    final snapshot = const SnapshotCodec().fromEnvelope(
      data,
      fixtures.query(),
      fixtures.captured,
    );
    final evaluator = POIProximityEvaluator(
      ProximityConfig(
        enterMeters: 300,
        exitMeters: 400,
        maxAccuracyMeters: 30,
        maxAge: const Duration(seconds: 10),
        cooldown: const Duration(seconds: 5),
        maxBearingDifference: 45,
        maxSpeedAccuracy: 3,
      ),
    );
    PoiAlert? check(int seconds) => evaluator.evaluate(
      snapshot: snapshot,
      sample: sample(time: now.add(Duration(seconds: seconds))),
      now: now.add(Duration(seconds: seconds)),
      chosenIds: {second['id'] as String},
      categories: {'MUSEUM'},
    );
    expect(check(0)?.poiId, second['id']);
    expect(check(1), isNull);
    expect(check(5)?.poiId, first['id']);
    expect(check(6), isNull);
  });
  test(
    'session switches await stop before start and discard previous callback',
    () async {
      final service = FakeService();
      final manager = TrackingSessionManager(service);
      var count = 0;
      Future<void> start(TrackingMode mode) => manager.start(
        mode,
        consent: true,
        prerequisites: true,
        continuousGate: true,
        onSample: (_) => count++,
      );
      await start(TrackingMode.activeRoute);
      final late = service.callback!;
      await start(TrackingMode.continuous);
      expect(service.starts, 2);
      expect(service.stops, 2);
      expect(manager.mode, TrackingMode.continuous);
      late(sample());
      expect(count, 0);
      service.callback!(sample());
      expect(count, 1);
      await manager.close();
    },
  );

  test(
    'queued mode change cannot be mistaken for an idempotent active start',
    () async {
      final f = FakeService(), m = TrackingSessionManager(FakeService());
      await m.close();
      final manager = TrackingSessionManager(f);
      Future<void> start(TrackingMode mode) => manager.start(
        mode,
        consent: true,
        prerequisites: true,
        continuousGate: true,
        onSample: (_) {},
      );
      await start(TrackingMode.activeRoute);
      final old = f.callback!;
      final switchMode = start(TrackingMode.continuous);
      final returnMode = start(TrackingMode.activeRoute);
      await switchMode;
      await returnMode;
      expect(manager.mode, TrackingMode.activeRoute);
      expect(f.starts, 2);
      old(sample());
      await manager.close();
      await expectLater(start(TrackingMode.activeRoute), throwsStateError);
    },
  );
  test('failed service stop reports interrupted rather than off', () async {
    final f = FakeService(), m = TrackingSessionManager(FakeService());
    await m.close();
    final manager = TrackingSessionManager(f);
    await manager.start(
      TrackingMode.activeRoute,
      consent: true,
      prerequisites: true,
      continuousGate: false,
      onSample: (_) {},
    );
    f.failStop = true;
    await expectLater(manager.stop(), throwsStateError);
    expect(manager.state, TrackingState.interrupted);
    expect(manager.mode, isNull);
    f.failStop = false;
    await manager.stop();
    expect(manager.state, TrackingState.off);
  });

  test(
    'camera rejects old future degraded duplicate and out-of-range samples',
    () {
      final p = GPSCameraPolicy();
      expect(
        p.evaluate(
          sample(time: now.subtract(const Duration(minutes: 1))),
          now: now,
          currentZoom: 15,
          currentRotation: 0,
        ),
        isNull,
      );
      expect(
        p.evaluate(
          sample(time: now.add(const Duration(seconds: 1))),
          now: now,
          currentZoom: 15,
          currentRotation: 0,
        ),
        isNull,
      );
      expect(
        p.evaluate(
          sample(accuracy: 100),
          now: now,
          currentZoom: 15,
          currentRotation: 0,
        ),
        isNull,
      );
      expect(
        p.evaluate(sample(), now: now, currentZoom: 15, currentRotation: 0),
        isNotNull,
      );
      expect(
        p.evaluate(sample(), now: now, currentZoom: 15, currentRotation: 0),
        isNull,
      );
      expect(
        LocationSample(
          position: const LocationPoint(latitude: 91, longitude: 0),
          timestamp: nullDate,
          accuracyMeters: 1,
        ).isUsable,
        isFalse,
      );
    },
  );
  test('course rotation wraps smoothly and stops preserve view', () {
    final p = GPSCameraPolicy();
    final t = p.evaluate(
      sample(heading: 1),
      now: now,
      currentZoom: 15,
      currentRotation: 1,
    )!;
    expect(t.rotation, closeTo(.5, .001));
    expect(t.zoom, closeTo(14.8, .001));
    final stopped = p.evaluate(
      sample(time: now.add(const Duration(seconds: 1)), speed: 0),
      now: now.add(const Duration(seconds: 1)),
      currentZoom: t.zoom,
      currentRotation: t.rotation,
    )!;
    expect(stopped.zoom, t.zoom);
    expect(stopped.rotation, t.rotation);
  });
  test('zoom hysteresis and invalid heading retain stable orientation', () {
    final p = GPSCameraPolicy();
    var t = p.evaluate(
      sample(heading: double.nan),
      now: now,
      currentZoom: 15,
      currentRotation: 40,
    )!;
    expect(t.rotation, 40);
    t = p.evaluate(
      sample(time: now.add(const Duration(seconds: 1)), speed: 13),
      now: now.add(const Duration(seconds: 1)),
      currentZoom: t.zoom,
      currentRotation: 40,
    )!;
    expect(t.zoom, closeTo(14.6, .001));
    t = p.evaluate(
      sample(time: now.add(const Duration(seconds: 2)), speed: 11),
      now: now.add(const Duration(seconds: 2)),
      currentZoom: t.zoom,
      currentRotation: 40,
    )!;
    expect(t.zoom, closeTo(14.8, .001));
  });
  test(
    'session repeated start and stop are idempotent and late samples rejected',
    () async {
      final f = FakeService(), m = TrackingSessionManager(FakeService());
      await m.close();
      final manager = TrackingSessionManager(f);
      var count = 0;
      Future<void> start() => manager.start(
        TrackingMode.activeRoute,
        consent: true,
        prerequisites: true,
        continuousGate: false,
        onSample: (_) => count++,
      );
      await start();
      await start();
      expect(f.starts, 1);
      f.callback!(sample());
      expect(count, 1);
      await manager.revoke();
      f.callback!(sample());
      expect(count, 1);
      final stops = f.stops;
      await manager.stop();
      expect(f.stops, stops);
    },
  );
  test('revocation during service start cancels pending activation', () async {
    final f = FakeService()..pending = Completer<void>();
    final m = TrackingSessionManager(f);
    final start = m.start(
      TrackingMode.activeRoute,
      consent: true,
      prerequisites: true,
      continuousGate: false,
      onSample: (_) => fail('Late callback'),
    );
    await Future<void>.delayed(Duration.zero);
    final stop = m.revoke();
    f.pending!.complete();
    await start;
    await stop;
    expect(m.state, TrackingState.off);
    expect(m.mode, isNull);
    f.callback!(sample());
  });
  test(
    'continuous gate fails and route completion never activates continuous',
    () async {
      final f = FakeService(), m = TrackingSessionManager(FakeService());
      await expectLater(
        m.start(
          TrackingMode.continuous,
          consent: true,
          prerequisites: true,
          continuousGate: false,
          onSample: (_) {},
        ),
        throwsStateError,
      );
      final manager = TrackingSessionManager(f);
      await manager.start(
        TrackingMode.activeRoute,
        consent: true,
        prerequisites: true,
        continuousGate: false,
        onSample: (_) {},
      );
      await manager.completeRoute();
      expect(manager.mode, isNull);
      expect(f.starts, 1);
    },
  );
  test(
    'proximity chooses selected POI deduplicates and rejects expired snapshot',
    () {
      final p = POIProximityEvaluator(
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
      final snapshot = fixtures.snapshot();
      final id = snapshot.pois.first.id;
      final alert = p.evaluate(
        snapshot: snapshot,
        sample: sample(),
        now: now,
        chosenIds: {id},
        categories: {},
      );
      expect(alert?.poiId, id);
      expect(alert?.chosen, isTrue);
      expect(
        p.evaluate(
          snapshot: fixtures.snapshot(),
          sample: sample(time: now.add(const Duration(seconds: 6))),
          now: now.add(const Duration(seconds: 6)),
          chosenIds: {id},
          categories: {},
        ),
        isNull,
      );
      p.reset();
      expect(
        p.evaluate(
          snapshot: snapshot,
          sample: sample(time: now.add(const Duration(days: 1))),
          now: now.add(const Duration(days: 1)),
          chosenIds: {id},
          categories: {},
        ),
        isNull,
      );
    },
  );
  test('proximity rejects degraded and suggested POIs without course', () {
    final p = POIProximityEvaluator(
      ProximityConfig(
        enterMeters: 1000,
        exitMeters: 1200,
        maxAccuracyMeters: 30,
        maxAge: const Duration(seconds: 10),
        cooldown: Duration.zero,
        maxBearingDifference: 45,
        maxSpeedAccuracy: 3,
      ),
    );
    final s = fixtures.snapshot();
    expect(
      p.evaluate(
        snapshot: s,
        sample: sample(accuracy: 100),
        now: now,
        chosenIds: {s.pois.first.id},
        categories: {},
      ),
      isNull,
    );
    expect(
      p.evaluate(
        snapshot: s,
        sample: sample(heading: null),
        now: now,
        chosenIds: {},
        categories: {s.pois.first.category},
      ),
      isNull,
    );
  });
}

final nullDate = DateTime.utc(2026);
