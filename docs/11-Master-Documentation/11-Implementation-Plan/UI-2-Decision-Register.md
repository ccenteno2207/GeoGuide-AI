# UI-2 — Registro de freeze, decisiones y trazabilidad de ejecución

**Baseline:** `726cb989a902110aeeab314e5747ce684e201748` (`origin/main`).
**Estado del registro:** `APPROVED_FROZEN` para decisiones y criterios; implementación `NOT_AUTHORIZED`. Baseline técnico `726cb989a902110aeeab314e5747ce684e201748`. La aprobación humana de freeze queda registrada aquí y en el contrato principal; no afirma integración remota.

## 1. Decisiones humanas aprobadas

| ID | Decisión | Resolución aprobada | Límite e impacto | Estado |
|---|---|---|---|---|
| U2-D01 | Filtro textual local | «Buscar en estos resultados», solo nombres de POI del snapshot actual; sin backend, geografía ampliada, alteración de ranking/filtros backend, mutación/persistencia o Driving. Vacío: «No hay coincidencias en estos resultados». Unicode NFD, quitar marcas diacríticas, trim, colapsar espacios, comparación case-insensitive por subcadena. Se conserva al abrir/cerrar Preview/Detail en sesión; se limpia al cambiar identidad del snapshot, vencerlo o salir de Exploración. | No es búsqueda global ni de localidad. | `APPROVED_FROZEN` |
| U2-D02 | Área de miniatura | Zona de dimensiones estables en tarjeta/detalle; placeholder neutral accesible, datos visibles sin imagen y sin presentar ilustración como foto. Candidatos: tarjeta 96×72 dp; detalle ratio 16:9 acotado. | Tamaños ajustables con evidencia futura de layout/accesibilidad; no incorpora dependencia multimedia. | `APPROVED_FROZEN` |
| U2-D03 | Medios de prueba | Fixtures sintéticos con procedencia adecuada solo para pruebas internas. Foto real solo si derechos permiten el uso controlado exacto y se documentan fuente, autor, licencia/autorización y atribución. Sin rights verificados no se renderiza. `TEST_ONLY` se excluye de APK release. | Los estados `TEST_ONLY`, `RIGHTS_NOT_VERIFIED`, `RIGHTS_VERIFIED`, `PUBLICATION_APPROVED` son conceptuales; sin schema/DTO/backend. | `APPROVED_FROZEN` |
| U2-D04 | Búsqueda de localidad/destino | Fuera de UI-2: sin búsqueda global, geocoding ni autocomplete remoto. | Contrato futuro independiente de fuente, cobertura, privacidad, atribución, desambiguación, rutas y API. | `APPROVED_FROZEN` |
| U2-D05 | Evidencia/validación | Suite automatizada completa requerida en implementación futura. Widget tests, Flutter renderer, APK, Android físico, TalkBack y cartografía/tiles se reportan por separado. | Lo no ejecutado se registra `PENDING`/`NOT_EXECUTED`, nunca PASS. No declara Production Readiness. | `APPROVED_FROZEN` |
| U2-D06 | Accesibilidad | WCAG AA donde corresponda; contraste independiente de tiles; targets ≥48×48 dp; lista alternativa, semantics, estados no solo color; escalas 1.0/2.0; viewports 360×640, 360×800, 640×360, 800×360; nombres largos y campos opcionales. | Automatización no sustituye validación real con lector. | `APPROVED_FROZEN` |

Las seis decisiones están aprobadas y congeladas como parte del contrato UI-2. Esta aprobación fija requisitos; no registra ejecución ni resultado PASS de validación.

```ini
UI_2_ACCEPTANCE_CRITERIA_AC01_AC14 = APPROVED
UI_2_ACCEPTANCE_EXECUTION = NOT_STARTED
```

## 2. Aclaraciones contractuales, sin reabrir contratos congelados

