# UI-2 — Map, Search & POI Experience
## Propuesta de contrato de fase

**Estado:** `APPROVED_FROZEN` · **Decisiones U2-D01–D06:** `APPROVED_FROZEN` · **Criterios UI2-AC-01–AC-14:** `APPROVED` · **Implementación:** `NOT_AUTHORIZED`
**Baseline de preparación:** `726cb989a902110aeeab314e5747ce684e201748` (`origin/main`).
**Autoridad del freeze:** aprobación humana expresa registrada en el encargo de freeze UI-2. **Freeze contractual:** aprobado y registrado en este worktree; esto no representa integración en `origin/main` ni autorización de ejecución.

El contrato conserva las decisiones aprobadas y no modifica ni reabre P8/P9. Los criterios de aceptación están aprobados como requisitos, no ejecutados como pruebas.

## 1. Propósito

Mejorar la experiencia de exploración turística de Rutea manteniendo el mapa como superficie principal y haciendo los POIs existentes fáciles de recorrer, comparar y comprender. UI-2 consume los datos disponibles del snapshot y conserva sus estados, procedencia y semántica. Incluye filtro local textual del snapshot; excluye búsqueda de destinos y localidades.

## 2. Decisiones aprobadas incorporadas

U2-D01 aprueba filtro textual local; U2-D02, zona reservada de miniatura con placeholder; U2-D03, política de medios de prueba/derechos; U2-D04 excluye búsqueda de localidades; U2-D05 separa evidencia automatizada, renderer, APK, dispositivo, TalkBack y tiles; U2-D06 fija el baseline accesible. Los términos completos figuran en el [registro de decisiones](UI-2-Decision-Register.md#1-decisiones-humanas-aprobadas). Las seis decisiones y los catorce criterios están aprobados y congelados; no se registran aquí como pruebas ejecutadas.

## 3. Alcance congelado

### Incluido

- Evolución visual del shell de exploración UI-1, conservando el mapa, la ruta, controles y handlers existentes.
- Uso de categorías turísticas Discovery existentes y sincronización de sus filtros existentes con la consulta/snapshot.
- Lista accesible sincronizada con marcadores, tarjeta compacta y acceso a Preview/Detail existentes.
- Presentación de nombre, categoría, descripción y procedencia únicamente si llegan en el DTO actual. `distanceToRouteMeters` se expresa como «A X m del trazado»; `routeProgress` y `score` nunca se muestran.
- Zona estable de miniatura en tarjetas y detalle, con placeholder neutral accesible cuando no existe imagen autorizada. No crear datos de POI ficticios ni afirmar que una ilustración sea fotografía.
- Revisión de estados loading/empty/error/offline/vencido ya provistos por UI/P9 y continuidad de contexto.
- Filtro textual local aprobado «Buscar en estos resultados», solo sobre nombre de POIs del snapshot vigente, exclusivamente en memoria, sin backend, cobertura ampliada, mutación del snapshot ni persistencia. No aparece en Driving. El vacío indica «No hay coincidencias en estos resultados».
- Accesibilidad y layout: objetivo WCAG AA donde corresponda, contraste suficiente independiente de tiles, targets ≥48×48 dp, lista equivalente, semantics, estados no solo por color, escalas 1.0/2.0 y viewports 360×640, 360×800, 640×360, 800×360; cubrir nombres largos y campos opcionales.
- Validación automatizada completa en ejecución futura. Widget tests, capturas Flutter renderer, build APK, Android físico, TalkBack y cartografía/tiles se reportan en categorías separadas; validación no ejecutada será `PENDING`/`NOT_EXECUTED`, nunca PASS.

### Exclusiones

Geocodificación, reverse geocoding, destinos/localidades por texto, autocomplete remoto, búsqueda global, nuevo endpoint/OpenAPI, cambios DB/Flyway, ranking o filtros locales que simulen cobertura completa, nuevas categorías, rutas o waypoints, coordenadas nombradas inventadas, fotografías reales en producto (sin gate de derechos/publicación independiente), API/almacenamiento/caché de media, workflow ADMIN, favoritos, reseñas, personalización, tracking/GPS, nueva política de cámara, Driving, CEFI conversacional/STT/micrófono, modificación de TTS/consentimiento, permisos/dependencias nuevas, cambios de infraestructura y declaración de readiness. Fixture `TEST_ONLY` solo en pruebas internas y nunca en APK release.

## 4. Invariantes de compatibilidad

1. UI-1 conserva su identidad, tema y límites de shell; ningún estado puede perderse por recomposición visual.
2. Mapa sigue visible y es protagonista; la lista es una alternativa accesible y sincronizada, no un reemplazo de ruta ni un resultado global.
3. Filtro de categoría sigue invocando los casos/repositorios existentes y backend conserva selección/ranking. El filtro textual local aprobado solo afecta nombre de resultados ya recibidos y su vacío dice «No hay coincidencias en estos resultados».
4. Abrir marcador/tarjeta/Preview/Detail no cambia `chosenIds`. Solo el control de selección explícita alterna un POI que pertenece al snapshot vigente. Al sustituirse o vencer snapshot se conserva la política de `SelectedPoiDraft`; B1 congela selección existente.
5. La cache P9 mantiene cardinalidad, límites, TTL, consentimiento, borrado y validación. Sin URL temporal, binary, foto o cambio de codec/esquema.
6. Distance label nunca implica lejanía al usuario, tiempo, desvío o navegación. No se derivan localidades de coordenadas.
7. Durante Driving se conserva exactamente el árbol reducido, guards y affordances autorizadas. Ninguna lista, búsqueda, filtro o acción nueva aparece, se agenda o se ejecuta al salir.
8. GPS ownership, consentimiento, lifecycle, B1/R01, avisos CEFI y rutas de backend permanecen intactos.

## 5. Arquitectura contractual mínima

Reusar `BaseMapPage`, `RouteDiscoveryController`, `OfflineDiscovery`, `RouteSnapshot`, `DiscoveryPoi`, `SelectedPoiDraft`, `PoiPreviewSheet`, `PoiDetailSheet` y `DiscoveryFilterSheet`. Añadir solo presentación/modelo de estado local si es necesario; la política de filtros o la selección no debe vivir en un widget de tarjeta. No cambiar caso de uso, repositorio, DTO, endpoint, almacenamiento local, schema o dependencias.

Mantener estado efímero de query dentro de Exploration; derivar lista visible desde `snapshot.pois` sin mutar snapshot ni query backend, usando Unicode NFD, eliminación de marcas diacríticas, trim, colapso de espacios y comparación case-insensitive por subcadena del nombre. No hay debounce ni llamada de red. Conservar query al abrir/cerrar Preview/Detail en la misma sesión; limpiarla al cambiar identidad del snapshot, al vencer este o salir de Exploración. No mostrar/guardar en Driving ni diferir acciones hasta la salida.

## 6. Criterios de aceptación aprobados

`UI2-AC-01` a `UI2-AC-14` quedan aprobados sin PASS de ejecución. Su contenido técnico se conserva íntegro; su evidencia corresponde a la implementación y validación futura bajo autorización independiente.

| ID | Criterio comprobable | Evidencia requerida |
|---|---|---|
| UI2-AC-01 Mapa | Mapa y ruta permanecen visibles como foco del shell; control oclusivo no impide reconocer el trazado. | Widget/layout tests en 360×640 y 360×800; evidencia comparativa con misma dimensión y fixture. |
| UI2-AC-02 Mapa/lista | Marcador abre Preview del mismo ID; fila y marcador se sincronizan; lista ofrece equivalencia no basada en mapa/color. | Widget tests con fixture de snapshot y test de retorno. |
| UI2-AC-03 Categoría | Selector muestra solo los códigos Discovery actuales; Aplicar ejecuta flujo existente, Cancelar no muta; reset respeta semántica existente. | Tests de sheet, controller, request mapper y estados. |
| UI2-AC-04 Tarjetas | Datos visuales son solo ID/name/category/description/distance/provenance existentes. Campos opcionales se ocultan cuando nulos/vacíos. | Tests de presentación con campos presentes/ausentes y unknown categories. |
| UI2-AC-05 Semántica distancia | Si se muestra, etiqueta exacta indica distancia al trazado; ningún texto dice distancia actual, desvío o ETA. | Widget assertion y revisión de strings. |
| UI2-AC-06 Preview/Detail | Abrir, cerrar y volver conserva ruta/filtros/consulta local/viewport factible y no cambia selección. | Secuencia widget/state test; comparación chosenIds previa/post. |
| UI2-AC-07 I01 | Selección solo cambia tras acción explícita; solo IDs del snapshot elegible; freeze impide cambios durante B1. | Regresión `i01_selection`, `i01_widget`, `i01_worker` y casos de snapshot sustituido/vencido. |
| UI2-AC-08 Búsqueda local | El campo aprobado «Buscar en estos resultados» filtra solo el nombre de POIs del snapshot vigente según Unicode NFD, eliminación de diacríticos, trim/colapso de espacios y comparación case-insensitive por subcadena; conserva query al abrir/cerrar Preview/Detail en la sesión, la limpia al cambiar identidad del snapshot, al vencerlo o salir de Exploración; no invoca red, geocoder ni persistencia. Vacío exacto: «No hay coincidencias en estos resultados». No está en Driving. | Tests unit/widget con spy repository (cero llamadas al tipear), fixtures acentuados/espacios y snapshot sustituido/vencido. |
| UI2-AC-09 Estados/cache | Loading, vacío, error, retry, cached/unavailable y expiración conservan mensaje y acción existentes; no se presenta snapshot vencido como actual. | Regresión offline + boundary TTL y widget tests usando reloj/store de prueba. |
| UI2-AC-10 Medios | Tarjetas/detalle reservan miniatura estable; placeholder accesible y datos siempre visibles sin imagen; no se presenta ilustración como foto. Fixture `TEST_ONLY` solo en pruebas internas, no se incluye en APK release ni se consulta URL externa. Fotos reales no se renderizan sin derechos verificables para uso controlado. | Tests de widget/asset manifest y auditoría de archivos/URLs y rights register. Los tamaños candidatos se ajustan solo con evidencia de layout/accesibilidad. |
| UI2-AC-11 Driving/GPS/voz | UI y llamadas de búsqueda no disponibles durante Driving; ninguna llamada nueva a GPS/voice ni cambio de permiso/manifiesto. | Tests de guards/callbacks y diff de manifiestos, dependencias, servicios y árbol Driving. |
| UI2-AC-12 Accesibilidad | Objetivo WCAG AA donde corresponda; contraste suficiente en texto/superficies independiente de colores variables de tiles; targets ≥48×48 dp; alternativa de lista, semantics adecuadas y estados no comunicados solo por color. | Widget semantics/layout/contrast tests y revisión tokens/superficies. TalkBack físico es evidencia aparte; automatización no equivale a PASS del lector. |
| UI2-AC-13 Viewports | Sin overflow en 360×640, 360×800, 640×360, 800×360 con escala 1.0/2.0; nombres largos y campos opcionales. | Matriz widget y capturas renderer sintéticas identificadas. Cartografía real/tiles y dispositivo se registran aparte. |
| UI2-AC-14 No regresión | Flutter format/analyze/test pasa; regresiones P8/P9/I01/GPS/B1/R01/CEFI/Driving existentes pasan; `git diff --check`; paths/dependencias autorizados. | Logs reales al ejecutar una fase futura; en este Discovery no se afirma PASS. |

### Alcances de verificación

Mocks/fixtures pueden demostrar layout, filtro local y transiciones; no demuestran contenido desplegado, derechos de fotografía, disponibilidad real de backend ni comportamiento de Android TalkBack. Las respuestas actuales de API y el snapshot real se verifican con contrato/mapper existentes. API nueva, localidades, media distribuida u operación ADMIN necesitarían sus propios contratos/integ tests y gate humano; quedan fuera de este contrato. En ejecución futura se exige suite automatizada completa. Widget tests, renderer, build APK, Android físico, TalkBack y cartografía/tiles se registran separadamente; los no ejecutados figuran `PENDING`/`NOT_EXECUTED`, nunca PASS o Production Readiness.

## 7. Requisitos de seguridad y datos

No agregar telemetría, permisos, IDs de dispositivo, tracking ni persistencia query. Limitar capturas a datos sintéticos y no usar coordenadas personales. No mostrar enlaces salvo procedencia ya suministrada. Ninguna foto se publica sin estado verificable de rights y aprobación requerida por la política [UI-2 Media](UI-2-POI-Media-and-Test-Fixture-Policy-Proposal.md). La capa puede mostrar placeholder sin afirmar ausencia de POI.

## 8. Plan de checkpoints futuro

El plan por etapas está en [UI-2 Decision Register / plan](UI-2-Decision-Register.md#5-plan-propuesto-ui-1-a-ui-5). El freeze de este contrato no autoriza la ejecución de UI-2 ni las fases posteriores.

```ini
UI_2_DISCOVERY = COMPLETED
UI_2_DECISIONS_D01_D06 = APPROVED
UI_2_ACCEPTANCE_CRITERIA_AC01_AC14 = APPROVED
UI_2_CONTRACT = APPROVED_FROZEN
UI_2_CONTRACT_FREEZE = RECORDED
UI_2_IMPLEMENTATION = NOT_AUTHORIZED
UI_2_AUTONOMOUS_IMPLEMENTATION = NOT_AUTHORIZED
```
