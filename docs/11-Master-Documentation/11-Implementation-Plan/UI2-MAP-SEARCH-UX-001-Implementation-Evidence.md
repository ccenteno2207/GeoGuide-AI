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

`dart format .`: PASS, 97 archivos revisados, 0 cambios. `flutter analyze`: PASS, sin issues. Suite Flutter completa: **278 PASS, 1 SKIPPED, 0 FAIL**. APK debug integrada: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, 168180528 bytes, SHA-256 `265D5C5445356B6B9E48360422D582227E19FF27271F2D9361B17020292A3CA1`; compilada con `BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`. El código lee esta configuración mediante `String.fromEnvironment`; no se agregó localhost ni túnel. `git diff --check`: PASS. No se instaló la APK y no se realizó validación física.

## Estados

```ini
UI2_MAP_SEARCH_UX_001_IMPLEMENTATION = PASS
UI2_MAP_SEARCH_UX_001_FOCUSED_TESTS = PASS_22
UI2_MAP_SEARCH_UX_001_FULL_TESTS = PASS_278_SKIP_1
UI2_MAP_SEARCH_UX_001_ANALYZE = PASS
UI2_MAP_SEARCH_UX_001_FORMAT = PASS
UI2_MAP_SEARCH_UX_001_APK_BUILD = PASS
UI2_MAP_SEARCH_UX_001_PHYSICAL = PENDING
UI2_MAP_SEARCH_UX_001_MERGE = NOT_AUTHORIZED
UI2_ROUTE_UX_001_PHYSICAL = PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
