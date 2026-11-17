# UI2-POI-UX-IMPLEMENTATION-001 — Incremento B: evidencia de tarjetas POI

## Alcance y estado

| Campo | Estado |
|---|---|
| Contrato | [Contrato congelado](UI2-POI-UX-Implementation-Contract-Proposal.md), D01–D08 y B-AC-01–12 |
| Baseline | `49ebeeaa0bc95b52e8a534690b24a700fcb5f387` (`origin/main`; PR #109 ya integrado) |
| Rama de trabajo | `feat/ui2-poi-cards` |
| Incremento A | Integrado antes de este cambio; la evidencia física HONOR H-A01–H-A07 es PASS, H-A08 NOT_VERIFIED y el resultado HONOR permanece PARTIAL |
| Incremento B — implementación | `IMPLEMENTED_PENDING_REVIEW` |
| Incremento B — validación física | `NOT_AUTHORIZED` |
| TalkBack | `NOT_TESTED`; remediación permanece como deuda técnica diferida |
| Publicación | `NOT_AUTHORIZED` (sin push, PR ni merge) |

Esta entrega modifica únicamente la presentación de las tarjetas de lista y su acción de acceso a Detail. No cambia modelos, filtros, selección, snapshots, fuentes de datos ni contratos.

## Implementación

- `PoiResultCard` limita visualmente el nombre a dos líneas y la descripción a dos líneas; conserva el dato original.
- La categoría reutiliza el catálogo local del Incremento A. Solo se presenta la distancia válida al trazado.
- Fuente y atribución opcionales se muestran en líneas compactas; los campos vacíos se ocultan. Se mantiene el placeholder neutral y no se agregan imágenes ni solicitudes de medios.
- El área de contenido conserva el callback de Preview. El botón independiente **Ver detalles** abre Detail directamente para el mismo POI desde `BaseMapPage`; su acción no está anidada dentro del `InkWell` de Preview.
- Detail conserva los campos disponibles, incluida la URL como texto seleccionable, sin apertura externa. La navegación no invoca el control de selección.

## B-AC — evidencia

| Criterio | Resultado | Evidencia |
|---|---|---|
| B-AC-01 | PASS | `poi_visual_contract_test.dart`; los límites de líneas se aplican a presentación, sin transformación de `DiscoveryPoi`. Viewports y escalas UI-2 en `ui2_experience_test.dart`. |
| B-AC-02 | PASS | Catálogo compartido, fallback y semántica de etiquetas en `a01_b_ui_language_test.dart` y `poi_visual_contract_test.dart`. |
| B-AC-03 | PASS | `poiDistanceLabel` conserva el formato de distancia al trazado y omite NaN; pruebas visuales y Preview/Detail existentes. |
| B-AC-04 | PASS | Descripción acotada visualmente y campos opcionales vacíos ocultos; `poi_visual_contract_test.dart`. |
| B-AC-05 | PASS | Botón «Ver detalles» con rol semántico, foco y activación por teclado, objetivo mínimo de 48 dp y callback independiente; `poi_visual_contract_test.dart`. |
| B-AC-06 | PASS | La prueba `list Ver detalles opens the same POI Detail directly without selection mutation` comprueba Detail del ID de prueba, ausencia de Preview y conservación de la selección explícita preexistente. |
| B-AC-07 | PASS | `a01_preview_actions_test.dart`: marcador abre Preview y Preview conserva navegación a Detail. |
| B-AC-08 | PASS | Prueba de integración de lista: el POI seleccionado antes de usar el CTA sigue seleccionado después de volver desde Detail; abrir superficies no cambia la sesión GPS. |
| B-AC-09 | PASS | `a01_preview_actions_test.dart` y pruebas de Detail verifican descripción, fuente, atribución y URL existente; no se incorpora navegación externa. |
| B-AC-10 | PASS | Placeholder existente conservado; prueba visual confirma ausencia de `Image`. Offline/lista conserva el mismo snapshot y no genera llamadas a fuente. |
| B-AC-11 | PASS | `ui2_experience_test.dart`: lista, Preview y Detail en viewports 360×640, 360×800, 640×360 y 800×360 con escalas 1× y 2×. |
| B-AC-12 | PASS | Diff restringido a Dart de presentación/mapa, pruebas y evidencia; no hay cambios de backend, API, DB ni dependencias. |

Los estados PASS anteriores corresponden a implementación y pruebas automatizadas locales, no a validación física o TalkBack.

## Validación automatizada

- `dart format` sobre los seis archivos Dart modificados: PASS.
- Cuatro archivos focalizados (`poi_visual_contract_test.dart`, `a01_preview_actions_test.dart`, `a01_b_ui_language_test.dart`, `ui2_experience_test.dart`): **32/32 tests PASS**.
- Test aislado de navegación directa lista → Detail con selección preexistente: **1/1 PASS**.
- `flutter analyze`: PASS, `No issues found!`.
- `git diff --check`: PASS.
- No se ejecutaron la suite completa, build APK, instalación ni pruebas físicas; no eran necesarias para esta tarea de presentación.

## Archivos del cambio

- `mobile/lib/features/discovery/presentation/poi_result_card.dart`
- `mobile/lib/features/map/presentation/base_map_page.dart`
- `mobile/test/features/discovery/presentation/poi_visual_contract_test.dart`
- `mobile/test/features/discovery/presentation/a01_preview_actions_test.dart`
- `mobile/test/features/discovery/presentation/a01_b_ui_language_test.dart`
- `mobile/test/features/discovery/ui2_experience_test.dart`
- Este registro y `DOCUMENTATION_INDEX.md`.

## Pendientes y límites

- Revisión de integración pendiente; no se publica en esta tarea.
- Validación física de las tarjetas en HONOR no autorizada.
- TalkBack permanece sin prueba y diferido.
- Incremento A mantiene sus resultados históricos sin reinterpretación.
- `UI_2_MASTER_CLOSURE = NOT_AUTHORIZED`; `P12_5 = NOT_AUTHORIZED`; `PRODUCTION_READINESS = NOT_DECLARED`.
