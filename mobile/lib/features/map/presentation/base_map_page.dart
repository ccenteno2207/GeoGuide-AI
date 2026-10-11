import '../../tracking/application/route_session_client.dart';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../tracking/presentation/voice_diagnostic.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../discovery/application/offline_discovery.dart';
import '../../discovery/domain/route_snapshot.dart';
import '../../discovery/presentation/offline_cache_sheet.dart';

import '../../location/application/request_current_location.dart';
import '../../location/application/gps_camera_policy.dart';
import '../../location/domain/location_repository.dart';
import '../../discovery/application/discover_route.dart';
import '../../discovery/domain/discovery_poi.dart';
import '../../discovery/presentation/poi_preview_sheet.dart';
import '../../discovery/presentation/poi_detail_sheet.dart';
import '../../discovery/presentation/discovery_filter_sheet.dart';
import '../../discovery/presentation/poi_presentation.dart';
import '../../discovery/presentation/route_discovery_controller.dart';
import '../../route_planning/application/plan_route.dart';
import '../../route_planning/domain/route_point.dart';
import '../../route_planning/presentation/route_planning_controller.dart';

class BaseMapPage extends StatefulWidget {
  const BaseMapPage({
    super.key,
    required this.requestCurrentLocation,
    required this.routeSession,
    this.planRoute,
    this.discoverRoute,
    this.offlineDiscovery,
    this.locationClock,
  });

  final RequestCurrentLocation requestCurrentLocation;
  final RouteSessionClient routeSession;
  final PlanRoute? planRoute;
  final DiscoverRoute? discoverRoute;
  final OfflineDiscovery? offlineDiscovery;
  final DateTime Function()? locationClock;

  @override
  State<BaseMapPage> createState() => _BaseMapPageState();
}

class _BaseMapPageState extends State<BaseMapPage> with WidgetsBindingObserver {
  final MapController _mapController = MapController();
  final GPSCameraPolicy _cameraPolicy = GPSCameraPolicy();
  LocationPoint? _currentLocation;
  String _locationStatus = 'Ubicación no solicitada';
  bool _isRequestingLocation = false;
  bool _ownershipPending = true;
  int _refreshRevision = 0, _normalRevision = 0;
  Timer? _freshnessTimer;
  Future<void> _normalCancellation = Future.value();
  DateTime _now() => widget.locationClock?.call() ?? DateTime.now();
  void _cancelFreshness() {
    _freshnessTimer?.cancel();
    _freshnessTimer = null;
  }

  Future<void> _detachNormal() {
    ++_normalRevision;
    _cancelFreshness();
    final old = _locationSubscription;
    _locationSubscription = null;
    _normalCancellation = _normalCancellation.then((_) async {
      await old?.cancel();
    });
    return _normalCancellation;
  }

  void _armFreshness(DateTime timestamp) {
    _cancelFreshness();
    final remaining =
        _cameraPolicy.config.maxAge - _now().difference(timestamp);
    _freshnessTimer = Timer(
      remaining.isNegative ? Duration.zero : remaining,
      () {
        _freshnessTimer = null;
        if (mounted && _followLocation && !_followPausedByLifecycle) {
          setState(
            () => _locationStatus = 'Sin actualización reciente de ubicación',
          );
        }
      },
    );
  }

  bool _showDiscoveryList = false;
  bool _drivingReduced = false;
  bool _b1Owned = false;
  bool _b1Busy = false;
  RouteSessionStatus? _b1Status;
  String get _b1StatusText => switch (_b1Status) {
    RouteSessionStatus.starting => 'Recorrido GPS: iniciando',
    RouteSessionStatus.active => 'Recorrido GPS: activo',
    RouteSessionStatus.interrupted =>
      'Recorrido GPS: interrumpido; revisa ubicación y notificaciones',
    _ => 'Recorrido detenido',
  };
  RouteSessionClient get _routeSession => widget.routeSession;
  bool _followLocation = false;
  bool _followCamera = false;
  bool _followPausedByLifecycle = false;
  DateTime? _lastLocationTimestamp;
  StreamSubscription<LocationSample>? _locationSubscription;
  late final RoutePlanningController _routePlanning;
  late final RouteDiscoveryController _routeDiscovery;

