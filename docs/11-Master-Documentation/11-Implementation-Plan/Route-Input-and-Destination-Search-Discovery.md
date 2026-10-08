# Route Input and Destination Search — Discovery Proposal

## Status and boundaries

```ini
DISCOVERY_ONLY = YES
IMPLEMENTATION = NOT_AUTHORIZED
P12_CONTRACT = UNCHANGED
P12_FIELD_EXECUTION = NOT_AUTHORIZED
```

This is an independent proposal. It does not add search or geocoding to P12, GPS Follow Mode, or the frozen Driving contract.

## Product scope decision

```ini
SEARCH_SCOPE = PLACES_AND_POIS_ONLY
POSTAL_ADDRESS_SEARCH = OUT_OF_SCOPE
ORIGIN = CURRENT_GPS_OR_SEARCHED_PLACE_OR_POI
DESTINATION = SEARCHED_PLACE_OR_POI
MAP_SELECTION_FALLBACK = REQUIRED
WAYPOINTS = OUT_OF_SCOPE
DRIVING_CHANGES = NONE
CONTRACT_STATUS = DESIGN_APPROVED_OPERATIONAL_GATES_PENDING
```

Valid examples include Canta, Plaza de Armas de Canta, Ica, Huacachina, Nazca and Paracas. Street names with house numbers, such as Avenida Perú 2469, are rejected as out of scope.

## A. Current architecture

The Flutter map currently accepts two map taps through `RoutePlanningController.selectPoint`. The first tap becomes origin, the second destination; a third selection starts a new pair. `PlanRoute` sends the pair to the existing route-planning port. `OfflineDiscovery` then composes the same query with Route Discovery and stores the existing one-snapshot cache. There is no text input, autocomplete, geocoding, reverse geocoding or waypoint model. The backend route API accepts only origin and destination.

## B. UX proposal

Add a route-input surface outside Driving with two editable fields:

1. **Origen**: actions `Usar mi ubicación`, `Buscar lugar o POI` and `Elegir en el mapa`.
2. **Destino**: actions `Buscar lugar o POI` and `Elegir en el mapa`.

Each result must represent a locality, geographic place, tourism attraction or POI, and show name, locality/region context and provider attribution. Curated GeoGuide AI catalog results take priority when a matching stable POI exists. The user confirms one result before it becomes a coordinate. Ambiguous or empty results remain unresolved and cannot be sent to routing. A map preview shows both confirmed points before `Planificar ruta`. Driving receives only the resulting route snapshot and exposes no search controls.

## C. Geocoding alternatives

| Alternative | Fit | Cost/privacy/licence | Disposition |
|---|---|---|---|
| Curated GeoGuide catalog first | Stable known POIs and tourism places already used by Route Discovery | Best provenance and privacy; coverage is finite and requires governance | Required first source |
| Self-hosted Nominatim | OSM localities, named places and POIs; postal-address mode is excluded | Open data/software; operational compute is ours; public instance has strict usage policy | Candidate for locality/place fallback |
| Self-hosted Photon | OSM place/POI search with Apache-2.0 software and OpenSearch | No per-request vendor fee; requires Java 21+/OpenSearch/data operations | Candidate for bounded place search |
| Self-hosted Pelias | Modular OSM/open-data place search with provider composition | No per-request vendor fee; highest operational/data complexity | Candidate only if place coverage justifies it |
| Hosted commercial geocoder | Usually strong coverage and SLA | Provider account, quotas, terms, possible recurring cost and location-data transfer | Not authorized; requires human product/security/cost decision |

The public Nominatim endpoint must not be treated as an unbounded production dependency: its policy requires attribution, a valid identifying User-Agent, caching and rate discipline. Photon and Pelias are technically self-hostable, but their operational resources and data refresh strategy must be approved first.

## D. Reusable components

- Existing `RoutePoint`, `PlanRoute`, route response mapper and error normalization.
- Existing Route Discovery query, category filters, POI presentation and snapshot identity.
- Existing map controller and manual tap selection as the fallback.
- New provider-neutral application port `SearchLocations` returning candidates with source attribution and confidence/context; no provider type should leak into widgets.

## E. Proposed functional contract

