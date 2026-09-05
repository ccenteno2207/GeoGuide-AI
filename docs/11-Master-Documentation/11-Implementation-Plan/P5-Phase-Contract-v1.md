# P5 PHASE CONTRACT v1 — Route Discovery

## Estado del contrato

```text
PHASE CONTRACT: FROZEN
PHASE APPROVAL: PENDING
AUTONOMOUS EXECUTION: NOT AUTHORIZED
```

**Clasificación:** P5 GOVERNANCE DECISION

**Baseline de freeze:** `e7789f9e86b91cead135ecc75caa7b0e14498f97`

**Fecha:** 2026-09-05

Congelar este contrato delimita P5; no inicia P5.1. La implementación funcional requiere
una instrucción posterior que apruebe la fase y autorice expresamente ejecución
autónoma.

## 1. Purpose

Implementar Route Discovery v1 como capability independiente que, sobre una ruta
normalizada producida por P4, descubre POIs P3 activos dentro de un corredor, calcula
señales espaciales, aplica ranking básico determinista y devuelve resultados mediante
una API HTTP. **CONFIRMED** por la arquitectura MVP y delimitado por este contrato.

## 2. Baseline

- `main` y `origin/main` en el freeze: `e7789f9e86b91cead135ecc75caa7b0e14498f97`.
- P0–P4: cerradas. P5 funcional: no iniciada.
- P5.0-A/B: aceptados y cerrados por gobierno.
- P5.0-C: completado en
  [P5 Governance Decisions](P5-Governance-Decisions.md).
- Estado técnico heredado validado mediante inspección documental y de código.

## 3. Dependencies

### P3 — CONFIRMED

`PointOfInterest`, `PoiId`, `Category`, `GeoPoint`, `SourceReference`, estado activo,
schema `geo`, `geometry(Point,4326)`, GiST, provenance y adaptadores JDBC existentes.

### P4 — CONFIRMED

`RoutingProvider`, `PlanRouteUseCase`, `Route`, `RouteGeometry`, `RoutePoint`, adaptador
GraphHopper 11, distancia/duración normalizadas, GeoJSON `LineString`,
`POST /api/v1/routes/plan` y errores normalizados.

P5 no modifica los contratos ni responsabilidades heredadas salvo autorización futura
explícita.

## 4. Functional Contract

### Input — P5 GOVERNANCE DECISION

- `origin` obligatorio.
- `destination` obligatorio.
- `categories` opcional.
- `corridorMeters` opcional.
- `limit` opcional.

### Processing — P5 GOVERNANCE DECISION

1. Validar request y criterios.
2. Planificar una ruta normalizada mediante `PlanRouteUseCase`/capability P4.
3. Consultar POIs activos dentro del corredor.
4. Aplicar filtro de categorías cuando exista.
5. Deduplicar por identidad canónica.
6. Calcular `distanceToRouteMeters`.
7. Calcular `routeProgress`.
8. Aplicar ranking determinista y explicable.
9. Aplicar límite final.
10. Producir ruta y resultados con metadata.

### Output — P5 GOVERNANCE DECISION

- Ruta normalizada: origen, destino, distancia, duración y GeoJSON `LineString`.
- `results[]`.
- Por resultado: identidad UUID, nombre, categoría, ubicación, distancia a ruta,
  progreso, score y reason codes.
- Metadata: `algorithmVersion` y `generatedAt` ISO-8601.

Un resultado vacío es válido y se representa con `results: []`.

## 5. Application Architecture

- Route planning y discovery son casos de uso separados.
- Un caso de composición de aplicación atiende `/routes/discover`.
- La composición invoca primero la capacidad P4 y luego Route Discovery.
- Dominio/aplicación discovery dependen sólo de tipos neutrales.
- El controller no contiene lógica de dominio ni llama directamente a GraphHopper.
- No se crea una geometría equivalente a `RouteGeometry` sin necesidad demostrada.
- El nombre exacto de las clases es **INFERRED** y puede decidirse durante P5.1 sin
  cambiar estos límites.

## 6. Spatial Query Contract

