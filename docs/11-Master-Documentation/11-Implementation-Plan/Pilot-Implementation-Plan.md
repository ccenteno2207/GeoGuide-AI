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
- estado: P2.0–P2.8 completados y validados según su alcance en
  `feature/p2-backend-bootstrap`, base `e21aeab`; P2.7A completado y validado;
- P2.0–P2.5: implementados y validados;
- P2.4: aplicación web/Actuator, único endpoint `health`, pruebas, empaquetado y health
  temporal HTTP 200 / `UP` validados;
- P2.5: JDBC/PostgreSQL/Flyway, configuración por variables y V001 mínima preparados;
  pruebas, empaquetado y `git diff --check` validados;
- P2.7: backend incorporado a Compose, datasource PostgreSQL/PostGIS real, healthcheck
  interno y ausencia de publicación de 8080/5432 validados;
- revisión técnica posterior de P2.5: solo lectura, sin correcciones bloqueantes;
- P2.6: Dockerfile multi-stage con `eclipse-temurin:21-jdk-jammy` para build mediante
  Maven Wrapper y `eclipse-temurin:21-jre-jammy` para runtime no privilegiado
  `10001:10001`; JAR construido dentro de Docker y `.dockerignore` creados;
- validación P2.6: revisión estática satisfactoria y validación dinámica completada
  en `srv-geoguide-ai`; build `17/17 FINISHED`, imagen
  `geoguide-ai/backend:p2.6-validation` (`c0937ddd6204`, 457 MB), runtime y JAR
  `10001:10001`, sin contenedores de validación activos;
- estado VM durante la validación: rama `feature/p2-backend-bootstrap`, HEAD `05f5c33`
  y working tree limpio; Compose sin cambios;
- adopción Flyway: backup e inventario previos, baseline explícito `0` con descripción
  `P1 pre-Flyway PostGIS state`, Flyway OSS 11.7.2 y V001 registrada exitosamente con
  checksum `-1627021776`; `baseline-on-migrate` no quedó habilitado permanentemente;
- preservación: PostGIS 3.4.3 y evidencia P1 sin diferencias before/after;
- operación: backend healthy, Actuator `{"status":"UP"}`, restart estable, schema `001`
  y ninguna migración pendiente; `flyway_schema_history` conserva exactamente baseline
  `0` y V001;
- P2.8: auditoría documental/técnica y `mvnw.cmd verify` con `BUILD SUCCESS`, 2 pruebas,
  0 fallos, 0 errores y 0 omitidas;
- deuda no bloqueante: privilegios elevados de `geoguide_app`, a reducir en hardening;
- M03 — API base disponible: **CUMPLIDO TÉCNICAMENTE**;
- checkpoint Git documental de P2.8/M03: **PENDIENTE**; no existe PR ni merge.

## P3 – Seed Data
- estado: **NO INICIADO**;
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