The capability accepts a place/POI query and optional map bias, returns zero or more attributed candidates, requires explicit candidate confirmation, and converts only a confirmed candidate to `RoutePoint`. Current GPS is allowed only as the origin. It must support manual map selection without search. It must exclude postal-address results using the policy detailed in section J and must not persist search history, upload personal history, or infer a route from an unconfirmed ambiguous result. A future waypoint list is a separate extension and is not included here.

## F. Errors and ambiguity

Represent empty, timeout, rate-limited, unauthorized, provider-unavailable and malformed responses separately. Display a recoverable message, preserve already confirmed fields, and never silently substitute a nearby place. Duplicate candidates use exact source identity; cross-source candidates remain separate as detailed in section J.

## G. Dependencies and risks

- Provider choice and operational ownership.
- API boundary and TLS/security policy.
- Attribution and OSM licence compliance.
- Privacy review for query text and precise location bias.
- CEFI integration is future work; conversational intent must not bypass explicit confirmation.
- Waypoints, multi-stop routing and route alternatives require a separate contract.

## H. Acceptance criteria proposal

1. Existing two-tap route planning remains available.
2. Origin and destination fields validate independently and preserve confirmed state.
3. Search results are attributed, selectable and never auto-applied when ambiguous.
4. Confirmed points reuse the existing route and Route Discovery ports.
5. Search failure categories are distinguishable and recoverable.
6. No query history, continuous location upload or background permission is introduced.
7. Driving exposes no search or secondary controls.
8. Provider policy, licence, rate limits, retention and cost are documented before implementation.
9. P12 contracts and evidence remain byte-equivalent.

## I. Decisions required

- Select self-hosted Nominatim, Photon, Pelias or a separately approved hosted provider.
- Approve operational resources and data refresh/licence policy.
- Place/POI scope and postal exclusion are already approved.
- Waypoints are already out of scope.
- Privacy and retention design are human-approved; operational verification remains required.

The design is HUMAN_APPROVED. Provider and operational decisions remain pending as specified in sections J/K; implementation and operational freeze are not authorized.

## J. Remediación contractual para aprobación humana

Esta sección precisa y reemplaza las alternativas abiertas de arquitectura, privacidad y AC anteriores. Las decisiones funcionales de PLACES_AND_POIS_ONLY ya están aprobadas; arquitectura, frontera API, combinación de fuentes y privacidad están aprobadas como diseño. Proveedor y recursos operativos siguen pendientes; no se autoriza implementación ni congelamiento operativo.

```ini
CONTRACT_STATUS = DESIGN_APPROVED_OPERATIONAL_GATES_PENDING
PREFERRED_CANDIDATE = PHOTON_SELF_HOSTED
PROVIDER_SELECTED = NO
INFRA_DEPLOYMENT = NOT_AUTHORIZED
PR_71_DOCUMENTARY_MERGE = HUMAN_AUTHORIZED
IMPLEMENTATION = NOT_AUTHORIZED
```

### Arquitectura y combinación de fuentes

Flutter invoca una futura capacidad SearchPlaces en Spring Boot. Application orquesta un puerto de consulta del catálogo curado y un puerto neutral de búsqueda externa; los adaptadores de infraestructura normalizan resultados. Domain define candidatos sin tipos Photon. Los widgets presentan candidatos y confirmación, sin acceso a SQL ni proveedores directamente.

La búsqueda inicial consulta exclusivamente el catálogo existente. El usuario puede solicitar explícitamente ampliar a fuentes externas para la misma consulta, incluso si hay coincidencias curadas. Un fallo externo conserva los resultados curados. No se usa Route Discovery como buscador global: su consulta depende de un corredor de ruta. El acceso read-only al catálogo necesita su propia capacidad, sin cambios de esquema propuestos.

Los resultados tienen identidad compuesta source/sourceId. El ID GeoGuide no se sustituye por un ID OSM; un resultado externo no se publica en el catálogo. Se agrupan únicamente identidades iguales dentro de una fuente. Entre fuentes se muestran candidatos separados con atribución, priorizando coincidencias curadas relevantes; no se fusionan por proximidad ni nombre. Homónimos muestran localidad, provincia/región y país; contexto ausente se declara no disponible. Ninguno se confirma automáticamente.

GPS asigna origen mediante acción explícita y no invoca geocodificación ni sesgo externo. El usuario confirma el punto antes de planificación. Solo una pareja confirmada alimenta PlanRoute, Route Discovery y el snapshot existente. Editar un campo invalida su confirmación y las solicitudes pendientes asociadas, preservando el otro campo. No cambia TTL, tamaño, formato ni identidad de la caché vigente.

