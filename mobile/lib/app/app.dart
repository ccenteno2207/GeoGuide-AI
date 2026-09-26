import 'package:flutter/material.dart';

import '../features/map/presentation/base_map_page.dart';
import '../features/location/application/request_current_location.dart';
import '../features/location/domain/location_repository.dart';
import '../features/location/infrastructure/geolocator_location_repository.dart';
import 'theme/geoguide_theme.dart';

class GeoGuideApp extends StatelessWidget {
  GeoGuideApp({super.key, LocationRepository? locationRepository})
    : _requestCurrentLocation = RequestCurrentLocation(
        locationRepository ?? GeolocatorLocationRepository(),
      );

  final RequestCurrentLocation _requestCurrentLocation;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoGuide AI',
      theme: GeoGuideTheme.light(),
      home: BaseMapPage(requestCurrentLocation: _requestCurrentLocation),
    );
  }
}
