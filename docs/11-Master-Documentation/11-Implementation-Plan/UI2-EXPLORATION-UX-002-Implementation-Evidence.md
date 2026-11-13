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
