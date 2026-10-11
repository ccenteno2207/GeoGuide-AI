import '../../location/domain/location_repository.dart';

enum TrackingMode { activeRoute, continuous }

enum TrackingState { off, starting, active, stopping, interrupted }

abstract interface class TrackingServicePort {
  Future<void> start(TrackingMode mode, void Function(LocationSample) onSample);
  Future<void> stop();
}

class TrackingSessionManager {
  TrackingSessionManager(this.service);
  final TrackingServicePort service;
  TrackingState _state = TrackingState.off;
  TrackingState get state => _state;
  TrackingMode? _mode;
  TrackingMode? get mode => _mode;
  int _generation = 0;
  int? _activeGeneration;
  Future<void> _queue = Future.value();
  bool _closed = false;
  Future<void> _serial(Future<void> Function() action) {
    final next = _queue.then((_) => action());
    _queue = next.catchError((Object _) {});
    return next;
  }

  Future<void> start(
    TrackingMode requested, {
    required bool consent,
    required bool prerequisites,
    required bool continuousGate,
    required void Function(LocationSample) onSample,
  }) {
    if (_closed ||
        !consent ||
        !prerequisites ||
        (requested == TrackingMode.continuous && !continuousGate)) {
      return Future.error(StateError('Session gate not satisfied'));
    }
    // Repeated active start must not invalidate its own callback generation.
    if (_state == TrackingState.active &&
        _mode == requested &&
        _activeGeneration == _generation) {
      return Future.value();
    }
    final generation = ++_generation;
    return _serial(() async {
      if (generation != _generation || _closed) return;
      try {
        _state = TrackingState.stopping;
        await service.stop();
        _mode = null;
        if (generation != _generation || _closed) {
          _state = TrackingState.off;
          return;
        }
        _state = TrackingState.starting;
        await service.start(requested, (sample) {
          if (!_closed &&
              generation == _generation &&
              _state == TrackingState.active &&
              sample.isUsable) {
            onSample(sample);
          }
        });
        if (generation != _generation || _closed) {
          await service.stop();
          _state = TrackingState.off;
          return;
        }
        _activeGeneration = generation;
        _mode = requested;
        _state = TrackingState.active;
      } catch (_) {
        _mode = null;
        _state = TrackingState.interrupted;
        try {
          await service.stop();
        } catch (_) {}
        rethrow;
      }
    });
  }

  Future<void> stop() {
    ++_generation;
    return _serial(() async {
      if (_state == TrackingState.off) return;
      _state = TrackingState.stopping;
      try {
        await service.stop();
        _state = TrackingState.off;
      } catch (_) {
        _state = TrackingState.interrupted;
        rethrow;
      } finally {
        _mode = null;
      }
    });
  }

  Future<void> revoke() => stop();
  Future<void> completeRoute() => stop();
  Future<void> close() {
    _closed = true;
    return stop();
  }
}
