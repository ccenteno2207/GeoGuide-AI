import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/location/application/current_location_fix_policy.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';

void main() {
  const policy = CurrentLocationFixPolicy();
  final now = DateTime.utc(2026, 11, 12, 12);

  CurrentLocationResult available({
    double? accuracy = 8,
    DateTime? timestamp,
    LocationPoint? point,
  }) => CurrentLocationResult.available(
    point ?? const LocationPoint(latitude: -12.04, longitude: -77.03),
    accuracyMeters: accuracy,
    timestamp: timestamp ?? now,
  );

  test('classifies a recent high quality fix as precise', () {
    final fix = policy.classify(available(), now);

    expect(fix.quality, CurrentLocationQuality.precise);
    expect(fix.isUsable, isTrue);
    expect(fix.cameraZoom, 15);
    expect(fix.statusLabel, 'Ubicación actual precisa');
  });

  test('classifies lower accuracy or older usable fix as approximate', () {
    final lowAccuracy = policy.classify(available(accuracy: 72), now);
    final older = policy.classify(
      available(timestamp: now.subtract(const Duration(seconds: 20))),
      now,
    );

    expect(lowAccuracy.quality, CurrentLocationQuality.approximate);
    expect(lowAccuracy.statusLabel, 'Ubicación aproximada (±72 m)');
    expect(lowAccuracy.cameraZoom, 14);
    expect(older.quality, CurrentLocationQuality.approximate);
  });

  test('rejects stale, future, unknown and invalid fixes', () {
    final fixes = [
      policy.classify(
        available(timestamp: now.subtract(const Duration(seconds: 31))),
        now,
      ),
      policy.classify(
        available(timestamp: now.add(const Duration(seconds: 1))),
        now,
      ),
      policy.classify(available(accuracy: null), now),
      policy.classify(
        available(point: const LocationPoint(latitude: 91, longitude: 0)),
        now,
      ),
      policy.classify(
        const CurrentLocationResult.withAvailability(
          LocationAvailability.denied,
        ),
        now,
      ),
    ];

    expect(fixes.every((fix) => !fix.isUsable), isTrue);
    expect(
      fixes.every((fix) => fix.quality == CurrentLocationQuality.untrusted),
      isTrue,
    );
  });
}
