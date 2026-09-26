import 'package:flutter/material.dart';

import '../domain/discovery_poi.dart';

class PoiDetailSheet extends StatelessWidget {
  const PoiDetailSheet({super.key, required this.poi});

  final DiscoveryPoi poi;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(poi.name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Categoría: ${poi.category}'),
            Text(
              'Distancia a la ruta: ${poi.distanceToRouteMeters.toStringAsFixed(0)} m',
            ),
            Text(
              'Progreso de ruta: ${(poi.routeProgress * 100).toStringAsFixed(0)}%',
            ),
            if (poi.reasonCodes.isNotEmpty)
              Text('Razones: ${poi.reasonCodes.join(', ')}'),
          ],
        ),
      ),
    );
  }
}
