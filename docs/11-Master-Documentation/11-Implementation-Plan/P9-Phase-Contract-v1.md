# GeoGuide AI — P9 Phase Contract v1 — Offline + Driving

**Content status:** `READY_FOR_FINAL_HUMAN_REVIEW`
**Phase governance:** `AWAITING_FINAL_CONTRACT_APPROVAL`
**Contract approval:** `NOT_YET_GRANTED`
**Implementation:** `NOT_AUTHORIZED` — P9.1 `NOT_STARTED`
**Execution now:** `PAUSED_AT_HUMAN_GATE` once this documentary preparation is delivered.

Versión v1 preparada con decisiones humanas D01–D05. **No es un contrato APPROVED_FROZEN.** La aprobación de dirección y parámetros no equivale a la aprobación final del conjunto ni al permiso para instalar paquetes, crear schema o implementar. Ningún P9-AC tiene resultado PASS en esta ejecución.

## 1. Purpose y baseline

P9 es un incremento acotado de **durable bounded data cache + reduced-interaction Driving view**. Conserva una copia coherente de datos ya obtenidos y reduce la interacción manual; no representa full offline navigation ni full Driving experience.

```ini
P9_CANDIDATE = B
P9_START_BASELINE = 7dfb0293507dcfa1eef90533c4dc9dbdd4d2a229
P8_FINAL_BASELINE = 7dfb0293507dcfa1eef90533c4dc9dbdd4d2a229
P9_DISCOVERY_BASELINE = 11d5f0bf3e92762bf9871a1df83415e9e54f4f3a
P9_CONTRACT_ENTRY_BASELINE = 11d5f0bf3e92762bf9871a1df83415e9e54f4f3a
P0–P8 = COMPLETED
P8_STATUS = CLOSED
P9_STATUS = NOT_STARTED_IMPLEMENTATION
```

Entrada verificada mediante fetch, origin/main y worktree limpio. P8.7 permanece autoritativa: P8.6/P8.7 COMPLETED; physical Android y precise one-shot PASS; Testcontainers 6/6, backend 59/59, Flutter 27 tests, analyze y APK HTTPS PASS **heredados**, no repetidos aquí. P7/P8 preservan Git blobs `17d3c3366a051263af49a246fd67823133a584bd` y `9e18c28043d4f66e70a66e607a123924d69b8093`. P8 no se reabre.

## 2. Human decisions D01–D06

| ID | Decisión humana de entrada | Resolución documental en v1 |
|---|---|---|
| D01 | APPROVED — candidato B y snapshot Route + Discovery | RESOLVED: scope de sección 3, asociación indivisible ruta/criterios/POIs/metadatos |
| D02 | APPROVED_WITH_DESIGN_GATE — SQLite + capa tipada compatible ADR-018 | RESOLVED_DOCUMENTALLY: [diseño local v1](P9-Local-Cache-Design-v1.md), schema conceptual, versiones propuestas, alternativas, atomicidad y corrupción. Paquetes/schema siguen sujetos a aprobación final, no instalados |
| D03 | APPROVED — una copia, 24 h, 5 MiB, privado, sin backup/transferencia | RESOLVED: parámetros exactos y reglas de retención/borrado en sección 6 y anexo |
| D04 | APPROVED_PARTIAL_DRIVING | RESOLVED: estado manual estático y Driving Interaction Matrix completa, sección 7 |
| D05 | APPROVED — AUTONOMOUS_WITHIN_FROZEN_CONTRACT | RESOLVED: efectiva para implementación solo después de contrato final aprobado/frozen y autorización explícita; sección 12 |
| D06 | DEFERRED — sin autorización física | DEFERRED: bloquea P9.3 y cualquier interacción física previa; no adb, APK install, flutter run físico o cambios de teléfono |

No queda parámetro implementable expresado como OPEN/TBD/«a criterio del implementador». Quedan gates de **aprobación**, no valores técnicos sin especificar. Las concreciones de diseño son propuestas completas para el gate final, no hechos históricos ni autorización automática.

## 3. In Scope

