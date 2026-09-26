import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BaseMapPage extends StatelessWidget {
  const BaseMapPage({super.key});

  static const developmentTileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const attribution = 'OpenStreetMap contributors';
  static const _initialCenter = LatLng(-12.0464, -77.0428);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GeoGuide AI')),
      body: FlutterMap(
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
          const SimpleAttributionWidget(source: Text(attribution)),
        ],
      ),
    );
  }
}
