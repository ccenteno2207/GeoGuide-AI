import 'package:flutter/material.dart';

import '../domain/discovery_poi.dart';
import 'poi_presentation.dart';
import 'poi_operational_info_section.dart';
import 'poi_tourism_content_section.dart';
import 'poi_thumbnail.dart';
import 'poi_ui_language.dart';

class PoiDetailSheet extends StatelessWidget {
  const PoiDetailSheet({
    super.key,
    required this.poi,
    this.loadOperationalInfo,
    this.loadTourismContent,
  });

  final DiscoveryPoi poi;
  final PoiOperationalInfoLoader? loadOperationalInfo;
  final PoiTourismContentLoader? loadTourismContent;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          attributedLabel: spanishPoiUiPrefix('Detalle de ', poi.name),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PoiThumbnail(poi: poi, detail: true),
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
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            poiCategoryIcon(poi.category),
                            key: ValueKey(
                              'poi-category-detail-icon-${poi.category}',
                            ),
                            size: 18,
                          ),
                        ),
                        Text(
                          'Categoría: ${friendlyPoiCategory(poi.category)}',
                          locale: spanishPoiUiLocale,
                        ),
                      ],
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
                PoiOperationalInfoSection(
                  poiId: poi.id,
                  load: loadOperationalInfo,
                ),
                PoiTourismContentSection(
                  poiId: poi.id,
                  load: loadTourismContent,
                ),
                if (poi.sourceLabel case final source?
                    when source.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Fuente: ', locale: spanishPoiUiLocale),
                        TextSpan(text: source),
                      ],
                    ),
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
                if (poi.attribution case final attribution?
                    when attribution.trim().isNotEmpty)
                  Text(
                    attribution,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if ((poi.sourceUrl?.trim().isNotEmpty ?? false) ||
                    (poi.sourceLabel?.trim().isNotEmpty ?? false) ||
                    (poi.attribution?.trim().isNotEmpty ?? false))
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Fuentes y referencias'),
                    children: [
                      if (poi.sourceLabel case final source?
                          when source.trim().isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(source),
                        ),
                      if (poi.attribution case final attribution?
                          when attribution.trim().isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(attribution),
                        ),
                      if (poi.sourceUrl case final sourceUrl?
                          when sourceUrl.trim().isNotEmpty)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Semantics(
                            link: true,
                            attributedLabel: spanishPoiUiPrefix(
                              'URL de la fuente',
                              '',
                            ),
                            child: SelectableText(sourceUrl),
                          ),
                        ),
                    ],
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
