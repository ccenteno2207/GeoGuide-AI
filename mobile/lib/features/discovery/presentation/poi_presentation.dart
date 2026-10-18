import '../domain/discovery_poi.dart';

export '../domain/discovery_poi.dart' show discoveryCategoryCodes;

String friendlyPoiCategory(String code) =>
    const {
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
    }[code] ??
    'Lugar de interés';

String? friendlyPoiReason(String code) => const {
  'NEAR_ROUTE': 'Cerca del trazado',
  'CATEGORY_MATCH': 'Coincide con la categoría seleccionada',
}[code];

String? poiDistanceLabel(DiscoveryPoi poi) {
  final distance = poi.distanceToRouteMeters;
  if (!distance.isFinite || distance < 0) return null;
  return 'A ${distance.round()} m del trazado';
}