| ID | Alcance contractual candidato |
|---|---|
| IS01 | Último snapshot coherente de una respuesta Discovery: ruta/geometría necesaria, criterios efectivos, POIs/detalles disponibles, provenance y metadata de modelo aprobado; máximo una copia durable |
| IS02 | Estados online/cache/no disponible, límites de vigencia visibles, recuperación controlada y reintento manual ante fallos de red; copia elegible recuperable al reiniciar |
| IS03 | Continuidad Map/List/Preview/Detail durante exploración; association de ruta/filtros/resultado intacta; retorno desde Driving conserva contexto de sesión |
| IS04 | Driving parcial de activación manual sobre contexto disponible, estático, texto breve, mínimos controles y salida explícita; defensa de todos los caminos de acceso según matriz |
| IS05 | Privacidad, seguridad, accesibilidad, pruebas/regresión e interacción Android física solo bajo D06 |

Guardar una consulta no crea ruta guardada, historial, favorito o identidad. Cachear un resultado vacío válido es válido. Nunca combinar geometría de consulta A con criterios o POIs de consulta B.

## 4. Out of Scope

```ini
SEARCH_GEOCODING_P9 = OUT_OF_SCOPE
CEFI_IMPLEMENTATION_P9 = OUT_OF_SCOPE
OFFLINE_MAPS_P9 = OUT_OF_SCOPE
OFFLINE_TILES_P9 = OUT_OF_SCOPE
ROUTING_OFFLINE_P9 = OUT_OF_SCOPE
CONTINUOUS_LOCATION_P9 = OUT_OF_SCOPE
BACKGROUND_LOCATION_P9 = OUT_OF_SCOPE
PROXIMITY_ALERTS_P9 = OUT_OF_SCOPE
USER_HISTORY_P9 = OUT_OF_SCOPE
FAVORITES_P9 = OUT_OF_SCOPE
AUTH_IDENTITY_P9 = OUT_OF_SCOPE
HTTP_API_CHANGE = NO
OPENAPI_CHANGE = NO
SERVER_DB_CHANGE = NO
FLYWAY_CHANGE = NO
ROUTING_PROVIDER_CHANGE = NO
INFRA_CHANGE = NO
DNS_TLS_CHANGE = NO
CI_CD_CHANGE = NO
```

También excluidos: reverse geocoding, nuevo destination-first, Recreation/Travel Service, visited/pending/want-to-visit, saved/frequent routes, preferencias persistentes globales, sincronización de usuario/contenido, telemetría nueva, PBF/grafo, tráfico, rerouting, turn-by-turn nuevo, velocidad/movimiento/progreso del conductor, próximo POI respecto del vehículo, ETA live/distancia restante, avisos de llegada, geofencing, CEFI/chat/prompts/tool calling, LLM/STT/TTS/microphone/wake word/audio UI, CarPlay/Android Auto y cambio a Riverpod.

No seleccionar proveedores ni crear abstracciones para estas capacidades. CEFI sigue siendo dirección futura; `CEFI_READY_ARCHITECTURE = REQUIRED_DIRECTION` y `CEFI_IMPLEMENTATION = NOT_STARTED` se preservan sin incorporarlo a P9.

## 5. Architecture, API y product semantics

Flutter/Dart con capas presentation → application → domain y adapters de infraestructura; preservar gestión de estado nativa existente. Casos de uso compartidos independientes del canal. [ADR-018](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-018-Local-Storage.md) gobierna SQLite tipado; el [anexo local](P9-Local-Cache-Design-v1.md) es parte del contenido sometido a aprobación, incluidos pins propuestos. No instalar, generar código ni crear DB en P9.0. No alterar LICENSE.

Reutilizar POST `/api/v1/routes/plan` y POST `/api/v1/routes/discover`. Para snapshot, la ruta y los resultados proceden del mismo envelope Discovery; la futura adaptación interna de mapper/repository no cambia HTTP/OpenAPI. `places/*` son placeholders no operativos. Backend conserva ranking/GIS; no recomputar ni reordenar ranking en cliente. GraphHopper/RoutingProvider y PostgreSQL/PostGIS quedan intactos. No activar Redis/MinIO para caché cliente.

GeoGuide AI es el producto; CEFI su futuro copiloto. Conservar DISCOVERY, RECREATION y TRAVEL_SERVICE separados, taxonomía P3 y categorías Discovery existentes; no mezclar FUEL/HEALTH/FOOD/LODGING. «Explorar nunca debe destruir el contexto del viaje». Distancia al trazado no es desvío; routeProgress no es progreso del conductor; generatedAt/cached_at no acreditan frescura factual. No renderizar UUID, score, códigos crudos o datos inventados.

