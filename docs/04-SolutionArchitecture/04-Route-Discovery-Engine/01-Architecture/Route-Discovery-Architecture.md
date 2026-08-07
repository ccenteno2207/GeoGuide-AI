# Arquitectura del Route Discovery Engine

## Flujo principal
1. El cliente envía origen, destino y preferencias.
2. Routing Adapter solicita una ruta al motor seleccionado.
3. Route Normalizer convierte la respuesta a un modelo interno.
4. Corridor Builder genera un buffer alrededor de la geometría.
5. POI Repository consulta PostGIS.
6. Candidate Filter elimina candidatos inválidos o duplicados.
7. Detour Estimator calcula el costo aproximado de desviación.
8. Ranking Engine asigna una puntuación.
9. Sequence Builder ordena POIs según progreso sobre la ruta.
10. API devuelve ruta + puntos descubiertos.

## Componentes
- RoutePlanningService
- RoutingProvider
- RouteNormalizer
- CorridorBuilder
- PoiSpatialRepository
- CandidateFilter
- DetourEstimator
- RankingEngine
- RouteProgressCalculator
- DiscoveryCache
- DiscoveryMetrics

## Regla de desacoplamiento
El dominio no debe depender directamente de GraphHopper, OSRM o Valhalla.
Las integraciones se implementarán mediante adaptadores.