- Crear un port read-side dedicado para consultar candidatos de Route Discovery.
- Implementarlo mediante adaptador PostgreSQL/PostGIS.
- Usar `ST_DWithin` para semántica de corredor y distancia métrica apropiada.
- Usar `ST_LineLocatePoint` para progreso, o equivalentes PostGIS técnicamente
  justificados con misma semántica.
- No calcular manualmente en Java operaciones ya cubiertas por PostGIS.
- No mezclar consultas especializadas con escritura del aggregate POI.

## 7. Corridor Contract

```text
corridorMeters default = 5000
corridorMeters minimum = 1000
corridorMeters maximum = 10000
```

Los valores son **P5 GOVERNANCE DECISION**, deben validarse en el borde HTTP/aplicación
y centralizarse para evitar constantes dispersas. La distancia se expresa en metros.

## 8. Candidate Contract

- Sólo POIs activos y dentro del corredor.
- Con categorías solicitadas cuando el filtro no esté vacío.
- Sin filtro de categoría cuando `categories` se omita o sea una colección vacía.
- Categorías desconocidas producen request inválido; no se silencian.
- Deduplicación por UUID canónico de `PoiId`.
- `limit` default 20, mínimo 1, máximo 50.
- El fetch espacial debe quedar acotado. Cualquier sobreselección interna debe ser
  pequeña, determinista y documentada; el resultado final nunca excede `limit`.
- Provenance no participa automáticamente en ranking ni se expone completa en esta API.

## 9. Ranking Contract

- `algorithmVersion = DISCOVERY_V1`.
- Determinista, reproducible, explicable y sin ML/LLM.
- Señal primaria: menor `distanceToRouteMeters`.
- Desempate estable: representación canónica ascendente del UUID de POI.
- `score` debe ser una transformación documentada, monotónica respecto de la distancia,
  finita y no negativa; su fórmula exacta queda autorizada como detalle técnico siempre
  que pruebas demuestren el orden y la reproducibilidad.
- `reasonCodes` v1 incluye al menos `NEAR_ROUTE`; incluye `CATEGORY_MATCH` cuando se
  aplicó un filtro solicitado.
- No se agregan columnas de quality/relevance para enriquecer el ranking.

## 10. Route Progress Contract

- `routeProgress` es finito y está normalizado en `[0.0, 1.0]`.
- `0.0` representa el inicio y `1.0` el final de la ruta.
- Se obtiene proyectando el POI sobre la geometría de ruta mediante PostGIS.
- Se expone por resultado y permanece conceptualmente separado de `score`.
- La API permite que consumidores futuros secuencien por progreso, pero v1 conserva el
  orden principal del ranking salvo decisión contractual posterior.

## 11. API Contract

`POST /api/v1/routes/discover`

Request conceptual:

```json
{
  "origin": {"latitude": -12.0464, "longitude": -77.0428},
  "destination": {"latitude": -11.4600, "longitude": -76.6200},
  "categories": ["HISTORIC_CHURCH"],
  "corridorMeters": 5000,
  "limit": 20
}
```

Response conceptual:

```json
{
  "route": {
    "origin": {"latitude": -12.0464, "longitude": -77.0428},
    "destination": {"latitude": -11.4600, "longitude": -76.6200},
    "distanceMeters": 0,
    "durationSeconds": 0,
    "geometry": {"type": "LineString", "coordinates": []}
  },
  "results": [{
    "id": "00000000-0000-0000-0000-000000000000",
    "name": "POI",
    "category": "HISTORIC_CHURCH",
    "location": {"latitude": -11.8, "longitude": -76.9},
    "distanceToRouteMeters": 100,
    "routeProgress": 0.5,
    "score": 1,
    "reasonCodes": ["NEAR_ROUTE", "CATEGORY_MATCH"]
  }],
  "algorithmVersion": "DISCOVERY_V1",
  "generatedAt": "2026-09-05T00:00:00Z"
}
```

Los valores son ilustrativos. OpenAPI 3.1 debe congelar tipos, límites, requeridos,
formatos y ejemplos antes de dar por terminado el checkpoint HTTP. No se aceptan en v1
`routeGeometry`, detour, additional time, preferencias complejas, opciones de cache,
provider selection ni campos CEFI.

