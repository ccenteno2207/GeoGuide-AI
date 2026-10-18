# UI-2 — Discovery y evidencia de alcance

**Discovery:** `COMPLETED` · **Estado contractual actual:** `APPROVED_FROZEN` · **Freeze:** `RECORDED` · **Implementación:** `NOT_AUTHORIZED`
**Baseline auditado:** `726cb989a902110aeeab314e5747ce684e201748` (`origin/main`, posterior a PR #84).
**Propósito:** documentar el estado observable del mapa, exploración, búsqueda, POIs y dependencias para preparar un contrato UI-2 sin reabrir contratos P8/P9 ni inferir autoridad del roadmap.

**Reconciliación posterior:** las decisiones humanas U2-D01–U2-D06 y los criterios UI2-AC-01–AC-14 fueron aprobados después del Discovery. Posteriormente se aprobó y registró el freeze contractual UI-2. Las observaciones siguientes conservan su carácter histórico; la secuencia posterior se registra en §10.

## 1. Resultado y método

El cierre remoto UI-1 se verificó como `PASS` antes de este Discovery. UI-1 está integrada por PR #83 en `e443c0aa10987e04367dd15a1df259438426c3bc`; el cierre documental se integró por PR #84 en `726cb989a902110aeeab314e5747ce684e201748`. La evidencia y el detalle de su alcance permanecen en [UI-1 Execution and Acceptance Evidence](UI-1-Execution-and-Acceptance-Evidence.md). La evidencia declara pruebas físicas y lector de pantalla pendientes, y las capturas comparativas son render del Widget Test, no cartografía de un dispositivo.

Se inspeccionaron fuentes versionadas del baseline remoto, incluyendo mapa, presentación Discovery, modelos y mapper móviles, endpoints/DTO backend, P3, P8/P9, I01, GPS/B1/R01, CEFI, Driving, accesibilidad y diseño. Los resultados de compilación o pruebas de UI-1 se citan como evidencia documental histórica; no se ejecutaron suites durante este Discovery.

## 2. Inventario funcional actual

| Capacidad | Estado observado | Evidencia principal | Implicación UI-2 |
|---|---|---|---|
| Mapa y ruta | Existe `BaseMapPage`, `FlutterMap`, control de cámara, marcadores de extremos/POIs y geometría de ruta. | [`base_map_page.dart`](../../../mobile/lib/features/map/presentation/base_map_page.dart), [`Map-Strategy.md`](../../07-Mobile-Engineering/05-Maps-GPS/Map-Strategy.md) | Mantener mapa y ruta centrales; no cambiar cámara/GPS. |
| Ruta | Selección de origen/destino por toques en mapa; planificador separado. | [`route_planning_controller.dart`](../../../mobile/lib/features/route_planning/presentation/route_planning_controller.dart), [`RoutePlanController`](../../../backend/src/main/java/ai/geoguide/routing/infrastructure/http/RoutePlanController.java) | No sustituir por entrada textual en UI-2. |
| POIs en mapa | Marcadores activan Preview. | [`base_map_page.dart`](../../../mobile/lib/features/map/presentation/base_map_page.dart) | Reutilizar navegación existente y conservar contexto. |
| Lista | Alternancia Mapa/Lista y selección de fila a Preview ya existen. | [`base_map_page.dart`](../../../mobile/lib/features/map/presentation/base_map_page.dart), [`exploration_shell_test.dart`](../../../mobile/test/features/map/exploration_shell_test.dart) | Mejoras de presentación deben respetar la equivalencia y no seleccionar al abrir. |
| Preview/Detail | Fichas muestran nombre, categoría, distancia al trazado, razón conocida y, si hay datos, descripción/procedencia. | [`poi_preview_sheet.dart`](../../../mobile/lib/features/discovery/presentation/poi_preview_sheet.dart), [`poi_detail_sheet.dart`](../../../mobile/lib/features/discovery/presentation/poi_detail_sheet.dart) | No añadir campos no presentes en DTO. |
| Categorías | Diez códigos Discovery del catálogo P3; selección de categorías causa nueva consulta. | [`discovery_poi.dart`](../../../mobile/lib/features/discovery/domain/discovery_poi.dart), [`DiscoveryFilterSheet`](../../../mobile/lib/features/discovery/presentation/discovery_filter_sheet.dart) | Reutilizar categorías Discovery; no mostrar automáticamente categorías de servicios. |
| Estados | Loading, vacío, error/retry y estado de disponibilidad offline existen. | [`offline_discovery.dart`](../../../mobile/lib/features/discovery/application/offline_discovery.dart), [`offline_ui_test.dart`](../../../mobile/test/features/discovery/offline_ui_test.dart) | Conservar semántica y mensajes factuales. |
| Snapshot/cache | Un snapshot ruta+consulta+POIs, TTL 24 h, máximo de payload 5 MiB, captura consentida. | [`route_snapshot.dart`](../../../mobile/lib/features/discovery/domain/route_snapshot.dart), P9 §6 | Sin URLs de imágenes o datos derivados que cambien el contrato del snapshot. |
| Selección I01 | `SelectedPoiDraft` liga IDs al objeto snapshot vigente; elección explícita; freeze al iniciar B1. | [`selected_poi_session.dart`](../../../mobile/lib/features/tracking/application/selected_poi_session.dart), [I01 evidence](I01-Selected-POI-Session-Integration-Evidence.md) | Preview/Detail y presentación de tarjeta no seleccionan por sí solos. |
| GPS/B1 | Ubicación puntual y sesión B1 tienen ownership, lifecycle y permisos existentes. | [`base_map_page.dart`](../../../mobile/lib/features/map/presentation/base_map_page.dart), [`R01 evidence`](R01-GPS-Lifecycle-Remediation-Evidence.md) | No modificar política ni activar ubicación por UI-2. |
| Driving | Rama reducida separada, pantalla estática con salida; callbacks UI de exploración están protegidos por guards. | `BaseMapPage._buildDrivingView`, P9 §7, [Driving screen spec](../../05-UX-UI/06-Screen-Specifications/Driving-Mode.md) | Mantener árbol/guards; lista, búsqueda y acciones nuevas excluidas. |
| CEFI | Avisos TTS consentidos actuales; sin STT/micrófono. | [`C2 evidence`](C2-CEFI-Voice-Alerts-Implementation-Evidence.md), ADR-027 | Sin expansión de voz; integración visual futura asignada a UI-3. |

## 3. Contrato de datos y límites reales

El endpoint de descubrimiento actual es `POST /api/v1/routes/discover`; la operación planifica y devuelve POIs dentro del corredor de una ruta. El controlador no define endpoint de búsqueda de lugar/localidad ni autocompletado. La respuesta `RouteDiscoveryResponse.Result` tiene `id`, `name`, `category`, `location`, `distanceToRouteMeters`, `routeProgress`, `score`, `reasonCodes`, `description`, `sourceLabel`, `sourceUrl` y `attribution`. El mapper móvil admite estos campos. No hay campo de imagen en dominio P3, persistencia, respuesta o modelo móvil. No se encontró endpoint público `GET /api/v1/pois` en el módulo inspeccionado.

La distancia disponible es exclusivamente perpendicular/al trazado (`distanceToRouteMeters`), presentada como «A X m del trazado»; no es distancia desde usuario, distancia a pie, desvío ni distancia restante. Los extremos son coordenadas de ruta; no se dispone de nombres de localidad derivados para etiquetarlos.

El catálogo de categorías tiene 15 entradas P3. Discovery expone 10 (cascada, laguna, montaña, bosque, playa, museo, sitio arqueológico, monumento, iglesia histórica y mirador). FUEL, HEALTH, FOOD, LODGING y OTHER no son categorías de exploración turística habilitadas por la lista actual. No ampliar taxonomía ni catálogo como parte implícita del contrato.

### Fixture P3

`backend/src/main/resources/data/p3/lima-obrajillo-v1.json` contiene exactamente cinco registros del fixture versionado: Santuario de Santa Rosa de Quives (`HISTORIC_CHURCH`), Petroglifos de Checta (`ARCHAEOLOGICAL_SITE`), Plaza de Armas de Canta (`MONUMENT`), Plaza de Armas de Obrajillo (`MONUMENT`) e Iglesia San Juan Bautista de Obrajillo (`HISTORIC_CHURCH`). Incluye coordenadas, descripción y dos referencias de procedencia por POI. La evidencia P3 reporta 5 POIs y 15 categorías cargados en su entorno validado en septiembre de 2026; esto no prueba que ese conteo siga desplegado en un ambiente actual ni que sea un conjunto global. El dataset no incluye fotografías.

## 4. Búsqueda: capacidades separadas

| Capacidad | Estado real | Recomendación UI-2 |
|---|---|---|
| Filtrar dentro de POIs de la respuesta/snapshot actual | Al auditar no había caja de búsqueda textual. | Decisión posterior aprobada U2-D01: filtro efímero por nombre dentro de los POIs del snapshot, rotulado «Buscar en estos resultados», sin consulta, cobertura ni mutación del snapshot. |
| Localidades/destinos como Canta o Ica | No existe consulta local ni endpoint actual que las resuelva desde texto. | Fuera del mínimo UI-2. Requiere contrato de búsqueda, fuente/cobertura, atribución, privacidad, ambigüedad y fallback al mapa. |
| Geocodificación/autocomplete | No existe en el flujo actual de exploración y queda diferida en UI-0/P8. | No incluir ni simular. Aprobación funcional y arquitectura/fuente separadas. |
| Extensión de backend/API | No hay endpoint que cumpla la búsqueda anterior; el endpoint actual es route-first. | Gate humano independiente, OpenAPI, backend y compatibilidad P9 antes de cualquier cambio. |

El filtro local aprobado solo opera en memoria sobre el snapshot vigente y nunca transforma la lista parcial en una afirmación de «sin lugares en la zona». Para preservar claridad de la identidad turística, cualquier capacidad geográfica futura debe limitar resultados a POIs, localidades y atractivos turísticos; personas, contactos, comercio genérico y domicilios arbitrarios quedan fuera de producto.

## 5. Medios, procedencia y ADMIN

P3 guarda procedencia y atribución textual, no activos de imagen. La arquitectura describe MinIO como almacenamiento de objetos futuro con bucket privado y acceso por backend/URL temporal cuando se implemente; esto no demuestra que exista integración POI-media, endpoint o autorización operativa. UI-2 no debe fabricar URLs ni introducir imágenes externas.

Las decisiones posteriores U2-D02/D03 aprueban espacio reservado de miniatura con placeholder neutral y fixtures sintéticos adecuados solo para pruebas internas. Fotografías reales requieren evidencia verificable de origen, autor, licencia/autorización y atribución pertinente; recursos sin derechos comprobados no se renderizan. `TEST_ONLY`, `RIGHTS_NOT_VERIFIED`, `RIGHTS_VERIFIED` y `PUBLICATION_APPROVED` siguen siendo estados conceptuales, no columnas existentes. No se incorpora recurso en esta reconciliación. La política está en [UI-2 POI Media and Test Fixture Policy Proposal](UI-2-POI-Media-and-Test-Fixture-Policy-Proposal.md).

ADMIN-0 es una propuesta de portal y workflow editorial no aprobada. No es dependencia de ejecución para UI-2 de presentación con los datos actuales. La publicación administrada de activos, si se requiere, es una fase posterior con API y contrato de medios separados.

## 6. Autoridad y contradicciones a presentar

- P8 es `APPROVED_FROZEN` y excluyó búsqueda, geocodificación y media. P9 está cerrada; su contrato limita snapshots a datos coherentes ya obtenidos y exige gate para Search/proveedor externo, cambios de API y datos. La futura UI-2 debe ser un contrato nuevo aprobado, sin reescribir P8/P9.
- La propuesta UI-0 conserva búsqueda geográfica fuera de operación y geocodificación no incluida. U2-D01 aprueba únicamente un filtro local del snapshot; no contradice esa frontera de API/geocodificación y no reabre P8.
- ADMIN-0, CEFI, Driving/GPS/B1/R01 y cualquier servicio de búsqueda no pueden tratarse como autorización derivada del diseño visual.

## 7. Límites del Discovery

No se modificó ni ejecutó código, pruebas, APIs, dependencias, base de datos, activos, contratos congelados, checkout principal o worktrees ajenos. No se descargaron fotografías. No se ejecutaron suites Flutter ni builds. La inspección fue sobre `origin/main` en `726cb989a902110aeeab314e5747ce684e201748`; el entorno de despliegue no se consultó, así que los conteos actuales de producción no se afirman.

## 8. Fuentes adicionales

- [P8 Phase Contract v1](P8-Phase-Contract-v1.md)
- [P9 Phase Contract v1](P9-Phase-Contract-v1.md)
- [P9.4 Final Audit](P9.4-Audit-and-Closure-Evidence.md)
- [GPS/CEFI governance evidence](GPS-CEFI-Post-Merge-Governance-Evidence.md)
- [Design System](../../05-UX-UI/04-Design-System/Design-System.md)
- [Accessibility](../../05-UX-UI/07-Accessibility/Accessibility.md)
- [ADR-016 Flutter](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-016-Flutter.md), [ADR-019 Map Library](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-019-Map-Library.md), [ADR-027 Channel Independent Interaction](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-027-Channel-Independent-Interaction-and-Voice.md)

## 9. Reconciliación de decisiones aprobadas

| Decisión | Aclaración aprobada posterior al Discovery |
|---|---|
| U2-D01 | El filtro local es parte del alcance UI-2; aplica solo al snapshot vigente, no llama backend, no muta snapshot ni persiste query, se oculta en Driving y dice «No hay coincidencias en estos resultados». Normalización: Unicode NFD, eliminar marcas diacríticas, trim, colapsar espacios y comparación case-insensitive por subcadena del nombre POI. La query sobrevive apertura/cierre de Preview/Detail en la misma sesión y se limpia al cambiar la identidad del snapshot, al vencer este o al abandonar Exploración. |
| U2-D02 | Toda tarjeta reserva un área de thumbnail de dimensiones estables con placeholder neutral accesible; nombre/datos no dependen de imagen. Los tamaños 96×72 dp (tarjeta) y 16:9 acotado (detalle) son puntos de partida ajustables en implementación tras layout/accesibilidad. |
| U2-D03 | Fixtures sintéticos solo para pruebas internas; fotos reales solo con derechos verificados para el uso controlado exacto, con fuente/autor/licencia o autorización y atribución requerida. Sin derechos, no renderizar. `TEST_ONLY` no entra en APK release. Los cuatro estados son conceptuales; sin cambios de esquema/API/backend. |
| U2-D04 | Búsqueda de localidades/destinos, búsqueda global, geocodificación y autocomplete remoto quedan fuera; requieren contrato funcional independiente sobre fuente/cobertura/privacidad/atribución/desambiguación/rutas/API. |
| U2-D05 | Exigir validación automatizada completa en ejecución futura. Widget tests, renderer Flutter, build APK, dispositivo Android, TalkBack y cartografía/tiles se registran por separado. Lo no ejecutado es `PENDING`/`NOT_EXECUTED`, nunca PASS. |
| U2-D06 | Contraste suficiente independiente de los colores variables de tiles; WCAG AA donde aplique, targets ≥48×48 dp, lista accesible, semantics, estados no solo por color, escalas 1.0/2.0, viewports 360×640/360×800/640×360/800×360, nombres largos y opcionales. Automatización no sustituye lector físico. |

```ini
UI_2_DECISIONS_D01_D06 = APPROVED
```

```ini
UI_1_REMOTE_CLOSURE_VERIFICATION = PASS
UI_2_DISCOVERY = COMPLETED
UI_2_CONTRACT = APPROVED_FROZEN
UI_2_CONTRACT_FREEZE = RECORDED
UI_2_IMPLEMENTATION = NOT_AUTHORIZED
```

## 10. Registro posterior del freeze

Después de completar el Discovery y reconciliar U2-D01–D06, el responsable aprobó formalmente la revisión de freeze y UI2-AC-01–AC-14. El contrato candidato quedó `APPROVED_FROZEN` en el worktree documental con referencia técnica `726cb989a902110aeeab314e5747ce684e201748`. Esta anotación registra un evento posterior; no altera qué observó originalmente el Discovery ni afirma integración en `origin/main`.

La aprobación de freeze no ejecuta ni valida criterios. Todas las pruebas futuras siguen bajo autorización de implementación independiente; no se declara PASS por esta anotación.
