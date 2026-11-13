import '../domain/location_repository.dart';

enum CurrentLocationQuality { precise, approximate, untrusted }

class ClassifiedLocationFix {
  const ClassifiedLocationFix({
    required this.quality,
    required this.position,
    required this.accuracyMeters,
    required this.timestamp,
  });

  final CurrentLocationQuality quality;
  final LocationPoint? position;
  final double? accuracyMeters;
  final DateTime? timestamp;

  bool get isUsable => quality != CurrentLocationQuality.untrusted;
  double get cameraZoom => quality == CurrentLocationQuality.precise ? 15 : 14;

  String get statusLabel => switch (quality) {
    CurrentLocationQuality.precise => 'Ubicación actual precisa',
    CurrentLocationQuality.approximate =>
      'Ubicación aproximada (±${accuracyMeters!.round()} m)',
    CurrentLocationQuality.untrusted =>
      'Ubicación no confiable; selecciona el origen en el mapa o reintenta',
  };
}

/// Classifies one-shot fixes without implying a street-level guarantee.
///
/// A usable fix must have real coordinates, a measured accuracy and a recent
/// timestamp. Continuous GPS and Driving policies are intentionally separate.
class CurrentLocationFixPolicy {
  const CurrentLocationFixPolicy({
    this.preciseMaxAccuracyMeters = 50,
    this.usableMaxAccuracyMeters = 100,
    this.preciseMaxAge = const Duration(seconds: 10),
    this.usableMaxAge = const Duration(seconds: 30),
  });

  final double preciseMaxAccuracyMeters;
  final double usableMaxAccuracyMeters;
  final Duration preciseMaxAge;
  final Duration usableMaxAge;

  ClassifiedLocationFix classify(CurrentLocationResult result, DateTime now) {
    final point = result.position;
    final accuracy = result.accuracyMeters;
    final timestamp = result.timestamp;
    if (result.availability != LocationAvailability.available ||
        point == null ||
        !point.latitude.isFinite ||
        !point.longitude.isFinite ||
        point.latitude.abs() > 90 ||
        point.longitude.abs() > 180 ||
        accuracy == null ||
        !accuracy.isFinite ||
        accuracy <= 0 ||
        timestamp == null ||
        timestamp.isAfter(now)) {
      return const ClassifiedLocationFix(
        quality: CurrentLocationQuality.untrusted,
        position: null,
        accuracyMeters: null,
        timestamp: null,
      );
    }

    final age = now.difference(timestamp);
    if (accuracy > usableMaxAccuracyMeters || age > usableMaxAge) {
      return ClassifiedLocationFix(
        quality: CurrentLocationQuality.untrusted,
        position: point,
        accuracyMeters: accuracy,
        timestamp: timestamp,
      );
    }

    final precise =
        accuracy <= preciseMaxAccuracyMeters && age <= preciseMaxAge;
    return ClassifiedLocationFix(
      quality: precise
          ? CurrentLocationQuality.precise
          : CurrentLocationQuality.approximate,
      position: point,
      accuracyMeters: accuracy,
      timestamp: timestamp,
    );
  }
}
