class LocationPoint {
  const LocationPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;
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

abstract interface class LocationRepository {
  Future<CurrentLocationResult> requestCurrentLocation();
}
