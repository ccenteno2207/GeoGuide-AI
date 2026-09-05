# Backlog de Implementación

## Sprint técnico 1
- [x] Modelo interno Route.
- [x] `RoutingProvider`.
- [x] Adaptador GraphHopper 11.
- [x] Endpoint `POST /api/v1/routes/plan`.
- [x] Geometría GeoJSON `LineString`.
- [x] Pruebas de contrato y normalización de errores.

Fundación de routing completada y cerrada en P4. Los siguientes sprints describen
capacidades planificadas; no constituyen un contrato de alcance ni autorizan P5.

## Sprint técnico 2 — NOT STARTED
- Consulta PostGIS de corredor.
- POI candidate model.
- `/routes/discover`.

## Sprint técnico 3 — NOT STARTED
- Ranking.
- Route progress.
- Filtros de categorías.
- Cache.
- métricas.

## Definition of Done
- código compilable;
- pruebas automatizadas;
- documentación API;
- sin secretos;
- logs con correlationId;
- benchmark básico;
- ADR actualizado si cambia una decisión.
