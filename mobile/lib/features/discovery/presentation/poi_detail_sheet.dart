import 'package:flutter/material.dart';

import '../domain/discovery_poi.dart';
import 'poi_presentation.dart';
import 'poi_thumbnail.dart';

class PoiDetailSheet extends StatelessWidget {
  const PoiDetailSheet({super.key, required this.poi});

  final DiscoveryPoi poi;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Semantics(
          container: true,
          label: 'Detalle de ${poi.name}',
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PoiThumbnail(detail: true),
                const SizedBox(height: 16),
                Text(poi.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text('Categoría: ${friendlyPoiCategory(poi.category)}'),
                if (poi.description case final description?
                    when description.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(description),
                ],
                if (poiDistanceLabel(poi) case final distance?) ...[
                  const SizedBox(height: 12),
                  Text(distance),
                ],
                for (final reason
                    in poi.reasonCodes
                        .map(friendlyPoiReason)
                        .whereType<String>()) ...[
                  const SizedBox(height: 4),
                  Text(reason),
                ],
                if (poi.sourceLabel case final source?
                    when source.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text('Fuente', style: Theme.of(context).textTheme.labelLarge),
                  Text(source),
                ],
                if (poi.attribution case final attribution?
                    when attribution.trim().isNotEmpty)
                  Text(attribution),
                if (poi.sourceUrl case final sourceUrl?
                    when sourceUrl.trim().isNotEmpty)
                  Semantics(
                    link: true,
                    label: 'URL de la fuente',
                    child: SelectableText(sourceUrl),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(48, 48),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Volver'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
