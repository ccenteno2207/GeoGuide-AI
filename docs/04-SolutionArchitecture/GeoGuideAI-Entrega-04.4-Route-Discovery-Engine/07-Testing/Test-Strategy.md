# Estrategia de Pruebas

## Unitarias
- CorridorBuilder.
- RankingEngine.
- CandidateFilter.
- RouteProgressCalculator.

## Integración
- Testcontainers con PostgreSQL/PostGIS.
- Consultas ST_DWithin.
- Índices espaciales.
- Casos de POI exactamente en el borde del corredor.

## Contrato
- OpenAPI.
- Compatibilidad del RoutingProvider.

## Casos funcionales
- Ruta sin POIs.
- Ruta con cientos de candidatos.
- Múltiples categorías.
- POI duplicado.
- Ruta muy corta.
- Ruta larga.
- Proveedor de routing no disponible.