### Frontera HTTP propuesta, sin implementación

`POST /api/v1/places/search` sería una capacidad nueva, aprobada como diseño contractual, con ADR aplicable pendiente antes de construcción. No modifica los contratos de routes/plan ni routes/discover.

Entrada: query (texto Unicode normalizado, no vacío), sourceMode (CURATED_ONLY por defecto o EXTERNAL_EXPLICIT), requestId opaco generado por cliente. País fijo PE, sin coordenadas GPS, dirección postal, waypoint ni identidad personal. No se expone URL configurable por el usuario.

Límites propuestos para aprobación: query 2–120 caracteres Unicode; hasta 10 candidatos por fuente; cuerpo hasta 4 KiB; presupuesto total de 10 segundos; sin retries automáticos contra proveedor; máximo una solicitud activa por campo en cliente. Estos valores son límites de diseño propuestos, no mediciones ni umbrales ya aprobados. La cuota agregada de servidor debe fijarse después de medir capacidad; su ausencia bloquea congelamiento/despliegue.

Salida: requestId, candidates[], source status (OK, EMPTY o error normalizado), truncated. Cada candidato contiene source, sourceId, kind (LOCALITY/PLACE/TOURISM/POI), displayName, administrativeContext, countryCode, latitude, longitude y attribution. Coordenadas finitas/rango WGS84 y país PE son validados por adaptador; no se ofrece score comparable entre fuentes.

Errores: 400 INVALID_QUERY/UNSUPPORTED_SCOPE; 413 REQUEST_TOO_LARGE; 429 RATE_LIMITED; 504 SEARCH_TIMEOUT; 503 SOURCE_UNAVAILABLE; 502 INVALID_SOURCE_RESPONSE/SOURCE_FAILURE. Credenciales rechazadas por proveedor se normalizan como fallo de fuente, no como 401 del usuario. TLS nunca se degrada a HTTP. Los mensajes no incluyen consultas, URLs internas, paths, credenciales ni payload proveedor. Un vacío válido devuelve 200 y candidates vacío. Una ampliación externa fallida puede conservar candidatos curados con source status de fallo explícito.

Cliente usa generaciones locales; solo la generación vigente puede actualizar el campo. Cancelar HTTP no garantiza cancelación del trabajo remoto. Backend limita tiempo/recursos y libera conexiones. Confirmación es un evento local explícito posterior a la respuesta, no una inferencia del servidor.

No hay rechazo indiscriminado de dígitos: un nombre de POI puede contener números. La política combina aviso de alcance y allow-list de tipos del proveedor; direcciones/calles/números postales no se devuelven como candidatos. Queries ambiguas se resuelven con resultados tipados o mensaje de alcance, sin afirmar que un patrón textual identifica siempre una dirección.

### Privacidad y retención — HUMAN_APPROVED_DESIGN

Sin historial persistente, sin caché compartida inicial y sin coordenadas GPS implícitas hacia buscadores. Query y candidatos viven en memoria durante procesamiento y sesión editable; se liberan al finalizar/cancelar la consulta o cerrar la sesión, sin prometer borrado criptográfico de memoria administrada.

Aplicación, proxy y servicio autoalojado deben excluir cuerpos/query/coordenadas de access logs, traces, métricas, crash reports y diagnósticos. Usar POST evita texto en URL, pero no sustituye la configuración de logging. Solo registrar código de resultado, duración y contador agregado sin requestId persistente ni identidad de dispositivo. Retención máxima aprobada de métricas técnicas agregadas: siete días con acceso de operador limitado, sin identificadores personales ni posibilidad práctica de reconstruir consultas individuales. No incluirlas en backups de consultas ni persistir payloads. Un proveedor ajeno no es elegible si no permite verificar esta política.

El snapshot de ruta existente conserva sus puntos bajo el contrato offline y consentimiento existentes; “sin historial de búsqueda” no significa que ese snapshot no tenga coordenadas. No ampliar su retención ni capturar datos adicionales. Validar minimización en todos los componentes antes de declarar PASS de privacidad.

### Evaluación reproducible de proveedores, sin instalación ni consultas ejecutadas