## 12. Error Contract

Se reutiliza RFC 9457/Spring `ProblemDetail` y la forma P4 `type`, `status`, `detail`,
`code`.

| Caso | HTTP | Code |
| --- | ---: | --- |
| Request/criterio inválido | 400 | `INVALID_DISCOVERY_REQUEST` |
| Ruta inexistente | 404 | `NO_ROUTE_FOUND` |
| Provider no disponible | 503 | `PROVIDER_UNAVAILABLE` |
| Timeout del provider | 504 | `PROVIDER_TIMEOUT` |
| Respuesta inválida/error provider | 502 | `PROVIDER_ERROR` |
| Falla interna de discovery | 500 | `DISCOVERY_ERROR` |

Los errores de routing heredados conservan su semántica P4. Cero POIs devuelve HTTP 200
con colección vacía. No se exponen SQL, payloads del provider, stack traces ni detalles
internos.

## 13. Persistence Contract

- `NO NEW MIGRATION`.
- No persistir rutas, resultados, historial discovery ni historial GPS continuo.
- Reutilizar tablas, constraints e índice GiST P3.
- La geometría de ruta es transitoria.
- Una migración sólo puede proponerse con evidencia objetiva y activa Governance Stop.

## 14. Performance Contract

- Ninguna consulta espacial global no acotada.
- Toda consulta usa corredor y límite.
- Aprovechar GiST cuando corresponda; evitar transformar innecesariamente la columna
  indexada.
- Evitar N+1 para categoría/proyección de candidatos.
- Capturar `EXPLAIN (ANALYZE, BUFFERS)` reproducible sobre datos de prueba/VM cuando sea
  seguro y demostrar un plan razonable; no se congela un SLO comercial.
- No introducir Redis para ocultar una consulta incorrecta.

## 15. Test Contract

### Unit

- Validación de criterios y límites.
- Filtrado, deduplicación y candidatos vacíos.
- Determinismo, fórmula, reason codes y tie-breaker de ranking.
- Fronteras/semántica de route progress.

### Integration — PostgreSQL/PostGIS real

- Corredor y borde mediante `ST_DWithin`.
- SRID y semántica métrica.
- Distancia a ruta y progreso.
- Filtros active/category.
- Duplicados e identidad canónica.
- Límite y plan/índice espacial donde sea práctico.

H2 o mocks no sustituyen PostGIS para estas pruebas.

### Application

- Composición ruta P4 -> discovery P5.
- Propagación de fallas P4.
- Cero, uno y múltiples POIs.
- Límite y orden determinista.

### HTTP

- Request válido/inválido.
- Defaults y fronteras.
- Respuesta vacía y con resultados.
- Errores de routing/discovery.
- Conformidad con OpenAPI.

### Required validation

- `mvn verify` con Java 21 y todas las pruebas P5 aplicables ejecutadas.
- `git diff --check`.
- Revisión explícita de secretos, privacidad, migrations y recursos protegidos.

## 16. VM Validation Contract

La validación final P5 en la VM de integración es obligatoria. Antes de actuar se debe
confirmar rama/revisión, árbol limpio, servicios y recursos protegidos. Debe demostrar:

- backend -> GraphHopper P4 -> Route Discovery -> PostgreSQL/PostGIS;
- ruta normalizada y resultados discovery reales o colección vacía controlada;
- filtros, límites, distancia, progreso, ranking y contrato HTTP;
- Problem Details para al menos request inválido y fallo representativo seguro;
- `mvn verify` con integración PostGIS no omitida;
- query-plan/evidencia espacial reproducible;
- health y no regresión P1–P4;
- preservación de base, PBF, graph cache, volúmenes y datos protegidos.

No se exige road pilot ni afirmar que una ruta histórica llegó a Obrajillo.

## 17. In Scope

- Modelos y servicios application/domain mínimos de Route Discovery.
- Composición con P4.
- Port y adaptador de consulta espacial.
- Corredor, candidatos, categorías, deduplicación y límites.
- Distancia a ruta, route progress y ranking `DISCOVERY_V1`.
- Endpoint, DTOs, OpenAPI, errores y tests.
- Evidencia local, PostGIS y VM; documentación de cierre.

