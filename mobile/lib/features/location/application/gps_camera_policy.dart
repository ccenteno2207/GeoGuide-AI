import '../domain/location_repository.dart';

/// Experimental configurable values, not physically calibrated acceptance limits.
class GPSCameraConfig {
  const GPSCameraConfig({
    this.maxAge = const Duration(seconds: 10),
    this.maxAccuracy = 50,
    this.minSpeed = 2,
    this.maxHeadingAccuracy = 30,
    this.maxSpeedAccuracy = 3,
    this.fastEnter = 15,
    this.fastExit = 12,
    this.nearZoom = 15,
    this.fastZoom = 13,
    this.headingFactor = .25,
    this.zoomStep = .2,
  });
  final Duration maxAge;
  final double maxAccuracy, minSpeed, maxHeadingAccuracy, maxSpeedAccuracy;
  final double fastEnter, fastExit, nearZoom, fastZoom, headingFactor, zoomStep;
}

class GPSCameraTarget {
  const GPSCameraTarget(this.position, this.zoom, this.rotation);
  final LocationPoint position;
  final double zoom, rotation;
}

class GPSCameraPolicy {
  GPSCameraPolicy({this.config = const GPSCameraConfig()}) {
    if (config.maxAge <= Duration.zero ||
        [
          config.maxAccuracy,
          config.minSpeed,
          config.maxHeadingAccuracy,
          config.maxSpeedAccuracy,
          config.fastEnter,
          config.fastExit,
          config.nearZoom,
          config.fastZoom,
          config.headingFactor,
          config.zoomStep,
        ].any((v) => !v.isFinite || v < 0) ||
        config.fastExit >= config.fastEnter ||
        config.headingFactor > 1 ||
        config.headingFactor == 0 ||
        config.zoomStep == 0) {
      throw ArgumentError('Invalid camera configuration');
    }
  }
  final GPSCameraConfig config;
  DateTime? _last;
  bool _fast = false;
  void reset() {
    _last = null;
    _fast = false;
  }

  GPSCameraTarget? evaluate(
    LocationSample s, {
    required DateTime now,
    required double currentZoom,
    required double currentRotation,
  }) {
    if (!s.isUsable ||
        s.accuracyMeters > config.maxAccuracy ||
        s.timestamp.isAfter(now) ||
        now.difference(s.timestamp) > config.maxAge ||
        (_last != null && !s.timestamp.isAfter(_last!)) ||
        !currentZoom.isFinite ||
        !currentRotation.isFinite) {
      return null;
    }
    _last = s.timestamp;
    final speed = s.speedMetersPerSecond;
    final speedAccuracy = s.speedAccuracyMetersPerSecond;
    final validSpeed =
        speed != null &&
        speed.isFinite &&
        speed >= 0 &&
        speedAccuracy != null &&
        speedAccuracy.isFinite &&
        speedAccuracy >= 0 &&
        speedAccuracy <= config.maxSpeedAccuracy;
    var rotation = currentRotation;
    var zoom = currentZoom;
    if (validSpeed && speed >= config.minSpeed) {
      if (!_fast && speed >= config.fastEnter) _fast = true;
      if (_fast && speed <= config.fastExit) _fast = false;
      final desired = _fast ? config.fastZoom : config.nearZoom;
      zoom += (desired - zoom).clamp(-config.zoomStep, config.zoomStep);
      final heading = s.headingDegrees, accuracy = s.headingAccuracyDegrees;
      if (heading != null &&
          heading.isFinite &&
          heading >= 0 &&
          heading < 360 &&
          accuracy != null &&
          accuracy.isFinite &&
          accuracy >= 0 &&
          accuracy <= config.maxHeadingAccuracy) {
        // flutter_map rotation is clockwise; course-up needs opposite rotation.
        final desiredRotation = (360 - heading) % 360;
        final delta = (desiredRotation - rotation + 540) % 360 - 180;
        rotation = (rotation + delta * config.headingFactor + 360) % 360;
      }
    }
    return GPSCameraTarget(s.position, zoom, rotation);
  }
}
