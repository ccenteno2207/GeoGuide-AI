# UI2-INTEGRATION-AUDIT-001 — Auditoría conjunta de integración

Fecha: 2026-11-12
Rama candidata: `codex/ui2-exploration-ux-002`

## Veredicto

```ini
UI2_INTEGRATION_AUDIT = READY_FOR_PR
UI2_INTEGRATION_PUSH = NOT_AUTHORIZED
UI2_INTEGRATION_PR = NOT_AUTHORIZED
UI2_INTEGRATION_MERGE = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

La rama candidata desciende de `origin/main` y contiene, en orden de dependencia, las tres iniciativas aprobadas. El diff queda en Flutter, pruebas, evidencia y referencias documentales del UI-2. Formato, análisis, pruebas focalizadas y suite Flutter completa pasaron. Las validaciones físicas parciales de dos iniciativas y TalkBack no probado permanecen visibles como limitaciones; no bloquean la revisión del PR porque no hay un fallo de implementación pendiente demostrado ni se solicita cierre maestro.

## Baselines y topología Git

| Referencia | SHA | Relación |
|---|---|---|
| `origin/main` después de `git fetch origin` | `0f114e320043da90d949b79ab0ab4fea5084c66b` | Merge-base de la candidata |
| `codex/ui2-route-ux-001` | `abf4682469afc5f247ee1ebf4a81f3b7367e5e23` | Antecesora de Map/Search y de la candidata |
| `codex/ui2-map-search-ux-001` | `f2bd94db2a00957deb6b68391e647150337b5a8c` | Antecesora de la candidata |
| `codex/ui2-exploration-ux-002` antes de esta auditoría | `995e303e6405e7aa99ee1efe1e20d8150eacbb00` | 15 commits exclusivos respecto de `origin/main` |

El merge-base de `HEAD` y `origin/main` es el propio `origin/main`. Las dos ramas dependientes son ancestros de la candidata; no faltan commits de esas ramas y la candidata no requiere un merge de contenido contra el baseline verificado. El cambio efectivo respecto de `origin/main` comprende 23 archivos: código Flutter, tests, el registro de decisiones, evidencias e índice documental. No se modificó `main` local ni se consultó o alteró otro worktree.

Map/Search y Exploration modifican algunos de los mismos widgets (`base_map_page.dart` y `destination_search_sheet.dart`) en secuencia dependiente. La candidata contiene el resultado combinado de esa secuencia y no agrega una segunda implementación paralela; no queda conflicto textual ni funcional demostrado por Git o por las pruebas.

## Matriz de cobertura

| Iniciativa | Código y comportamiento comprobados | Evidencia/estado vigente | Resultado |
|---|---|---|---|
| UI2-ROUTE-UX-001 | Origen manual prioritario; en su ausencia, GPS puntual válido con permiso existente; destino buscado no calcula automáticamente; «Ver ruta» llama PlanRoute y luego Route Discovery; resumen, geometría y POIs; revisiones contra respuesta obsoleta y doble cálculo. | [Evidencia UI2-ROUTE-UX-001](UI2-ROUTE-UX-001-Implementation-Evidence.md): H1/H2/H3 PASS; físico PARTIAL. | Contenido presente y automatización de rama aprobada. |
| UI2-MAP-SEARCH-UX-001 | Centrado puntual inicial mediante `requestPermission: false`; interacción manual inhibe el centrado tardío; sugerencias con debounce de 300 ms, estados de error/vacío/offline y selección sin cálculo automático. | [Evidencia UI2-MAP-SEARCH-UX-001](UI2-MAP-SEARCH-UX-001-Implementation-Evidence.md): implementación/analyze/tests PASS; físico PARTIAL; merge no autorizado. | Contenido presente; limitación física preservada. |
| UI2-EXPLORATION-UX-002 | Buscador opaco, fila seleccionable sin acción redundante, acción contextual, layout adaptable, política de calidad GPS y ausencia del aviso persistente para una posición aproximada utilizable. | [Evidencia UI2-EXPLORATION-UX-002](UI2-EXPLORATION-UX-002-Implementation-Evidence.md): implementación PASS; físico PASS en la evidencia final UX-01–UX-05; TalkBack NOT_TESTED. | Contenido presente; la observación física final no certifica TalkBack ni cierra UI-2. |

### Revisión de dependencias y protecciones

- El flujo de destino buscado prepara el origen sin ejecutar PlanRoute. «Ver ruta» es la acción explícita; el control permanece deshabilitado mientras se resuelve origen o se calcula.
- Un origen manual existente se conserva. Si falta, la ubicación puntual usa permiso ya concedido y la política de edad/precisión; ante ubicación no utilizable se ofrece elegir el origen en el mapa.
- Route Planning descarta resultados cuyo destino/origen ya cambió. La consulta de origen y búsqueda también verifican revisión/destino; el botón impide cálculo concurrente.
- Route Discovery se ejecuta tras PlanRoute satisfactorio y presenta geometría, resumen y POIs por el flujo existente.
- El centrado inicial intenta una sola consulta puntual y no desplaza la cámara después de interacción manual. Las sugerencias se retrasan 300 ms y respuestas de una consulta anterior se ignoran.
- Los streams existentes se limitan al seguimiento activado explícitamente o a la reanudación de una sesión previa. La iniciativa no agrega suscripción inicial, servicio background, permiso ni cambio a Driving.

## Auditoría de alcance y contratos

- El diff no contiene Backend/API, migraciones/DB, infraestructura, dependencias, configuración sensible, `AndroidManifest.xml`, permisos, Driving ni contrato P9.
- El único registro normativo modificado es la adenda aprobada de UX-01–UX-05 en `UI-2-Decision-Register.md`; los contratos congelados no se editaron. La decisión MAP-002 de centrado inicial permanece en su alcance ya aprobado; esta auditoría no la amplía.
- Los estados históricos UI2-MAP-SEARCH-UX-001 físico PARTIAL y UI2-ROUTE-UX-001 físico PARTIAL se conservan. UX-002 tiene checkpoints anteriores PENDING/PARTIAL, seguidos por un resultado físico vigente PASS al completar la observación de cámara y controles. TalkBack sigue NOT_TESTED; la documentación de AC-12 lo clasifica como evidencia física separada y no se afirma un PASS del lector ni accesibilidad integral.
- La secuencia ADB de Atrás durante una repetición inconclusa de búsqueda se registra como inconclusa: el proceso permaneció activo y no se detectó crash fatal. No se atribuye un defecto reproducible.

## Validaciones

| Comando | Resultado |
|---|---|
| `git fetch origin` | PASS; `origin/main` quedó en `0f114e320043da90d949b79ab0ab4fea5084c66b`. |
| `git status --short`, rama, HEAD, merge-base y worktrees | Candidata limpia antes de editar esta auditoría; rama y HEAD coincidieron con lo reportado; merge-base igual a `origin/main`. |
| `git merge-base --is-ancestor codex/ui2-route-ux-001 HEAD` | PASS. |
| `git merge-base --is-ancestor codex/ui2-map-search-ux-001 HEAD` | PASS. |
| `git diff --check origin/main...HEAD` | PASS. |
| `dart format --output=none --set-exit-if-changed lib test` | PASS; 99 archivos revisados, 0 modificados. |
| `flutter analyze` | PASS; sin hallazgos. |
| Suite focalizada de búsqueda/mapa/GPS/rutas/B1/R01/UI | PASS, 101/101. |
| `flutter test --reporter compact` | PASS, 284 PASS, 1 SKIP, 0 FAIL. |
| Escaneo de patrones de secreto en diff | Sin coincidencias. |
| `git diff --name-only origin/main...HEAD` y revisión de alcance | PASS; solo los 23 archivos listados en el diff funcional/documental de las iniciativas. |

No se reconstruyó APK: no hubo cambios de código durante esta auditoría y cada artefacto tiene su evidencia propia. No se repitieron pruebas físicas.

## Riesgos y límites

1. `UI2_MAP_SEARCH_UX_001_PHYSICAL = PARTIAL` y `UI2_ROUTE_UX_001_PHYSICAL = PARTIAL`; integrar el código no eleva esos estados.
2. `TALKBACK = NOT_TESTED`; no se declara validación de lector de pantalla ni certificación completa de accesibilidad.
3. La observación ADB posterior a ruta confirmó resumen y marcadores, pero la repetición de abrir la hoja de búsqueda con toque por coordenadas no produjo una observación concluyente. El propietario sí confirmó la selección anterior del destino de catálogo y la aparición de «Ver ruta» sin cálculo automático.
4. Los estados P12/UI-2 globales no cambian por este dictamen.

## Recomendación de integración

Crear un único PR desde `codex/ui2-exploration-ux-002` hacia `main`, dado que la rama ya contiene las dos dependencias y el diff conjunto no deja cambios exclusivos por integrar desde las ramas ancestro. En el PR, conservar por separado los estados físicos parciales y `TALKBACK = NOT_TESTED`, ejecutar los controles remotos configurados y no solicitar cierre maestro UI-2. Esta recomendación no autoriza publicar, crear PR ni fusionar.

## Publicación autorizada — UI2-INTEGRATION-PR-001

- PR [#101](https://github.com/ccenteno2207/GeoGuide-AI/pull/101), título `UI2: integrate route, map search, and exploration UX`.
- Estado al verificar: `OPEN`, no draft; base `main`, cabeza `codex/ui2-exploration-ux-002`.
- En la creación: cabeza `46165800843e0a71c2bd7ce295be611a8972a6a7`, base `0f114e320043da90d949b79ab0ab4fea5084c66b`, 16 commits, 24 archivos.
- GitHub reportó `mergeable = MERGEABLE` y `mergeStateStatus = CLEAN`.
- `gh pr checks 101` respondió `no checks reported on the 'codex/ui2-exploration-ux-002' branch`; esto se registra como `NO_CHECKS_REPORTED`, no como validación CI PASS. No había decisión de revisión registrada al consultar.
- No se ejecutó merge. La rama y PR permanecen abiertos a revisión humana.

```ini
UI2_INTEGRATION_PR = OPEN
UI2_INTEGRATION_MERGE = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