## 18. Out of Scope

- CEFI, voz, STT/TTS, LLM, prompts y audio.
- Detour, distancia/tiempo adicional y rutas alternativas por POI.
- Nearby, search, autocomplete y Places API genérica.
- Redis/cache y MinIO.
- Mobile y trabajo propio de seguridad P10.
- Persistencia de rutas, discovery o GPS continuo.
- Migraciones nuevas; modificación de V001–V004.
- Cambios/upgrades de GraphHopper, `RoutingProvider`, PBF, bounding box o graph cache.
- OSRM, Valhalla, real-road pilot y actividades P12.

## 19. Definition of Done

P5 sólo cumple cuando, con evidencia objetiva:

1. Reutiliza P4 sin reimplementar routing.
2. Existe un use case discovery separado.
3. Existe un port read-side espacial apropiado.
4. PostGIS recupera POIs dentro del corredor.
5. Sólo considera POIs activos válidos.
6. Category filtering funciona.
7. Deduplicación por identidad funciona.
8. `distanceToRouteMeters` está disponible.
9. `routeProgress` está disponible en `[0,1]`.
10. `DISCOVERY_V1` es determinista, explicable y estable.
11. Existe `POST /api/v1/routes/discover`.
12. OpenAPI refleja la implementación real.
13. Errores están normalizados; cero resultados no es error.
14. Pruebas unitarias pasan.
15. Pruebas PostGIS pasan sin sustituto H2.
16. Pruebas application/HTTP pasan.
17. `mvn verify` pasa.
18. V001–V004 permanecen sin cambios.
19. GraphHopper/PBF/bounding box/graph cache permanecen sin cambios.
20. Validación VM pasa y preserva P1–P4.
21. Evidencia P5 queda documentada.
22. Diff no contiene secretos ni alcance ajeno; árbol final queda limpio.
23. Auditoría maestra puede emitir PASS/FAIL objetivamente.

## 20. Mandatory Governance Stops

Emitir `GOVERNANCE STOP` y esperar autorización ante necesidad de:

- cambiar este contrato, ampliar scope o alterar una decisión congelada;
- crear migración o modificar V001–V004;
- cambiar arquitectura/contratos P3/P4 o `RoutingProvider`;
- modificar GraphHopper, PBF, bounding box o graph cache;
- introducir Redis, persistencia discovery, detour, CEFI/LLM/voz o nearby/search;
- resolver contradicción de producto no contemplada;
- operación destructiva o riesgo de pérdida de datos;
- aceptar pruebas fallando u omitir evidencia requerida.

## 21. Evidence Requirements

- **DOC:** contrato, OpenAPI, DoD y evidencia de cierre alineados.
- **CODE:** límites modulares, tipos neutrales, port/adaptador y diff revisados.
- **TEST:** unit, application, HTTP y Testcontainers/PostGIS.
- **DATABASE:** SRID, corredor, progreso, filtros, límites, GiST/query plan.
- **HTTP:** request/response/error del endpoint discovery.
- **GIT/COMMIT/PR:** rama autorizada, commits cohesivos, PR y árbol limpio.
- **VM/DOCKER/LOG:** revisión desplegada, health, flujo real y no regresión.

## 22. Execution Checkpoints

### P5.1 — Domain and criteria

- **Objective:** tipos discovery, criterios validados, candidatos y ranking v1 puros.
- **Authorized changes:** paquetes P5 application/domain y unit tests.
- **Forbidden changes:** HTTP, SQL, P3/P4, infraestructura.
- **Tests:** validación, deduplicación, ranking, tie-breaker, empty candidates.
- **Evidence:** CODE, TEST, GIT; commit cohesivo.
- **Exit criteria:** dominio compilable, determinista y probado.
- **Mandatory stop:** nueva señal de datos, cambio P3/P4 o alcance adicional.

### P5.2 — Spatial read side

