# UI2-POI-UX-IMPLEMENTATION-001 — Evidencia de Incremento A

## Alcance y estado

| Campo | Estado |
|---|---|
| Contrato | `UI2-POI-UX-Implementation-Contract-Proposal.md` — FROZEN, PR #108 |
| Baseline de implementación | `9cf514916a96cbe83935edb20095f82c78015159` (`origin/main`) |
| Rama | `feat/ui2-poi-category-icons` |
| Incremento A — iconografía | `IMPLEMENTED_PENDING_REVIEW` |
| Incremento B — tarjetas | `NOT_AUTHORIZED` |
| HONOR / TalkBack | No ejecutados; TalkBack sigue como deuda técnica diferida |

La implementación se limita a iconografía de presentación. No modifica la taxonomía de dominio, los contratos congelados ni las decisiones históricas.

## Catálogo visual

El único catálogo está en `mobile/lib/features/discovery/presentation/poi_presentation.dart` y es local; usa `IconData` Material incluido en Flutter.

| Código | Etiqueta conservada | Icono Material |
|---|---|---|
| `WATERFALL` | Catarata | `Icons.water_drop` |
| `LAGOON` | Laguna | `Icons.water` |
| `MOUNTAIN` | Montaña | `Icons.terrain` |
| `FOREST` | Bosque | `Icons.forest` |
| `BEACH` | Playa | `Icons.beach_access` |
| `MUSEUM` | Museo | `Icons.museum` |
| `ARCHAEOLOGICAL_SITE` | Sitio arqueológico | `Icons.account_balance` |
| `MONUMENT` | Monumento | `Icons.castle` |
| `HISTORIC_CHURCH` | Iglesia histórica | `Icons.church` |
| `VIEWPOINT` | Mirador | `Icons.visibility` |
| `FUEL` | Combustible | `Icons.local_gas_station` |
| `HEALTH` | Salud | `Icons.medical_services` |
| `FOOD` | Alimentación | `Icons.restaurant` |
| `LODGING` | Hospedaje | `Icons.hotel` |
| `OTHER` | Otros | `Icons.category` |

`WATERFALL` utiliza la gota (`water_drop`) como símbolo Material disponible más próximo; no hay un glifo literal de catarata en el catálogo Material usado por la app. El fallback de códigos visuales desconocidos es `Lugar de interés` con `Icons.category`; no agrega códigos aceptados al dominio.

## Criterios A-AC

| Criterio | Resultado | Evidencia |
|---|---|---|
| A-AC-01 — 15 códigos | PASS | Test del catálogo verifica los 15 códigos, etiquetas y glifos únicos. |
| A-AC-02 — filtro de diez códigos | PASS | Filtro itera `discoveryCategoryCodes`; test comprueba iconos en las diez filas y excluye servicios. |
| A-AC-03 — marcador POI diferenciado | PASS | El marcador usa el icono de categoría dentro del contenedor existente; catálogo excluye los glifos de origen, destino y GPS (`trip_origin`, `location_on`, `my_location`). Callback y área existentes se conservan. |
| A-AC-04 — catálogo compartido | PASS | Tarjeta, Preview y Detail obtienen icono y etiqueta del mismo catálogo; tests widget verifican el símbolo. |
| A-AC-05 — fallback sin relajar validadores | PASS | Test del fallback visual y prueba del envelope offline que sigue rechazando `FUEL`. |
| A-AC-06 — servicios fuera de Discovery | PASS | Los cinco códigos de servicio tienen presentación, pero no pertenecen a `discoveryCategoryCodes`; filtro y validador de snapshot se mantienen. |
| A-AC-07 — reconocimiento por silueta y etiqueta | PASS | Los 15 glifos son distintos; agua, laguna, terreno, playa y mirador tienen símbolos diferenciados y mantienen etiqueta textual. |
| A-AC-08 — interacción/semántica | PASS | Test de acción de marcador conserva tooltip/Preview; no se cambió callback ni contenedor táctil. |
| A-AC-09 — offline | PASS | Mapeo local sin descarga; regresión focalizada de cache/snapshot PASS. |
| A-AC-10 — POIs superpuestos | PASS | Test con 20 POIs de la misma ubicación verifica acceso al último elemento en lista en tres tamaños de pantalla. No se exige que todos los glifos sean visibles simultáneamente en mapa. |

## Archivos de implementación y pruebas

- Presentación compartida: `mobile/lib/features/discovery/presentation/poi_presentation.dart`.
- Integración visual: `discovery_filter_sheet.dart`, `poi_result_card.dart`, `poi_preview_sheet.dart`, `poi_detail_sheet.dart` y `mobile/lib/features/map/presentation/base_map_page.dart`.
- Pruebas: `poi_category_catalog_test.dart`, `discovery_filter_sheet_test.dart`, `poi_preview_sheet_test.dart`, `poi_detail_sheet_test.dart`, `poi_visual_contract_test.dart`, `a01_preview_actions_test.dart`, `offline_cache_test.dart` y `poi_list_close_test.dart`.

No se añadieron dependencias, assets remotos ni cambios de backend, API, DB o permisos. No se alteraron Driving, selección `chosenIds`, validadores de taxonomía ni formato/datos de snapshots. El Incremento B permanece fuera de alcance.

## Validación

- Regresión focalizada ampliada (12 archivos de prueba): **103/103 PASS**, incluida la prueba del catálogo tras añadir la comprobación de separación respecto del icono GPS.
- `dart format --output=none --set-exit-if-changed` sobre los archivos Dart afectados: **PASS**, 14 archivos, 0 cambios.
- `flutter analyze`: **PASS**, sin hallazgos.
- `git diff --check`: **PASS**.
- Sin APK, instalación física, prueba HONOR ni prueba TalkBack en este incremento.

Riesgo visual residual: la identificación depende de glifos Material y su legibilidad final en el launcher/dispositivo requiere revisión visual; no se afirma validación física.

## Gobierno

```ini
UI2_POI_UX_CONTRACT = FROZEN
UI2_CATEGORY_ICONS_INCREMENT_A = IMPLEMENTED_PENDING_REVIEW
UI2_POI_CARDS_INCREMENT_B = NOT_AUTHORIZED
UI2_CATEGORY_ICONS_PUSH_PR_MERGE = NOT_AUTHORIZED
UI2_CATEGORY_ICONS_HONOR_VALIDATION = NOT_AUTHORIZED
TALKBACK_REMEDIATION = DEFERRED_TECH_DEBT
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
