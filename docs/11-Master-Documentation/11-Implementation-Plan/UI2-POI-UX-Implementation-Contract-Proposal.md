# UI2-POI-UX-IMPLEMENTATION-001 — Iconografía de categorías y tarjetas POI

## Estado y autoridad

| Campo | Estado |
|---|---|
| Baseline documental de referencia | `5db705ce7a98fc912f04977cfa32aff51f0d91e6` (`origin/main` verificado) |
| Decisiones de producto D01–D08 | `APPROVED` |
| Contrato de implementación | `FROZEN` |
| Incremento A — iconografía | `NOT_AUTHORIZED` |
| Incremento B — tarjetas POI | `NOT_AUTHORIZED` |
| Push / PR / merge | `NOT_AUTHORIZED` |
| TalkBack | `NOT_TESTED` |
| Remediación TalkBack | `DEFERRED_TECH_DEBT` |
| Cierre maestro UI-2 | `NOT_AUTHORIZED` |
| P12.5 | `NOT_AUTHORIZED` |
| Production Readiness | `NOT_DECLARED` |

Esta propuesta consolida las decisiones aprobadas para una futura enmienda de experiencia. No sustituye ni reescribe el contrato UI-2 congelado. La implementación requiere que este contrato alcance `FROZEN` y reciba autorización independiente.

## 1. Propósito y alcance

Definir dos incrementos de presentación Flutter para el descubrimiento turístico: (A) iconos de las categorías ya existentes y (B) tarjetas compactas para la lista de POIs y su Detail. La fuente de datos, taxonomía, Route Discovery, filtros, persistencia, permisos y comportamiento de Driving permanecen bajo los contratos vigentes.

### Incluye

- Catálogo local compartido de código de categoría → etiqueta/icono, utilizado desde filtro, marcador, tarjeta, Preview y Detail.
- Catálogo visual con mapeo para las 15 categorías activas; las cinco categorías de servicio son entradas de presentación únicamente y se mantienen fuera del flujo actual de Route Discovery, sus filtros y snapshots.
- Fallback visual genérico cuando un código desconocido llegue válidamente a la capa de presentación; no se relaja la validación de códigos en DTO, mapper, endpoint ni snapshot.
- Jerarquía compacta de tarjeta con nombre, categoría, distancia válida, descripción existente y CTA «Ver detalles».
- Detail con los datos existentes de procedencia y conservación del placeholder de miniatura.

### Excluye

Nuevas categorías/subcategorías, API/backend/DB, cambios de DTO o snapshots, nuevos paquetes o recursos remotos, clustering, fotos reales, geocodificación, GPS, permisos, Driving, CEFI, cambios a `chosenIds`, pruebas físicas y declaración de readiness.

## 2. Decisiones aprobadas

| ID | Decisión | Límite de aplicación |
|---|---|---|
| D01 | Un catálogo de presentación resuelve código → etiqueta e icono para evitar lógica duplicada. | Catálogo Flutter local; no crea una segunda taxonomía de dominio. |
| D02 | El catálogo visual tiene mapeo para las 15 categorías activas. | Solo las 10 categorías Discovery actuales aparecen en filtros, resultados y snapshots turísticos. Los cinco códigos de servicio son mapeos de presentación sin consumo en esas superficies actuales; no agregar categorías ni subcategorías. |
| D03 | Reutilizar una representación reconocible y consistente en filtro, mapa, tarjeta, Preview y Detail. | Diferenciar por silueta además de color; desconocidos usan fallback visual sin cambiar la validación de entrada. |
| D04 | Tarjeta compacta: nombre (máximo dos líneas), categoría con icono/etiqueta, distancia válida, descripción abreviada visualmente y «Ver detalles». | Conservar placeholder; no modificar el texto fuente ni agregar fotografías. |
| D05 | «Ver detalles» abre Detail del mismo POI; el marcador del mapa conserva Preview. | CTA no debe propagar un segundo tap ni mutar selección. El área restante de la tarjeta conserva la navegación actual definida por UI-2. |
| D06 | La tarjeta puede mostrar fuente compacta si existe y no degrada legibilidad; Detail conserva descripción, fuente, atribución y URL disponibles. | Ocultar valores ausentes; no inventar contenido ni lanzar enlaces externos como parte de este cambio. |
| D07 | La distancia representa solo separación al trazado. | Etiqueta exacta «A X m del trazado»; no implica distancia al usuario, ETA ni desvío. Ocultar valores no válidos. |
| D08 | Preservar offline, TTL/snapshots, filtros y conteos, invalidación obsoleta, ruta/origen/destino/GPS, atribución OSM y Driving P9. | Sin cambio de codec, esquema, selección, lifecycle GPS o árbol de Driving. |