- **Objective:** port y adaptador PostGIS para corredor, distancia y progreso.
- **Authorized changes:** port/adaptador P5, consultas y tests Testcontainers.
- **Forbidden changes:** migrations, schema, cache, infraestructura.
- **Tests:** ST_DWithin, borde, SRID, active/category, distancia, progreso, límite.
- **Evidence:** CODE, TEST, DATABASE, query plan, GIT; commit cohesivo.
- **Exit criteria:** consulta correcta, acotada y reproducible sobre PostGIS real.
- **Mandatory stop:** necesidad objetiva de migration/index/schema.

### P5.3 — Application composition

- **Objective:** componer `PlanRouteUseCase` con discovery sin acoplar providers.
- **Authorized changes:** application services/configuration y tests.
- **Forbidden changes:** `RoutingProvider`, GraphHopper, HTTP final.
- **Tests:** éxito, vacío, múltiples candidatos, límite y errores heredados.
- **Evidence:** CODE, TEST, GIT; commit cohesivo.
- **Exit criteria:** flujo application completo y provider-neutral.
- **Mandatory stop:** necesidad de cambiar contrato P4.

### P5.4 — HTTP and OpenAPI

- **Objective:** endpoint v1, DTOs, Problem Details y OpenAPI completos.
- **Authorized changes:** controller/DTO/handler P5, OpenAPI y tests HTTP.
- **Forbidden changes:** endpoints P4, auth P10, capacidades fuera de alcance.
- **Tests:** requests, defaults, límites, vacío, schema y errores.
- **Evidence:** CODE, TEST, HTTP, DOC, GIT; commit cohesivo.
- **Exit criteria:** contrato HTTP implementado y OpenAPI alineado.
- **Mandatory stop:** incompatibilidad material con este contrato.

### P5.5 — Integrated validation and evidence

- **Objective:** validar localmente, en PostGIS real y VM; documentar evidencia.
- **Authorized changes:** tests/fixes P5 en alcance y evidencia documental.
- **Forbidden changes:** servicios/datos protegidos y scope futuro.
- **Tests:** `mvn verify`, `git diff --check`, HTTP/VM y no regresión.
- **Evidence:** TEST, DATABASE, HTTP, VM, DOCKER, LOG, DOC, GIT; commit de evidencia.
- **Exit criteria:** DoD 1–23 objetivamente satisfecha.
- **Mandatory stop:** regresión no resoluble, operación destructiva o evidencia imposible.

### P5.6 — PR and master audit

- **Objective:** revisión final, PR único y decisión de auditoría maestra.
- **Authorized changes:** remediación P5 en la misma rama/PR y documentación asociada.
- **Forbidden changes:** merge o cierre automático sin decisión maestra.
- **Tests:** repetición proporcional a cambios de remediación.
- **Evidence:** GIT, COMMIT, PR, TEST y matriz DoD.
- **Exit criteria:** auditoría `APPROVED` o remediación completada y revalidada.
- **Mandatory stop:** solicitud de scope adicional o cambio contractual.

### P5.7 — Post-merge validation and closure proposal

- **Objective:** sincronizar `main`, repetir controles contractuales y preparar cierre.
- **Authorized changes:** evidencia documental de post-merge si está autorizada.
- **Forbidden changes:** declarar cierre unilateral o iniciar P6.
- **Tests:** controles local/VM relevantes, health y no regresión.
- **Evidence:** GIT, COMMIT, VM, HTTP, TEST, DOC.
- **Exit criteria:** `READY FOR MASTER CLOSURE` con evidencia completa.
- **Mandatory stop:** divergencia de revisiones o regresión post-merge.

## 23. Closure Criteria

P5 puede cerrarse únicamente después de implementación autorizada, PR revisada e
integrada, validación post-merge, satisfacción documentada de toda la DoD y decisión
formal del master. Un PR merged no equivale a cierre. No iniciar P6 automáticamente.

## Evaluación de readiness

El contrato está congelado, delimitado y sin decisiones materiales abiertas. Sin
embargo, conforme al Scope Freeze Gate del skill, la aprobación y la autorización de
ejecución aún requieren una instrucción posterior explícita.

```text
AUTONOMOUS_EXECUTION_READY
```