| Fuente | Texto/decisión aplicable | Tratamiento propuesto |
|---|---|---|
| P8 §4 | Search/geocoding y media fuera de P8. | UI2 es fase separada. Filtro local del snapshot queda aprobado para UI2; P8 no se altera. Localidades/geocoding/media siguen fuera. |
| UI-0 compatibilidad | Dirección futura de búsqueda visual, selección por mapa preservada; buscador simulado prohibido. | U2-D01 permite filtro acotado de datos existentes; no representa búsqueda geográfica ni resultados simulados. |
| P9 §§5–7 | Snapshot preserva route/query/result coherente; Drive reducido y estático; Search, proveedores externos y cambio API requieren gate. | Usar snapshot como fue capturado; no alterar cache ni Driving. Un endpoint futuro se gobierna por contrato aparte. |
| ADR-016/019 | Flutter y librería de mapa aprobada. | Reutilizar stack y widgets existentes; sin migración de estado/librería. |
| ADR-027 | Interacción de voz desacoplada, estrategia hands-free y separación de lógica. | Sin voz nueva; el control visual CEFI corresponde a UI-3 y mantiene servicio actual. |
| I01 evidence | `chosenIds` explícitos vinculados a snapshot, freeze al iniciar B1. | Acción de tarjeta/Preview/Detail no selecciona. |
| ADMIN-0 | Propuesta de administración no aprobada. | No es dependencia para placeholders ni lectura de campos actuales; sin integración ni autorización de portal/API. |

## 3. Riesgos y clasificación

| Riesgo | Nivel | Tipo | Condición/mitigación |
|---|---|---|---|
| Filtrado local entendido como catálogo global | Alto | Riesgo de producto | Control y vacío con textos exactos aprobados; limitar internamente a nombres del snapshot. |
| Selección implícita o snapshot sustituido | Alto | Regresión funcional | Acción explícita única, mismos guards I01 y pruebas identidad/TTL/freeze. |
| Foto sin derechos o atribución de POI confundida con foto | Alto | Legal/producto | Placeholder; rights register por activo y aprobación para cada canal. |
| URLs multimedia en snapshot | Alto | Privacidad/arquitectura | No incluir; duración firmada no cubre cache P9. Media necesita contrato propio. |
| Overflow/accesibilidad en tarjetas/filtros | Medio | UX/accesibilidad | Matriz de viewports, texto 2.0, semantics; pruebas TalkBack aparte. |
| Driving expone affordance tras recompose/callback tardío | Alto | Seguridad/regresión | Sin superficie nueva, mantener rama/guards, probar handlers directos y no diferir. |
| API nueva para localidades entra por conveniencia visual | Alto | Gobernanza | STOP y nuevo gate backend/OpenAPI/proveedor/privacidad; excluida de UI2. |

## 4. Paquetes de documentación

1. [Discovery and Scope Evidence](UI-2-Discovery-and-Scope-Evidence.md): inventario/evidencia de baseline y límites.
2. [Map, Search & POI Experience Contract Proposal](UI-2-Map-Search-and-POI-Experience-Contract-Proposal.md): contrato, exclusiones, arquitectura mínima y AC.
3. [Compatibility and Dependency Matrix](UI-2-Compatibility-and-Dependency-Matrix.md): matriz entre fases y contratos.
4. [POI Media and Test Fixture Policy](UI-2-POI-Media-and-Test-Fixture-Policy-Proposal.md): assets, derechos, entorno y snapshot.
5. Este registro: autoridad, decisiones y secuencia propuesta.

## 5. Plan propuesto UI-1 a UI-5

El plan es secuencial y cada checkpoint conserva su propio gate. UI-1 se declara cerrada con validaciones física/lector pendientes; una deuda de validación no autoriza cambios retroactivos. UI-2 es contrato `APPROVED_FROZEN`, pero su implementación requiere autorización independiente. UI-3/4/5 no se autorizan por el orden del plan.

