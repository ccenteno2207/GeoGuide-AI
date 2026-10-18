# UI-2.1 — Ejecución local y evidencia de aceptación

Fecha: 2026-10-18. **Veredicto: `UI_2_1_IMPLEMENTATION = READY_FOR_REVIEW`.**

## Autoridad, baseline y aislamiento

Autorización humana expresa: «UI-2.1 IMPLEMENTATION — CONTINUE_BY_DEFAULT».
La autorización es posterior al freeze y a la integración documental; habilita
implementación, validación y commits locales, sin push, PR, merge ni dispositivo.
Los cinco documentos congelados UI-2 conservan íntegramente su contenido y sus
estados históricos; este registro complementa su ejecución, no modifica el contrato.

- Base efectiva verificada mediante fetch: `597950decddecef38dd4f6c44595b807a4087f14`.
- PR contractual [#85](https://github.com/ccenteno2207/GeoGuide-AI/pull/85): `MERGED`, mismo SHA de integración.
- Sin avance remoto posterior al crear el worktree.
- Rama local: `feat/ui2-map-search-poi-experience`.
- Worktree: `D:\Codex\worktrees\GeoGuide-AI\ui2-implementation`.
- Checkout principal preservado en `e443c0aa10987e04367dd15a1df259438426c3bc`, con los tres borradores UI-0 sin seguimiento.
- Trabajo local; no cierre maestro, autorización de publicación ni Production Readiness.

Se leyeron AGENTS, contexto, roadmap, índice, guía de ejecución, Entrega 04.6,
ADR móviles aplicables, P8/P9, evidencia UI-0/UI-1, I01/GPS/B1/R01/CEFI y los cinco
documentos UI-2. Las restricciones de Driving y las capas actuales se preservan.

## Implementación y decisiones técnicas dentro del contrato

`BaseMapPage` conserva controladores, handlers, selección de extremos y cámara.
Con la lista abierta reserva espacios separados para mapa y resultados: lado a lado
en horizontal, mapa arriba y lista abajo en vertical. La lista ocupa 55 % del cuerpo
en vertical. No se añaden movimientos de cámara. La atribución preexistente se muestra
en una franja propia fuera de la cartografía, con texto escalable de 12 sp.
Al escribir con teclado, se compacta temporalmente el título y se conserva la franja
de acciones; el panel aprovecha la altura disponible. El cierre de lista sigue fijo.

`PoiResultCard` presenta nombre, categoría legible, distancia exacta al trazado y
descripción/procedencia significativas del DTO. Una categoría desconocida se presenta
como «Lugar de interés», sin exponer el código. Las tarjetas conservan placeholder
96×72 dp; con texto grande o ancho reducido, los datos pasan debajo para evitar una
columna estrecha. Preview/Detail son desplazables y reservan placeholder 16:9, ancho
máximo 320 dp. No se incorpora foto, URL de imagen ni asset de prueba al producto.

`PoiResultFilter` contiene únicamente estado efímero de presentación. Deriva el
subconjunto por nombre sin mutar snapshot, query backend, ranking ni selección.
El mismo subconjunto alimenta marcadores y lista. El texto es «Buscar en estos
resultados» y el vacío exacto es «No hay coincidencias en estos resultados».

Cambiar extremos por mapa sigue ocultando los POIs anteriores mientras se prepara
otra ruta. La derivación local respeta esa limpieza preexistente del controlador,
sin reutilizar visualmente los POIs del snapshot anterior. La prueba usa el gesto
real y espera la ventana de toque doble del mapa.

La normalización usa descomposición canónica Unicode 17, eliminación de marcas,
trim/colapso de espacios y comparación por subcadena en minúsculas. Hangul se descompone
algorítmicamente; los demás datos canónicos están en un archivo Dart con procedencia,
hash y licencia Unicode. No hay dependencia nueva. La comprobación independiente
usa [NormalizationTest.txt](https://www.unicode.org/Public/17.0.0/ucd/NormalizationTest.txt)
y [UnicodeData.txt](https://www.unicode.org/Public/17.0.0/ucd/UnicodeData.txt), descargados
solo por una herramienta de desarrollo, nunca por la aplicación.

La consulta sobrevive Preview/Detail y alternancia mapa/lista dentro de la sesión.
Se limpia al sustituir identidad del snapshot, vencer su elegibilidad, entrar en
Driving o destruir Exploración. Una revisión invalida callbacks anteriores; no se
encolan ediciones para después de Driving. El timer de consulta se cancela al salir
de Exploración y no añade trabajo a Driving.

### Elegibilidad online y P9 intacto

La inspección y prueba de frontera confirmó que `OfflineDiscovery.revalidate`
preserva el objeto en estado online y aplica su expulsión existente al estado cached.
No se cambia esta política, ni TTL, codec, store, esquema o consentimiento.
La nueva presentación comprueba `RouteSnapshot.eligible` para mostrar resultados y
buscador. Si un objeto online deja de ser elegible, limpia la consulta, oculta POIs y
declara «Resultados no disponibles. Reintenta para consultar datos nuevos», con el
handler de reintento existente. El objeto online permanece intacto y no se consulta
la red automáticamente. La prueba llega a la frontera antes de bombear el timer.

## Checkpoints

Precondiciones comunes: contrato UI-2 aprobado/congelado, autorización humana UI-2.1,
baseline compatible y worktree nuevo limpio. Alcance: presentación Flutter, filtro
local, pruebas, builds y evidencia. Fuera: backend, almacenamiento, permisos,
dependencias, GPS/Driving/voz funcionales, media publicada y ADMIN. VM/Docker/HTTP
real y dispositivo: N/A, fuera de esta autorización.

| ID | Objetivo y criterio de salida | Evidencia | Estado |
| --- | --- | --- | --- |
| CP1 | Shell, mapa y lista equivalentes, ruta no ocluida por panel y cámara preservada | Layout/geometry/context tests y renderer; handlers reutilizados | `COMPLETED` |
| CP2 | Tarjetas, fichas y placeholder accesibles; campos presentes/ausentes | Tests de preview/detail/card y revisión PNG | `COMPLETED` |
| CP3 | Filtro local, identidad/TTL/salida y cero llamadas al escribir | Tests unitarios/integración, callbacks antiguos y conformidad Unicode | `COMPLETED` |
| CP4 | Escalas, tamaños, semantics, estados y teclado horizontal | Matriz 4×2, guidelines y pruebas de teclado vertical/horizontal y teardown | `COMPLETED` |
| CP5 | Suite completa, APK, auditorías y reporte local | Suite completa, builds, logs y auditorías PASS; commits locales | `COMPLETED` |

Las primeras pasadas encontraron selectores de scroll ambiguos, scroll de distancia
fija insuficiente para tarjetas nuevas, expectativa de código crudo, overflow con
teclado horizontal y solapamiento visual de ruta. Se corrigieron dentro de UI-2,
manteniendo las aserciones de identidad, cierre, selección, estados y no regresión.
Los PNG iniciales con Ahem fueron reemplazados por capturas con fuentes del SDK.

## Matriz UI2-AC-01 a UI2-AC-14

Resultados finales comprobados sobre la implementación local. `PASS_AUTOMATED` no
equivale a validación física ni aprobación de integración. TalkBack permanece pendiente.

| Criterio | Cobertura y evidencia | Resultado final |
| --- | --- | --- |
| UI2-AC-01 | Mapa/ruta; espacios no solapados; geometría del fixture dentro del mapa en ocho combinaciones | `PASS_AUTOMATED` |
| UI2-AC-02 | Mismos IDs y subconjunto en marcadores/lista; Preview del ID correcto | `PASS_AUTOMATED` |
| UI2-AC-03 | Categorías actuales; suite existente de sheet/controller/mapper, Aplicar/Cancelar/Reset | `PASS_AUTOMATED` |
| UI2-AC-04 | DTO existente, categoría desconocida legible, campos nulos/vacíos y nombres largos | `PASS_AUTOMATED` |
| UI2-AC-05 | «A X m del trazado»; distancia inválida oculta, sin score/routeProgress/códigos | `PASS_AUTOMATED` |
| UI2-AC-06 | Preview/Detail conserva snapshot, filtros, query y center/zoom | `PASS_AUTOMATED` |
| UI2-AC-07 | Suites I01 selection/widget/worker; elección explícita y freeze B1 conservados | `PASS_AUTOMATED` |
| UI2-AC-08 | Unicode, nombre/subcadena, orden, cero llamadas, limpieza y callbacks obsoletos | `PASS_AUTOMATED` |
| UI2-AC-09 | P9 cache/UI, frontera TTL/5 MiB, vacío/error/retry, presentación no elegible | `PASS_AUTOMATED` |
| UI2-AC-10 | Placeholder, semantics, opcionales y auditoría de assets/APK | `PASS_AUTOMATED` |
| UI2-AC-11 | Regresión GPS/B1/R01/CEFI/Driving y diff de paths/métodos protegidos | `PASS_AUTOMATED` |
| UI2-AC-12 | Guidelines de contraste/targets/etiquetas, lista equivalente; TalkBack separado | `PASS_AUTOMATED` |
| UI2-AC-13 | 360×640, 360×800, 640×360, 800×360; texto 1.0/2.0 y teclado | `PASS_AUTOMATED` |
| UI2-AC-14 | Format, analyze, suite completa, APK debug/release, auditoría de alcance/whitespace | `PASS_AUTOMATED` |

## Validación integral y artefactos

**SDK comprobado:** Flutter 3.47.2 stable / Dart 3.13.2; [metadata](UI-2.1-Validation-Logs/sdk.json).

| Comando / comprobación local | Resultado real | Evidencia |
| --- | --- | --- |
| `flutter pub get` | PASS; lockfile sin cambios | [Salida](UI-2.1-Validation-Logs/pub-get.txt) |
| `dart format --output=none --set-exit-if-changed .` | PASS, 83 archivos, 0 cambios, antes de crear la exportación histórica ignorada de build | [Salida](UI-2.1-Validation-Logs/format.txt) |
| `flutter analyze` | PASS, sin incidencias; build excluido por configuración existente | [Salida](UI-2.1-Validation-Logs/analyze.txt) |
| `flutter test --reporter expanded` | PASS, 202 pruebas: 183 heredadas + 19 nuevas | [Suite completa](UI-2.1-Validation-Logs/flutter-tests.txt) |
| Suite UI-2 con `UI2_CAPTURE=true` | PASS, 15 casos reejecutados para capturas; incluidos en los 202, no son pruebas únicas adicionales | [Renderer](UI-2.1-Validation-Logs/renderer-tests.txt) |
| Renderer del baseline exportado | PASS, 2 casos separados, mismo fixture/SDK/fuentes y lock intacto | [Baseline](UI-2.1-Validation-Logs/baseline-renderer-tests.txt) |
| `flutter build apk --debug --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` | PASS | [Build debug](UI-2.1-Validation-Logs/debug-build.txt) |
| `flutter build apk --release --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` | PASS | [Build release](UI-2.1-Validation-Logs/release-build.txt) |
| `python tool/verify_poi_unicode.py` | PASS, 100.170 vectores oficiales NFD + eliminación de marcas | [Conformidad Unicode](UI-2.1-Validation-Logs/unicode-conformance.txt) |
| `verify_apk_icons.py` sobre ambos APK y auditoría ZIP release | PASS; sin fixtures TEST_ONLY ni media no verificada; único PNG de assets Flutter es logo preexistente del paquete fijado flutter_map, hash cotejado | [Auditoría APK](UI-2.1-Validation-Logs/apk-audit.txt) |
| Métodos/rutas protegidos y contratos congelados | PASS; Driving tree y métodos GPS/voz/lifecycle intactos; entrada Driving solo añade limpieza de consulta | [Auditoría alcance](UI-2.1-Validation-Logs/scope-audit.txt) |
| Integridad Git de entornos protegidos | PASS: 18 worktrees previos y 3 stashes intactos; 12 archivos pendientes con SHA-256 idéntico; rama de implementación ausente del remoto | [Auditoría previa al commit](UI-2.1-Validation-Logs/git-integrity.txt) |
| Documentación | PASS: UTF-8 estricto, enlaces locales, 14 criterios, whitespace y diff autorizado | Validación documental y `git diff --check` de esta ejecución |

Los logs archivados conservan resultados reales; se redactaron prefijos locales de
SDK/perfil y se quitó padding terminal al final de línea. Los warnings del toolchain
Java/SDK XML y versiones más recientes disponibles no son fallos de build; no se
cambiaron SDK, dependencias o permisos. Todas las validaciones son locales.

### APK y hashes

| Artefacto local | Bytes | SHA-256 |
| --- | --- | --- |
| `mobile/build/app/outputs/flutter-apk/app-debug.apk` | 167843977 | `641deaff0f167444cc3e2e45e3c5c0a7767f2cc1c8cbb0462a583db06034a2f3` |
| `mobile/build/app/outputs/flutter-apk/app-release.apk` | 60472029 | `fe4df3cf18388c70c99296dd148e530dfa4cb487ca06979a517611fc35022b65` |

[Inventario SHA-256](UI-2.1-Validation-Logs/artifact-sha256.json): APK, 23 PNG,
fixture y fuentes SDK. El hash de la función de fixture es idéntico entre baseline
y ejecución actual. Los hashes de fuente se normalizan a UTF-8/LF para corresponder
al contenido canónico Git. Los APK son posteriores a la última edición de producción;
los cambios posteriores se limitan a herramientas/captura de pruebas y documentación.
No se ejecutó instalación ni distribución.

### Archivos de implementación

Nueve fuentes de presentación:

- `mobile/lib/features/map/presentation/base_map_page.dart`.
- `mobile/lib/features/discovery/presentation/poi_preview_sheet.dart`.
- `mobile/lib/features/discovery/presentation/poi_detail_sheet.dart`.
- `mobile/lib/features/discovery/presentation/poi_presentation.dart`.
- `mobile/lib/features/discovery/presentation/poi_result_card.dart`.
- `mobile/lib/features/discovery/presentation/poi_result_filter.dart`.
- `mobile/lib/features/discovery/presentation/poi_thumbnail.dart`.
- `mobile/lib/features/discovery/presentation/unicode_name_normalization.dart`.
- `mobile/lib/features/discovery/presentation/unicode_name_data.dart`.

Ocho archivos de pruebas:

- `mobile/test/widget_test.dart`.
- `mobile/test/features/discovery/offline_ui_test.dart`.
- `mobile/test/features/discovery/poi_list_close_test.dart`.
- `mobile/test/features/discovery/presentation/poi_preview_sheet_test.dart`.
- `mobile/test/features/discovery/presentation/poi_detail_sheet_test.dart`.
- `mobile/test/features/discovery/presentation/poi_visual_contract_test.dart`.
- `mobile/test/features/discovery/poi_result_filter_test.dart`.
- `mobile/test/features/discovery/ui2_experience_test.dart`.

Herramientas de evidencia: `mobile/tool/verify_poi_unicode.py` y
`mobile/tool/capture_ui2_baseline.py`. Documentación nueva: este informe,
`UI-2-Visual-Evidence/` (23 PNG y README) y `UI-2.1-Validation-Logs/`.
No hay cambios de backend/API, modelo, codec/store/cache, permisos, manifiestos,
dependencias, código nativo, archivos ADMIN ni contratos congelados.

### Trazabilidad Git local

Commit funcional y visual: `6a7c4fda359e2eb70e7b4c8b11b11c70a0f8bf66`.
43 paths: 9 fuentes, 8 tests, 2 herramientas, 23 PNG y README. El commit documental
posterior incorpora este informe y los logs. Su SHA final se entrega en el reporte
de cierre local, junto a la comprobación del worktree limpio.

El checkout principal continúa en main/e443c0aa con sus tres borradores UI-0.
origin/main permanece en el baseline contractual. Se preservan los 18 worktrees
previos, 3 stashes y 12 archivos pendientes con hashes idénticos. Se conserva la
rama/worktree nuevos. No se hizo push, PR, merge, rebase, reset ni limpieza.

## Evidencia visual y límites

[Inventario de 23 capturas y registro de medios](UI-2-Visual-Evidence/README.md).
Todas son `FLUTTER_RENDERER_TEST`, con datos sintéticos, Roboto/Material Icons del SDK
y tiles HTTP bloqueados por el binding. Se revisan layout y legibilidad del fixture.
No acreditan Android físico, backend desplegado, cartografía operativa, GPS real,
foco/audio nativo ni TalkBack. El error capturado es fixture de presentación.

Android físico, TalkBack y tiles reales: **`NOT_EXECUTED`**. La autorización excluye
instalar APK, usar emulador como sustituto silencioso o activar permisos reales.
Los APK se generan únicamente como artefactos de build locales.

## Estados y siguiente gate

```ini
UI_2_1_IMPLEMENTATION = READY_FOR_REVIEW
UI_2_CONTRACT = APPROVED_FROZEN
UI_2_FROZEN_CONTRACT_INTEGRATION = PASS
UI_2_IMPLEMENTATION = IMPLEMENTED_LOCAL_PENDING_REVIEW
UI_2_AUTOMATED_VALIDATION = PASS
UI_2_PHYSICAL_VALIDATION = NOT_EXECUTED
UI_2_TALKBACK_VALIDATION = NOT_EXECUTED
UI_2_REAL_TILES_VALIDATION = NOT_EXECUTED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
UI_2_PUSH = NOT_AUTHORIZED
UI_2_PR = NOT_AUTHORIZED
UI_2_MERGE = NOT_AUTHORIZED
ADMIN_IMPLEMENTATION = NOT_AUTHORIZED
DRIVING_FUNCTIONAL_PACKAGE = NOT_AUTHORIZED
```

Siguiente gate: revisión humana de implementación y evidencia local. Publicación,
PR/merge, validación física y cierre maestro requieren autorizaciones independientes.
UI-3 y posteriores no se inician por este resultado.

`STOP_AND_REPORT`
