import 'package:flutter/material.dart';

import 'theme/geoguide_theme.dart';

class GeoGuideApp extends StatelessWidget {
  const GeoGuideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GeoGuide AI',
      theme: GeoGuideTheme.light(),
      home: const BootstrapPage(),
    );
  }
}

class BootstrapPage extends StatelessWidget {
  const BootstrapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GeoGuide AI')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.explore_outlined, size: 64),
              SizedBox(height: 16),
              Text(
                'Mobile Bootstrap',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text('P6.1 — Flutter Bootstrap'),
            ],
          ),
        ),
      ),
    );
  }
}
