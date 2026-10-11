# C2 — Hotfix UX de cierre de lista POI

Fecha: 2026-10-11. Rama: feature/gps-camera-tracking-proximity-core.
Entrada local: c183ac00e7334a1b0257b60521a196372f3296be, worktree limpio.
git fetch origin completado; origin/main:
e19e17212c48ecf1b9604c512cac4f5b9fb64686, sin avance remoto inesperado.

## Evidencia humana reconciliada

El usuario confirmó recuperación de todos los iconos en el APK anterior corregido,
mapa/ruta visibles, cinco POIs, categorías y apertura/cierre de fichas. También
confirmó posteriormente que pulsar Cancelar en el diálogo Avisos de voz CEFI dejó
el icono de altavoz desactivado. Cancelación del consentimiento: PASS humano sobre
APK 09D9E0471F1123757F5BA75ED039685B0B0290761B252523C459C9F92D261A89.
No equivale a voz audible validada ni a sesión GPS de este nuevo APK.

## Causa y corrección

BaseMapPage mostraba la lista como último elemento del Stack, con bottom:150 y
height:260, sobre el control Ver mapa situado detrás. No había cierre dentro del
panel. El defecto ya estaba presente antes del hotfix MaterialIcons.

El panel normal incorpora Cerrar lista y ver mapa, con icono de cierre y semántica
de botón. La cabecera permanece fuera del ListView: no desaparece al desplazar una
lista larga. El panel se limita al espacio disponible del body, con márgenes y
altura máxima 320 logical pixels; se adapta también a pantallas bajas/landscape.
El cierre solo cambia _showDiscoveryList a false; no recalcula ruta, filtros,
snapshot, marcadores, sesión ni consentimiento. Mantiene el toggle externo y los
callbacks existentes de Preview/ficha. No introduce otro productor GPS.

Driving conserva su implementación exacta y no muestra el panel ni el cierre.
Los verificadores MaterialIcons, normalización de paths y configuración de build
del hotfix anterior permanecen intactos.

## Pruebas

- Cuatro widget tests nuevos: lista de 20 POIs en 320×480, 360×640 y 640×360;
  desplazamiento hasta el último POI; cierre hitTestable antes y después de scroll;
  retorno al mapa y preservación del snapshot/categorías.
- Integración widget: abrir Preview y ficha, cerrar ficha y lista; sesión activa
  conservada, sin nuevo inicio ni petición de permisos; ruta/snapshot intactos.
- Regresión Driving existente ampliada: cierre de lista ausente en Driving.
- Fixtures sintéticos solo en tests; no se inyectan POIs o ubicaciones en el móvil.

## Validación final y artefacto

Commit funcional: b4dd0f0b5ac8f9e8e8330973e4a1e8d460559df2.

| Control | Resultado real |
| --- | --- |
| Pruebas widget nuevas, dirigidas | 4/4 PASS |
| Formato lib/test | 65 archivos, 0 cambios pendientes |
| flutter analyze --no-pub | PASS, sin incidencias |
| Suite Flutter completa | 122/122 PASS (118 anteriores + 4 nuevas) |
| b1PolicyChecks | 50 assertions PASS |
| c2VoiceChecks | 80 assertions PASS |
| Pruebas del verificador de assets | 5/5 PASS |
| Build APK debug HTTPS | BUILD SUCCESSFUL |
| verifyDebugMaterialIcons obligatorio | PASS, fuente de 1 645 184 bytes |
| Verificador independiente sobre APK final | PASS, 11 assets |
| Fuente frente al SDK completo | Bytes idénticos |
| Literal HTTPS en kernel | Presente |
| Manifest fuente | Sin cambios, SHA-256 igual al baseline C2 |
| Driving desde _enterDriving hasta fin del archivo | Texto idéntico al HEAD de entrada |
| git diff --check | PASS |
| Instalación/retest físico nuevo APK | NOT_EXECUTED |

Comandos: dart format --output=none --set-exit-if-changed lib test;
flutter analyze --no-pub; flutter test --no-pub;
gradlew.bat --max-workers=2 :app:b1PolicyChecks :app:c2VoiceChecks;
flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443;
python -m unittest discover -s tool -p test_verify_apk_icons.py;
python tool/verify_apk_icons.py build/app/outputs/flutter-apk/app-debug.apk.

APK: mobile/build/app/outputs/flutter-apk/app-debug.apk.
SHA-256: 5E6DAFD27B4EAFC18FDF7F60BB8D9519BD5D001C7201D94441A891EC37563172.
Manifest fuente SHA-256: 40DA0EA6EE2C76EB58B8A3726049C87526CAACEABE337E2E72C3F571B8B18A8E.

READY_FOR_C2_UX_RETEST acredita preparación técnica y pruebas automatizadas;
no acredita el cierre físico de lista en HONOR ni voz audible o conducción.

## Retest conjunto pendiente de autorización del APK

1. Confirmar APK/hash, HONOR/API 36 y ausencia de sesión activa; actualizar con
   adb install -r, conservando datos/permisos, solo con autorización humana.
2. Con ruta real disponible, Ver lista → abrir/cerrar una ficha → desplazar lista →
   Cerrar lista y ver mapa. Confirmar ruta, categorías y marcadores conservados.
3. Cancelación de voz ya tiene PASS humano sobre APK anterior; comprobar una vez
   en el nuevo build solo como regresión de UI. No repetir los escenarios de iconos
   completos si la inspección breve no muestra regresión.
4. Iniciar GPS explícitamente y aceptar consentimiento. Confirmar estado B1.1,
   controles normales no disponibles, notificación persistente y Home/retorno.
5. Stop desde notificación. ADB read-only: servicio/notificación ausentes y sin
   registros actuales de ubicación del paquete. Confirmación humana: sin voz
   posterior. No usar eventos históricos como prueba de solicitudes activas.
6. Voz audible solo con POI genuinamente elegible. Si no existe, registrar
   BLOCKED_NO_ELIGIBLE_POI. No inyectar muestras, alterar umbrales ni desplazarse.

La validación visual del cierre en el HONOR sigue NOT_EXECUTED. No instalar este
APK sin autorización humana; no borrar datos o modificar permisos por ADB.
No cambios de GPS, proximidad, TTS, foco, consentimiento, permisos, dependencias,
backend, Photon, P12, infraestructura o contratos congelados. Sin push, PR o merge.
P12.5 NOT_AUTHORIZED; no pruebas dinámicas ni conducción.
