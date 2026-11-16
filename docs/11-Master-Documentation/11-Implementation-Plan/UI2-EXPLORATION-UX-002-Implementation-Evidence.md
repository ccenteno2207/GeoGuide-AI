# UI2-EXPLORATION-UX-002 — Implementation Evidence

Date: 2026-11-12

Branch: `codex/ui2-exploration-ux-002`
Implementation baseline: `f2bd94db2a00957deb6b68391e647150337b5a8c`

## Scope delivered

This work implements the owner-approved exploration refinements UX-01 through UX-05. It inherits UI2-MAP-SEARCH-UX-001 and UI2-ROUTE-UX-001 from the baseline branch. It does not modify backend/API/database/infrastructure, Android permissions, continuous/background location, or Driving behavior and contracts.

- UX-01: destination search sheet uses an opaque, themed surface with readable contrast and an accessible filled search field.
- UX-02: each destination result row is selectable; the redundant trailing action and technical provenance are omitted from the list. Only geographic context supplied by the existing result DTO is displayed.
- UX-03: the exploration panel reports planning/discovery progress and route errors; «Ver ruta» appears for a pending destination with usable origin, disappears after the current route is calculated, and returns when endpoint state changes. Existing PlanRoute → Route Discovery flow and stale-request guards are retained.
- UX-04: the search action takes the available width when no route action is pending; at narrow widths the route action is placed below rather than compressing the search field.
- UX-05: one-shot location results are classified using actual provider accuracy and sample age. Precise: accuracy ≤50 m and age ≤10 s. Approximate: accuracy ≤100 m and age ≤30 s. Invalid, future, stale, unknown-accuracy, or unavailable results are not presented as a usable current fix. Approximate state is described from provider data; these software thresholds do not guarantee street-level physical accuracy.

One-shot requests continue to use previously granted permission only (`requestPermission: false`). The request has an eight-second timeout. No new permission, location stream, recurring recenter, background tracking, or Driving/GPS Follow behavior was introduced. Map interaction before the initial response still prevents camera recentering.

## Changed implementation and tests

- `mobile/lib/features/destination_search/presentation/destination_search_sheet.dart`
- `mobile/lib/features/location/application/current_location_fix_policy.dart`
- `mobile/lib/features/location/infrastructure/geolocator_location_repository.dart`
- `mobile/lib/features/map/presentation/base_map_page.dart`
- `mobile/lib/features/map/presentation/rutea_location_marker.dart`
- `mobile/test/features/destination_search/destination_search_test.dart`
- `mobile/test/features/location/current_location_fix_policy_test.dart`
- `mobile/test/features/location/gps_camera_widget_test.dart`
- `mobile/test/features/map/ui231_system_insets_test.dart`
- `mobile/test/widget_test.dart`

The full Flutter test run initially exposed nine UI status visibility failures in B1/R01 regressions: the new GPS quality message could take precedence over an active tracking/session status. The map panel now gives active operational status precedence and shows precision messaging during normal exploration. The focused B1 and R01 tests passed after that correction.

## Validation

- Focal exploration/location/search/insets/widget suite: **64/64 PASS** before the final operational-status precedence correction.
- B1 and R01 tracking regression tests after that correction: **22/22 PASS**.
- Complete Flutter suite after the correction: **284 PASS, 1 skipped, 0 failed**.
- `dart format --output=none --set-exit-if-changed lib test`: PASS; 99 files checked, 0 changed.
- `flutter analyze`: PASS; no issues found.
- `git diff --check`: PASS.
- Changed documentation/index files: strict UTF-8 and local Markdown target checks PASS.
- Scope review: no Android manifest/permission, `pubspec`, backend, API, DB, infrastructure, or Driving-specific source/test changes. No secret-like assignment was found in the patch.
- Debug APK built with `--dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`: `mobile/build/app/outputs/flutter-apk/app-debug.apk`; 168,188,104 bytes; SHA-256 `92D408E68F3799475DD03CD7140D00383D6DCF308CC18C415081FB1E4CBA4CE2`.
- The APK is configured with the existing HTTPS endpoint; it was not installed. No ADB reverse or temporary tunnel was used.

Physical HONOR validation has not been performed for this task. APK installation is not authorized by this task.

