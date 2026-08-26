# Plan Maestro de Implementación del Piloto

## Fase P0 – Repository Readiness
- ordenar documentación;
- LICENSE;
- README raíz;
- .gitignore;
- conventions.

## P1 – Local Infrastructure
- Docker Compose: completado y validado;
- PostGIS, Redis y MinIO: salud, función y persistencia validadas;
- routing spike: completado; GraphHopper 11.0 seleccionado por ADR-028, incorporado al
  Compose interno y validado con ruta, HTTP 400 y reutilización tras reinicio;
- hito M02: completado. P1 cumple su criterio de cierre técnico.

## P2 – Backend Bootstrap
- Spring Boot;
- health;
- Flyway;
- places.

## P3 – Seed Data
- taxonomía;
- POIs del corredor piloto;
- provenance.

## P4 – Routing
- origin/destination;
- route geometry.

## P5 – Route Discovery
- corridor;
- candidates;
- ranking;
- API.

## P6 – Mobile Bootstrap
- Flutter;
- map;
- GPS.

## P7 – Vertical Slice
Mobile → API → route → PostGIS → POIs → map.

## P8 – POI Experience
preview/detail/filter.

## P9 – Offline & Driving
cache + interaction reduction.

## P10 – Quality/Security
tests, scans, hardening.

## P11 – Server Deployment
HTTPS + deploy + backup + observability.

## P12 – Road Pilot
prueba física controlada y registro de hallazgos.

## Regla
No comenzar AI/RAG antes de completar el vertical slice estable.