  static const developmentTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const attribution = 'OpenStreetMap contributors';
  static const _initialCenter = LatLng(-12.0464, -77.0428);

  @override
  void initState() {
    super.initState();
    _routeSession.onSample = _onLocationSample;
    _routeSession.onState = (status) {
      final active = status == RouteSessionStatus.active;
      if (!mounted) return;
      final stoppedOwnedSession =
          _b1Owned && !active && status != RouteSessionStatus.starting;
      if (stoppedOwnedSession) ++_refreshRevision;
      final stateRevision = _refreshRevision;
      if (active || status == RouteSessionStatus.starting) {
        _ownershipPending = true;
        unawaited(
          _detachNormal().then((_) {
            if (mounted && _b1Owned && stateRevision == _refreshRevision) {
              setState(() {
                _ownershipPending = false;
                _followPausedByLifecycle = false;
              });
              if (_followLocation) {
                _armFreshness(_lastLocationTimestamp ?? _now());
              }
            }
          }),
        );
      } else if (_b1Owned) {
        _cancelFreshness();
      }
      if (stoppedOwnedSession) {
        _ownershipPending = false;
      }
      setState(() {
        if (_b1Owned ||
            active ||
            status == RouteSessionStatus.starting ||
            status == RouteSessionStatus.interrupted) {
          _b1Status = status;
          _b1Owned = active || status == RouteSessionStatus.starting;
          _followLocation = active;
          if (!active) {
            if (status != RouteSessionStatus.starting) _followCamera = false;
            _locationStatus = status == RouteSessionStatus.interrupted
                ? 'Ubicación no disponible; recorrido interrumpido'
                : status == RouteSessionStatus.starting
                ? 'Esperando inicio del recorrido GPS'
                : 'Recorrido detenido';
          }
        }
      });
    };
    _refreshRouteSession();
    _routePlanning = RoutePlanningController(planRoute: widget.planRoute);
    _routeDiscovery = RouteDiscoveryController(
      discoverRoute: widget.discoverRoute,
    );
    WidgetsBinding.instance.addObserver(this);
    widget.offlineDiscovery?.onChanged = _offlineChanged;
    widget.offlineDiscovery?.initialize();
  }

  Future<void> _refreshRouteSession() async {
    final revision = ++_refreshRevision;
    setState(() => _ownershipPending = true);
    final resumeNormal = _followLocation && !_b1Owned;
    try {
      await _detachNormal();
      await _routeSession.refresh();
      if (!mounted || revision != _refreshRevision) return;
      await _normalCancellation;
      if (!mounted || revision != _refreshRevision) return;
      setState(() {
        _ownershipPending = false;
        _followPausedByLifecycle = false;
      });
      if (resumeNormal && !_b1Owned && !_b1Busy) {
        _followLocation = true;
        _subscribeToLocation();
      }
    } catch (_) {
      if (mounted && revision == _refreshRevision) {
        setState(
          () => _locationStatus =
              'Estado GPS sin confirmar; vuelve a la app para comprobarlo',
        );
      }
    }
  }