### Detalle de navegación D05

La acción explícita «Ver detalles» en una tarjeta de lista navega directamente al Detail del mismo ID. El marcador continúa abriendo Preview, desde donde se conserva el acceso existente a Detail. El manejo del CTA debe impedir que el mismo toque active también el callback de la tarjeta. Abrir tarjeta, Preview o Detail no altera `chosenIds`. El área de tarjeta fuera del CTA mantiene el comportamiento que ya tenga el contrato UI-2 congelado; esta propuesta no convierte el tap de exploración en selección.

## 3. Taxonomía verificada en el baseline

La taxonomía fuente `backend/src/main/resources/data/p3/taxonomy-v1.json` contiene 15 códigos planos activos. `geo.category` tampoco define jerarquía de categoría/subcategoría.

| Grupo actual | Código | Etiqueta existente | Concepto visual propuesto |
|---|---|---|---|
| Discovery | `WATERFALL` | Catarata | Agua descendente |
| Discovery | `LAGOON` | Laguna | Superficie de laguna |
| Discovery | `MOUNTAIN` | Montaña | Cumbres |
| Discovery | `FOREST` | Bosque | Árboles |
| Discovery | `BEACH` | Playa | Playa y ola |
| Discovery | `MUSEUM` | Museo | Edificio de museo |
| Discovery | `ARCHAEOLOGICAL_SITE` | Sitio arqueológico | Ruinas |
| Discovery | `MONUMENT` | Monumento | Monumento |
| Discovery | `HISTORIC_CHURCH` | Iglesia histórica | Iglesia |
| Discovery | `VIEWPOINT` | Mirador | Mirador/paisaje |
| Servicio | `FUEL` | Combustible | Combustible |
| Servicio | `HEALTH` | Salud | Salud |
| Servicio | `FOOD` | Alimentación | Alimentación |
| Servicio | `LODGING` | Hospedaje | Hospedaje |
| Otros | `OTHER` | Otros | Marcador genérico |

Las etiquetas deben reutilizar la presentación actual (`poi_presentation.dart`) donde corresponda. No existe código `PLAZA`, `CAVE` ni otras subcategorías en esta taxonomía; no derivar categorías por el nombre del POI. La selección de glifos Material concretos se verifica durante la implementación contra la versión Flutter existente y se prueba por ambigüedad antes de cerrar el catálogo. Aunque el catálogo define las 15 entradas, el modelo, mapper y snapshot Discovery actuales admiten las diez categorías turísticas; los cinco mapeos de servicio no los habilitan para aparecer en lista o mapa.

## 4. Componentes y datos existentes

