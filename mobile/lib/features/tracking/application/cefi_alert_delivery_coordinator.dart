import 'dart:async';

import 'poi_proximity_evaluator.dart';

enum AlertDeliveryState {
  accepted,
  delivered,
  failed,
  suppressed,
  expired,
  cancelled,
}

class CEFIAlertEvent {
  CEFIAlertEvent(
    this.eventId,
    this.generation,
    this.snapshotRevision,
    this.candidate,
    this.expiresAt,
  );
  final String eventId, snapshotRevision;
  final int generation;
  final PoiAlert candidate;
  final DateTime expiresAt;
  AlertDeliveryState _state = AlertDeliveryState.accepted;
  AlertDeliveryState get state => _state;
}

class CEFIAlertAck {
  const CEFIAlertAck(
    this.eventId,
    this.generation,
    this.snapshotRevision,
    this.state,
  );
  final String eventId, snapshotRevision;
  final int generation;
  final AlertDeliveryState state;
}

/// A terminal ack means the adapter released output ownership. DELIVERED means
/// completed output, not merely queued output. cancel must complete only after
/// output is stopped; failure blocks subsequent dispatch. No adapter retries.
abstract interface class CEFIAlertDeliveryPort {
  Future<CEFIAlertAck> deliver(CEFIAlertEvent event);
  Future<void> cancel(String eventId);
}

/// Technical simulated completion only: no sound, notification or persistence.
class SilentAlertSink implements CEFIAlertDeliveryPort {
  @override
  Future<CEFIAlertAck> deliver(CEFIAlertEvent e) async => CEFIAlertAck(
    e.eventId,
    e.generation,
    e.snapshotRevision,
    AlertDeliveryState.delivered,
  );
  @override
  Future<void> cancel(String eventId) async {}
}

class CEFIAlertDeliveryCoordinator {
  CEFIAlertDeliveryCoordinator(
    this.port, {
    required this.cooldown,
    required this.validity,
    DateTime Function()? clock,
  }) : now = clock ?? DateTime.now {
    if (cooldown.isNegative || validity <= Duration.zero) {
      throw ArgumentError('Invalid delivery limits');
    }
  }
  final CEFIAlertDeliveryPort port;
  final Duration cooldown, validity;
  final DateTime Function() now;
  static int _nextGeneration = 0;
  int _generation = 0, _sequence = 0;
  String? _revision;
  DateTime? _contextExpiry, _lastSample, _lastDelivered;
  final Set<String> _delivered = {};
  final Map<String, DateTime> _attempts = {};
  CEFIAlertEvent? _flight, _pending, _lastOutcome;
  Timer? _deadline;
  int _cancelling = 0;
  bool _outputUnsafe = false;
  bool get outputBlocked => _outputUnsafe || _cancelling != 0;
  CEFIAlertEvent? get inFlight => _flight;
  CEFIAlertEvent? get pending => _pending;
  CEFIAlertEvent? get lastOutcome => _lastOutcome;
  int get generation => _generation;
  void open(String revision, DateTime expiresAt) {
    stop();
    _generation = ++_nextGeneration;
    _revision = revision;
    _contextExpiry = expiresAt;
  }

  void _finish(CEFIAlertEvent e, AlertDeliveryState state) {
    e._state = state;
    _lastOutcome = e;
  }

  void _cancel(CEFIAlertEvent e, AlertDeliveryState state) {
    _finish(e, state);
    _cancelling++;
    unawaited(
      Future<void>.sync(() => port.cancel(e.eventId))
          .catchError((Object _) {
            _outputUnsafe = true;
          })
          .whenComplete(() {
            _cancelling--;
          }),
    );
  }

  // Consent changes cancel outstanding work without replay or resetting consumed POIs.
  void cancelOutstanding() {
    _deadline?.cancel();
    _deadline = null;
    if (_flight case final e?) _cancel(e, AlertDeliveryState.cancelled);
    if (_pending case final e?) _finish(e, AlertDeliveryState.cancelled);
    _flight = _pending = null;
    _generation = ++_nextGeneration;
  }

  void stop() {
    _revision = null;
    _deadline?.cancel();
    _deadline = null;
    if (_flight case final e?) _cancel(e, AlertDeliveryState.cancelled);
    if (_pending case final e?) _finish(e, AlertDeliveryState.cancelled);
    _flight = _pending = null;
    _lastSample = _lastDelivered = _contextExpiry = null;
    _attempts.clear();
    _delivered.clear();
  }

