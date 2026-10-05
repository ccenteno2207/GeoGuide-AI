import '../domain/discovery_poi.dart';

const discoveryCategoryCodes = <String>[
  'WATERFALL', 'LAGOON', 'MOUNTAIN', 'FOREST', 'BEACH', 'MUSEUM',
  'ARCHAEOLOGICAL_SITE', 'MONUMENT', 'HISTORIC_CHURCH', 'VIEWPOINT',
];

String friendlyPoiCategory(String code) => const {
      'WATERFALL': 'Catarata',
      'LAGOON': 'Laguna',
      'MOUNTAIN': 'Montaña',
      'FOREST': 'Bosque',
      'BEACH': 'Playa',
      'MUSEUM': 'Museo',
      'ARCHAEOLOGICAL_SITE': 'Sitio arqueológico',
      'MONUMENT': 'Monumento',
      'HISTORIC_CHURCH': 'Iglesia histórica',
      'VIEWPOINT': 'Mirador',
    }[code] ?? code;

String? friendlyPoiReason(String code) => const {
      'NEAR_ROUTE': 'Cerca del trazado',
      'CATEGORY_MATCH': 'Coincide con la categoría seleccionada',
    }[code];

String? poiDistanceLabel(DiscoveryPoi poi) {
  final distance = poi.distanceToRouteMeters;
  if (!distance.isFinite || distance < 0) return null;
  return 'A ${distance.round()} m del trazado';
}