Identidad: reutilizar UUID POI, no crear user/device/session id persistente. El slot constante y hash técnico de consulta no se presentan como identidad de persona o ruta guardada. Ubicación: precise current location one-shot heredada, sin cambio de permisos; current-location marker no se persiste ni aparece como posición viva en Driving. La activación Driving no solicita GPS.

## 6. Cache / offline / privacy policy

```ini
CACHE_MODEL = ONE_REPLACEABLE_SNAPSHOT
CACHE_SNAPSHOT_COUNT = 1
CACHE_TTL = 24_HOURS
CACHE_TTL_MS = 86400000
CACHE_MAX_SIZE = 5_MIB
CACHE_MAX_PAYLOAD_BYTES = 5242880
CACHE_STORAGE = APP_PRIVATE_STORAGE
CACHE_AUTOMATIC_BACKUP = DISABLED
CACHE_TRANSFER = DISABLED
CACHE_EXPIRED_BEHAVIOR = NOT_ELIGIBLE_FOR_OFFLINE_USE
CACHE_DELETE = USER_ACCESSIBLE
LOCAL_SCHEMA_VERSION = 1
LOCAL_PAYLOAD_FORMAT_VERSION = 1
```

El [anexo](P9-Local-Cache-Design-v1.md) fija schema conceptual de una fila, whitelist de datos, canonicalización, tiempo/size exactos, consentimiento por sesión, versionado sin migración de datos desconocidos, atomic replacement, corrupción, private no-backup path y borrado interrumpible. No duplica seis tablas del modelo conceptual histórico.

**Tamaño:** 5 MiB de payload total JSON UTF-8 sin compresión, incluyendo metadata y provenance; no de caracteres ni solo POIs. SQLite tiene overhead distinto: archivo DB máximo 6 MiB, más journal rollback transitorio, nunca segunda copia consultable. Esta distinción está sometida a revisión final y es explícita; no se promete footprint total de 5 MiB. Copia nueva fuera del límite no reemplaza la previa ni se trunca.

**TTL:** desde recepción/validación original; 0 <= edad <24 h. A las 24 h exactas deja de ser elegible; lectura/reinicio/guardado tardío no renuevan tiempo. Retroceso detectado del reloj invalida; comprobación al leer/reanudar y timer mientras visible. La misma regla aplica a copias en memoria servidas como offline: no eludir expiración renombrándolas «online». Sin actividad background; purga física al siguiente acceso si proceso estaba detenido. No prometer reloj confiable contra manipulación del SO.

**Retención:** ruta/origen/destino se tratan como intención de viaje potencialmente sensible. No tokens, secretos, credenciales, current-location marker, historial GPS, movimiento, device ids, copias históricas ni exportación. Guardar solo con consentimiento contextual de captura, revocable mediante borrado; no una preferencia global. `getNoBackupFilesDir()` privado contiene DB/journal/control de borrado; no fallback a almacenamiento exportable.

**Atomicidad/borrado:** nueva copia completamente validada reemplaza slot en una única transacción; fallo conserva anterior elegible. Expirada/corrupta/incompatible/sobredimensionada no se usa. Delete invalida lecturas/escrituras pendientes, registra intención local durable, borra datos/archivos y no declara éxito antes de terminar; startup completa borrado pendiente antes de abrir DB. Sin garantía forense de flash ni cifrado nuevo; la garantía comprobable es ausencia lógica, sin backup/transferencia o recaptura tardía. No introducir identidad para gestionar consentimiento/borrado.

| Situación | Resultado contractual |
|---|---|
| Online válido + captura consentida | Presentar resultado, guardar atomically; fallo de guardado no pierde resultado online ni copia previa |
| Error red/timeout/indisponibilidad + copia elegible de misma consulta | Mostrar copia rotulada y error visible; no decir que se refrescó |
| Sin copia o no elegible | No disponible, sin inventar ruta/POIs/mapa; reintento manual fuera de Driving |
| Consulta nueva/filtro nuevo falla | Mantener último contexto válido con sus criterios; no reasignarlo a la petición fallida, ni filtrar localmente un top-N como resultado backend completo |
| Error TLS/autorización/contrato o payload inválido | Error específico visible; sin bypass, retry loop o sustitución silenciosa por éxito cacheado |
| Resultado vacío válido | Vacío de esa consulta, distinto de error; puede reemplazar copia |
| Reapertura | Validar copia sin red automática; presentar resumen y criterios, sin modal/POI seleccionado ni captura nueva sin consentimiento |
| Vuelve conectividad | No polling ni sincronización; reintento manual explícito y acotado; publicar solo respuesta de consulta vigente |
| Tiles no disponibles | Datos/lista disponibles en exploración según copia; sin promesa de cartografía descargada |

