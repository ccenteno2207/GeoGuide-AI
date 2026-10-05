# GeoGuide AI MVP UX Baseline

Estado: `ESTABLISHED_FOR_PRODUCT_REVIEW`; consolidado el 5-oct-2026.

Este documento es la referencia única de producto para la revisión previa a P8.0. No
implementa funcionalidad, no modifica contratos y no autoriza P8.

## Experiencia primaria objetivo

```text
DESTINO → confirmar/elegir ORIGEN → RUTA → comprender recorrido
        → DESCUBRIR → POIs → PREVIEW → DETAIL
        → regresar al mismo contexto del recorrido
```

GeoGuide AI no es simplemente un navegador GPS. Ayuda a planificar, comprender el
trayecto, descubrir lugares relacionados, decidir qué conocer y construir conocimiento
reutilizable en rutas futuras. Las preguntas guía son “¿Qué puedo conocer sin desviarme
demasiado?” y “¿Qué me falta conocer en esta ruta?”. No son contratos técnicos.

El destino debe evolucionar hacia búsqueda por lugar, búsqueda por dirección o mapa.
El origen podrá ser Mi ubicación, búsqueda o mapa y siempre será editable; también debe
existir intercambio de extremos. El flujo P7 de dos toques es una capacidad actual y
una alternativa válida, no la UX final.

`SEARCH_GEOCODING = IMPORTANT_FOR_FINAL_MVP`, `CURRENT_IMPLEMENTATION = NOT_AVAILABLE`
y `ARCHITECTURE_DECISION_REQUIRED = YES`. No se selecciona proveedor ni se incluye
geocoding silenciosamente en P8. Un gate posterior debe evaluar cobertura, privacidad,
licencias, atribución, límites, disponibilidad e integración.

## Principios consolidados

- Explorar nunca destruye el contexto del viaje: ruta, extremos, viewport, resultados,
  filtros, selección y retorno se preservan conceptualmente.
- `distanceToRouteMeters` es distancia al trazado; no es `detourDistance`.
- `routeProgress` no es progreso real del conductor; `NEAR_ROUTE` no garantiza acceso.
- Discovery, Recreation y Travel Service son intenciones de producto distintas, sin
  crear entidades técnicas separadas en este gate.
- Discovery debe poder explorarse mediante mapa y lista/tarjetas sincronizados; la lista
  es un candidato fuerte para P8.
- El ranking autoritativo permanece en backend.
- Las acciones complejas ocurren pre-trip o detenido. Voz no equivale automáticamente a
  seguridad.
- La UI y CEFI futuro deben reutilizar capacidades de aplicación y dominio.
- Hechos, provenance, frescura y errores deben poder representarse en varios canales.
- No hay historial GPS permanente por defecto; estados de visita futuros son explícitos
  y corregibles.

## Intenciones de producto

| Intención | Pregunta | Ejemplos | Frontera |
|---|---|---|---|
| DISCOVERY | ¿Qué vale la pena conocer? | naturaleza, historia, cultura, patrimonio, pueblos, paisajes, miradores | Núcleo; taxonomía final pendiente de auditoría P3. |
| RECREATION | ¿Dónde puedo parar o realizar una actividad? | centros recreacionales, clubes, piscinas, parques, ocio | No aumenta automáticamente el progreso de descubrimiento. |
| TRAVEL_SERVICE | ¿Qué necesito durante el recorrido? | hospedaje, combustible, alimentación, estacionamiento, descanso | Servicio de viaje; no es “lugar que me falta conocer”. |

Un restaurante puede representar alimentación o descubrimiento gastronómico/cultural
según la intención y la evidencia. El modelo geoespacial general de `PointOfInterest`
se distingue de la semántica de producto; no se refactoriza P3.

## Discovery, preview, detail y filtros

Discovery cubre conceptualmente naturaleza, historia, cultura, patrimonio,
pueblos/localidades, paisajes, miradores y otros lugares de valor; la taxonomía no se
congela aquí.

Preview es candidato P8: nombre, categoría amigable, contexto del recorrido, motivo
comprensible, estado del rutero cuando exista y acción Ver detalle. No muestra score,
reason codes crudos, `routeProgress` decimal ni identificadores técnicos.

Detail es candidato P8: nombre, categoría, descripción, ubicación/contexto, distancia
al trazado, motivo, provenance/fuente, frescura disponible y retorno al mapa. P3 tiene
descripción y provenance, pero el discovery HTTP actual no las expone; persistencia no
equivale a API. P8.0 debe decidir si amplía el contrato. Desvío, tiempo adicional,
accesibilidad real y añadir POI a la ruta son capacidades futuras.

`CATEGORY_FILTER = CORE_P8_CANDIDATE`. Las categorías deben auditar P3, evitar
duplicados, ser extensibles y tener etiquetas amigables. Si cambia el universo de
discovery, se prefiere una nueva consulta backend; filtrar solo resultados descargados
debe comunicarse como “estos resultados”. El ranking permanece en backend.

## Historia futura del rutero

La visión distingue `NO VISITADO`, `QUIERO CONOCER` y `VISITADO`. Visitar requiere
acción explícita, no inferencia por GPS, y debe poder revertirse. El estado pertenece
a usuario ↔ lugar, no a una única ruta; una visita puede reconocerse en otra ruta si
existe identidad estable del lugar. Rutas frecuentes, ida/vuelta, persistencia,
cuentas, sincronización y retención requieren un gate de privacidad posterior.

## CEFI-ready architecture

`CEFI_READY_ARCHITECTURE = REQUIRED_DIRECTION`.

