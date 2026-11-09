import 'package:flutter/material.dart';

import '../domain/discovery_poi.dart';
import 'poi_presentation.dart';
import 'poi_thumbnail.dart';
import 'poi_ui_language.dart';

class PoiDetailSheet extends StatelessWidget {
  const PoiDetailSheet({super.key, required this.poi});

  final DiscoveryPoi poi;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Semantics(
          container: true,
          attributedLabel: spanishPoiUiPrefix('Detalle de ', poi.name),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PoiThumbnail(detail: true),
                const SizedBox(height: 12),
                Text(poi.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Text(
                      'Categoría: ${friendlyPoiCategory(poi.category)}',
                      locale: spanishPoiUiLocale,
                    ),
                  ),
                ),
                if (poi.description case final description?
                    when description.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(description),
                ],
                if (poiDistanceLabel(poi) case final distance?) ...[
                  const SizedBox(height: 12),
                  Text(distance, locale: spanishPoiUiLocale),
                ],
                for (final reason
                    in poi.reasonCodes
                        .map(friendlyPoiReason)
                        .whereType<String>()) ...[
                  const SizedBox(height: 4),
                  Text(reason, locale: spanishPoiUiLocale),
                ],
                if (poi.sourceLabel case final source?
                    when source.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Fuente',
                    locale: spanishPoiUiLocale,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  Text(source),
                ],
                if (poi.attribution case final attribution?
                    when attribution.trim().isNotEmpty)
                  Text(attribution),
                if (poi.sourceUrl case final sourceUrl?
                    when sourceUrl.trim().isNotEmpty)
                  Semantics(
                    link: true,
                    attributedLabel: spanishPoiUiPrefix('URL de la fuente', ''),
                    child: SelectableText(sourceUrl),
                  ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: Semantics(
                    localeForSubtree: spanishPoiUiLocale,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(48, 48),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Volver'),
                    ),
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
