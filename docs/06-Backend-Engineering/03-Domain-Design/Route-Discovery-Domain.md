# Dominio Route Discovery

## Interfaces centrales

### RoutingProvider
Responsable de obtener una ruta desde un proveedor externo/autohospedado.

Operaciones conceptuales:
- calculateRoute(origin, destination, profile)

### PoiSpatialQueryPort
Responsable de consultar candidatos geográficos.

### RouteDiscoveryUseCase
Orquesta:
1. route;
2. corridor;
3. candidates;
4. filtering;
5. ranking con señales disponibles;
6. sequencing.

En una evolución posterior puede orquestar estimación de distancia de desvío y tiempo
adicional antes del ranking. Esa estimación es opcional: no bloquea corredor, consulta
espacial, filtrado, ranking básico ni secuenciación.

### RankingPolicy
Permite evolucionar el algoritmo sin acoplarlo a controllers o persistencia.

## Resultado
`RouteDiscoveryResult`
- Route
- List<RoutePoiCandidate>
- algorithmVersion
- generatedAt