| Fase | Propósito/secuencia | Pruebas/evidencia sugerida | Exclusiones/gate |
|---|---|---|---|
| UI-1 — Design System & Exploration Shell | Cerrada: tokens, shell y composición inicial; estado documental remoto revisado. | Evidencia PR #83/#84; formatos/analyze/183 tests/APK/iconos documentados; dispositivo y TalkBack pendientes. | No reabrir sin defecto material y autorización. |
| UI-2 — Map, Search & POI Experience | Contrato congelado; implementar solo después de autorización independiente: filtro local aprobado, zona thumbnail/placeholder y presentación de lista/tarjetas/preview/estados. | Suite automatizada completa; format/analyze/test; capturas renderer identificadas; APK, Android físico, TalkBack y tiles reportados separadamente. | Sin geocoding, API, media publicada, Driving/GPS/CEFI funcional, permisos o dependencia ADMIN. |
| UI-3 — CEFI visual | Tras contrato/freeze propios: control compacto de avisos consentidos en exploración, esfera/ondas y etiqueta correcta «Avisos de CEFI». | Semantics, consentimiento, cancelación TTS, lista/shell regression, modo Driving sin control; verificar no escucha falsa. | No «Habla con CEFI» operativo, STT/chat/micrófono ni cambios al motor de alertas. |
| UI-4 — Driving visual | Solo si se abre paquete funcional independiente aprobado para cualquier cambio; mantener UI protegida y reducida. | P9 interaction matrix, guards/callbacks, dispositivos estacionarios y no-interferencia, evidencia física si autorizada. | No incorporar cambios propuestos de GPS/Driving desde Discovery previos; no turn-by-turn/voz nueva/seguimiento. |
| UI-5 — Final visual hardening | Contrato de consolidación visual tras UI-1–UI-4 aprobadas, foco accesible y regresiones de toda experiencia. | Matriz completa de pantallas/viewports, accesibilidad física, PR/post-merge audit y cierre. | No se inicia automáticamente; sin producir declaración de producción. |

## 6. Matriz de trazabilidad contrato–widget–prueba

| Contrato/criterio | Widget/modelo principal (actual) | Pruebas relevantes existentes a preservar | Nueva verificación futura propuesta |
|---|---|---|---|
| UI-1 / UI2-AC-01 | `BaseMapPage`, `GeoGuideTheme`, `FlutterMap` | `exploration_shell_test.dart` | Área mapa/oclusiones, ruta visible, estados y captura igual viewport. |
| UI2-AC-02 | marker/list `BaseMapPage`, `PoiPreviewSheet` | `poi_list_close_test.dart`, `poi_preview_sheet_test.dart` | IDs sincronizados y restauración desde preview. |
| UI2-AC-03 | `DiscoveryFilterSheet`, `RouteDiscoveryController` | `discovery_filter_sheet_test.dart`, `route_discovery_controller_test.dart` | Cancel no aplica; request codes válidos/estados. |
| UI2-AC-04/05 | `DiscoveryPoi`, mapper, preview/detail/presentation | `route_discovery_response_mapper_test.dart`, preview/detail tests | Campos nulos, textos exactos, ocultar score/códigos/routeProgress. |
| UI2-AC-06/07 | `SelectedPoiDraft`, `RouteSnapshot`, BaseMapPage | `i01_selection_test.dart`, `i01_widget_test.dart`, `i01_worker_test.dart` | Abrir/navegar no cambia chosen IDs; invalidación/freeze. |
| UI2-AC-08 | Derivación local sobre `snapshot.pois` (capacidad nueva aprobada) | `offline_cache_test.dart` | Test puro con normalización/diacríticos, spy de cero llamadas remotas, limpieza al sustituir/vencer snapshot o salir, persistencia solo al volver de Preview/Detail en sesión. |
| UI2-AC-09 | `OfflineDiscovery`, snapshot store/sheets | `offline_ui_test.dart`, `offline_cache_test.dart` | Expiración/error/cached/failure no resucita snapshot vencido. |
| UI2-AC-10 | Placeholder/tarjeta (sin asset model actual) | `poi_preview_sheet_test.dart`, `poi_detail_sheet_test.dart` | Semantics, ausencia de consulta externa y no asset TEST_ONLY en release. |
| UI2-AC-11 | Driving branch, B1 guards, voice coordinator | `b1_widget_test.dart`, `r01_investigation_test.dart`, `cefi_delivery_test.dart` | Cero affordances/llamadas adicionales, callback after exit no se difiere. |
| UI2-AC-12/13 | Theme, `BaseMapPage`, list/sheets | `exploration_shell_test.dart`, temas y tests existentes de sheets | 4 tamaños×2 escalas, semantics/contraste/targets, contenido largo; TalkBack físico separado. |
| UI2-AC-14 | Archivos autorizados del futuro PR | mobile suite completo / git | comandos reales, diff paths, manifest/deps, `git diff --check`, post-merge según autorización. |