## Validación de APK e instalación HONOR — PR #101

Fecha: 2026-11-12. Fuente: `b68761c731f16a0c060bd584c5192c5dd570f9ef`.

| Comprobación | Resultado y evidencia |
|---|---|
| APK debug HTTPS | Generada con `BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`; `mobile/build/app/outputs/flutter-apk/app-debug.apk`, 168,188,104 bytes, SHA-256 `EFB4FD81EDE82C69DDF44661BEB39358B2A2BD752D0A06AA16467599556B7BF5`. El endpoint HTTPS está incluido en el kernel Flutter del APK. |
| Identidad/firma | `com.geoguideai.geoguide_ai`, versión `1.0.0`, `versionCode=1`, target SDK 36. El certificado SHA-256 `894975b5bc6751da09b3d69923d4ae399192470d86c107106f65f6cb8d7eab7e` coincide con el APK instalado antes de la actualización. |
| Dispositivo/instalación | HONOR LLY-NX3, Android API 36; `adb install -r` devolvió `Success`. No se desinstaló ni borró datos. Rutea quedó en primer plano en `MainActivity`; no se observó crash en la consulta de logcat realizada. |
| ADB reverse | `adb reverse --list` vacío; la validación no dependió de un reverse ni túnel temporal. |
| Inicio visual | Propietario confirmó mapa estable, atribución OSM y controles visibles, sin panel técnico persistente ni solicitud nueva de permisos. |
| Búsqueda/selección | Al escribir `Obra` apareció la sugerencia de Obrajillo. Tras seleccionarla, se mostró el destino y «Ver ruta» sin cálculo automático. |
| Cálculo explícito y POIs | El propietario pulsó «Ver ruta» y observó `Ruta: 97.7 km · 104 min`; confirmó la geometría de ruta y marcadores visibles, cinco POIs en «Ver lista», apertura de Preview y Detail, información y fuente MINCETUR en Detail, y retorno al mapa sin error. La línea compacta de resumen no presenta conteo de lugares ni estado Online; no se infiere defecto por esa ausencia. |
| Cámara y Driving | Tras desplazar manualmente el mapa y esperar aproximadamente 60 segundos, la cámara permaneció en la zona elegida. Driving siguió cerrado y no se abrió automáticamente. |

```ini
UI2_PR_101_PREMERGE = PASS
UI2_PR_101_STATUS = OPEN
UI2_PR_101_MERGE = NOT_AUTHORIZED
UI2_APK_BUILD = PASS
UI2_HONOR_INSTALL = PASS
UI2_HONOR_PHYSICAL = PARTIAL
TALKBACK = NOT_TESTED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

Pendiente de esta sesión física: comprobar la acción puntual de ubicación sin conceder permisos nuevos. No se afirma la prueba de TalkBack. La ausencia de checks remotos configurados y de revisiones registradas se mantiene como se documentó arriba; no equivale a CI PASS ni a aprobación de merge.
