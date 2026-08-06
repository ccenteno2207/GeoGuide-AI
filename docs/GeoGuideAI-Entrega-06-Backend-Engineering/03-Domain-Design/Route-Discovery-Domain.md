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
5. detour;
6. ranking;
7. sequencing.

### RankingPolicy
Permite evolucionar el algoritmo sin acoplarlo a controllers o persistencia.

## Resultado
`RouteDiscoveryResult`
- Route
- List<RoutePoiCandidate>
- algorithmVersion
- generatedAt