Photon vigente se basa en OpenSearch y requiere Java 21+; una instancia externa requiere OpenSearch 3.x según documentación consultada. La referencia anterior a Elasticsearch queda corregida. El demo público no garantiza disponibilidad; no se propone como dependencia operativa. Nominatim autoalojado requiere PostgreSQL/PostGIS e importación/actualización. Pelias utiliza Elasticsearch e importadores/servicios adicionales; su complejidad no se justifica todavía para este mínimo.

Plan de evaluación pendiente: registrar versión exacta, licencia de software/datos, fecha/checksum y procedencia del extracto Perú; comprobar disponibilidad del extracto sin asumir que exista un dump Photon Perú. Medir importación, tamaño final, pico RAM/CPU, SSD libre y espacio para actualización/rollback. Evaluar actualización, reconstrucción, healthcheck, TLS, cuotas, logs, recuperación y mantenimiento. No reutilizar ni modificar PostGIS productivo para estas pruebas.

Corpus propuesto: Canta, Plaza de Armas de Canta, Ica, Huacachina, Nazca, Paracas; variantes de acentos/mayúsculas/errores; homónimos; nombres con números; consulta inexistente; Avenida Perú 2469 como negativo postal. Para cada caso registrar tipo, contexto, fuente/ID y pertinencia contrastada con fuentes documentadas, sin consultas personales. Medir latencia y recursos sin inventar resultados ni SLA. Ranking y cobertura se comparan con el mismo corpus e importación documentada. La calidad peruana permanece NOT_VALIDATED.

Coste: software abierto no equivale a operación gratuita. Presupuestar cómputo, disco, energía/alojamiento, actualización y horas operativas; no hay importe aprobado ni servicios comerciales autorizados. Revisar ODbL/atribución OSM y licencia exacta de release/componentes antes de seleccionar. Photon Apache-2.0 no determina por sí solo la licencia de datos.

Fuentes oficiales consultadas: https://github.com/komoot/photon ; https://nominatim.org/release-docs/latest/admin/Installation/ ; https://operations.osmfoundation.org/policies/nominatim/ ; https://github.com/pelias/pelias . La instancia pública Nominatim limita tráfico agregado a 1 petición/s, prohíbe autocomplete y requiere decisión informada del responsable; no se propone como dependencia del mínimo.

### Matriz de aceptación propuesta

Todos los criterios están NOT_EXECUTED para la nueva capacidad. La evidencia se genera únicamente tras autorización de implementación.

| ID | Comportamiento esperado | Método | Evidencia exigida | Regla PASS / FAIL |
|---|---|---|---|---|
| RI-AC-01 | GPS solo asigna origen mediante acción explícita, sin sesgo externo | Unit/widget y Android | Assertions y observación permiso/acción | PASS si no hay asignación/envío implícito; FAIL si ocurre |
| RI-AC-02 | Ambos campos exigen confirmación e invalidan candidato al editar | Unit/widget | Estados de cada campo y caso edición | PASS con confirmación explícita y otro campo preservado; FAIL con uso de texto no confirmado |
| RI-AC-03 | Nombre, contexto, fuente y atribución visibles | Mapper/widget | Casos con contexto completo/ausente | PASS si se muestran o ausencia se declara; FAIL si se inventa contexto |
| RI-AC-04 | Catálogo primero, ampliación explícita, homónimos y duplicados seguros | Unit/integración/widget | Identidades iguales/distintas y fallo externo | PASS sin fusión entre fuentes ni selección automática; FAIL si se pierde candidato curado o se fusionan distintos |
| RI-AC-05 | Solo tipos places/POIs; direcciones postales fuera | Mapper/corpus | Negativo postal y nombre legítimo con dígitos | PASS sin candidatos address/street y sin rechazo numérico indiscriminado; FAIL si se admiten direcciones |
| RI-AC-06 | Selección manual funciona ante fallo de búsqueda | Widget/Android | Selección de ambos puntos y planificación | PASS si fallback permite ruta real; FAIL si depende del proveedor |
| RI-AC-07 | Respuestas tardías no reemplazan generación actual | Unit con futures controlados | A/B respondidas en orden inverso y cancelación | PASS si solo B actualiza; FAIL si A sobrescribe |
| RI-AC-08 | Vacío, timeout, TLS, cuota y respuesta inválida distinguibles | Unit/integración | Fallos deterministas, mensajes sanitizados | PASS con estados correctos y curados preservados; FAIL con fallback inseguro o detalles sensibles |
| RI-AC-09 | Solo puntos confirmados válidos pasan a routing/discovery | Unit/contrato HTTP | Captura controlada de solicitudes y no-route | PASS con pareja exacta y error de ruta separado; FAIL con punto inválido/no confirmado |
| RI-AC-10 | Snapshot coherente, sin cambiar TTL/esquema/límites | Regresión offline | Consulta/route/POI coherentes y hashes históricos | PASS preservando contrato y generaciones; FAIL si mezcla consultas o renueva TTL |
| RI-AC-11 | Sin historial, GPS externo implícito ni logs sensibles | Inspección/config y integración | App/proxy/proveedor, cancelación, retención | PASS sin payload persistido y política aplicada; FAIL ante filtración o componente no verificado |
| RI-AC-12 | Driving/P12/GPS sin cambios de contrato ni controles | Diff/hash/widget | Hashes contratos y árbol Driving | PASS byte-equivalencia y UI preservada; FAIL ante cambios |
| RI-AC-13 | Cobertura Perú y operación verificadas antes de desplegar | Corpus/capacidad/auditoría | Versión, dataset, licencias, presupuesto y recuperación | PASS con acta de selección aprobada y evidencia completa; FAIL con demo asumido, cobertura o recursos sin validar |