Cada reintento de Discovery dispara a lo sumo una solicitud vigente; impedir duplicados mientras está en curso. La planificación normal conserva su secuencia plan/discover; no multiplicarla por watchers de conectividad. Error técnico no activa nuevas capacidades.

## 7. Driving Interaction Matrix

Estados: `EXPLORATION` y `DRIVING_REDUCED`, ambos temporales. Entrada manual solo desde raíz de exploración con ruta + resultado Discovery coherentes (vacío válido permitido), online o copia elegible, sin modal, borrado/guardado/red/ubicación en curso. Si no cumple, control de entrada deshabilitado con razón accesible; sin petición implícita para habilitarlo. Capturar contexto de retorno en memoria. Reinicio de proceso comienza en EXPLORATION, sin restaurar Driving ni abrir Detail; volver de background dentro del mismo proceso conserva modo y revalida TTL.

Driving muestra únicamente resumen estático: título del modo, origen/destino como etiquetas breves sin coordenadas crudas, distancia/duración total planificada identificadas como estáticas, estado online/copia/no disponible y botón **Salir de Driving**. Mapa existente puede ser fondo estático con atribución, sin gestos/selección ni seguimiento; equivalente textual siempre disponible. Sin lista de POIs, descripciones históricas, ETA live o lectura requerida para continuar conduciendo. Texto de orientación: «Explora solo cuando estés detenido»; no se verifica movimiento ni se certifica seguridad vial.

`ALLOWED`: acción definida dentro del modo. `BLOCKED`: el intento no cambia modo/contexto ni abre superficie o invoca servicio. `DEFERRED_UNTIL_EXIT`: no se ejecuta ni se encola en Driving; se ofrece nuevamente, por acción nueva, tras salida explícita. No diferir en background para ejecutarlo automáticamente al salir.

| Acción / entrada | En DRIVING_REDUCED | Regla observable |
|---|---|---|
| Leer resumen y estado online/cache/no disponible | ALLOWED | Texto breve + semantics; sin datos vivos inventados |
| Fondo de mapa y atribución existentes | ALLOWED | Solo visual estático; no precarga/cache de tiles, sin nuevo proveedor |
| Cambiar Map/List | DEFERRED_UNTIL_EXIT | Recordar vista anterior en memoria; no lista navegable en modo |
| Seleccionar POI por marcador/lista | DEFERRED_UNTIL_EXIT | Sin seleccionar/abrir contenido ni alterar retorno |
| Abrir Preview, incluyendo callback interno | DEFERRED_UNTIL_EXIT | Bloqueo en guard de intención/entrada, no solo botón oculto |
| Preview → View Detail / abrir Detail directamente | DEFERRED_UNTIL_EXIT | No modal, histórico ni selección de texto |
| Cerrar Preview/Detail/filter por pop callback rezagado | BLOCKED | No debe existir modal al entrar; callback obsoleto no altera navegación |
| Cambiar origen por tap o cualquier setter de UI | DEFERRED_UNTIL_EXIT | No muta controllers ni cache/contexto |
| Cambiar destino | DEFERRED_UNTIL_EXIT | Igual protección por todas las entradas |
| Abrir/aplicar/restablecer/cancelar filtros | DEFERRED_UNTIL_EXIT | No reconsulta ni cambio de criterios mientras activo |
| Calcular ruta / invocar plan o discover | DEFERRED_UNTIL_EXIT | No solicitudes iniciadas por Driving |
| Reintentar red | DEFERRED_UNTIL_EXIT | Error breve; retry solo después de salir y volver a pulsar |
| Usar ubicación actual / recenter por GPS | DEFERRED_UNTIL_EXIT | No solicitud de permiso o posición; no se muestra marker como vivo |
| Pan/zoom/doble tap/long press del mapa | BLOCKED | Ningún callback de selección o movimiento de cámara |
| Textos extensos, links/fuente seleccionable/copy menu | DEFERRED_UNTIL_EXIT | No Detail ni controles de texto; sin rutas indirectas desde attribution |
| Guardar/capturar/borrar copia o abrir explicación de consentimiento | DEFERRED_UNTIL_EXIT | No diálogos complejos ni escritura por interacción en Driving; TTL/purga técnica siguen vigentes |
| Back del sistema, gesto Back o Navigator.pop alternativo | BLOCKED | Permanece en modo; no revela vista anterior o ficha oculta. Única salida interna es botón explícito |
| Pulsar Salir de Driving | ALLOWED | Una acción explícita pasa a EXPLORATION restaurando contexto válido; sin diálogo que infiera inmovilidad |
| Entrar de nuevo estando activo | BLOCKED | Transición idempotente; no pila de vistas duplicadas |
| Perder red / vencer copia mientras visible | ALLOWED (evento) | Estado breve; al vencer, retirar datos cacheados no elegibles, sin abrir modal/red/GPS ni salir automáticamente |
| Home/minimizar/cerrar app desde SO | ALLOWED | No interceptar control del SO ni añadir servicios; al reanudar revalidar TTL |
| Deep path interno, accessibility action o callback invocado directamente | BLOCKED para acción restringida | Guard central de modo + pruebas por todas las entradas; no agregar deep links nuevos |

