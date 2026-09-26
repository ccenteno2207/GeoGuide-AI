import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../location/application/request_current_location.dart';
import '../../location/domain/location_repository.dart';

class BaseMapPage extends StatefulWidget {
  const BaseMapPage({super.key, required this.requestCurrentLocation});

  final RequestCurrentLocation requestCurrentLocation;

  @override
  State<BaseMapPage> createState() => _BaseMapPageState();
}

class _BaseMapPageState extends State<BaseMapPage> {
  final MapController _mapController = MapController();
  LocationPoint? _currentLocation;
  String _locationStatus = 'Ubicación no solicitada';
  bool _isRequestingLocation = false;

  static const developmentTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const attribution = 'OpenStreetMap contributors';
  static const _initialCenter = LatLng(-12.0464, -77.0428);

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
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 12,
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
              const SimpleAttributionWidget(source: Text(attribution)),
            ],
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(_locationStatus, textAlign: TextAlign.center),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