  void _expire() {
    final time = now();
    if (_flight case final e?) {
      if (!time.isBefore(e.expiresAt)) {
        _flight = null;
        _cancel(e, AlertDeliveryState.expired);
      }
    }
    if (_pending case final e?) {
      if (!time.isBefore(e.expiresAt)) {
        _pending = null;
        _finish(e, AlertDeliveryState.expired);
      }
    }
    if (_contextExpiry != null && !time.isBefore(_contextExpiry!)) stop();
  }

  void _schedule() {
    _deadline?.cancel();
    final deadlines = [
      if (_flight != null) _flight!.expiresAt,
      if (_pending != null) _pending!.expiresAt,
    ];
    if (deadlines.isEmpty || _revision == null) return;
    deadlines.sort();
    _deadline = Timer(deadlines.first.difference(now()), () {
      _expire();
      _schedule();
    });
  }

  CEFIAlertEvent _event(PoiAlert candidate) {
    final expiry = now().add(validity);
    return CEFIAlertEvent(
      '$_generation:${++_sequence}',
      _generation,
      _revision!,
      candidate,
      expiry.isBefore(_contextExpiry!) ? expiry : _contextExpiry!,
    );
  }

  // Called only for a fresh, valid proximity sample, never from an ack/retry timer.
  void consider(List<PoiAlert> candidates, DateTime sampleTime) {
    _expire();
    if (_revision == null ||
        sampleTime.isAfter(now()) ||
        now().difference(sampleTime) > validity ||
        (_lastSample != null && !sampleTime.isAfter(_lastSample!))) {
      return;
    }
    _lastSample = sampleTime;
    final eligible = candidates
        .where((c) => !_delivered.contains(c.poiId))
        .toList();
    eligible.sort((a, b) {
      final priority = (a.chosen ? 0 : 1).compareTo(b.chosen ? 0 : 1);
      return priority != 0
          ? priority
          : candidates.indexOf(a).compareTo(candidates.indexOf(b));
    });
    if (_pending != null &&
        !eligible.any((c) => c.poiId == _pending!.candidate.poiId)) {
      _attempts[_pending!.candidate.poiId] = now();
      _finish(_pending!, AlertDeliveryState.suppressed);
      _pending = null;
    }
    final retryGap = cooldown > validity ? cooldown : validity;
    for (final c in eligible) {
      if (_flight?.candidate.poiId == c.poiId) continue;
      if (_pending?.candidate.poiId == c.poiId) continue;
      final attempt = _attempts[c.poiId];
      if (attempt != null && now().difference(attempt) < retryGap) continue;
      if (!outputBlocked &&
          _flight == null &&
          _pending == null &&
          (_lastDelivered == null ||
              now().difference(_lastDelivered!) >= cooldown)) {
        _dispatch(_event(c));
      } else if (_pending == null) {
        _pending = _event(c);
      } else if (c.chosen && !_pending!.candidate.chosen) {
        _attempts[_pending!.candidate.poiId] = now();
        _finish(_pending!, AlertDeliveryState.suppressed);
        _pending = _event(c);
      } else {
        _attempts[c.poiId] = now();
        _finish(_event(c), AlertDeliveryState.suppressed);
      }
    }
    if (!outputBlocked &&
        _flight == null &&
        _pending != null &&
        (_lastDelivered == null ||
            now().difference(_lastDelivered!) >= cooldown)) {
      final e = _pending!;
      _pending = null;
      _dispatch(e);
    }
    _schedule();
  }

  void _dispatch(CEFIAlertEvent e) {
    _flight = e;
    _attempts[e.candidate.poiId] = now();
    unawaited(
      Future<CEFIAlertAck>.sync(() => port.deliver(e))
          .then((ack) {
            if (_revision == null ||
                _flight != e ||
                e.generation != _generation ||
                e.snapshotRevision != _revision) {
              return;
            }
            _expire();
            if (_flight != e) return;
            _flight = null;
            final valid =
                ack.eventId == e.eventId &&
                ack.generation == e.generation &&
                ack.snapshotRevision == e.snapshotRevision;
            final state = valid && ack.state != AlertDeliveryState.accepted
                ? ack.state
                : AlertDeliveryState.failed;
            _finish(e, state);
            if (state == AlertDeliveryState.delivered) {
              _delivered.add(e.candidate.poiId);
              _lastDelivered = now();
            }
            _schedule();
          })
          .catchError((Object _) {
            _expire();
            if (_flight != e || _revision == null) return;
            _flight = null;
            _finish(e, AlertDeliveryState.failed);
            _schedule();
          }),
    );
    _schedule();
  }
}