```ini
UI2_EXPLORATION_UX_002_IMPLEMENTATION = PASS
UI2_EXPLORATION_UX_002_PHYSICAL = PENDING
UI2_EXPLORATION_UX_002_MERGE = NOT_AUTHORIZED
UI2_MAP_SEARCH_UX_001_PHYSICAL = PARTIAL
UI2_ROUTE_UX_001_PHYSICAL = PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

## Physical validation — HONOR LLY-NX3 (2026-11-12)

### Installation preflight and result

- Device serial `AM4L6R5617005821`, model `LLY-NX3`, Android API 36; ADB state `device` and interactive screen confirmed before installation.
- Candidate APK SHA-256 `92D408E68F3799475DD03CD7140D00383D6DCF308CC18C415081FB1E4CBA4CE2`, 168,188,104 bytes. Package `com.geoguideai.geoguide_ai`, versionCode 1, versionName 1.0.0, label `Rutea`.
- Candidate and installed certificate SHA-256 both `894975b5bc6751da09b3d69923d4ae399192470d86c107106f65f6cb8d7eab7e`. `/data` had 103 GB available.
- `adb install -r` returned `Success`. `firstInstallTime` remained 2026-10-05 20:08:37; `lastUpdateTime` advanced to 2026-11-12 18:51:51. No uninstall, data clear, permission change, or ADB reverse was used. The application launched; the inspected recent AndroidRuntime log contained no fatal crash.

### Physical observations

| Check | State | Evidence / limitation |
|---|---|---|
| UX-PHYS-01 — opaque search | PASS | Initial view showed a solid white, high-contrast full-width search surface, unobstructed top controls and visible OSM attribution. |
| UX-PHYS-02 — compact incremental results | PASS (ADB interaction) | Entering `Obra` produced `Plaza de Armas de Obrajillo` without pressing the search action. The row was a single accessible clickable surface with no trailing «Seleccionar» control. A tap away from the result title selected the destination; no route was calculated until «Ver ruta» was tapped. Owner's separate visual/tactile observation is pending. |
| UX-PHYS-03 — contextual route action | PASS | Selecting a destination showed «Ver ruta» and `Origen: Tu ubicación aproximada (±100 m)`. Explicit action produced `Ruta: 97.7 km · 104 min` and POI markers. Selecting `Canta` cleared the prior summary and restored «Ver ruta»; recalculation produced `Ruta: 98.4 km · 101 min` with POI markers. |
| UX-PHYS-04 — responsive search width | PASS (observed bounds) | With a pending destination, search and «Ver ruta» occupied full-width stacked rows; after calculation the search returned to full width. OSM attribution remained visible. No overlay was observed. |
| UX-PHYS-05 — GPS quality | PARTIAL | On opening, the map centered on the available one-shot fix and showed `Ubicación aproximada (±100 m)`. No coordinates were recorded. No permission prompt appeared and the UI still offered «Activar seguimiento de ubicación». Manual map-pan retention and absence of repeated recentering/continuous GPS have not yet been physically verified. |
| Brief POI regression | PARTIAL | The list reported `5 de 5 lugares`; Plaza de Armas de Canta Preview and Detail opened, and Detail showed category, distance and source URL. No external URL was opened. A category filter was toggled, but the visible result count remained five; category-specific reduction/restoration has not been confirmed. Driving was not entered. |

The initial diagnostic screenshot was not added to the repository because it included personal map context. Its on-device copy was removed. An attempt to remove the local temporary copy at `%TEMP%\rutea_ux002_initial.png` was rejected by the automatic approval review (`blocked by policy`); it remains in the temporary directory and was not shared as evidence or committed.

```ini
UI2_EXPLORATION_UX_002_IMPLEMENTATION = PASS
UI2_EXPLORATION_UX_002_PHYSICAL = PARTIAL
UI2_EXPLORATION_UX_002_MERGE = NOT_AUTHORIZED
UI2_MAP_SEARCH_UX_001_PHYSICAL = PARTIAL
UI2_ROUTE_UX_001_PHYSICAL = PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

### Owner feedback and correction — 2026-11-12

After testing, the owner considered the visible `Ubicación aproximada (±100 m)` message unnecessary. The UI was adjusted so a usable approximate fix no longer produces a persistent visible status banner. Its accuracy halo and accessible marker semantics remain; the effective route-origin label remains explicit, and a non-usable/untrusted fix still receives a contextual warning.

