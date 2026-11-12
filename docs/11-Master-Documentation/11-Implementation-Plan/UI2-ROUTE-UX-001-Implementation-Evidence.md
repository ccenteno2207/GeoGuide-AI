# UI2-ROUTE-UX-001 — Evidencia de implementación local

Fecha: 2026-11-12

## Estado

Implementación y validación automatizada local. Instalación física pendiente; publicación, PR y merge no autorizados.

## Flujo

- «Seleccionar» fija el destino sin iniciar el cálculo.
- Un origen manual seleccionado prevalece. Si falta, el cliente consulta ubicación puntual con `requestPermission: false`; solo acepta coordenadas válidas, precisión ≤100 m y timestamp dentro de 2 minutos.
- Si no hay ubicación utilizable, la interfaz pide seleccionar el origen en el mapa.
- «Ver ruta» inicia PlanRoute; solo ante éxito se invoca Route Discovery. El modo Conducción no se inicia automáticamente.

## Validación H2

- `dart format --output=none --set-exit-if-changed` sobre los 15 archivos Dart afectados: PASS.
- `flutter analyze`: PASS, sin issues.
- `flutter test`: 271 PASS, 1 SKIP.
- `git diff --check`: PASS.
- Sin cambios al AndroidManifest, permisos o backend. No se añadieron streams de ubicación; centrado automático al abrir queda fuera del alcance.

## APK H3

- Build: `flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` — PASS.
- Ruta: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- Tamaño: 194,273,791 bytes.
- SHA-256: `092DC53006797728BEC0B17C1604D4259229048146117F13CE8D9388E57950D1`.
- `aapt dump badging`: paquete `com.geoguideai.geoguide_ai`, versión `1.0.0`, etiqueta `Rutea`.
- Configuración de build usa el endpoint HTTPS indicado; búsqueda estática de localhost, 127.0.0.1, 10.0.2.2 y HTTP en código móvil no encontró endpoints locales ni fallback. No se instaló ni probó físicamente este APK.

Limitaciones: el full suite informa un test omitido; validación física de esta build sigue pendiente.
