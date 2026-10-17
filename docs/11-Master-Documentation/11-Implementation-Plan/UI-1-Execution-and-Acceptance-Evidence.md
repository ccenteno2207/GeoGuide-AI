# UI-1 — Ejecución y evidencia de aceptación

**Contrato:** UI-1 Design System & Exploration Shell, versión congelada y aprobada por autorización humana de esta ejecución.
**Estado de ejecución:** UI-1 implementada, integrada y cerrada con validaciones física y de lector de pantalla pendientes.
**Base:** `f4637e64ad08688ab0188528f0a588076501f6b9`.
**Rama:** `feature/ui1-design-system-exploration-shell`.
**Dispositivo físico:** `DEVICE_VALIDATION_PENDING`; no se declara validación GPS, Driving físico ni operación cartográfica real.

Este registro complementa el contrato congelado sin modificarlo. No autoriza UI-2 ni cambia estados de P9, Driving, GPS, CEFI o validación física.

## Resumen de alcance

La variante de tema y sus tokens se aplican únicamente al subtree de exploración. Se reorganiza la cabecera y la franja de acciones y se presenta el estado sobre una tarjeta legible. Los handlers y la disponibilidad de las acciones existentes se conservaron. La rama de Driving sale antes del wrapper de tema. Preview/Detail continúan tomando el contexto del tema global anterior. No se cambiaron servicios, permisos, manifiestos, dependencias, APIs ni contratos congelados.

## Matriz de aceptación UI1-AC-01 a UI1-AC-10

| Criterio | Estado | Evidencia y alcance de la comprobación |
|---|---|---|
| AC-01 — Tokens, tema y contraste | PASS | `mobile/lib/app/theme/geoguide_theme.dart`; `mobile/test/app/theme/geoguide_theme_test.dart`. Comprueba los tokens aprobados, Material 3, pares primarios/secundarios/superficie/acento y separación del tema global. |
| AC-02 — Mejora perceptible equivalente | PASS | [Comparación visual](UI-1-Visual-Comparison-Evidence.md) y PNG antes/después en `UI-1-Visual-Evidence/`. Mismo fixture, renderer, viewport y escala; revisión visual documenta cabecera, acciones y superficie de estado. Las capturas no simulan tiles reales. |
| AC-03 — Área de mapa y acciones | PASS | `exploration_shell_test.dart`: mide área no ocluida >=50% de SafeArea para el caso inicial; matriz adaptable comprueba targets IconButton >=48×48 y controles de ubicación disponibles. |
| AC-04 — Estado y callbacks en resize | PASS | Prueba de resize mantiene la misma instancia de `BaseMapPage` y el contador del origen offline; el diff conserva el `FlutterMap`, controladores, keys y enlaces de handlers. No se añadió navegación ni efecto de carga por resize. |
| AC-05 — I01 y selección de POI | PASS — regresión de alcance | La suite completa existente, incluidos `i01_selection_test.dart`, `i01_widget_test.dart` e `i01_worker_test.dart`, pasa sin cambios en código I01. El diff no edita selección, worker, codec ni servicios; Preview mantiene contexto y comportamiento globales. No se afirma validación física de POI. |
| AC-06 — GPS/B1/R01 | PASS — regresión de alcance | Las suites GPS/B1/R01 existentes pasan dentro del suite completo; `offline_ui_test.dart` y el caso de resize del shell pasan. Diff de producción sin cambios a ownership, timers, lifecycle o cancelación. No equivale a prueba física GPS. |
| AC-07 — Driving y tema | PASS | La prueba de shell verifica el tema global en Driving y Preview, y el conjunto `offline_ui_test.dart` pasa. `_drivingReduced` toma la rama anterior al tema local. Sin modificación funcional de Driving. |
| AC-08 — Viewports, escala y targets | PASS — automatizado | Ocho combinaciones: 360×640, 360×800, 640×360 y 800×360, escalas 1.0/2.0. Comprueba ausencia de excepción/overflow, FlutterMap, controles etiquetados, escala efectiva y targets. Contraste medido en tests de tema. Revisión física de foco y lector de pantalla no ejecutada. |
| AC-09 — Diff y alcance protegido | PASS | `git diff --check`; auditoría de paths. Cambios de producción limitados al tema y composición de `BaseMapPage`; prueba existente actualizada solo para garantizar visibilidad del control y tamaño de MediaQuery en fixture escalado. Sin cambio a pubspec/lock, nativo, backend o contratos. |
| AC-10 — Validación y APK | PASS | `dart format .`: 75 archivos, 0 cambios; `flutter analyze --no-pub` limpio; `flutter test --no-pub` completo: 183 pruebas pasan; `git diff --check` limpio; APK release y debug generados; `verify_apk_icons.py`: PASS. |

## Comandos y artefactos

- `dart format .` desde `mobile`: PASS, `Formatted 75 files (0 changed)`.
- `flutter analyze --no-pub` desde `mobile`: PASS, `No issues found!` (Flutter 3.47.2 / Dart 3.13.2).
- `flutter test --no-pub` desde `mobile`: PASS, 183 tests.
- `flutter build apk --no-pub` desde `mobile`: PASS, release APK de 59,832,985 bytes, SHA-256 `098EA9549941BD8B57A77E65002B77C36D5A8114568AC849B41DA356EE6F25C7`.
- `flutter build apk --debug --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` desde `mobile`: PASS.
- `python tool/verify_apk_icons.py build/app/outputs/flutter-apk/app-debug.apk` desde `mobile`: PASS; sha256 `15EBF35D135D51E2DA9B782A0307062409EFC3280E522E08DFBAC8FD3352F390`.
- El SDK informó versiones más nuevas disponibles para dependencias fijadas; no se actualizó ni modificó el lockfile.
- Validación en dispositivo: pendiente, no reemplazada por widget tests o APK.