Los nombres son rutas/targets orientativos basados en el árbol actual. No significa que casos nuevos ya existan ni que los tests se ejecutaron para esta preparación.

## 7. Bloqueos para ejecución

Freeze contractual registrado según aprobación humana. Permanecen fuera del alcance y exigirían autorización/contrato independiente: localidad/API nueva, media publicada, permisos/dependencias, cambio Driving/GPS/CEFI o dependencia ADMIN. La implementación UI-2 sigue sin autorización.

```ini
UI_1_MASTER_CLOSURE = CLOSED_WITH_VALIDATION_PENDING
UI_2_DISCOVERY = COMPLETED
UI_2_DECISIONS_D01_D06 = APPROVED
UI_2_ACCEPTANCE_CRITERIA_AC01_AC14 = APPROVED
UI_2_CONTRACT = APPROVED_FROZEN
UI_2_CONTRACT_FREEZE = RECORDED
UI_2_IMPLEMENTATION = NOT_AUTHORIZED
UI_2_AUTONOMOUS_IMPLEMENTATION = NOT_AUTHORIZED
ADMIN_PORTAL_IMPLEMENTATION = NOT_AUTHORIZED
ADMIN_API_IMPLEMENTATION = NOT_AUTHORIZED
DRIVING_FUNCTIONAL_PACKAGE = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
VERDICT = UI_2_CONTRACT_FREEZE_DOCUMENTED
```

## 8. Adenda aprobada — UI2-MAP-SEARCH-UX-001 (2026-11-12)

El propietario aprobó una excepción de alcance limitada para centrar una sola vez el mapa de Exploración al abrirlo y mostrar sugerencias incrementales de destinos. Esta adenda registra la decisión posterior; no reescribe el freeze ni altera retrospectivamente sus antecedentes.

### MAP-001 — centrado inicial de ubicación puntual

- Tras confirmar el estado de ownership de la sesión, Flutter puede hacer una única consulta puntual con `requestPermission = false`, exclusivamente mediante permisos ya concedidos y mecanismos existentes.
- Solo una posición válida, con coordenadas finitas/rango válido, marca temporal dentro de dos minutos y precisión conocida de hasta 100 m, se muestra como ubicación actual y puede centrar la cámara una vez a zoom local.
- Si la persona mueve el mapa o elige un punto/destino antes de la respuesta, se conserva su encuadre. Una respuesta tardía no recentra. No se repite al reanudar la app, no se activa un stream, tracking, background o Driving y el fallo conserva el mapa inicial y sus controles.
- Esta autorización sustituye únicamente el diferimiento del centrado inicial de Exploración asociado a MAP-002. En la matriz P9, el control «Usar ubicación actual / recenter por GPS» permanece `DEFERRED_UNTIL_EXIT` dentro de Driving; esa restricción no se cambia. P9 §7 y las reglas de ownership, consentimiento, lifecycle, permisos y no persistencia permanecen vigentes.

### SEARCH-001 — sugerencias incrementales de destinos

