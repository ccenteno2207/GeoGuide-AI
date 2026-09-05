# P5.0-C — Contradicciones y decisiones

## 1. Estado

- **Checkpoint:** P5.0-C — Contradictions and Decisions.
- **Estado:** `COMPLETED`.
- **Veredicto:** `PASS WITH GOVERNANCE NOTES`.
- **Baseline:** `e7789f9e86b91cead135ecc75caa7b0e14498f97`.
- **Modo:** `CONTROLLED GOVERNANCE MODE`.
- **Bloqueos restantes:** `NONE`.

Este registro resuelve las contradicciones identificadas en P5.0-A y verificadas contra
el estado técnico en P5.0-B. Las decisiones introducidas aquí son **P5 GOVERNANCE
DECISION**; no se presentan como hechos históricos y no autorizan implementación por sí
solas.

## 2. Registro de resolución

| Decisión | Problema | Alternativas consideradas | Decisión final | Evidencia | Clasificación |
| --- | --- | --- | --- | --- | --- |
| D-01 | Posible duplicación o acoplamiento de routing | Reimplementar routing; consumir HTTP propio; reutilizar capacidad P4 | Route Discovery consume la ruta normalizada P4 y tipos neutrales; no depende de GraphHopper | ADR-010/011/028; `RoutingProvider`, `PlanRouteUseCase`, `Route` | ACCEPTED — P5 GOVERNANCE DECISION |
| D-02 | Modelos internos de geometría divergentes | Nueva geometría P5; GeoJSON interno; reutilizar `Route`/`RouteGeometry` | Contrato interno: `Normalized Route + Discovery Criteria -> Discovered POIs`; reutiliza tipos P4 salvo necesidad demostrada | P5.0-B verificó tipos neutrales y reutilizables | ACCEPTED — P5 GOVERNANCE DECISION |
| D-03 | OpenAPI placeholder y variantes de request | Geometría enviada por cliente; sólo lógica interna; composición origin/destination | P5 v1 incluye `POST /api/v1/routes/discover`, que compone planificación P4 y discovery P5 | Entrega 04.6, API especializada, ausencia de controller real | ACCEPTED — P5 GOVERNANCE DECISION |
| D-04 | `PoiRepository` no soporta consulta espacial | Extender repositorio de aggregate; SQL en servicio; read-side dedicado | Introducir un port de lectura espacial dedicado a candidatos | ADR-010/012; P5.0-B verificó sólo `save/findById` | ACCEPTED — P5 GOVERNANCE DECISION |
| D-05 | Operadores espaciales aún no implementados | Geometría manual Java; PostGIS; librería GIS adicional | Usar `ST_DWithin` y `ST_LineLocatePoint`, o equivalentes PostGIS justificados | ADR-012; Point 4326 y GiST heredados | ACCEPTED — P5 GOVERNANCE DECISION |
| D-06 | Corredor configurable sin valores congelados | Sin default; valores 1/5/10 km; rango acotado | `corridorMeters`: default 5000, mínimo 1000, máximo 10000 | Arquitectura proponía valores, no un contrato | ACCEPTED — P5 GOVERNANCE DECISION |
| D-07 | Selección/deduplicación no congelada | Todos los POIs; identidad nueva; identidad canónica P3 | Sólo POIs activos, dentro del corredor y categorías solicitadas; deduplicar por identidad POI existente | Modelo P3 e índice espacial verificados | ACCEPTED — P5 GOVERNANCE DECISION |
| D-08 | Resultados potencialmente no acotados | Sin límite; paginación; límite simple | `limit`: default 20, máximo 50; consulta y resultado deben quedar acotados | Estrategia de rendimiento y P5.0-B | ACCEPTED — P5 GOVERNANCE DECISION |
| D-09 | Señales de ranking no disponibles en P3 | Crear quality; ranking opaco; proximidad determinista | `DISCOVERY_V1`: distancia a ruta como señal primaria y UUID canónico como desempate; `score` y `reasonCodes` explicables | P3 no tiene quality/relevance operacional verificable | ACCEPTED — P5 GOVERNANCE DECISION |
| D-10 | Progreso figuraba como arquitectura, no contrato | Diferir; calcular en Java; PostGIS | Incluir `routeProgress` 0.0–1.0 con PostGIS; mantenerlo separado del ranking | Entrega 04.4; ADR-012 | ACCEPTED — P5 GOVERNANCE DECISION |
| D-11 | Detour aparece en ejemplos antiguos | Hacerlo obligatorio; opcional; diferir | Distancia/tiempo adicional y rutas alternativas quedan fuera de P5 v1 | Documentación vigente los declara evolución posterior | DEFERRED |
| D-12 | Posible persistencia de rutas/resultados | Persistir; cachear; transitorio | Ruta y resultados discovery son transitorios; no se persiste historial GPS | Privacy by Default; baseline P4 sin persistencia | ACCEPTED — P5 GOVERNANCE DECISION |
| D-13 | Posible cambio de schema/índices | Migración preventiva; usar baseline; decidir durante código | `NO NEW MIGRATION`; cualquier necesidad objetiva causa Governance Stop | P3 ya aporta Point 4326 y GiST | ACCEPTED — P5 GOVERNANCE DECISION |
| D-14 | Redis aparece en estrategia/backlog | Cache obligatoria; opcional; diferir | Redis queda fuera del contrato funcional v1 hasta medir | No existe requisito/SLO que lo justifique | DEFERRED |
| D-15 | CEFI podría confundirse con discovery | Integrarlo; crear adaptador; consumidor futuro | P5 permanece independiente del canal; CEFI/LLM/voz quedan fuera | ADR-027; Product Master; Project Context | REJECTED para P5 v1 |
| D-16 | Nearby/search podrían mezclarse con corredor | Places API genérica; reutilización futura; sólo ruta | P5 consulta POIs respecto de una ruta; nearby/search quedan fuera | P3 DoD y planificación P6+ | REJECTED para P5 v1 |
| D-17 | Cambios al motor/dataset territorial | Cambiar motor/PBF; mantener P4 | Consumir P4 sin modificar GraphHopper, PBF, bounding box o graph cache | ADR-028; cierre P4 | REJECTED para P5 v1 |

