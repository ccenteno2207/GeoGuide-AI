# P3 — Evidencia de validación y Release Gate R3

## Estado

Validación ejecutada el 4 de septiembre de 2026 sobre
`feature/p3-poi-data-domain`. Los criterios técnicos y de datos de
[P3 Definition of Done](P3-Definition-of-Done.md) cumplen. El PR #7 fue integrado mediante
`aaa4c6b` y `main` quedó sincronizada y limpia.

## Entornos

- Laptop Windows: Maven Wrapper con Java 21; 26 pruebas, 0 fallos, 0 errores y 4
  Testcontainers omitidas por ausencia de Docker local.
- VM de integración `manager@192.168.1.106`: Maven 3.9.16/Java 21 en contenedor con
  Docker real; 26 pruebas, 0 fallos, 0 errores y 0 omitidas.
- VM heredada: PostgreSQL/PostGIS, Redis, MinIO, GraphHopper y backend saludables.

## Resultado técnico

| Área | Evidencia | Resultado |
|---|---|---|
| Dominio | Casos de invariantes y fronteras de `GeoPoint` | CUMPLE |
| Arquitectura | Dominio sin imports Spring/JPA/HTTP; puertos y adaptadores separados | CUMPLE |
| Flyway limpio | Testcontainers aplicó V001–V004 sobre PostGIS 16-3.4 | CUMPLE |
| Persistencia | UUID, FK, `active BOOLEAN`, `TIMESTAMPTZ`, `geometry(Point,4326)` y GiST | CUMPLE |
| Round-trip | POI, categoría, geometría, timestamps y provenance recuperados | CUMPLE |
| Dataset | Dos cargas conservaron identidades y conteos | CUMPLE |

## Baseline heredado en VM

Flyway conservó el baseline 0 y V001 con checksum histórico, y añadió en orden V002,
V003 y V004. No se modificó V001, no se habilitó `baseline-on-migrate`, no se reconstruyó
la base y no se eliminaron volúmenes.

Después de la carga y de reiniciar el backend:

| Control | Resultado |
|---|---:|
| Category | 15 |
| PointOfInterest | 5 |
| Provenance | 10 |
| POIs sin provenance | 0 |
| POIs con SRID distinto de 4326 | 0 |
| `p1_persistence_test` | `1 / P1_OK` preservado |

La red `geoguide-ai_data` continúa interna. Backend, PostgreSQL, Redis, MinIO y
GraphHopper permanecen saludables y 8080/5432 no se publican al host.

## Aceptación R3

| Grupo | Criterios | Resultado |
|---|---|---|
| Integridad/geografía | R3-01–R3-05 | CUMPLE |
| Provenance/identidad | R3-06–R3-08 | CUMPLE |
| Calidad/unicidad | R3-09–R3-10 | CUMPLE |
| Idempotencia/reproducibilidad | R3-11–R3-13 | CUMPLE |
| Aprobación y decisiones | R3-14–R3-15 | CUMPLE |

La matriz POI→fuente y las reglas binarias de pertenencia/distribución están en
`backend/src/main/resources/data/p3/README.md`. La taxonomía y el corredor fueron
aprobados durante P3.0-E. No se introdujeron umbrales numéricos de aceptación.

## Observación de trazabilidad P1

La evidencia histórica rotulada “Lima → Obrajillo” en el caso 6 del routing spike termina
realmente en Santa Rosa de Quives. P3 no usa esa distancia como validación del trayecto
completo. Obrajillo y todos los POIs P3 permanecen dentro del bounding box heredado, por
lo que no fue necesario ampliar el PBF ni ejecutar routing nuevo.

## Veredicto

`P3-DOD-01`–`P3-DOD-47`: **CUMPLE**.

`R3-01`–`R3-15`: **CUMPLE**.

`P3-DOD-48`: **CUMPLE** mediante PR #7, merge commit `aaa4c6b` y sincronización limpia
de `main` en laptop y VM.