Inventario de entradas existentes: `_selectRoutePoint`, `_calculateRoute`, `_openFilters`, `_retryDiscovery`, `_requestLocation`, `_showPoiPreview`, `_showPoiDetail`, toggle Map/List y callbacks de marker/ListTile en `BaseMapPage`; `onViewDetail`, `Navigator.pop`, Apply/Reset/Cancel de sheets. No se encontró router de deep links registrado en el código actual; eso no exime validar invocaciones directas. Guards en dispatch/application coordinador y en límites de navegación impiden bypass por UI/semantics; ninguna lógica GIS/ranking se traslada a widgets.

No se entra al modo con solicitudes pendientes; una respuesta rezagada o callback ya invalidado tampoco abre contenido. El flag de modo no es cuenta/sesión persistente. Expiración/borrado técnico puede invalidar datos, pero no repuebla contexto desde otra consulta. Al salir después de expiración se muestra no disponible y opción de recuperación explícita, sin resucitar copia vencida.

## 8. Security, accessibility y physical policy

Mantener runtime HTTPS sin HTTP fallback/TLS bypass. Errores seguros y validación del contenido local; almacenamiento privado no hace confiable el payload. No almacenar/loggear secretos, GPS real, device serial completo o PII; evidencia con fixtures sintéticos/dataset público autorizado. Sin telemetría nueva ni porcentaje global inventado. Revisar licencias de dependencias sin modificar LICENSE del proyecto.

Conservar TalkBack, foco lógico, labels, targets, contraste, reduced motion cuando aplique y alternativa no cartográfica. Datos online/cache/no disponible se identifican sin depender del color. Flujos nuevos/modificados deben funcionar con TextScaler 2.0, sin overflow ni recorte de acciones; no bajar tamaño para ocultar errores. Para verificabilidad, targets interactivos >=48 logical px, contraste >=4.5:1 texto normal y >=3:1 texto grande/elementos esenciales, y orden de foco que llegue a Salir sin recorrer controles ocultos. Estos umbrales concretan el objetivo accesible heredado, no certifican toda la app. Referencias de contraste: [WCAG texto](https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html) y [WCAG elementos no textuales](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html).

`D06 = DEFERRED`, `PHYSICAL_DEVICE_AUTHORIZATION = NOT_GRANTED`. En P9.0 no adb, instalación APK, flutter run físico, cambios de conectividad/permisos ni interacción. Plan futuro estacionario/controlado: online → pérdida de red → copia/no copia → reinicio → vuelta de red/retry; TTL/borrado/invalidación; entrada/salida Driving; intentos por caminos bloqueados; Map/List/Preview/Detail; TalkBack/texto grande; permisos denegados sin nuevos prompts. Registrar APK/SHA y casos PASS/FAIL sin datos personales. No conducir y manipular simultáneamente; no adelantar piloto vial P12.

## 9. Checkpoints

