import 'package:flutter/material.dart';

import '../domain/discovery_poi.dart';

export '../domain/discovery_poi.dart' show discoveryCategoryCodes;

class PoiCategoryPresentation {
  const PoiCategoryPresentation({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

/// Local presentation mapping for the active taxonomy. Discovery filters and
/// snapshots remain constrained by [discoveryCategoryCodes].
const poiCategoryCatalog = <String, PoiCategoryPresentation>{
  'WATERFALL': PoiCategoryPresentation(
    label: 'Catarata',
    icon: Icons.water_drop,
  ),
  'LAGOON': PoiCategoryPresentation(label: 'Laguna', icon: Icons.water),
  'MOUNTAIN': PoiCategoryPresentation(label: 'Montaña', icon: Icons.terrain),
  'FOREST': PoiCategoryPresentation(label: 'Bosque', icon: Icons.forest),
  'BEACH': PoiCategoryPresentation(label: 'Playa', icon: Icons.beach_access),
  'MUSEUM': PoiCategoryPresentation(label: 'Museo', icon: Icons.museum),
  'ARCHAEOLOGICAL_SITE': PoiCategoryPresentation(
    label: 'Sitio arqueológico',
    icon: Icons.account_balance,
  ),
  'MONUMENT': PoiCategoryPresentation(label: 'Monumento', icon: Icons.castle),
  'HISTORIC_CHURCH': PoiCategoryPresentation(
    label: 'Iglesia histórica',
    icon: Icons.church,
  ),
  'VIEWPOINT': PoiCategoryPresentation(
    label: 'Mirador',
    icon: Icons.visibility,
  ),
  'FUEL': PoiCategoryPresentation(
    label: 'Combustible',
    icon: Icons.local_gas_station,
  ),
  'HEALTH': PoiCategoryPresentation(
    label: 'Salud',
    icon: Icons.medical_services,
  ),
  'FOOD': PoiCategoryPresentation(
    label: 'Alimentación',
    icon: Icons.restaurant,
  ),
  'LODGING': PoiCategoryPresentation(label: 'Hospedaje', icon: Icons.hotel),
  'OTHER': PoiCategoryPresentation(label: 'Otros', icon: Icons.category),
};

const _unknownPoiCategory = PoiCategoryPresentation(
  label: 'Lugar de interés',
  icon: Icons.category,
);

PoiCategoryPresentation poiCategoryPresentation(String code) =>
    poiCategoryCatalog[code] ?? _unknownPoiCategory;

IconData poiCategoryIcon(String code) => poiCategoryPresentation(code).icon;

String friendlyPoiCategory(String code) => poiCategoryPresentation(code).label;

String? friendlyPoiReason(String code) => const {
  'NEAR_ROUTE': 'Cerca del trazado',
  'CATEGORY_MATCH': 'Coincide con la categoría seleccionada',
}[code];

String? poiDistanceLabel(DiscoveryPoi poi) {
  final distance = poi.distanceToRouteMeters;
  if (!distance.isFinite || distance < 0) return null;
  return 'A ${distance.round()} m del trazado';
}