### Checkpoints y recuperación propuestos

RI.0 aprobación del contrato/ADR/API/proveedor y privacidad; RI.1 evaluación aislada de proveedor/capacidad; RI.2 implementación catálogo/orquestación/adaptadores; RI.3 interfaz y regresión; RI.4 Android/evidencia; RI.5 revisión y cierre. RI.1 no puede instalar/importar hasta autorización específica. Si evaluación no satisface RI-AC-13, volver al gate proveedor sin cambiar scope.

Rollback funcional futuro: deshabilitar búsqueda y conservar selección manual, sin borrar snapshot. Cualquier despliegue requiere plan revisado de retorno de versión y reconstrucción del índice. No hacer migraciones ni operaciones destructivas como parte de esta propuesta.

### Decisiones humanas pendientes y riesgos residuales

Aprobados como diseño: orquestación Spring Boot, puerto SearchPlaces, frontera POST /api/v1/places/search con entradas/salidas/errores/validaciones, combinación catálogo primero y ampliación explícita, identidades separadas y privacidad/retención máxima de siete días. Pendientes: ADR aplicable antes de construcción, proveedor y versión tras evaluación, recursos/cuota/presupuesto/propietario operativo, límites operativos propuestos y corpus/criterios de cobertura. Alcance postal, waypoints y Driving ya están resueltos y no requieren nueva aprobación.

Riesgos: cobertura incompleta, POIs homónimos, licencias de datasets, fuga por logs de infraestructura, falta de extracto compatible, carga del índice y lugares fuera del grafo GraphHopper. No hay cobertura peruana ni coste demostrado todavía. El mínimo es implementable después de resolver estos gates; esta aprobación de diseño no autoriza implementación de API, servicios ni despliegues.

## K. Aprobación humana de diseño y cierre documental

El propietario aprobó el diseño funcional y arquitectónico, la frontera API contractual y la política de privacidad. No existe todavía el endpoint propuesto ni se han implementado controller, servicio o adaptador. Photon sigue siendo candidato y no proveedor seleccionado. La aprobación documental no aprueba infraestructura ni presupuesto.

```ini
ROUTE_INPUT_DESIGN = APPROVED
ROUTE_INPUT_PROVIDER = NOT_SELECTED
ROUTE_INPUT_IMPLEMENTATION = NOT_AUTHORIZED
ROUTE_INPUT_INFRASTRUCTURE = NOT_AUTHORIZED
RI_AC_EXECUTION = NOT_STARTED
CONTRACT_OPERATIONAL_FREEZE = NOT_AUTHORIZED
P12_CONTRACT = UNCHANGED
P12_5 = NOT_AUTHORIZED
```

RI-AC-01 a RI-AC-13 están definidos y NOT_EXECUTED. Para iniciar construcción se requiere resolver evaluación/selección de proveedor, cobertura Perú, dimensionamiento, costes, licencias, operación, cuotas y ADR aplicable; obtener autorización explícita de construcción y despliegue y completar congelamiento operativo mediante gobierno. La verificabilidad de privacidad debe demostrarse antes de producción. Este checkpoint autoriza únicamente integrar el documento mediante PR #71 y detenerse.