| ID / GOAL | IN_SCOPE | OUT_OF_SCOPE | VALIDATION | EXIT_CRITERIA |
|---|---|---|---|---|
| P9.0 — Contract / governance | Baseline, D01–D05, diseño local y matriz, AC, PR documental | Código, paquetes/schema, dispositivo | DOC/GIT/PR: diff, links, hashes, scope y secret scan | Contenido listo para review; para COMPLETED requiere aprobación final del contrato. Estado actual AWAITING_FINAL_CONTRACT_APPROVAL |
| P9.1 — Offline data/cache | IS01–IS03, adapter y schema local aprobados, mapping, consentimiento, límites, estados/recovery | Driving, DB servidor/API/infra/proveedores o historial | Unit/mapper/store real de test, boundary/crash/restart/corrupción, format/analyze/tests/build HTTPS | AC01–05,08–11 aplicables aprobados con evidencia; PR/revisión/integración y validación posterior según autorización |
| P9.2 — Reduced-interaction Driving | IS04 y matriz completa, guards, retorno y accesibilidad | Voz, GPS/tracking/proximidad, seguridad vial certificada | Unit/widget/state tests por caminos directos/alternativos y AC06–11 | Matriz y regresión pasan; review/integración y validación posterior según autorización |
| P9.3 — Physical Android validation | IS05 y plan aprobado bajo D06; correcciones acotadas por evidencia | Prueba vial o alcance nuevo | DEVICE + TEST, APK/SHA, continuidad, offline/restart, TalkBack | AC12 y criterios físicos aplicables aprobados; suite repetida si hubo correcciones |
| P9.4 — Final audit and closure | Matriz completa, privacidad/scope/docs, integraciones y evidencia | Nueva funcionalidad o inicio P10 | DOC/GIT/PR/TEST + evidencia DEVICE ya autorizada | AC01–12 PASS al SHA final, gates resueltos, 0 conflictos, hashes históricos intactos y cierre humano formal |

Precondiciones: P9.1 exige aprobación final explícita del contrato+anexo y autorización de implementación/autonomía, incluyendo paquete/schema propuestos. P9.2 exige P9.1 completo. P9.3 exige P9.2 completo y D06 concedido por separado. P9.4 exige P9.3 y cierre humano; un PR integrado no cierra una fase.

Registros posteriores usarán goal/scope/non-scope, precondiciones, acciones autorizadas/protegidas, archivos inspeccionados/modificados, comandos, resultado esperado/real, tests, evidencia, SHA/branch/PR, riesgos y salida. Estado P9.1–P9.4 hoy NOT_STARTED, plan PROPOSED; VM no requerida por defecto para este incremento cliente.

## 10. Acceptance Criteria P9-AC-01–P9-AC-12

**Estado de todos: NOT_EXECUTED.** El contenido se evalúa documentalmente ahora; sus comportamientos se prueban solo después de autorización. No reducir cobertura heredada.