| Área | Hecho del baseline | Implicación contractual |
|---|---|---|
| Modelo | `DiscoveryPoi` contiene ID, nombre, categoría, coordenadas, `distanceToRouteMeters`, `routeProgress`, `reasonCodes` y campos opcionales `description`, `sourceLabel`, `sourceUrl`, `attribution`. | La tarjeta/Detail usan solo estos datos disponibles. `score` no está mapeado en Flutter. |
| Presentación | `poi_presentation.dart` resuelve etiquetas; no hay catálogo compartido de iconos. | D01 añade presentación visual local; no debe duplicar etiquetas ni crear taxonomía nueva. |
| Filtro | `discovery_filter_sheet.dart` presenta las diez categorías Discovery como filas con nombre. | Los iconos se agregan a esas filas; servicios no entran en el filtro. |
| Tarjeta | `poi_result_card.dart` presenta nombre, etiqueta de categoría, distancia válida, descripción, procedencia y placeholder; abre el flujo actual de Preview. | El CTA explícito puede abrir Detail directamente, manteniendo la ruta actual fuera del CTA según UI-2. |
| Preview / Detail | `poi_preview_sheet.dart` y `poi_detail_sheet.dart` consumen el mismo POI; Detail presenta fuente, atribución y URL cuando existen. | Ambos reutilizan el catálogo; se conservan campos y navegación actuales salvo el CTA especificado. |
| Miniatura | `poi_thumbnail.dart` muestra placeholder neutral; no consulta imágenes remotas. | Se conserva sin imagen ficticia ni nueva dependencia. |
| Mapa | `BaseMapPage` usa marcador POI con `Icons.place`; los marcadores se dibujan individualmente y no hay clustering. | Sustituir solo el símbolo interior según catálogo; mantener superficie, contraste, hit target y semántica. Marcadores pueden solaparse; la lista conserva todos los POIs. |
| Offline | `snapshot_codec.dart` almacena código y campos permitidos y valida el catálogo Discovery. | La búsqueda del icono es local y sin red. El fallback visual no debe relajar codec/whitelist. |

## 5. Incremento A — Catálogo de iconos

### Requisitos de diseño y ejecución

- Usar iconos Material disponibles en Flutter, preferentemente sin paquete adicional ni assets descargables.
- Catálogo único código → icono y etiqueta existente; fallback genérico seguro para valores que alcancen la vista.
- Aplicar el icono en filtros Discovery, marcador POI, tarjeta, Preview y Detail. Añadir texto/semantics donde el contexto no incluya etiqueta visible; el color nunca es la única señal.
- Mantener el contenedor y área interactiva del marcador, distinguiendo POI de origen, destino y ubicación GPS.
- Los iconos se derivan de `category` guardada; funcionan offline. No se agrega clustering: la lista no pierde elementos cuando los símbolos de mapa se superponen.
- No se aprueba usar marcas, pictogramas externos o paquetes con licencia/huella de runtime nueva.

### Criterios de aceptación A

| ID | Criterio verificable |
|---|---|
| A-AC-01 | Hay representación definida para los 15 códigos activos del baseline. |
| A-AC-02 | Las 10 categorías Discovery muestran icono coherente en el filtro; ninguna categoría de servicio se agrega al filtro turístico. |
| A-AC-03 | Cada marcador POI admitido por el flujo Discovery actual muestra el icono de su código y se distingue de origen/destino/GPS. |
| A-AC-04 | Tarjeta, Preview y Detail usan el catálogo compartido para ese mismo POI. |
| A-AC-05 | Un código desconocido que llegue a presentación usa fallback; validadores de API/mapper/snapshot permanecen intactos. |
| A-AC-06 | `FUEL`, `HEALTH`, `FOOD`, `LODGING` y `OTHER` tienen mapeo en el catálogo, pero no se muestran en filtros, resultados ni snapshots Discovery en esta iniciativa. |
| A-AC-07 | La categoría se reconoce por icono y etiqueta/silhouette, no solo por color; se evalúan pares visualmente ambiguos. |
| A-AC-08 | Targets, semántica y acción existente de marcadores se conservan. |
| A-AC-09 | La correspondencia funciona offline sin descarga ni cambio de snapshot. |
| A-AC-10 | Si POIs próximos producen solapamiento de marcadores, todos siguen disponibles en lista y los tests no afirman que cada glyph sea simultáneamente visible. |

## 6. Incremento B — Tarjeta y Detail

### Especificación de presentación

