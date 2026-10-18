import 'package:flutter/material.dart';

import '../domain/discovery_poi.dart';
import 'poi_presentation.dart';
import 'poi_thumbnail.dart';

class PoiResultCard extends StatelessWidget {
  const PoiResultCard({super.key, required this.poi, required this.onPressed});
  final DiscoveryPoi poi;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          poi.name,
          style: Theme.of(context).textTheme.titleMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _poiTag(context, friendlyPoiCategory(poi.category)),
            if (poiDistanceLabel(poi) case final distance?)
              Text(distance, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
        if (poi.description case final description?
            when description.trim().isNotEmpty)
          Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
        if (poi.sourceLabel case final source? when source.trim().isNotEmpty)
          Text('Fuente: $source'),
        if (poi.attribution case final attribution?
            when attribution.trim().isNotEmpty)
          Text(attribution),
      ],
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Semantics(
          button: true,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Large text gets the full card width instead of a narrow column.
                if (MediaQuery.textScalerOf(context).scale(16) >= 24 ||
                    constraints.maxWidth < 260) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const PoiThumbnail(),
                      const SizedBox(height: 8),
                      details,
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PoiThumbnail(),
                    const SizedBox(width: 12),
                    Expanded(child: details),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _poiTag(BuildContext context, String label) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    ),
  );
}