## Límites de evidencia

Las capturas provienen de Flutter Widget Test con tiles HTTP bloqueados, no de un mapa en vivo. Los tests y el build no autorizan ni acreditan cambios a GPS, B1/R01, P9, Driving, CEFI o backend. No se observó permiso nuevo ni cambio de dependencia. La validación visual en dispositivo y lector de pantalla queda fuera de la evidencia automatizada disponible.

## Plan de integración previo al merge (registro histórico)

Completar el build debug y verificación de iconos; auditar diff/status; documentar resultado final; crear commit, publicar rama y PR; revisar checks/auditoría; fusionar normalmente solo si los gates pasan; validar el estado post-merge sobre `main`. La integración no inicia UI-2 y no equivale al cierre formal de una fase distinta.

## Cierre maestro post-merge

Fecha de reconciliación documental: 2026-10-17. La aprobación humana autoriza exclusivamente este cierre y el registro de pendientes; no amplía el alcance de implementación.

### Integración verificada

| Dato | Evidencia |
|---|---|
| Baseline anterior | `f4637e64ad08688ab0188528f0a588076501f6b9` |
| Commit candidato de UI-1 | `78ff94a7e1e14ec5ce1a135a5e29b23db49539c9` |
| Pull request | [PR #83](https://github.com/ccenteno2207/GeoGuide-AI/pull/83), estado `MERGED`, merge normal |
| Commit resultante | `e443c0aa10987e04367dd15a1df259438426c3bc` |
| Estado actual verificado | `main`, `origin/main` y remoto `refs/heads/main` coinciden en `e443c0aa10987e04367dd15a1df259438426c3bc` |

### Validación posterior a la integración

Las validaciones siguientes se ejecutaron sobre el checkout `main` sincronizado en el commit resultante:

- `dart format --output=none --set-exit-if-changed .` desde `mobile`: PASS; 75 archivos, 0 cambios.
- `flutter analyze --no-pub` desde `mobile`: PASS; `No issues found!`.
- `flutter test --no-pub` desde `mobile`: PASS; 183 pruebas, `All tests passed!`.
- `git diff --check`: PASS.

Los APK se construyeron desde el candidato UI-1 `78ff94a` antes del merge; el código móvil resultante fue integrado en `e443c0a`:

- Release: `flutter build apk --no-pub`; PASS; 59,832,985 bytes; SHA-256 `098EA9549941BD8B57A77E65002B77C36D5A8114568AC849B41DA356EE6F25C7`.
- Debug: `flutter build apk --debug --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`; PASS.
- Iconos: `python tool/verify_apk_icons.py build/app/outputs/flutter-apk/app-debug.apk`; PASS; SHA-256 `15EBF35D135D51E2DA9B782A0307062409EFC3280E522E08DFBAC8FD3352F390`.

GitHub no reportó checks configurados para PR #83 (`statusCheckRollup=[]`; `gh pr checks 83` indicó que no había checks reportados). Esto se registra como ausencia de señal CI, no como PASS de CI. La aceptación se apoya en las validaciones locales documentadas arriba.

### Comparación visual y límites

Las capturas antes/después permanecen en `UI-1-Visual-Evidence/` y sus bytes no se modificaron durante este cierre. SHA-256 comprobado:

| Captura | SHA-256 |
|---|---|
| `exploration_before_360x800.png` | `DAA2DE3E91614B19A2447468ED9BCFE1720DCE8A46463B8D956D7C0E93B43C2D` |
| `exploration_after_360x800.png` | `24A877E2128045713B937942FC3B4AB4A51974D21F810A3427DDDDF3E5A3ECEB` |

Ambas imágenes fueron renderizadas por Flutter Widget Test, con el mismo fixture 360×800, DPR 1.0 y escala 1.0; no son fotografías ni capturas de un dispositivo. El harness no carga tiles de red y muestra la cinta de debug. Por tanto, verifican composición del widget, no cartografía en vivo, GPS, Driving en carretera o presentación en hardware. Véase [comparación visual](UI-1-Visual-Comparison-Evidence.md).

La validación física en dispositivo y la revisión con lector de pantalla no se ejecutaron y permanecen `PENDING`. Los APK no se instalaron. El cierre no convierte esas limitaciones en PASS.

### Integridad y preservación

El PR integró los cambios de presentación, pruebas y evidencia descritos en esta matriz. No se modificaron contratos congelados, `pubspec.yaml`/lockfile, código de backend, infraestructura, permisos o recursos nativos. La búsqueda/geocodificación continúa diferida; UI-2 y capacidades de Driving, GPS/B1/R01, CEFI conversacional y ADMIN siguen fuera de autorización.

Se verificó que los worktrees y stashes existentes permanecieran registrados. El checkout principal terminó sin cambios rastreados y conservó tres borradores Rutea como untracked. También se preservaron los archivos locales existentes en `admin0-discovery` (4 documentos), `ui1-contract-preparation` (2 documentos), `ui1-visual-baseline` (directorio untracked de pruebas) e `i01-r01-baseline` (1 prueba untracked). `ui1-design-system` quedó limpio; los stashes existentes no se modificaron.

```ini
UI_1_IMPLEMENTATION = COMPLETED
UI_1_MASTER_CLOSURE = CLOSED_WITH_VALIDATION_PENDING
UI_1_DEVICE_VALIDATION = PENDING
UI_1_SCREEN_READER_VALIDATION = PENDING

UI_2_IMPLEMENTATION = NOT_AUTHORIZED
ADMIN_PORTAL_IMPLEMENTATION = NOT_AUTHORIZED
ADMIN_API_IMPLEMENTATION = NOT_AUTHORIZED
DRIVING_FUNCTIONAL_PACKAGE = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