- Nombre del atractivo hasta dos líneas; categoría con icono y etiqueta.
- Distancia mostrada solo si numéricamente válida, en metros y con formato contractual «A X m del trazado».
- Descripción existente acortada por presentación (no sobrescrita ni truncada en modelo); sin descripción, ocultar región correspondiente.
- CTA accesible «Ver detalles» abre Detail del mismo ID. El tap del CTA no propaga una segunda activación.
- Preview desde marcador no cambia. Abrir cualquier superficie de lectura no altera selección.
- Fuente/atribución/URL disponibles permanecen en Detail; fuente compacta en tarjeta es opcional y solo se muestra si no perjudica lectura. No se abre enlace externo en este alcance.
- Placeholder actual de miniatura permanece. No agregar fotos, URLs de imágenes, ilustraciones que simulen fotos ni consultas remotas.
- Respetar viewports, escalas, layout y semantics ya congelados en UI-2.

### Criterios de aceptación B

| ID | Criterio verificable |
|---|---|
| B-AC-01 | Nombre y categoría se muestran con jerarquía legible; nombre limitado visualmente a dos líneas sin mutar el dato. |
| B-AC-02 | Categoría muestra icono/etiqueta del catálogo A. |
| B-AC-03 | Distancia válida usa «A X m del trazado»; valores inválidos se omiten. |
| B-AC-04 | Descripción se acorta solo visualmente y campos opcionales vacíos quedan ocultos. |
| B-AC-05 | «Ver detalles» es identificable, accesible y activa una sola acción. |
| B-AC-06 | CTA abre Detail del mismo POI, sin mutar selección. |
| B-AC-07 | Marcador sigue abriendo Preview, y Preview conserva acceso a Detail. |
| B-AC-08 | Abrir tarjeta/Preview/Detail no cambia `chosenIds`; selección solo cambia mediante su control explícito vigente. |
| B-AC-09 | Detail conserva descripción, fuente, atribución y URL existentes; no inventa contenido ni abre URLs externamente. |
| B-AC-10 | Placeholder y funcionamiento offline permanecen, sin nuevas solicitudes de medios. |
| B-AC-11 | Tarjeta y Detail permanecen legibles en viewports/escalas de UI-2, incluidos nombres largos y texto ampliado. |
| B-AC-12 | No hay cambios de backend, API ni DB. |

## 7. Compatibilidad y reconciliación

| Fuente vigente | Requisito | Reconciliación propuesta |
|---|---|---|
| UI-1 Design System | Tokens visuales de GeoGuide, contraste, consistencia y combinación icono + etiqueta. | Iconos usan tokens/containers existentes; silueta y etiqueta impiden depender solo del color. |
| UI-2 congelado | Solo DTO y categorías existentes; mapa como protagonista; lista accesible; no selección por lectura; miniatura placeholder; distance semantics; targets ≥48 dp; Driving/GPS invariantes. | D01–D08 extienden presentación dentro de esas invariantes. El CTA Detail precisa una acción visual dentro del acceso existente a Preview/Detail; no cambia selección ni estado de navegación/ruta. |
| I01 | `chosenIds` cambia solo por acción explícita de selección. | La navegación CTA no llama ni simula el control de selección. |
| P9 | No cambiar snapshots, TTL, límites, consentimiento, codec, Driving, permisos ni cache. | Iconos son lookup local por categoría; no media ni datos nuevos persistidos. El catálogo de 15 códigos no amplía la whitelist Discovery de diez categorías. |
| Arquitectura / ADRs | Flutter presenta; dominio y datos siguen en servicios/repositorios existentes. | Sin nueva dependencia, endpoint, caso de uso ni módulo arquitectónico. |

**Contradicciones materiales detectadas:** ninguna con la taxonomía vigente ni con las invariantes expresas. **Límite que debe quedar en el freeze:** el contrato UI-2 garantiza acceso de lista a Preview/Detail, mientras el comportamiento actual de la tarjeta abre Preview; esta propuesta asigna explícitamente el CTA «Ver detalles» a Detail. Para preservar el contrato y evitar ambigüedad, el tap fuera del CTA conserva el comportamiento de tarjeta ya vigente. Si se desea que toda la fila abra Detail, debe cambiarse esta decisión antes del freeze. El fallback de icono es únicamente visual y no autoriza aceptar categorías no conocidas en transporte o almacenamiento.