GeoGuide AI es producto/plataforma; CEFI es copiloto/canal futuro dentro del producto.
UI y CEFI deben consumir capacidades compartidas de Plan Route, Discovery y POI Detail,
con resultados estructurados de identidad, nombre, categoría, contexto, razones,
provenance y hechos aprobados. Los errores estructurados deben ser interpretables por
ambos canales.

Ejemplos conceptuales, no contratos: “¿Qué me falta conocer camino a Ica?” → Discovery
no visitado; “muéstrame naturaleza” → categoría; “necesito combustible” → Travel Service;
“quiero parar en un lugar campestre” → Recreation; “marca este lugar como visitado” →
operación futura compartida. No se crean intents, prompts, schemas ni proveedores.

`CEFI_TEXTUAL_VERTICAL_SLICE = FUTURE_OPTION`. No se implementan LLM, STT, TTS,
micrófono, wake word, sesiones, permisos de voz ni UI CEFI.

## Privacidad y conducción

Visitados, “quiero conocer”, rutas frecuentes, recientes y voz requieren decisiones
explícitas de cuenta, almacenamiento, sincronización, retención y eliminación. No se
almacena GPS permanente, audio o conversaciones por suposición. Pre-trip y detenido
admiten búsqueda, filtros y lectura extensa; durante conducción se limita la interacción
y las respuestas futuras deben ser breves y confirmar acciones que cambien estado.
Driving Mode no se implementa.

## P8 candidate scope

**P8_CANDIDATE:** preview, detail, categorías/filtros, mapa/lista, estados
loading/empty/error, explicación comprensible, provenance/frescura si se aprueba el
contrato, continuidad de contexto, accesibilidad y preparación visual/semántica para
un futuro estado de visita.

**P8_EXPLICIT_NON_SCOPE:** saved routes, historial persistente, want-to-visit
persistent, auth/accounts, search/geocoding, detour calculation, Recreation engine,
Travel Service, CEFI/CEFI textual, voice, LLM, STT, TTS, Driving Mode, offline,
favorites, media y navegación turn-by-turn.

## Decisiones requeridas en P8.0

1. Frontera exacta de preview/detail/filter y mapa/lista.
2. Campos POI, provenance y frescura contractuales.
3. Semántica de categorías alineada con P3.
4. Filtrado local frente a nueva consulta backend.
5. Lenguaje para distancia al trazado y futuro desvío.
6. Continuidad de ruta, viewport y retorno.
7. Estados vacío/error y validación de accesibilidad.
8. Capacidades compartidas sin sobrediseño.
9. Impacto de tiles por entorno, manteniendo su gobierno pendiente.

## Auditoría P3 de categorías (solo lectura)

La fuente auditada es `backend/src/main/resources/data/p3/taxonomy-v1.json`.
El inventario actual tiene **15 categorías activas**, una jerarquía plana y ningún
`parent` o árbol de subcategorías. Esta auditoría no modifica P3, la base de datos ni
la taxonomía móvil.

**P3_CATEGORY_LIST:** `WATERFALL`, `LAGOON`, `MOUNTAIN`, `FOREST`, `BEACH`,
`MUSEUM`, `ARCHAEOLOGICAL_SITE`, `MONUMENT`, `HISTORIC_CHURCH`, `VIEWPOINT`,
`FUEL`, `HEALTH`, `FOOD`, `LODGING`, `OTHER`.

**P3_PRODUCT_INTENT_MAPPING (semántico, no contractual):**

- **DISCOVERY:** `WATERFALL`, `LAGOON`, `MOUNTAIN`, `FOREST`, `BEACH`, `MUSEUM`,
  `ARCHAEOLOGICAL_SITE`, `MONUMENT`, `HISTORIC_CHURCH`, `VIEWPOINT`.
- **TRAVEL_SERVICE:** `FUEL`, `HEALTH`, `FOOD`, `LODGING`.
- **RECREATION:** sin categoría P3 dedicada actualmente; no se crea una categoría
  paralela en este gate.
- **OTHER:** categoría ambigua que requiere revisión de contenido/origen antes de
  tratarla como discovery, recreation o travel service.

La aplicación futura debe distinguir intención de producto de la entidad geoespacial:
un servicio comercial sigue siendo un lugar válido, pero no se presenta
automáticamente como lugar pendiente de conocer ni incrementa el progreso discovery.

## Fuentes y trazabilidad

Este baseline consolida Product Master, Project Context, roadmap, requisitos, UX/UI,
arquitectura, contratos P3/P5/P6/P7, ADRs vigentes y la implementación actual de
discovery como evidencia de capacidades. Los contratos y el código describen límites
existentes; este documento establece la decisión de producto para la experiencia MVP.
El benchmark conceptual de planificación de rutas y accesibilidad se contrastó con
las guías oficiales de Google Maps, Waze, Apple Maps, WCAG 2.2 y Android Accessibility;
no introduce dependencias ni cambia el scope del producto.

```text
PRODUCT_UX_BASELINE = ESTABLISHED
CEFI_READY_ARCHITECTURE = REQUIRED_DIRECTION
P8_STATUS = NOT STARTED
P8_CONTRACT_EXISTS = NO
CEFI_IMPLEMENTATION = NOT STARTED
EXCEL_CHANGED = NO
FUNCTIONAL_FILES_CHANGED = NONE
NEXT_RECOMMENDED_GATE = P8.0 SCOPE / CONTRACT / ENTRY GOVERNANCE
AUTONOMOUS_EXECUTION = PAUSED_BEFORE_P8_0_SCOPE_CONTRACT_ENTRY
```