- Para la superficie de destino ya aprobada por UI2-SEARCH-001, la consulta al catálogo/API de primera parte existente se dispara tras aproximadamente 300 ms de pausa de escritura. Se conservan deduplicación, invalidación de respuesta obsoleta, estados de carga/vacío/error/sin conexión y reintento.
- Esta adenda sustituye solo la frase de consulta exclusivamente explícita de UI2-SEARCH-001 §§2 y 6, y la exclusión de autocomplete remoto de U2-D04, para estas sugerencias turísticas basadas en el catálogo y endpoint ya aprobados. El envío explícito mediante tecla/botón puede seguir disponible.
- No se añade proveedor, endpoint, API, esquema, geocodificación general ni direcciones postales. Resultados limitados a localidades y destinos/POIs turísticos existentes, con coordenadas verificadas y elección explícita. Seleccionar solo establece el destino; «Ver ruta» continúa siendo la única confirmación de cálculo.

### Alcance que permanece intacto

No cambia el filtro local U2-D01, el snapshot, los contratos congelados, permisos Android, tracking continuo, ubicación background, Driving, CEFI, P12 o la declaración de Production Readiness. El centrado MAP-001 y las sugerencias SEARCH-001 solo pueden considerarse completados contra evidencia de implementación y pruebas separada.

```ini
UI2_MAP_SEARCH_UX_001_OWNER_DECISION = APPROVED
UI2_MAP_001_STARTUP_LOCATION = ONE_SHOT_PREVIOUS_PERMISSION_ONLY
UI2_SEARCH_001_INCREMENTAL_SUGGESTIONS = APPROVED_EXISTING_CATALOG_AND_ENDPOINT
UI2_SEARCH_001_SELECTION_CALCULATES_ROUTE = NO
P9_DRIVING_GPS_RECENTER = DEFERRED_UNTIL_EXIT
UI2_MAP_SEARCH_UX_001_PHYSICAL = PENDING
UI2_MAP_SEARCH_UX_001_MERGE = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

## 9. Adenda aprobada — UI2-EXPLORATION-UX-002 (2026-11-12)

El propietario autorizó el refinamiento UX-01–UX-05 de la exploración Flutter. Esta adenda registra una excepción de implementación limitada; no modifica retrospectivamente el contrato UI-2 congelado ni sus antecedentes.

- **UX-01 — Buscador:** superficie opaca, contraste y estilo del Design System; conserva accesibilidad y escalado.
- **UX-02 — Resultados:** la fila completa es seleccionable; se omite el botón redundante y la provenance técnica en la lista. Se muestra solo el contexto geográfico confiable presente en el DTO, sin inventar localidades; la información disponible permanece en el detalle.
- **UX-03 — Acción contextual:** «Ver ruta» solo aparece cuando hay destino y origen utilizable; representa carga de PlanRoute/Route Discovery, desaparece para la ruta vigente y se recupera ante cambios o error. No se calcula al seleccionar una sugerencia.
- **UX-04 — Ancho:** el buscador usa la región completa cuando la acción de ruta no está pendiente y se adapta al ancho disponible cuando sí lo está.
- **UX-05 — Calidad puntual:** la política del cliente clasifica como precisa una posición con precisión horizontal ≤50 m y edad ≤10 s; como aproximada, ≤100 m y ≤30 s; el resto no se presenta como ubicación actual utilizable. Son umbrales de aceptación del software, no garantía de exactitud física ni calibración del dispositivo. La precisión aproximada utilizable se expresa mediante el halo proporcional y semantics accesibles del marcador, sin rótulo persistente; una posición no confiable conserva un aviso contextual basado en el proveedor.

La ubicación sigue siendo puntual y usa solo permiso previamente concedido (`requestPermission = false`); no agrega permiso, stream, seguimiento continuo, background, centrado repetido ni cambio de Driving. El timeout puntual de ocho segundos evita una espera indefinida. P9 y el aplazamiento GPS de Driving permanecen intactos. La validación de dispositivo físico queda pendiente.

```ini
UI2_EXPLORATION_UX_002_OWNER_DECISION = APPROVED
UI2_EXPLORATION_UX_002_SCOPE = UX_01_UX_05
UI2_EXPLORATION_UX_002_PHYSICAL = PENDING
UI2_EXPLORATION_UX_002_MERGE = NOT_AUTHORIZED
UI2_MAP_SEARCH_UX_001_PHYSICAL = PARTIAL
UI2_ROUTE_UX_001_PHYSICAL = PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
