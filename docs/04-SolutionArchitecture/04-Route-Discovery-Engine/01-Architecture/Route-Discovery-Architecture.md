# Arquitectura del Route Discovery Engine

## Flujo principal
1. El cliente envía origen, destino y preferencias.
2. Routing Adapter solicita una ruta al motor seleccionado.
3. Route Normalizer convierte la respuesta a un modelo interno.
4. Corridor Builder genera un buffer alrededor de la geometría.
5. POI Repository consulta PostGIS.
6. Candidate Filter elimina candidatos inválidos o duplicados.
7. Ranking Engine asigna una puntuación con señales disponibles en el MVP.
8. Sequence Builder ordena POIs según progreso sobre la ruta.
9. API devuelve ruta + puntos descubiertos.

En una evolución posterior, Detour Estimator calcula distancia de desvío y tiempo
adicional aproximados antes del ranking.

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

`DetourEstimator` es un componente planificado, no una dependencia del núcleo inicial.
El corredor, la consulta espacial y el ranking básico funcionan sin una estimación de
desvío.

## Regla de desacoplamiento
El dominio no debe depender directamente de GraphHopper, OSRM o Valhalla.
Las integraciones se implementarán mediante adaptadores.