| ID | Criterio objetivo | Trazabilidad / validación futura |
|---|---|---|
| P9-AC-01 | Con copia elegible obtenida previamente, sin red y tras reinicio de proceso se pueden leer ruta/POIs/detalles disponibles; sin copia, no disponible sin datos fabricados. Vacío válido se distingue de fallo. | D01/D03, IS01–02; store SQLite real de test + UI/restart |
| P9-AC-02 | Superficies modificadas distinguen online/cache/no disponible y limitación de vigencia; capturedAt/generatedAt no se presentan como verificación editorial. | D01, IS02; assertions de texto/estado/semantics |
| P9-AC-03 | Red/timeout fallido conserva contexto válido con sus criterios; retry exitoso publica nueva respuesta coherente; ninguna duplicación ilimitada de solicitudes, watcher o retry loop. | IS02–03; success/failure/retry/empty, request counters y generación |
| P9-AC-04 | Siempre coinciden ruta, criterios y resultados; consulta/filtro distintos o respuesta tardía no mezclan datos. Ranking y distancia al trazado conservan semántica; no score/progreso de conductor inventado. | D01, IS03; dos consultas y envelope Discovery único, sin GIS/ranking local |
| P9-AC-05 | Máximo una fila/snapshot; TTL exacto 86,400,000 ms sin renovar por lectura/reinicio; 5,242,880 bytes máximos de payload íntegro; privado no-backup/sin transferencia. Consentimiento, expiración, corrupción, versión, borrado e interrupción cumplen anexo. Escritura fallida conserva última copia válida. | D02/D03, IS01/05; boundaries TTL ±1 ms y size ±1 byte, UTF-8 multibyte, DB cap 6 MiB/disco lleno, transacción interrumpida, digest/formato inválido, delete_pending/restart, inspección path/backup. Ninguna copia no elegible se muestra offline |
| P9-AC-06 | Cada celda de Driving Matrix se cumple por controles visibles/ocultos, Back, mapa, sheets, callbacks directos y semantics; no texto extenso ni solicitudes de acciones diferidas. Salida solo explícita recupera contexto válido. | D04, IS04; matriz enumerada de transiciones y test de cada entrada |
| P9-AC-07 | Driving no solicita ubicación/permiso ni representa progreso/ETA/próximo POI vivo; no tracking, voice/audio/proximidad o proveedor excluido. Estado estático no se confunde con posición actual. | D04/exclusiones, IS04–05; mocks sin llamadas y diff de manifiesto/dependencias/código |
| P9-AC-08 | Map/List → Preview → Detail → regreso y entrar/salir Driving preservan ruta, filtros, selección y viewport factible durante sesión; invalidación de copia no resucita datos; reabrir proceso usa la política inicial definida. | D01/D04, IS03; secuencias online/cache, error/expiración, comparación de estado |
| P9-AC-09 | Labels/foco/estados anunciados, alternativa no cartográfica, controles alcanzables, TextScaler 2.0 sin overflow/recorte, targets >=48 logical px y contraste 4.5:1 normal / 3:1 grande/esenciales; TalkBack llega a salida sin acciones bloqueadas. | IS05; semantics/layout/contraste y DEVICE cuando D06 lo autorice |
| P9-AC-10 | HTTPS sin fallback/bypass; errores de seguridad no se ocultan como éxito cacheado. Storage/diff/evidencia sin tokens/credenciales/GPS real/serial completo, historial o identificadores nuevos. Backup/transferencia/export no incluyen copia; borrar evita recaptura tardía. | D03, IS05; network mocks, scan, inspección de almacenamiento/config y controles del anexo |
| P9-AC-11 | Suite móvil heredada y nuevos tests pasan, format/analyze correctos, APK HTTPS construye; API/OpenAPI/DB servidor/Flyway/proveedores/infra/CI intactos; hashes P7/P8 iguales. Ningún skip obligatorio se declara PASS. | IS01–05; comandos reales y comparación Git. Backend no se ejecuta si no cambia su scope; cambio necesario activa STOP |
| P9-AC-12 | Matriz Android estacionaria autorizada demuestra offline/restart/retry, cache lifecycle, continuidad y accesibilidad sobre APK/SHA candidato; sin manipulación del conductor en marcha ni datos personales en evidencia. | D06, IS05; autorización física registrada, casos PASS/FAIL y limitaciones |

Cambios desde draft: AC05 ya fija TTL/bytes/backup/expiración y prueba fallos/atomicidad; AC06 se vincula a una matriz concreta; AC07 enumera exclusiones aprobadas; AC08 concreta reinicio/invalidación; AC09 expresa umbrales; AC10 integra borrado/transferencia. Los otros criterios mantienen objetivo y cobertura. AC12 sigue bloqueado por D06, no omitido.

## 11. Human Gates y STOP_AND_REPORT

Gates resueltos **documentalmente**: D01 scope, D02 diseño, D03 lifecycle, D04 matriz, D05 política futura. Gate final de aprobación del contrato/anexo sigue pendiente. D06 se difiere para candidato P9.1/P9.2 verificable. Una aprobación posterior debe identificar la revisión exacta; aprobar solo el scope no equivale a aceptar pins/schema/anexo.

Se mantienen gates para DB/schema servidor, schema/dependencia material fuera del anexo aprobado, API nueva/breaking, identidad, Search/proveedores externos, tiles/mapas offline, RoutingProvider/routing offline, CEFI/LLM/STT/TTS/audio, permisos sensibles/tracking/background, seguridad/privacidad ampliada, infraestructura/DNS/TLS/firewall/CI y expansión de producto. Force/admin/protection bypass no se propone ni se utiliza.

STOP inmediato ante baseline concurrente material, conflicto contractual nuevo, necesidad de modificar P7/P8, capacidad excluida, dependencia material no evaluable/incompatible con propuesta aprobada, parámetro no resoluble dentro del contrato, necesidad de dispositivo sin D06 o aparente necesidad de force/bypass. No resolver esas decisiones por inferencia. Usar:

```text
STOP_AND_REPORT

Reason:
Gate:
Evidence:
Impact:
Decision required:
Repository state:
```

