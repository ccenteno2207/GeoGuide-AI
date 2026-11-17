import 'package:flutter/material.dart';

import '../domain/discovery_poi.dart';

/// Compile-time opt-in used only by the isolated internal demo build.
const bool internalPoiImagesDemoEnabled = bool.fromEnvironment(
  'UI2_POI_LOCAL_IMAGES_DEMO',
  defaultValue: false,
);

/// Closed local-demo catalog. Stable P3 IDs are the only lookup keys.
abstract final class PoiLocalDemoImageCatalog {
  static const Map<String, String> assetsByPoiId = {
    '02000000-0000-0000-0000-000000000001':
        'assets/demo/poi_images/02000000-0000-0000-0000-000000000001.png',
    '02000000-0000-0000-0000-000000000002':
        'assets/demo/poi_images/02000000-0000-0000-0000-000000000002.png',
    '02000000-0000-0000-0000-000000000003':
        'assets/demo/poi_images/02000000-0000-0000-0000-000000000003.png',
    '02000000-0000-0000-0000-000000000004':
        'assets/demo/poi_images/02000000-0000-0000-0000-000000000004.png',
    '02000000-0000-0000-0000-000000000005':
        'assets/demo/poi_images/02000000-0000-0000-0000-000000000005.png',
  };

  static String? assetFor(String poiId) =>
      internalPoiImagesDemoEnabled ? assetsByPoiId[poiId] : null;
}

/// Shared reserved media area. Standard builds retain the original placeholder.
class PoiThumbnail extends StatelessWidget {
  const PoiThumbnail({super.key, required this.poi, this.detail = false});

  final DiscoveryPoi poi;
  final bool detail;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final placeholder = Semantics(
      label: 'Imagen no disponible',
      image: true,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Center(
            child: Icon(
              Icons.landscape_outlined,
              color: colors.onSurfaceVariant,
              size: detail ? 28 : 24,
            ),
          ),
        ),
      ),
    );
    final asset = PoiLocalDemoImageCatalog.assetFor(poi.id);
    final image = asset == null
        ? placeholder
        : ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              asset,
              key: ValueKey('poi-local-demo-image-${poi.id}'),
              fit: BoxFit.cover,
              semanticLabel: 'Fotografía de referencia de ${poi.name}',
              errorBuilder: (_, _, _) => placeholder,
            ),
          );
    if (!detail) return SizedBox(width: 72, height: 54, child: image);
    return Center(
      child: SizedBox(
        key: const ValueKey('poi-detail-thumbnail-frame'),
        width: 160,
        height: 90,
        child: image,
      ),
    );
  }
}