- Focused GPS/location policy tests after the change: **9/9 PASS**.
- B1/R01 regression tests: **22/22 PASS**.
- `flutter analyze`: PASS; no issues found.
- Rebuilt debug APK with the existing HTTPS endpoint: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, 168,188,104 bytes, SHA-256 `EFB4FD81EDE82C69DDF44661BEB39358B2A2BD752D0A06AA16467599556B7BF5`.
- Updated HONOR via `adb install -r`: `Success`; package/signature unchanged and `firstInstallTime` preserved. No uninstall, data clear, permission change or ADB reverse.
- Owner returned Rutea to the foreground after the update. The accessible UI hierarchy contains the marker description `Ubicación aproximada, precisión estimada ±100 metros`, but no persistent visible `Ubicación aproximada (±100 m)` status banner was present. This confirms banner removal in the installed UI; it is not a physical TalkBack reading test.
- At this checkpoint UX-PHYS-05 remained PARTIAL pending a foreground camera observation; the later owner observation is recorded below.

### Final camera, GPS and accessibility verification — 2026-11-12

- Physical manual pan/recentering: **PASS for the observed interval**. The owner reported manually moving the map and, after waiting one minute, it remained at the chosen area without returning to GPS. This also records no recentering during that interval; it does not prove behavior under every session state.
- Search/route controls: **PASS for the focused check**. The owner confirmed the catalog options appeared and selected `Plaza de Armas de Obrajillo`; «Ver ruta» appeared on return to the map without calculating automatically. The UI tree showed an enabled «Ver ruta» action with `Origen: Tu ubicación actual`. One explicit ADB tap on that action produced `Ruta: 97.7 km · 104 min` and POI preview markers. The map summary, search/category/list controls, OSM attribution and `Entrar en modo conducción` remained present; Driving was not started automatically.
- A later attempt to reopen search by coordinate tap did not yield a captured search sheet; the subsequent Back key returned to the HONOR launcher. Rutea's process remained alive, no fatal AndroidRuntime error was found, and the activity was brought back to foreground without clearing state. This attempt is inconclusive and is not counted as a search failure.
- Focused Flutter regression: `flutter test test/features/location/gps_camera_widget_test.dart --reporter expanded` — **6/6 PASS**. This covers the one-shot startup fix without subscribing to tracking, denied/unavailable GPS, approximate marker semantics without a status banner, an untrusted fix, a manual map gesture winning over a late GPS response, and explicit camera-follow pause/resume behavior.
- Source review: `BaseMapPage._scheduleInitialLocation` guards the startup attempt and `_loadInitialLocation` calls the one-shot request with `requestPermission: false`; `_initialCameraHasUserInteraction` prevents a late startup response from moving the camera after a user gesture. The stream subscription is invoked by the existing explicit follow control (`_toggleFollowLocation`) and by resuming a previously active follow session; it is not started by normal initial exploration. The stream and follow implementation predate this UX-002 branch (introduced in commit `11157954`).
- Scope review: no manifest or native Android permission/service changes exist in this branch relative to its merge base. Existing foreground location service / follow behavior remains a separate, user-activated route-session capability; this review does not characterize that existing feature as absent.
- Accessibility: `TALKBACK = NOT_TESTED`. The Flutter widget test verifies marker semantics, but no physical TalkBack announcement/repetition check was completed in this session.

```ini
UX_PHYS_05 = PASS
UI2_EXPLORATION_UX_002_PHYSICAL = PASS
TALKBACK = NOT_TESTED
```

TalkBack remains separate evidence under UI2-AC-12; its physical reading test is not claimed by this UX-01–UX-05 result. No overall accessibility certification or UI-2 master closure is implied.

## UI2-PHYSICAL-VALIDATION-001 — HONOR build, instalación y checkpoint parcial (2026-11-16)

### Baseline y artefacto