## 3. Decisiones finales por dominio

### Alcance funcional

P5 v1 recibe origen, destino y criterios simples; planifica mediante P4; consulta POIs
activos dentro del corredor; filtra categorías; deduplica; calcula distancia a ruta y
progreso; aplica ranking determinista; limita y devuelve ruta más resultados.

### Arquitectura

Route Discovery es un capability separado y provider-neutral. La composición pertenece
a aplicación. El controller no llama a GraphHopper. Se incorpora un port read-side
espacial y un adaptador PostgreSQL/PostGIS, sin ampliar indiscriminadamente
`PoiRepository`.

### API

Se adopta `POST /api/v1/routes/discover` con `origin`, `destination`, `categories?`,
`corridorMeters?` y `limit?`. No acepta `routeGeometry` del cliente en v1. Devuelve
`route` y `results[]` con identidad, nombre, categoría, ubicación, distancia a ruta,
progreso, score y razones, más metadata mínima del algoritmo.

### Datos y persistencia

Se reutilizan P3, Point/SRID 4326 y GiST. No se crean tablas, migraciones ni persistencia
de resultados. Provenance sigue siendo requisito de publicabilidad heredado, pero no es
señal automática de ranking.

### Algoritmos

El corredor y las distancias se calculan en PostGIS. `DISCOVERY_V1` ordena por distancia
a ruta y desempata por UUID canónico. `routeProgress` se calcula por separado y se
expone; no altera implícitamente el ranking.

## 4. Decisiones diferidas

- Detour, distancia/tiempo adicional y rutas alternativas por POI.
- Redis y otras optimizaciones basadas en cache.
- Señales de ranking distintas de datos P3/P5 verificables.
- Nearby, search, CEFI, voz, LLM, mobile y real-road pilot.

## 5. Nota de gobierno

El requerimiento de “generation timestamp where contractually appropriate” se resuelve
incluyéndolo como `generatedAt` obligatorio en metadata de respuesta para trazabilidad.
El posible doble límite se resuelve exigiendo un fetch acotado y un límite final igual al
`limit` validado; cualquier sobreselección interna debe ser pequeña, determinista,
documentada y cubierta por evidencia de plan de consulta.
