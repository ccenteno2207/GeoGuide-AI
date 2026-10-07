import 'dart:async';

import '../../../core/network/app_failure.dart';
import '../domain/route_snapshot.dart';
import '../../route_planning/application/plan_route.dart';

enum DiscoveryAvailability { online, cached, unavailable, error }

/// Process-only consent and presentation lifetime; storage details stay in the adapter.
class OfflineDiscovery {
  OfflineDiscovery({
    required this.source,
    required this.store,
    required this.backendContext,
    this.planRoute,
    int Function()? now,
  }) : now = now ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch);
  final DiscoverySnapshotSource source;
  final RouteDiscoverySnapshotStore store;
  final String backendContext;
  final PlanRoute? planRoute;
  final int Function() now;
  void Function()? onChanged;
  RouteSnapshot? snapshot;
  DiscoveryQuery? requested;
  DiscoveryAvailability availability = DiscoveryAvailability.unavailable;
  bool captureEnabled = false, busy = false, saving = false;
  String message = 'Sin copia offline disponible';
  String? cacheMessage;
  int _generation = 0;
  int _consentGeneration = 0;
  bool _disposed = false;
  Timer? _expiry;
  Stopwatch _elapsed = Stopwatch();
  int _ageAtPresentation = 0, _lastObserved = 0;
  void _notify() {
    if (!_disposed) onChanged?.call();
  }

  void _present(RouteSnapshot s, DiscoveryAvailability state) {
    final sameLifetime =
        snapshot?.capturedAtUtcMs == s.capturedAtUtcMs &&
        snapshot!.query.sameAs(s.query);
    snapshot = s;
    availability = state;
    if (!sameLifetime) {
      _ageAtPresentation = now() - s.capturedAtUtcMs;
      _elapsed = Stopwatch()..start();
    }
    if (!sameLifetime || now() > _lastObserved) _lastObserved = now();
    _expiry?.cancel();
    if (state == DiscoveryAvailability.cached) {
      _expiry = Timer(
        Duration(
          milliseconds: (s.expiresAtUtcMs - now()).clamp(
            0,
            (RouteSnapshot.ttlMs -
                    _ageAtPresentation -
                    _elapsed.elapsedMilliseconds)
                .clamp(0, RouteSnapshot.ttlMs),
          ),
        ),
        () => revalidate(),
      );
    }
  }

  Future<void> initialize() async {
    final generation = _generation;
    try {
      final cached = await store.readEligible();
      if (generation != _generation || _disposed) return;
      if (cached != null && cached.query.backendContext == backendContext) {
        _present(cached, DiscoveryAvailability.cached);
        requested = cached.query;
        message = 'Copia offline: puede estar desactualizada. Vigencia máxima 24 horas.';
      }
    } catch (_) {
      cacheMessage = 'Almacenamiento offline no disponible';
    }
    _notify();
  }

  void invalidatePending() {
    _generation++;
  }

  Future<void> discover(DiscoveryQuery query, {bool planFirst = false}) async {
    if (busy || _disposed) return;
    requested = query;
    final generation = ++_generation;
    busy = true;
    message = 'Buscando lugares en la ruta';
    _notify();
    try {
      if (planFirst && planRoute != null) {
        await planRoute!(origin: query.origin, destination: query.destination);
        if (generation != _generation || _disposed) return;
      }
      final result = await source.discover(query);
      if (generation != _generation || _disposed) return;
      if (!result.query.sameAs(query)) {
        throw const AppFailure(AppFailureType.invalidResponse);
      }
      _present(result, DiscoveryAvailability.online);
      message = result.pois.isEmpty
          ? 'Online: no se encontraron lugares'
          : 'Online: ${result.pois.length} lugares';
      _notify();
      await _capture(result, generation);
    } on AppFailure catch (failure) {
      if (generation != _generation || _disposed) return;
      final network =
          failure.type == AppFailureType.backendUnavailable ||
          failure.type == AppFailureType.timeout;
      if (network) {
        RouteSnapshot? cached;
        try {
          cached = await store.readEligible();
        } catch (_) {
          cacheMessage = 'Almacenamiento offline no disponible';
        }
        if (generation != _generation || _disposed) return;
        final previous = snapshot;
        if (cached != null && cached.query.sameAs(query)) {
          _present(cached, DiscoveryAvailability.cached);
          message = 'Copia offline; no se pudo actualizar. Puede estar desactualizada (máximo 24 horas).';
        } else if (previous != null &&
            previous.eligible(now()) &&
            now() >= _lastObserved &&
            _ageAtPresentation + _elapsed.elapsedMilliseconds <
                RouteSnapshot.ttlMs) {
          // Retain its original query; never label it as the failed new query.
          _present(previous, DiscoveryAvailability.cached);
          message = 'No se pudo actualizar. Se conserva la consulta anterior como copia temporal (máximo 24 horas).';
        } else {
          snapshot = null;
          availability = DiscoveryAvailability.unavailable;
          message = 'Sin datos offline disponibles. ${failure.userMessage}';
        }
      } else {
        final previous = snapshot;
        if (previous != null) _present(previous, DiscoveryAvailability.cached);
        availability = DiscoveryAvailability.error;
        message = 'Error: ${failure.userMessage}. No se actualizó la consulta.';
        await revalidate();
      }
    } catch (_) {
      if (generation == _generation) {
        final previous = snapshot;
        if (previous != null) _present(previous, DiscoveryAvailability.cached);
        availability = DiscoveryAvailability.error;
        message = 'Error: no se pudieron validar los datos recibidos';
        await revalidate();
      }
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> retry() async {
    final q = requested;
    if (q != null) await discover(q);
  }

  Future<void> enableCapture() async {
    if (saving) return;
    captureEnabled = true;
    _consentGeneration++;
    _notify();
    final s = snapshot;
    if (s != null && availability == DiscoveryAvailability.online) {
      await _capture(s, _generation);
    }
  }

  Future<void> _capture(RouteSnapshot s, int generation) async {
    if (!captureEnabled || saving) return;
    final consent = _consentGeneration;
    saving = true;
    _notify();
    try {
      await store.replaceValidated(
        s,
        stillCurrent: () =>
            !_disposed &&
            captureEnabled &&
            consent == _consentGeneration &&
            generation == _generation &&
            now() >= _lastObserved &&
            _ageAtPresentation + _elapsed.elapsedMilliseconds <
                RouteSnapshot.ttlMs &&
            identical(snapshot, s),
      );
      if (consent == _consentGeneration) {
        cacheMessage =
            'Copia offline guardada; vence a las 24 horas de recibirla';
      }
    } catch (_) {
      if (consent == _consentGeneration) cacheMessage = 'No se guardó la copia offline; se conserva la anterior si sigue vigente';
    } finally {
      saving = false;
      _notify();
    }
  }

  Future<void> delete() async {
    captureEnabled = false;
    _consentGeneration++;
    _generation++;
    if (availability != DiscoveryAvailability.online) {
      snapshot = null;
      availability = DiscoveryAvailability.unavailable;
    }
    cacheMessage = 'Eliminando copia offline';
    _notify();
    try {
      await store.delete();
      cacheMessage = 'Copia offline eliminada';
    } catch (_) {
      cacheMessage = 'Borrado pendiente; reintenta eliminar la copia';
    }
    _notify();
  }

  Future<void> revalidate() async {
    final s = snapshot;
    if (s == null || availability == DiscoveryAvailability.online) return;
    final time = now();
    if (!s.eligible(time) ||
        time < _lastObserved ||
        _ageAtPresentation + _elapsed.elapsedMilliseconds >=
            RouteSnapshot.ttlMs) {
      snapshot = null;
      availability = DiscoveryAvailability.unavailable;
      message = 'Copia vencida. Reintenta para consultar datos nuevos.';
      _expiry?.cancel();
      _notify();
      try {
        await store.readEligible();
      } catch (_) {
        /* Never restore expired presentation. */
      }
    } else {
      _lastObserved = time;
    }
  }

  Future<void> dispose() async {
    _disposed = true;
    _generation++;
    _expiry?.cancel();
    onChanged = null;
    await store.close();
  }
}
