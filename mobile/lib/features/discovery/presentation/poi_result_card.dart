import 'package:flutter/material.dart';

import '../domain/discovery_poi.dart';
import 'poi_presentation.dart';
import 'poi_thumbnail.dart';
import 'poi_ui_language.dart';

class PoiResultCard extends StatelessWidget {
  const PoiResultCard({
    super.key,
    required this.poi,
    required this.onPressed,
    required this.onViewDetails,
  });
  final DiscoveryPoi poi;

  /// Opens the existing Preview surface when the card body is activated.
  final VoidCallback onPressed;

  /// Opens Detail directly without activating the card body's Preview action.
  final VoidCallback onViewDetails;

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
            _poiTag(context, poi.category),
            if (poiDistanceLabel(poi) case final distance?)
              Text(
                distance,
                locale: spanishPoiUiLocale,
                style: Theme.of(context).textTheme.labelMedium,
              ),
          ],
        ),
        if (poi.description case final description?
            when description.trim().isNotEmpty)
          Text(description, maxLines: 2, overflow: TextOverflow.ellipsis),
        if (poi.sourceLabel case final source? when source.trim().isNotEmpty)
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Fuente: ', locale: spanishPoiUiLocale),
                TextSpan(text: source),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        if (poi.attribution case final attribution?
            when attribution.trim().isNotEmpty)
          Text(attribution, maxLines: 1, overflow: TextOverflow.ellipsis),
      ],
    );
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
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
                          PoiThumbnail(poi: poi),
                          const SizedBox(height: 8),
                          details,
                        ],
                      );
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PoiThumbnail(poi: poi),
                        const SizedBox(width: 12),
                        Expanded(child: details),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
              child: Semantics(
                localeForSubtree: spanishPoiUiLocale,
                child: TextButton(
                  key: const ValueKey('poi-card-view-details'),
                  style: TextButton.styleFrom(minimumSize: const Size(48, 48)),
                  onPressed: onViewDetails,
                  child: const Text('Ver detalles'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _poiTag(BuildContext context, String code) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Icon(
              poiCategoryIcon(code),
              key: ValueKey('poi-category-card-icon-$code'),
              size: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            friendlyPoiCategory(code),
            locale: spanishPoiUiLocale,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    ),
  );
}
