import 'package:flutter/material.dart';

import '../domain/discovery_poi.dart';
import 'poi_presentation.dart';

class PoiPreviewSheet extends StatelessWidget {
  const PoiPreviewSheet({
    super.key,
    required this.poi,
    this.onViewDetail,
    this.selectionControl,
  });

  final DiscoveryPoi poi;
  final VoidCallback? onViewDetail;
  final Widget? selectionControl;

  @override
  Widget build(BuildContext context) {
    final distance = poiDistanceLabel(poi);
    final reasons = poi.reasonCodes
        .map(friendlyPoiReason)
        .whereType<String>()
        .toSet()
        .toList(growable: false);

    return SafeArea(
      child: Semantics(
        container: true,
        label: 'Vista previa de ${poi.name}',
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(poi.name, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Categoría: ${friendlyPoiCategory(poi.category)}'),
              if (distance != null) ...[
                const SizedBox(height: 4),
                Text(distance),
              ],
              for (final reason in reasons) ...[
                const SizedBox(height: 4),
                Text(reason),
              ],
              ?selectionControl,
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cerrar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: onViewDetail,
                      child: const Text('Ver detalle'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
