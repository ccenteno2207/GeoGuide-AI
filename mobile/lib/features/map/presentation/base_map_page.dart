import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../location/application/request_current_location.dart';
import '../../location/domain/location_repository.dart';
import '../../discovery/application/discover_route.dart';
import '../../discovery/domain/discovery_poi.dart';
import '../../discovery/presentation/poi_preview_sheet.dart';
import '../../discovery/presentation/poi_detail_sheet.dart';
import '../../discovery/presentation/route_discovery_controller.dart';
import '../../route_planning/application/plan_route.dart';
import '../../route_planning/domain/route_point.dart';
import '../../route_planning/presentation/route_planning_controller.dart';

class BaseMapPage extends StatefulWidget {
  const BaseMapPage({
    super.key,
    required this.requestCurrentLocation,
    this.planRoute,
    this.discoverRoute,
  });

  final RequestCurrentLocation requestCurrentLocation;
  final PlanRoute? planRoute;
  final DiscoverRoute? discoverRoute;

  @override
  State<BaseMapPage> createState() => _BaseMapPageState();
}

class _BaseMapPageState extends State<BaseMapPage> {
  final MapController _mapController = MapController();
  LocationPoint? _currentLocation;
  String _locationStatus = 'Ubicación no solicitada';
  bool _isRequestingLocation = false;
  late final RoutePlanningController _routePlanning;
  late final RouteDiscoveryController _routeDiscovery;

  static const developmentTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const attribution = 'OpenStreetMap contributors';
  static const _initialCenter = LatLng(-12.0464, -77.0428);

  @override
  void initState() {
    super.initState();
    _routePlanning = RoutePlanningController(planRoute: widget.planRoute);
    _routeDiscovery = RouteDiscoveryController(
      discoverRoute: widget.discoverRoute,
    );
  }

  Future<void> _requestLocation() async {
    setState(() => _isRequestingLocation = true);
    final result = await widget.requestCurrentLocation();
    if (!mounted) return;

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

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _selectRoutePoint(TapPosition _, LatLng point) {
    setState(() {
      _routePlanning.selectPoint(
        RoutePoint(latitude: point.latitude, longitude: point.longitude),
      );
    });
  }

  Future<void> _calculateRoute() async {
    setState(() {});
    await _routePlanning.calculate();
    final origin = _routePlanning.origin;
    final destination = _routePlanning.destination;
    if (_routePlanning.route != null && origin != null && destination != null) {
      await _routeDiscovery.discover(origin: origin, destination: destination);
    }
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _showPoiPreview(DiscoveryPoi poi) {
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

  Future<void> _showPoiDetail(DiscoveryPoi poi) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => PoiDetailSheet(poi: poi),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GeoGuide AI'),
        actions: [
          IconButton(
            tooltip: 'Usar ubicación actual',
            onPressed: _isRequestingLocation ? null : _requestLocation,
            icon: const Icon(Icons.my_location),
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
                          width: 40,
                          height: 40,
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
              const SimpleAttributionWidget(source: Text(attribution)),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_routePlanning.origin != null &&
                    _routePlanning.destination != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: FilledButton.icon(
                      onPressed: _routePlanning.canPlan
                          ? _calculateRoute
                          : null,
                      icon: _routePlanning.isCalculating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.alt_route),
                      label: const Text('Calcular ruta'),
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
                        Text(_locationStatus, textAlign: TextAlign.center),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