- `origin/main` y baseline de validación: `25493eb55e659b90bb0e5321d953c28b07cf7c81` (PR #103 integrado).
- Commit correctivo contenido: `eda5119aef1e18200818e39f757db785aaf19134`.
- Build ejecutado desde ese baseline en worktree aislado `codex/ui2-physical-validation-001`.
- Comando: `flutter build apk --debug --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` — PASS.
- APK: `mobile/build/app/outputs/flutter-apk/app-debug.apk`; 168,188,512 bytes; SHA-256 `A7DC8D0033143E9C0558B88D50214EF34DA0FA15F42B14739A8D4057D6597DBA`.
- Package `com.geoguideai.geoguide_ai`; versionCode `1`, versionName `1.0.0`, target SDK 36, etiqueta `Rutea`.
- Certificado APK SHA-256 `894975b5bc6751da09b3d69923d4ae399192470d86c107106f65f6cb8d7eab7e`, igual al certificado de la APK instalada antes de actualizar.

### Preflight e instalación

- HONOR LLY-NX3, modelo `LLY-NX3`, serial `AM4L6R5617005821`, Android API 36; ADB `device`, pantalla despierta y `mDreamingLockscreen=false`.
- Paquete instalado antes de actualizar: versión 1.0.0; espacio `/data` disponible 109,464,004 KiB. No había sesión Rutea/GPS/Driving/voz que preservar, según confirmación del propietario.
- `adb install -r`: `Success`. `firstInstallTime` permaneció `2026-10-05 20:08:37`; `lastUpdateTime` avanzó a `2026-11-16 17:47:39`. No se ejecutó uninstall, `pm clear`, ni cambio de permisos.
- Rutea se abrió en primer plano. `adb reverse --list` no reportó reglas. No se encontró `FATAL EXCEPTION` en las últimas 1,500 líneas de logcat consultadas.

### Observación física recibida

| Control | Estado | Evidencia / límite |
|---|---|---|
| PV-01 — Inicio y mapa | PARTIAL | El propietario observó mapa visible sin errores, atribución `© OpenStreetMap contributors` visible y ninguna nueva solicitud de permisos; TalkBack estaba apagado. Luego confirmó que los controles flotantes responden. La presencia/ausencia de panel técnico persistente no quedó confirmada para esta instalación. Logcat consultado sin crash fatal reciente. |
| PV-02 — Búsqueda turística | PASS | El propietario buscó `Obra`; apareció Plaza de Armas de Obrajillo, seleccionó la sugerencia y volvió al mapa con destino marcado y «Ver ruta» visible, sin cálculo automático. Reabrió la búsqueda, leyó el título/campo, la cerró con Atrás y confirmó que el destino permanecía marcado. Mientras la superficie de búsqueda está abierta queda delante del contenido previo y bloquea controles subyacentes hasta cerrarla; la observación no indica recorte ni bloqueo después del cierre. |
| PV-03 — Cálculo explícito | PARTIAL | El propietario pulsó «Ver ruta»; no percibió indicador de carga ni apareció error. El resumen visible fue `Ruta: 97.7 km - 104 min`; reportó cinco iconos POI en el mapa y que «Ver ruta» desapareció tras el cálculo. Pendiente confirmar la línea geométrica, conteo/contenido en «Ver lista» y la prueba de pulsación repetida; no se forzó error. |
| PV-04 — Respuestas obsoletas PR #103 | NOT_TESTED físicamente | La protección y regresiones deterministas están cubiertas en automatización integrada por PR #103; no se provocó una carrera física en esta sesión. |
| PV-05 — GPS puntual | NOT_TESTED | Pendiente observar ubicación inicial, control puntual, gesto manual y ausencia de seguimiento nuevo sin registrar coordenadas. |
| PV-06 — POIs | NOT_TESTED | Pendiente lista, Preview, Detail, procedencia disponible y retorno. |
| PV-07 — Driving | NOT_TESTED | Solo se comprobará que no se active automáticamente y que no haya regresión evidente; no se amplía P9. |
| PV-08 — UX general | NOT_TESTED | Pendiente observación de paneles, teclado, legibilidad, controles y navegación en HONOR. |

TalkBack no se probó por decisión del propietario. El aplazamiento es deuda técnica de accesibilidad y no bloquea esta validación funcional; no se declara accesibilidad integral PASS.

```ini
UI2_HONOR_BUILD = PASS
UI2_HONOR_INSTALL = PASS
UI2_PHYSICAL_VALIDATION = PARTIAL
UI2_FUNCTIONAL_REGRESSION = PARTIAL
UI2_PR103_PHYSICAL = NOT_TESTED
TALKBACK = NOT_TESTED
TALKBACK_REMEDIATION = DEFERRED_TECH_DEBT
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
