# P5 — Evidencia de validación

## Línea base y alcance

- Baseline oficial: `fbcbca048833fbce7ac8c3ac3e24aa3cc7d397eb`.
- Rama: `feature/p5-route-discovery`.
- Revisión validada en VM: `916773f3f4c736f966367a7a1cef5c7c34ce8c2a`.
- Contrato: `P5 Phase Contract v1`; sin migraciones, persistencia discovery ni cambios P3/P4.

## Checkpoints

| Checkpoint | Commit | Evidencia | Resultado |
| --- | --- | --- | --- |
| P5.1 | `ba968de` | 8 pruebas unitarias de criterios, deduplicación y ranking | PASS |
| P5.2 | `0c947e8`, `5d2cb47` | PostGIS real, corredor, filtro, progreso y plan GiST | PASS |
| P5.3 | `fc737de` | composición P4 → P5 y propagación de error | PASS |
| P5.4 | `916773f` | 4 pruebas HTTP, Problem Details y OpenAPI | PASS |

## Validación local

- Java 21; `mvn verify`: 58 pruebas, 0 fallos, 0 errores y 6 omitidas por ausencia
  de Docker local. Las cuatro pruebas HTTP P5 se ejecutaron y pasaron.
- `git diff --check`: PASS.
- Las omisiones locales PostGIS no se contabilizan como PASS; fueron ejecutadas en VM.

## Validación VM/PostGIS

Entorno autorizado `srv-geoguide-ai` (`manager@192.168.1.106`):

- `mvn verify` en Java 21/Testcontainers: 58 pruebas, 0 fallos, 0 errores, 0 omitidas.
- `PostgisIntegrationTests`: 6 ejecutadas; base efímera PostgreSQL 16/PostGIS,
  migraciones V001–V004, `ST_DWithin`, métrica, active/category, distancia, progreso,
  límite y `EXPLAIN (ANALYZE, BUFFERS)` con uso verificable del GiST heredado.
- Backend construido y reemplazado aisladamente; backend, GraphHopper, PostgreSQL,
  Redis y MinIO quedaron `healthy`.
- `POST /api/v1/routes/discover`: HTTP 200, ruta real normalizada, `results: []`,
  `algorithmVersion: DISCOVERY_V1` y `generatedAt`.
- Request discovery inválido: HTTP 400, RFC 9457, `INVALID_DISCOVERY_REQUEST`.
- No regresión P4: `POST /api/v1/routes/plan` HTTP 200 con distancia, duración y LineString.
- Datos persistentes preservados: 15 categorías, 5 POIs y 10 provenance.
- Volúmenes `postgres_data`, `redis_data` y `minio_data` preservados.
- Configuración GraphHopper preservada: SHA-256
  `2029eeffdb5ae852c360364ea6ab5c52bf985d1d1d250e97c885cf202cb9385c`.

## Seguridad, privacidad y recursos protegidos

- Sin secretos nuevos ni exposición de SQL, stack traces o payload interno del provider.
- Sin almacenamiento de rutas, resultados o historial GPS.
- Sin cambios a `LICENSE`, V001–V004, `RoutingProvider`, GraphHopper, PBF, bounding box,
  graph cache, Compose, Redis o MinIO.
- Fuera de alcance ausente: detour, nearby/search, CEFI, voz, LLM y mobile.

## Veredicto P5.5

`PASS`: validación local, PostGIS real, VM, HTTP, no regresión y preservación completadas.
