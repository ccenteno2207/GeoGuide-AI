import 'package:flutter_test/flutter_test.dart';
import 'package:geoguide_ai/features/location/application/request_current_location.dart';
import 'package:geoguide_ai/features/location/domain/location_repository.dart';

class _StreamRepository implements LocationRepository, LocationStreamSource {
  @override
  Future<CurrentLocationResult> requestCurrentLocation() async =>
      const CurrentLocationResult.withAvailability(
        LocationAvailability.available,
      );

  @override
  Stream<LocationSample> watchLocation() => Stream.value(
    LocationSample(
      position: const LocationPoint(latitude: -12.0, longitude: -77.0),
      timestamp: DateTime.utc(2026, 1, 1),
      accuracyMeters: 4,
    ),
  );
}

void main() {
  test('forwards foreground location samples without persistence', () async {
    final samples = await RequestCurrentLocation(_StreamRepository())
        .watch()
        .toList();

    expect(samples, hasLength(1));
    expect(samples.single.position.latitude, -12.0);
    expect(samples.single.accuracyMeters, 4);
  });

  test(
    'one-shot repositories remain compatible with an empty follow stream',
    () async {
      final repository = _OneShotRepository();

      expect(
        await RequestCurrentLocation(repository).watch().toList(),
        isEmpty,
      );
    },
  );
}

class _OneShotRepository implements LocationRepository {
  @override
  Future<CurrentLocationResult> requestCurrentLocation() async =>
      const CurrentLocationResult.withAvailability(
        LocationAvailability.unavailable,
      );
}