  Future<void> _toggleVoiceConsent() async {
    if (_drivingReduced || _b1Busy) return;
    final enabling = !_routeSession.voiceEnabled;
    if (enabling) {
      final accepted = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Avisos de voz CEFI'),
          content: const Text(
            'Avisos breves de lugares cercanos durante el recorrido GPS. Voz local, sin micrófono ni grabación. Pueden reducir temporalmente otro audio. Si no hay voz española local o foco de audio, se omite el aviso. Puedes desactivarlos aquí fuera de Driving o detener el recorrido.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Activar avisos'),
            ),
          ],
        ),
      );
      if (accepted != true || !mounted || _drivingReduced) return;
    }
    try {
      await _routeSession.setVoiceConsent(enabling);
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cambiar el consentimiento de voz'),
          ),
        );
      }
    }
  }

  Future<void> _toggleRouteSession() async {
    if (_ownershipPending ||
        _b1Busy ||
        _drivingReduced ||
        _isRequestingLocation) {
      return;
    }
    if (_b1Owned) {
      try {
        await _routeSession.stop();
      } catch (_) {
        if (mounted) {
          setState(
            () => _locationStatus =
                'No se confirmó la detención; usa Detener en la notificación',
          );
        }
      }
      return;
    }
    final snapshot = widget.offlineDiscovery?.snapshot;
    if (snapshot == null ||
        !snapshot.eligible(DateTime.now().millisecondsSinceEpoch)) {
      return;
    }
    final consent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Iniciar recorrido GPS'),
        content: const Text(
          'La ubicación continuará con la app en segundo plano o pantalla bloqueada hasta detener el recorrido. Sin historial ni envío continuo. Se mostrará una notificación con Detener. Sin navegación giro a giro. Los avisos de voz requieren consentimiento separado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Iniciar recorrido'),
          ),
        ],
      ),
    );
    if (consent != true || !mounted || _ownershipPending) return;
    ++_refreshRevision;
    setState(() {
      _b1Busy = true;
      _b1Status = RouteSessionStatus.starting;
    });
    try {
      await _routeSession.requestPermissions();
      if (!mounted) return;
      await _stopFollowLocation(); // Await cancellation before native producer starts.
      _followLocation = true;
      _followCamera = true;
      _followPausedByLifecycle = false;
      _lastLocationTimestamp = null;
      _cameraPolicy.reset();
      await _routeSession.start(snapshot);
      if (mounted && _routeSession.active) {
        setState(() {
          _b1Owned = true;
          _b1Status = RouteSessionStatus.active;
          _locationStatus = 'Esperando una muestra de ubicación válida';
        });
      }
    } catch (_) {
      await _stopFollowLocation();
      _followLocation = false;
      _followCamera = false;
      if (mounted) {
        setState(() {
          _b1Status = RouteSessionStatus.interrupted;
          _locationStatus = 'No se pudo iniciar el recorrido: revisa ubicación y notificaciones';
        });
      }
    } finally {
      if (mounted) setState(() => _b1Busy = false);
    }
  }

  void _offlineChanged() {
    if (!mounted) return;
    final offline = widget.offlineDiscovery!;
    final snapshot = offline.snapshot;
    setState(() {
      _routeDiscovery.pois = snapshot?.pois ?? const [];
      _routeDiscovery.status = offline.message;
      _routeDiscovery.isDiscovering = offline.busy;
      _routeDiscovery.hasError =
          offline.availability != DiscoveryAvailability.online;
      _routePlanning.route = snapshot?.route;
      if (snapshot != null) {
        _routeDiscovery.origin = snapshot.query.origin;
        _routeDiscovery.destination = snapshot.query.destination;
        _routeDiscovery.appliedCategories = snapshot.query.categories.toSet();
        _routePlanning.origin = snapshot.query.origin;
        _routePlanning.destination = snapshot.query.destination;
      }
    });
    if (!_drivingReduced &&
        snapshot == null &&
        Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      ++_refreshRevision;
      _ownershipPending = true;
      unawaited(_detachNormal());
      if (_followLocation) _followPausedByLifecycle = true;
    }
    if (state == AppLifecycleState.resumed) {
      _refreshRouteSession();
      widget.offlineDiscovery?.revalidate();
    }
  }

  Future<void> _discoverOffline(
    RoutePoint origin,
    RoutePoint destination,
    Set<String> categories, {
    bool planFirst = false,
  }) async {
    if (_b1Owned || _b1Busy) return;
    final offline = widget.offlineDiscovery!;
    await offline.discover(
      DiscoveryQuery(
        backendContext: offline.backendContext,
        origin: origin,
        destination: destination,
        categories: categories,
      ),
      planFirst: planFirst,
    );
  }

  Future<void> _requestLocation() async {
    if (_ownershipPending || _b1Owned || _b1Busy) return;
    if (_drivingReduced) return;
    setState(() => _isRequestingLocation = true);
    final revision = ++_normalRevision;
    final result = await widget.requestCurrentLocation();
    if (!mounted) return;
    if (revision != _normalRevision ||
        _ownershipPending ||
        _b1Owned ||
        _b1Busy) {
      setState(() => _isRequestingLocation = false);
      return;
    }

    setState(() {
      _isRequestingLocation = false;
      _currentLocation = result.position;
      _locationStatus = switch (result.availability) {
        LocationAvailability.available => 'Ubicación actual visible',
        LocationAvailability.serviceDisabled =>
          'Servicio de ubicación no disponible',
        LocationAvailability.denied => 'Permiso de ubicación denegado',
        LocationAvailability.deniedForever =>
          'Permiso de ubicación bloqueado en ajustes',
        LocationAvailability.unavailable => 'Ubicación no disponible',
      };
    });

    final position = result.position;
    if (position != null) {
      _mapController.move(LatLng(position.latitude, position.longitude), 15);
    }
  }

  Future<void> _toggleFollowLocation() async {
    if (_ownershipPending || _drivingReduced || _b1Owned || _b1Busy) return;
    if (_followLocation) {
      await _stopFollowLocation();
      return;
    }
    setState(() => _isRequestingLocation = true);
    final revision = ++_normalRevision;
    final result = await widget.requestCurrentLocation();
    if (!mounted) return;
    if (revision != _normalRevision ||
        _ownershipPending ||
        _b1Owned ||
        _b1Busy) {
      setState(() => _isRequestingLocation = false);
      return;
    }
    setState(() {
      _isRequestingLocation = false;
      _currentLocation = result.position;
      _locationStatus = result.availability == LocationAvailability.available
          ? 'Seguimiento de ubicación activo'
          : 'Seguimiento no disponible';
    });
    if (result.position == null) return;
    _followLocation = true;
    _followCamera = true;
    _lastLocationTimestamp = null;
    _cameraPolicy.reset();
    _mapController.move(
      LatLng(result.position!.latitude, result.position!.longitude),
      15,
    );
    _subscribeToLocation();
  }

  void _subscribeToLocation() {
    if (_ownershipPending ||
        _b1Owned ||
        _b1Busy ||
        _locationSubscription != null) {
      return;
    }
    final revision = ++_normalRevision;
    _armFreshness(_lastLocationTimestamp ?? _now());
    _locationSubscription = widget.requestCurrentLocation.watch().listen(
      (sample) {
        if (revision == _normalRevision && !_ownershipPending && !_b1Owned) {
          _onLocationSample(sample);
        }
      },
      onError: (_) {
        if (mounted &&
            revision == _normalRevision &&
            !_ownershipPending &&
            !_b1Owned) {
          setState(
            () => _locationStatus = 'Ubicación no disponible temporalmente',
          );
        }
      },
    );
  }

  void _onLocationSample(LocationSample sample) {
    final now = _now();
    if (!mounted || !_followLocation || _followPausedByLifecycle) return;
    if (!sample.isUsable || sample.timestamp.isAfter(now)) {
      setState(
        () => _locationStatus =
            'Muestra de ubicación no válida; esperando actualización',
      );
      return;
    }
    if (now.difference(sample.timestamp) > _cameraPolicy.config.maxAge) {
      setState(
        () => _locationStatus =
            'Ubicación desactualizada; esperando actualización',
      );
      return;
    }
    if (_lastLocationTimestamp != null &&
        !sample.timestamp.isAfter(_lastLocationTimestamp!)) {
      return;
    }
    _lastLocationTimestamp = sample.timestamp;
    _armFreshness(sample.timestamp);
    setState(() {
      _currentLocation = sample.position;
      _locationStatus = sample.accuracyMeters > _cameraPolicy.config.maxAccuracy
          ? 'Precisión de ubicación reducida'
          : 'Seguimiento de ubicación activo';
    });
    if (_followCamera && !_drivingReduced) {
      final target = _cameraPolicy.evaluate(
        sample,
        now: now,
        currentZoom: _mapController.camera.zoom,
        currentRotation: _mapController.camera.rotation,
      );
      if (target != null) {
        _mapController.move(
          LatLng(target.position.latitude, target.position.longitude),
          target.zoom,
        );
        _mapController.rotate(target.rotation);
      }
    }
  }

  Future<void> _stopFollowLocation() async {
    await _detachNormal();
    if (!mounted) return;
    setState(() {
      _followLocation = false;
      _followCamera = false;
      _followPausedByLifecycle = false;
      _locationStatus = 'Seguimiento de ubicación detenido';
    });
  }

  void _resumeFollowCamera() {
    if (!_followLocation ||
        _currentLocation == null ||
        _drivingReduced ||
        _lastLocationTimestamp == null ||
        _now().difference(_lastLocationTimestamp!) >=
            _cameraPolicy.config.maxAge) {
      return;
    }
    setState(() => _followCamera = true);
    final location = _currentLocation!;
    _mapController.move(LatLng(location.latitude, location.longitude), 15);
  }

  @override
  void dispose() {
    ++_refreshRevision;
    _cancelFreshness();
    unawaited(_detachNormal());
    _routeSession.onSample = null;
    _routeSession.onState = null;
    WidgetsBinding.instance.removeObserver(this);
    widget.offlineDiscovery?.dispose();
    _mapController.dispose();
    super.dispose();
  }

  void _selectRoutePoint(TapPosition _, LatLng point) {
    if (_ownershipPending || _drivingReduced || _b1Owned || _b1Busy) return;
    if (widget.offlineDiscovery?.busy == true ||
        widget.offlineDiscovery?.saving == true) {
      return;
    }
    widget.offlineDiscovery?.invalidatePending();
    setState(() {
      if (widget.offlineDiscovery != null) _routeDiscovery.pois = const [];
      _routePlanning.selectPoint(
        RoutePoint(latitude: point.latitude, longitude: point.longitude),
      );
    });
  }

  Future<void> _calculateRoute() async {
    if (_ownershipPending || _b1Owned || _b1Busy) return;
    if (_drivingReduced) return;
    if (widget.offlineDiscovery case final offline?) {
      final origin = _routePlanning.origin,
          destination = _routePlanning.destination;
      if (origin != null && destination != null && !offline.busy) {
        await _discoverOffline(
          origin,
          destination,
          discoveryCategoryCodes.toSet(),
          planFirst: true,
        );
      }
      return;
    }
    setState(() {});
    await _routePlanning.calculate();
    final origin = _routePlanning.origin;
    final destination = _routePlanning.destination;
    if (_routePlanning.route != null && origin != null && destination != null) {
      await _routeDiscovery.discover(
        origin: origin,
        destination: destination,
        categories: discoveryCategoryCodes.toSet(),
      );
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openFilters() async {
    if (_drivingReduced) return;
    final origin = _routePlanning.origin;
    final destination = _routePlanning.destination;
    if (origin == null || destination == null || _routePlanning.route == null) {
      return;
    }
    final categories = await showModalBottomSheet<Set<String>>(
      context: context,
      isScrollControlled: true,
      builder: (_) => DiscoveryFilterSheet(
        appliedCategories: _routeDiscovery.appliedCategories,
      ),
    );
    if (!mounted || categories == null) return;
    if (widget.offlineDiscovery != null) {
      await _discoverOffline(origin, destination, categories);
      return;
    }
    await _routeDiscovery.discover(
      origin: origin,
      destination: destination,
      categories: categories,
    );
    if (mounted) setState(() {});
  }

  String _filterSummary() {
    final applied = _routeDiscovery.appliedCategories;
    if (applied.length == discoveryCategoryCodes.length) return 'Todas';
    if (applied.isEmpty) return '0 categorías';
    return '${applied.length} categorías';
  }

  Future<void> _retryDiscovery() async {
    if (_drivingReduced) return;
    if (widget.offlineDiscovery case final offline?) {
      await offline.retry();
      return;
    }
    final origin = _routePlanning.origin;
    final destination = _routePlanning.destination;
    if (origin == null || destination == null) return;
    await _routeDiscovery.discover(
      origin: origin,
      destination: destination,
      categories: _routeDiscovery.appliedCategories,
    );
    if (mounted) setState(() {});
  }

  Future<void> _showPoiPreview(DiscoveryPoi poi) async {
    if (_drivingReduced) return;
    final offline = widget.offlineDiscovery;
    if (offline != null) {
      await offline.revalidate();
      if (!mounted ||
          !(offline.snapshot?.pois.any((p) => identical(p, poi)) ?? false)) {
        return;
      }
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PoiPreviewSheet(
        poi: poi,
        onViewDetail: () {
          Navigator.of(context).pop();
          _showPoiDetail(poi);
        },
      ),
    );
  }

  Future<void> _showPoiDetail(DiscoveryPoi poi) async {
    if (_drivingReduced) return;
    final offline = widget.offlineDiscovery;
    if (offline != null) {
      await offline.revalidate();
      if (!mounted ||
          !(offline.snapshot?.pois.any((p) => identical(p, poi)) ?? false)) {
        return;
      }
    }
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PoiDetailSheet(poi: poi),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_drivingReduced) return _buildDrivingView(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoGuide AI'),
        actions: [
          if (VoiceDiagnosticAction.available(
            debug: kDebugMode,
            driving: _drivingReduced,
          ))
            VoiceDiagnosticAction(
              consent: _routeSession.voiceEnabled,
              routeBusy: _b1Owned || _b1Busy || _routeSession.active,
            ),
          IconButton(
            tooltip: _routeSession.voiceEnabled
                ? 'Desactivar avisos de voz CEFI'
                : 'Activar avisos de voz CEFI',
            icon: Icon(
              _routeSession.voiceEnabled ? Icons.volume_up : Icons.volume_off,
            ),
            onPressed: _b1Busy ? null : _toggleVoiceConsent,
          ),
          if (widget.offlineDiscovery?.snapshot != null || _b1Owned)
            IconButton(
              onPressed: (_ownershipPending || _b1Busy || _isRequestingLocation)
                  ? null
                  : _toggleRouteSession,
              tooltip: _b1Owned
                  ? 'Detener recorrido GPS'
                  : 'Iniciar recorrido GPS',
              icon: Icon(_b1Owned ? Icons.stop_circle : Icons.route),
            ),
          if (widget.offlineDiscovery case final offline?)
            IconButton(
              tooltip: 'Gestionar copia offline',
              icon: const Icon(Icons.offline_pin),
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => OfflineCacheSheet(controller: offline),
              ),
            ),
          IconButton(
            tooltip: (_b1Owned || _b1Busy)
                ? 'Ubicación puntual no disponible durante el recorrido GPS'
                : 'Usar ubicación actual',
            onPressed:
                (_ownershipPending ||
                    _isRequestingLocation ||
                    _b1Owned ||
                    _b1Busy)
                ? null
                : _requestLocation,
            icon: const Icon(Icons.my_location),
          ),
          if (_followLocation && !_followCamera)
            IconButton(
              tooltip: 'Reanudar seguimiento de cámara',
              icon: const Icon(Icons.center_focus_strong),
              onPressed: _resumeFollowCamera,
            ),
          IconButton(
            tooltip: (_b1Owned || _b1Busy)
                ? 'Seguimiento normal no disponible: el recorrido GPS controla la ubicación'
                : _followLocation
                ? 'Detener seguimiento de ubicación'
                : 'Activar seguimiento de ubicación',
            icon: Icon(_followLocation ? Icons.gps_fixed : Icons.gps_not_fixed),
            onPressed:
                (_ownershipPending ||
                    _isRequestingLocation ||
                    _b1Owned ||
                    _b1Busy)
                ? null
                : _toggleFollowLocation,
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12,
              onTap: _selectRoutePoint,
              onPositionChanged: (_, hasGesture) {
                if (hasGesture && _followCamera) {
                  setState(() => _followCamera = false);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: developmentTileUrl,
                userAgentPackageName: 'com.geoguideai.geoguide_ai',
                maxNativeZoom: 19,
              ),
              if (_currentLocation case final location?)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(location.latitude, location.longitude),
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.my_location,
                        color: Colors.blue,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              if (_routePlanning.origin case final origin?)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(origin.latitude, origin.longitude),
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.trip_origin,
                        color: Colors.green,
                        size: 34,
                      ),
                    ),
                  ],
                ),
              if (_routePlanning.destination case final destination?)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(
                        destination.latitude,
                        destination.longitude,
                      ),
                      width: 44,
                      height: 44,
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.red,
                        size: 36,
                      ),
                    ),
                  ],
                ),
              if (_routePlanning.route case final route?)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: route.geometry
                          .map(
                            (point) => LatLng(point.latitude, point.longitude),
                          )
                          .toList(growable: false),
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 5,
                    ),
                  ],
                ),
              if (_routeDiscovery.pois.isNotEmpty)
                MarkerLayer(
                  markers: _routeDiscovery.pois
                      .map(
                        (poi) => Marker(
                          point: LatLng(
                            poi.location.latitude,
                            poi.location.longitude,
                          ),
                          width: 48,
                          height: 48,
                          child: IconButton(
                            tooltip: 'Vista previa de ${poi.name}',
                            onPressed: () => _showPoiPreview(poi),
                            icon: const Icon(
                              Icons.place,
                              color: Colors.deepOrange,
                              size: 32,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              Align(
                alignment: Alignment.topRight,
                child: ColoredBox(
                  color: Theme.of(context).colorScheme.surface,
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Wrap(
                      children: [Text('flutter_map | © '), Text(attribution)],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            top: 80,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_routePlanning.origin != null &&
                        _routePlanning.destination != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FilledButton.icon(
                          onPressed:
                              _routePlanning.canPlan &&
                                  !_routeDiscovery.isDiscovering
                              ? _calculateRoute
                              : null,
                          icon: _routePlanning.isCalculating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.alt_route),
                          label: const Text('Calcular ruta'),
                        ),
                      ),
                    if (_routePlanning.route != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FilledButton.tonalIcon(
                          onPressed: _routeDiscovery.isDiscovering
                              ? null
                              : _openFilters,
                          icon: const Icon(Icons.filter_alt),
                          label: Text('Categorías: ${_filterSummary()}'),
                        ),
                      ),
                    if (_routeDiscovery.pois.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: FilledButton.tonalIcon(
                          onPressed: () => setState(
                            () => _showDiscoveryList = !_showDiscoveryList,
                          ),
                          icon: Icon(
                            _showDiscoveryList ? Icons.map : Icons.list,
                          ),
                          label: Text(
                            _showDiscoveryList ? 'Ver mapa' : 'Ver lista',
                          ),
                        ),
                      ),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _routeDiscovery.status ?? _routePlanning.status,
                              textAlign: TextAlign.center,
                            ),
                            if (_b1Status != null)
                              Text(_b1StatusText, textAlign: TextAlign.center),
                            if (_b1Owned || _b1Busy)
                              const Text(
                                'Ubicación controlada por el recorrido GPS; controles normales no disponibles',
                                textAlign: TextAlign.center,
                              ),
                            Text(_locationStatus, textAlign: TextAlign.center),
                            if (widget.offlineDiscovery
                                case final offline?) ...[
                              if (offline.snapshot case final snapshot?)
                                Text(
                                  'Ruta: ${(snapshot.route.distanceMeters / 1000).toStringAsFixed(1)} km · ${(snapshot.route.durationSeconds / 60).round()} min planificados\n'
                                  'Origen: ${snapshot.query.origin.latitude.toStringAsFixed(4)}, ${snapshot.query.origin.longitude.toStringAsFixed(4)}\n'
                                  'Destino: ${snapshot.query.destination.latitude.toStringAsFixed(4)}, ${snapshot.query.destination.longitude.toStringAsFixed(4)}\n'
                                  'Corredor: ${snapshot.query.corridorMeters} m · hasta ${snapshot.query.limit} lugares',
                                  textAlign: TextAlign.center,
                                ),
                              Semantics(
                                liveRegion: true,
                                child: Text(switch (offline.availability) {
                                  DiscoveryAvailability.online => 'Online',
                                  DiscoveryAvailability.cached =>
                                    'Copia offline · vigencia máxima 24 horas',
                                  DiscoveryAvailability.unavailable =>
                                    'No disponible',
                                  DiscoveryAvailability.error =>
                                    'Error de actualización',
                                }),
                              ),
                              if (offline.cacheMessage case final message?)
                                Text(message, textAlign: TextAlign.center),
                            ],
                            if (_routeDiscovery.isDiscovering)
                              Semantics(
                                liveRegion: true,
                                label: 'Cargando lugares de la ruta',
                                child: Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            if (_routeDiscovery.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: OutlinedButton.icon(
                                  onPressed: _routeDiscovery.isDiscovering
                                      ? null
                                      : _retryDiscovery,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('Reintentar'),
                                ),
                              ),
                            if (_routeDiscovery.pois.isEmpty &&
                                _routeDiscovery.appliedCategories.length !=
                                    discoveryCategoryCodes.length &&
                                !_routeDiscovery.isDiscovering)
                              const Text(
                                'No encontramos lugares de estas categorías para esta ruta.',
                              ),
                            if (widget.offlineDiscovery?.snapshot != null &&
                                !_routeDiscovery.isDiscovering)
                              FilledButton.icon(
                                onPressed: _enterDriving,
                                icon: const Icon(Icons.directions_car),
                                label: const Text('Entrar en modo conducción'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showDiscoveryList && _routeDiscovery.pois.isNotEmpty)
            Positioned(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 320),
                  child: Card(
                    key: const ValueKey('discovery-list-panel'),
                    child: Semantics(
                      container: true,
                      label: 'Lista de lugares descubiertos',
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              key: const ValueKey('close-discovery-list'),
                              onPressed: () =>
                                  setState(() => _showDiscoveryList = false),
                              icon: const Icon(Icons.close),
                              label: const Text('Cerrar lista y ver mapa'),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _routeDiscovery.pois.length,
                              itemBuilder: (context, index) {
                                final poi = _routeDiscovery.pois[index];
                                return ListTile(
                                  key: ValueKey('discovery-list-${poi.id}'),
                                  title: Text(poi.name),
                                  subtitle: Text(
                                    poiDistanceLabel(poi) ??
                                        friendlyPoiCategory(poi.category),
                                  ),
                                  onTap: () => _showPoiPreview(poi),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _enterDriving() {
    if (_drivingReduced ||
        _routePlanning.route == null ||
        widget.offlineDiscovery?.snapshot == null ||
        widget.offlineDiscovery?.busy == true ||
        widget.offlineDiscovery?.saving == true) {
      return;
    }
    setState(() {
      _drivingReduced = true;
      _showDiscoveryList = false;
    });
  }

  void _exitDriving() {
    if (!mounted) return;
    setState(() => _drivingReduced = false);
  }

  Widget _buildDrivingView(BuildContext context) {
    final route = _routePlanning.route;
    final snapshot = widget.offlineDiscovery?.snapshot;
    final offline = widget.offlineDiscovery;
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(title: const Text('Modo conducción reducido')),
        body: Stack(
          children: [
            if (route != null)
              FlutterMap(
                options: const MapOptions(
                  initialCenter: _initialCenter,
                  initialZoom: 12,
                  interactionOptions: InteractionOptions(
                    flags: InteractiveFlag.none,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate: developmentTileUrl,
                    userAgentPackageName: 'com.geoguideai.geoguide_ai',
                    maxNativeZoom: 19,
                  ),
                  if (_currentLocation case final location?)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: LatLng(location.latitude, location.longitude),
                          width: 48,
                          height: 48,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 36,
                          ),
                        ),
                      ],
                    ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: route.geometry
                            .map((p) => LatLng(p.latitude, p.longitude))
                            .toList(growable: false),
                        color: Theme.of(context).colorScheme.primary,
                        strokeWidth: 5,
                      ),
                    ],
                  ),
                ],
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Explora solo cuando estés detenido',
                            textAlign: TextAlign.center,
                          ),
                          if (route != null)
                            Text(
                              'Ruta estática: ${(route.distanceMeters / 1000).toStringAsFixed(1)} km · ${(route.durationSeconds / 60).round()} min planificados',
                              textAlign: TextAlign.center,
                            ),
                          Text(
                            offline == null
                                ? 'Estado no disponible'
                                : switch (offline.availability) {
                                    DiscoveryAvailability.online =>
                                      'Estado: online',
                                    DiscoveryAvailability.cached =>
                                      'Estado: copia offline',
                                    DiscoveryAvailability.unavailable =>
                                      'Estado: no disponible',
                                    DiscoveryAvailability.error =>
                                      'Estado: error de actualización',
                                  },
                            textAlign: TextAlign.center,
                          ),
                          if (snapshot != null)
                            Text(
                              'Origen y destino conservados en contexto de sesión',
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: _exitDriving,
                              icon: const Icon(Icons.exit_to_app),
                              label: const Text('Salir de modo conducción'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
