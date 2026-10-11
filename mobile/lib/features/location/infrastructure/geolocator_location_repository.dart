import 'package:geolocator/geolocator.dart';

import '../domain/location_repository.dart';

class GeolocatorLocationRepository
    implements LocationRepository, LocationStreamSource {
  @override
  Stream<LocationSample> watchLocation() =>
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).map(
        (position) => LocationSample(
          position: LocationPoint(
            latitude: position.latitude,
            longitude: position.longitude,
          ),
          timestamp: position.timestamp,
          accuracyMeters: position.accuracy,
          headingDegrees: position.heading,
          headingAccuracyDegrees: position.headingAccuracy,
          speedMetersPerSecond: position.speed,
          speedAccuracyMetersPerSecond: position.speedAccuracy,
        ),
      );

  @override
  Future<CurrentLocationResult> requestCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const CurrentLocationResult.withAvailability(
        LocationAvailability.serviceDisabled,
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return const CurrentLocationResult.withAvailability(
        LocationAvailability.denied,
      );
    }
    if (permission == LocationPermission.deniedForever) {
      return const CurrentLocationResult.withAvailability(
        LocationAvailability.deniedForever,
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return CurrentLocationResult.available(
        LocationPoint(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } on LocationServiceDisabledException {
      return const CurrentLocationResult.withAvailability(
        LocationAvailability.serviceDisabled,
      );
    } catch (_) {
      return const CurrentLocationResult.withAvailability(
        LocationAvailability.unavailable,
      );
    }
  }
}