Fallos ordinarios de tests/formato/implementación, una vez autorizado su scope, se corrigen autónomamente; no sirven para relajar criterios o ampliar alcance.

## 12. Execution Policy y Git

`P9_EXECUTION_POLICY = AUTONOMOUS_WITHIN_FROZEN_CONTRACT` recoge D05. **Efectividad funcional diferida:** contrato final aprobado/frozen, revisión exacta identificada y autorización explícita de implementación antes de P9.1. Después, ejecutar checkpoints dentro de límites, detener solo en gates definidos, validar físicamente bajo D06, auditar y solicitar cierre.

Esta ejecución autoriza solo rama/commit/push/PR documental y validación documental post-PR. No merge automático: el permiso previo de merge correspondía a reconciliación PR #44, no se extiende a esta finalización. Usar merge normal únicamente con autorización vigente específica; nunca force/admin/bypass. Preservar checkouts operativos y draft anterior. No actualizar Excel ni porcentaje global.

## 13. Definition of Done

P9.0 puede quedar listo documentalmente con este contenido y evidencias, pero su estado sigue awaiting final approval. Para cerrar funcionalmente P9: contrato/anexo aprobados, P9.1–P9.3 completos, AC01–12 al SHA final PASS, tests/analyze/build pertinentes, backup/retención/borrado y matriz auditados, D06 y validación física registrados, PRs revisados/integrados con post-merge, 0 conflictos vigentes, sin scope no autorizado, hashes P7/P8 intactos y cierre humano formal. No inicio automático P10.

## 14. Fuentes y preservación histórica

- [AGENTS](../../../AGENTS.md), [PROJECT_CONTEXT](../../../PROJECT_CONTEXT.md), [AI_DEVELOPMENT_GUIDE](../../../AI_DEVELOPMENT_GUIDE.md), [ROADMAP](../../../ROADMAP.md) y [Documentation Index](../../../DOCUMENTATION_INDEX.md).
- [Entrega 04.6](../../04-SolutionArchitecture/06-Master-Architecture/01-Master/GeoGuideAI-Master-Architecture.md), ADR-018, [ADR-019](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-019-Map-Library.md), [ADR-027](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-027-Channel-Independent-Interaction-and-Voice.md).
- [P8 contract](P8-Phase-Contract-v1.md), [P8.7 closure](P8.7-Final-Audit-and-Closure.md), [Pilot Plan](Pilot-Implementation-Plan.md), [Product Master](../02-Product/Product-Master.md).
- [Offline Strategy](../../07-Mobile-Engineering/08-Offline-Cache/Offline-Strategy.md), [Driving mobile](../../07-Mobile-Engineering/10-Driving-Mode/Driving-Mode.md), [Driving UX](../../05-UX-UI/06-Screen-Specifications/Driving-Mode.md), [accessibility](../../07-Mobile-Engineering/11-Accessibility/Mobile-Accessibility.md), [Release Gates](Release-Gates.md).
- Código auditado: [BaseMapPage](../../../mobile/lib/features/map/presentation/base_map_page.dart), [Discovery mapper](../../../mobile/lib/features/discovery/infrastructure/route_discovery_response_mapper.dart), [backend response](../../../backend/src/main/java/ai/geoguide/discovery/infrastructure/http/RouteDiscoveryResponse.java), [OpenAPI](../../06-Backend-Engineering/12-OpenAPI/backend-openapi-baseline.yaml).

Los tres outputs de reconciliación/discovery/draft v0.1 se preservan fuera del repositorio y se identifican por hashes en [evidencia de finalización](P9.0-Contract-Finalization-Evidence.md). PR #44 integró nueve documentos de estado, no aquellos outputs; esta precisión no cambia baseline ni decisiones humanas. No se reescriben ADRs, contratos o evidencias históricas.

## 15. Estado final documental

```ini
P9_CONTRACT_CONTENT = READY_FOR_FINAL_HUMAN_REVIEW
P9_0_STATUS = AWAITING_FINAL_CONTRACT_APPROVAL
D01 = RESOLVED
D02 = RESOLVED_DOCUMENTALLY
D03 = RESOLVED
D04 = RESOLVED
D05 = RESOLVED
D06 = DEFERRED
P9_1 = NOT_STARTED
P9_IMPLEMENTATION = NOT_AUTHORIZED
PHYSICAL_DEVICE = NOT_USED
AUTONOMOUS_EXECUTION = PAUSED_AT_HUMAN_GATE
```
