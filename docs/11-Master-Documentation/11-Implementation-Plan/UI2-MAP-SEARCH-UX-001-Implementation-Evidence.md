# UI2-MAP-SEARCH-UX-001 — Evidencia de implementación

**Fecha de ejecución:** 2026-11-12`n**Rama:** `codex/ui2-map-search-ux-001`
**Baseline:** `origin/main` `0f114e320043da90d949b79ab0ab4fea5084c66b`, con dependencia local `codex/ui2-route-ux-001` incorporada en el merge de preparación `1b4d85cc91307f887a1b67d3f1d562f3f7eac0dc`.

## Decisión aplicable

La autorización específica está registrada en la [adenda UI2-MAP-SEARCH-UX-001 del Registro de Decisiones UI-2](UI-2-Decision-Register.md#8-adenda-aprobada--ui2-map-search-ux-001-2026-11-12). Esta implementación no modifica los contratos congelados. El centrado inicial se limita a Exploración, usa una sola consulta puntual con `requestPermission: false` y no inicia tracking. Las sugerencias consultan el catálogo y endpoint existentes; seleccionar un resultado no calcula la ruta y se mantiene «Ver ruta» como acción explícita.

## Cambios implementados

- Al confirmar el estado de la sesión de ubicación, la pantalla realiza una sola consulta puntual sin pedir permisos. Solo conserva una ubicación válida con coordenadas dentro de rango, precisión conocida hasta 100 m y marca temporal de no más de dos minutos. La cámara se centra una vez a zoom 15 y se muestra el marcador existente. Si la respuesta llega después de que la persona mueve el mapa o selecciona un punto/destino, se conserva su encuadre. Denegación, error o ubicación inválida mantienen el mapa inicial. La ruta de inicio no abre una suscripción GPS ni cambia Driving.
- El origen GPS obtenido al inicio se reutiliza para preparar una ruta mientras continúe vigente; un origen manual sigue teniendo prioridad. La selección de una sugerencia sigue sin iniciar PlanRoute.
- La búsqueda consulta incrementalmente tras 300 ms, normaliza espacios, cancela el debounce anterior y descarta respuestas obsoletas. Mantiene selección explícita, botón/envío accesible, carga, vacío, error/reintento y un mensaje de servicio/conectividad no disponible.

## Validación

Pruebas focalizadas finales: **22 PASS, 0 FAIL** en `destination_search_test.dart`, `gps_camera_widget_test.dart` y `widget_test.dart`. Cubren debounce, deduplicación al enviar durante el debounce, respuesta tardía obsoleta, resultado vacío, error/reintento y estado de servicio sin conexión; GPS inicial puntual con permiso no solicitado, denegación/no disponibilidad, interacción manual previa a la respuesta y regresión del flujo «Ver ruta»/PlanRoute/Route Discovery. Los tests se ejecutaron con dobles locales deterministas.

`dart format .`: PASS, 97 archivos revisados, 0 cambios. `flutter analyze`: PASS, sin issues. Suite Flutter completa: **278 PASS, 1 SKIPPED, 0 FAIL**. APK debug integrada: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, 168180528 bytes, SHA-256 `265D5C5445356B6B9E48360422D582227E19FF27271F2D9361B17020292A3CA1`; compilada con `BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`. El código lee esta configuración mediante `String.fromEnvironment`; no se agregó localhost ni túnel. `git diff --check`: PASS.

## Validación física (2026-11-12)

Prechecks: PASS. ADB identificó un HONOR LLY-NX3 (`LLY-NX3`), Android API 36, estado `device`; paquete `com.geoguideai.geoguide_ai`; APK fuente con el tamaño y SHA-256 indicados arriba. El certificado SHA-256 de firma del APK candidato y de la APK previamente instalada coincidió (`894975b5bc6751da09b3d69923d4ae399192470d86c107106f65f6cb8d7eab7e`). La instalación previa era versionName `1.0.0`, versionCode `1`; `adb install -r` devolvió `Success`, y `firstInstallTime` se mantuvo en `2026-10-05 20:08:37`, evidencia de que se actualizó el paquete existente sin desinstalar ni borrar sus datos. No se usó ADB reverse.

El primer intento de continuar encontró el teléfono en AOD/bloqueado; no se intentó eludir el bloqueo. El propietario luego lo desbloqueó manualmente y dejó Rutea visible. No se cambió ningún permiso ni ajuste del teléfono.

| Escenario | Resultado | Observación comprobada |
| --- | --- | --- |
| MAP-PHYS-01 — Inicio con GPS autorizado | PASS | Mapa abierto centrado en la ubicación puntual, con encuadre local y marcador Rutea/halo visible. No hubo prompt nuevo de permisos. El control indicaba «Activar seguimiento de ubicación», por lo que no estaba activo. El nivel exacto de zoom no se midió instrumentalmente. |
| MAP-PHYS-02 — Interacción manual | PARTIAL | Después de desplazar el mapa, el encuadre manual se mantuvo durante la observación y no hubo recentrado repetitivo. Una respuesta GPS deliberadamente tardía no pudo reproducirse físicamente (`NOT_REPRODUCED`); conserva la cobertura automatizada. |
| MAP-PHYS-03 — GPS no disponible | NOT_TESTED | Fine y coarse location seguían concedidos y el GPS puntual estaba disponible. No se revocaron permisos ni se forzó una condición artificial. |
| SEARCH-PHYS-01 — Sugerencias | PASS | Al escribir `Obra`, apareció «Plaza De Armas De Obrajillo» sin pulsar la lupa y el teclado permaneció abierto. Al editar a `Canta`, la coincidencia cambió a «Plaza De Armas De Canta». Captura saneada, sin el mapa ni la ubicación: `D:\Codex\evidence\GeoGuide-AI\UI2-MAP-SEARCH-UX-001\2026-11-12\search-suggestions-Obra.png`. |
| SEARCH-PHYS-02 — Selección | PASS | Seleccionar Obrajillo cerró la búsqueda, estableció el destino, mostró «Origen: Tu ubicación actual» y dejó disponible «Ver ruta». No se calculó hasta pulsar «Ver ruta». |
| SEARCH-PHYS-03 — Respuestas obsoletas | PARTIAL | Tras cambiar rápidamente de `Obra` a `Canta`, la interfaz terminó mostrando la coincidencia de Canta, sin bloqueo ni error y sin resultado antiguo visible. No se consiguió reproducir una respuesta de red tardía que llegara fuera de orden (`NOT_REPRODUCED`); existe prueba automatizada determinista para esa condición. |
| ROUTE-PHYS-01 — Regresión de ruta | PASS | «Ver ruta» calculó y mostró geometría y `Ruta: 97.7 km · 104 min`. Route Discovery devolvió 5 lugares. La lista mostró 5/5; Preview y Detail de Plaza de Armas de Obrajillo abrieron y regresaron. Filtrar solo «Sitio arqueológico» mostró 1/1 (Petroglifos de Checta); «Restablecer» devolvió todas las categorías y 5/5. Driving no se inició automáticamente y el seguimiento continuó inactivo. No se abrió el enlace externo de la ficha. |

La búsqueda y el cálculo funcionaron con conectividad del dispositivo; `adb reverse --list` estaba vacío y no se utilizó ADB reverse. Las capturas de pantalla completas que contenían contexto de ubicación se dejaron fuera del repositorio y se eliminaron; se conserva solo la captura recortada de sugerencias indicada arriba.

## Estados

```ini
UI2_MAP_SEARCH_UX_001_IMPLEMENTATION = PASS
UI2_MAP_SEARCH_UX_001_FOCUSED_TESTS = PASS_22
UI2_MAP_SEARCH_UX_001_FULL_TESTS = PASS_278_SKIP_1
UI2_MAP_SEARCH_UX_001_ANALYZE = PASS
UI2_MAP_SEARCH_UX_001_FORMAT = PASS
UI2_MAP_SEARCH_UX_001_APK_BUILD = PASS
UI2_MAP_SEARCH_UX_001_PHYSICAL = PARTIAL
UI2_MAP_SEARCH_UX_001_MERGE = NOT_AUTHORIZED
UI2_ROUTE_UX_001_PHYSICAL = PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
