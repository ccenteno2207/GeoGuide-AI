class LocationPoint {
  const LocationPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
}

class LocationSample {
  const LocationSample({
    required this.position,
    required this.timestamp,
    required this.accuracyMeters,
    this.headingDegrees,
    this.headingAccuracyDegrees,
    this.speedMetersPerSecond,
    this.speedAccuracyMetersPerSecond,
  });

  final LocationPoint position;
  final DateTime timestamp;
  final double accuracyMeters;
  final double? headingDegrees, headingAccuracyDegrees;
  final double? speedMetersPerSecond, speedAccuracyMetersPerSecond;

  bool get isUsable =>
      position.latitude.isFinite &&
      position.longitude.isFinite &&
      position.latitude.abs() <= 90 &&
      position.longitude.abs() <= 180 &&
      accuracyMeters.isFinite &&
      accuracyMeters >= 0;
}

enum LocationAvailability {
  available,
  serviceDisabled,
  denied,
  deniedForever,
  unavailable,
}

class CurrentLocationResult {
  const CurrentLocationResult._({required this.availability, this.position});

  const CurrentLocationResult.available(LocationPoint position)
    : this._(availability: LocationAvailability.available, position: position);

  const CurrentLocationResult.withAvailability(
    LocationAvailability availability,
  ) : this._(availability: availability);

  final LocationAvailability availability;
  final LocationPoint? position;
}

abstract class LocationRepository {
  Future<CurrentLocationResult> requestCurrentLocation();
}

abstract interface class LocationStreamSource {
  /// Foreground-only stream of location samples.
  Stream<LocationSample> watchLocation();
}
