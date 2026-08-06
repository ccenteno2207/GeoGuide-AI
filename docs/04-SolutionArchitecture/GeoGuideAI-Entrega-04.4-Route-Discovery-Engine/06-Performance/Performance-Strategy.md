# Estrategia de Rendimiento

## Objetivos
- Evitar consultas espaciales globales.
- Reducir llamadas repetidas al motor de rutas.
- Mantener tiempos previsibles aun con crecimiento de POIs.

## Técnicas
- GiST.
- Bounding box preliminar cuando aporte valor.
- Redis para resultados de ruta/discovery repetidos.
- Límites de candidatos.
- Paginación/segmentación en rutas muy largas.
- Timeouts en servicios externos.
- Circuit breaker en futuras fases si se necesitan integraciones remotas.

## Métricas
- route_calculation_duration
- discovery_query_duration
- candidates_found
- candidates_ranked
- cache_hit_ratio
- routing_provider_errors