## 8. Riesgos y mitigaciones

| Riesgo | Nivel | Mitigación contractual |
|---|---|---|
| Glifos similares (p. ej., cascada/laguna o montaña/mirador) | Medio | Revisar pares en tamaños reales; silueta + etiqueta; sustituir símbolos ambiguos antes de cierre de A. |
| Solapamiento de POIs cercanos | Medio | No introducir clustering en alcance; lista conserva todos los resultados y su lectura. Revisión visual informa limitación del mapa. |
| Ampliar accidentalmente taxonomía o filtro | Alto | Fuente única de 15 códigos; filtro exclusivamente sobre los 10 Discovery existentes; test de códigos/requests. |
| CTA activa también el tap de tarjeta | Medio | Manejar propagación y probar exactamente una navegación. |
| La tarjeta oculta datos o presenta semántica engañosa | Medio | Solo campos DTO, ocultar ausentes y exactitud de etiqueta de distancia. |
| Cambio de selección al navegar | Alto | Comparar `chosenIds` antes/después; mantener control de selección separado. |
| Fallback usado para permitir datos desconocidos | Alto | No tocar validación del mapper/codec/API; el fallback solo cubre renderizado. |
| TalkBack no cubierto en esta iniciativa | Medio | Mantener `NOT_TESTED` y deuda diferida; automatización no se reporta como prueba física. |

## 9. Validación futura y orden

Tras freeze y autorización de implementación:

1. **A:** catálogo y fallback → filtros → marcadores → tarjetas/Preview/Detail → pruebas unitarias/widget y revisión de colisiones visuales.
2. Ejecutar format, analyze y suite Flutter pertinente/completa; comprobar offline, selection, stale snapshots, layout y Driving sin cambios.
3. **B:** tarjeta compacta y CTA → navegación Detail → campos opcionales/placeholder → pruebas de interacción, selección y escalado.
4. Evidencia renderer/APK y, solo con autorización separada, HONOR físico. No inferir PASS de TalkBack.

No iniciar B antes de demostrar compatibilidad de A. Ninguna validación de esta propuesta ha sido ejecutada: todos los criterios A/B están pendientes.

## 10. Referencias vigentes

- [Contrato UI-2 congelado](UI-2-Map-Search-and-POI-Experience-Contract-Proposal.md)
- [Registro de decisiones UI-2](UI-2-Decision-Register.md)
- [Diseño de categorías POI de UI-1](../../05-UX-UI/04-Design-System/POI-Categories.md)
- [Design System UI-1](../../05-UX-UI/04-Design-System/Design-System.md)
- [Contrato P9](P9-Phase-Contract-v1.md)
- [ADR-016 Flutter](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-016-Flutter.md) y [ADR-019 biblioteca de mapas](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-019-Map-Library.md)
- Fuente taxonómica: `backend/src/main/resources/data/p3/taxonomy-v1.json` y migración `backend/src/main/resources/db/migration/V002__create_geo_category.sql` (nombre verificado).

## 11. Estados de cierre de esta propuesta

```ini
UI2_POI_UX_PRODUCT_DECISIONS = APPROVED
UI2_POI_UX_CONTRACT = FROZEN
UI2_CATEGORY_ICONS_INCREMENT_A = NOT_AUTHORIZED
UI2_POI_CARDS_INCREMENT_B = NOT_AUTHORIZED
UI2_POI_UX_PUSH_PR_MERGE = NOT_AUTHORIZED
TALKBACK = NOT_TESTED
TALKBACK_REMEDIATION = DEFERRED_TECH_DEBT
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

**Freeze documental:** D01–D08 y A-AC-01–10/B-AC-01–12 quedan congelados en este alcance de presentación. «Ver detalles» navega a Detail; el tap fuera del CTA conserva Preview y el marcador conserva Preview. `chosenIds` no cambia por navegación. El mapeo para servicios no amplía las diez categorías admitidas por Discovery. Ninguno de los incrementos queda autorizado por este freeze.
