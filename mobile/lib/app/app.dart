import 'package:flutter/material.dart';

import '../features/map/presentation/base_map_page.dart';
import 'theme/geoguide_theme.dart';

class GeoGuideApp extends StatelessWidget {
  const GeoGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoGuide AI',
      theme: GeoGuideTheme.light(),
      home: const BaseMapPage(),
    );
  }
}
