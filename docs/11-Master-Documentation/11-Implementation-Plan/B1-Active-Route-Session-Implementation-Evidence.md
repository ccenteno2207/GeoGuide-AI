# B1 — Active Route Session: implementación y preparación estacionaria

Fecha: 2026-10-10. Estado: READY_FOR_B1_STATIONARY_VALIDATION.

## Autorización y trazabilidad

Paquete B1 autorizado expresamente por el usuario; el contrato unificado v0.2 sigue PROPOSED_NOT_APPROVED. No se congela ni amplía P12/GPS histórico.

- Rama: feature/gps-camera-tracking-proximity-core.
- Entrada: 6ef80d8042d8ea01293ca7d90dbe828d204b1ea0, worktree limpio.
- origin/main verificado mediante fetch antes y después: e19e17212c48ecf1b9604c512cac4f5b9fb64686.
- Commit funcional B1: a5e4a6b45a4fa2295ac2253559025a6c5ceab6e9.
- Sin push, PR ni merge.

## Implementación

MainActivity exige Activity visible, consentimiento UI previo y ausencia de propietario/petición pendiente. Un snapshot canónico elegible se transmite en memoria al servicio, sin escritura nueva. RouteSessionService inicia foreground de tipo location, una suscripción LocationManager y FlutterEngine dedicado con entrypoint b1RouteSessionMain.

ActiveRouteCoordinator reutiliza TrackingSessionManager y POIProximityEvaluator; SilentAlertSink descarta las alertas. No hay TTS ni notificaciones audibles POI. El puerto de aplicación RouteSessionClient mantiene la UI separada del canal Android. Se cancela y espera la suscripción foreground anterior antes de iniciar el productor nativo; durante B1 se bloquean inicio GPS alternativo, ubicación puntual y cambios de consulta/ruta.

El botón de inicio/stop existe en modo normal; no se añade a Driving. Las restricciones, cámara y mapa de Driving permanecen sin ampliación. Stop desde la app o notificación, revocación, proveedor deshabilitado, fallo, eliminación de tarea o expiración del snapshot terminan la propiedad. START_NOT_STICKY y ausencia de receptor boot evitan reinicio automático. No se detecta automáticamente llegada a destino: el usuario finaliza explícitamente.

Snapshot, muestras y evaluación permanecen en memoria. No hay nuevas escrituras de coordenadas, historial, upload continuo, credenciales ni logs de ubicación en estos adaptadores.

## Manifest

Fuente: mobile/android/app/src/main/AndroidManifest.xml.
SHA-256: 1E6900B8EBEAB9C61955B64402907C486522E20896006138A4264E70DD6BED1F.

Fusionado debug: mobile/build/app/intermediates/merged_manifests/debug/processDebugManifest/AndroidManifest.xml.
SHA-256: 749E42369A79959DFB68E05C106D0C94DD71A006EEF1CADFA30784DA993FF8F4.

Permisos fuente: INTERNET, ACCESS_COARSE_LOCATION, ACCESS_FINE_LOCATION, FOREGROUND_SERVICE, FOREGROUND_SERVICE_LOCATION, POST_NOTIFICATIONS. Sin ACCESS_BACKGROUND_LOCATION ni RECEIVE_BOOT_COMPLETED. Servicio B1 no exportado, stopWithTask=true, foregroundServiceType=location. El fusionado conserva el servicio de la dependencia Geolocator y permiso signature AndroidX DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION; su declaración no demuestra ejecución simultánea. B1 utiliza LocationManager, no ese servicio de Geolocator. minSdk=24, targetSdk=36.

## Validaciones ejecutadas

| Control | Resultado real | Alcance |
| --- | --- | --- |
| dart format --output=none --set-exit-if-changed lib test | PASS, 59 archivos, cero cambios | Dart fuente/tests |
| flutter analyze | PASS, No issues found | Mobile |
| flutter test --reporter expanded | PASS, 93/93, fail=0, skip=0 | 85 previos + 8 B1 |
| gradlew.bat :app:b1PolicyChecks | PASS, 50 assertions, BUILD SUCCESSFUL | JVM puro, API 24/28/29/31/33/34/36; no instrumentación Android |
| flutter build apk --debug --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443 | PASS | APK final compilado después del control nativo |
| git diff --check | PASS | Diff documental y funcional |

Los tests B1 verifican consentimiento ausente, snapshot expirado, stop/callback tardío, expiración durante sesión, teardown del puerto, rechazo de modo continuo, denegación del canal e inicio UI con transferencia exclusiva. Las 50 assertions nativas verifican visibilidad/propiedad/tamaño, requisitos según versión, notificaciones y revocación de precisión. Los tests existentes cubren serialización, generaciones y cierre del core. No prueban que Android mantenga un servicio vivo bajo restricciones HONOR; tampoco sustituyen pruebas de Home, bloqueo o terminación del proceso.

Fallos intermedios corregidos: timing del test widget al esperar cancelación de stream, ubicación del botón que interfería con regresión Driving y classpath Gradle ambiguo del runner JVM. Resultados finales arriba. Persisten avisos no fatales de toolchain/deprecaciones Android/Gradle y source/target Java 8 de dependencias; no se actualiza stack ni dependencias.

## APK final y dispositivo

APK: mobile/build/app/outputs/flutter-apk/app-debug.apk.
SHA-256: F02FD852C0FF61469FB2CEE1E586B6E74DE2D180840D9BB9394543B6FC0A3EC3.
Tamaño: 207759756 bytes.
Endpoint de build: https://geoguide.getcom.pe:5443.

ADB read-only detectó HONOR LLY-NX3 autorizado, API 36. AVD P6_MapSpike_API36 disponible. No se instaló APK ni se ejecutó prueba física/emulador en B1.

## Matriz Android pendiente

| Caso | Estado |
| --- | --- |
| Instalación no destructiva y lanzamiento APK B1 | NOT_EXECUTED — requiere confirmación humana |
| Inicio visible, consentimiento y permisos efectivos | NOT_EXECUTED |
| Notificación persistente y Stop | NOT_EXECUTED |
| Home/retorno y bloqueo/desbloqueo | NOT_EXECUTED |
| Revocación manual y teardown real | NOT_EXECUTED |
| Exclusividad real de productores y callbacks posteriores | NOT_EXECUTED |
| Terminación de proceso/tarea sin reactivación | NOT_EXECUTED |
| Batería y restricciones específicas HONOR | NOT_EXECUTED |
| Movimiento/conducción | NOT_EXECUTED — no autorizado |

## Protocolo propuesto, sujeto a confirmación

1. Instalar con adb install -r preservando datos; ante incompatibilidad de firma detenerse, sin uninstall/pm clear.
2. Abrir la ruta/snapshot existente elegible. En reposo, iniciar B1 y aceptar consentimiento. Android solicitará ubicación mientras se usa la app si falta y notificaciones; precisa/aproximada queda a elección humana. Nunca permiso de ubicación Siempre.
3. Observar indicador y marcador; Home durante 30 segundos, retorno, bloqueo 30 segundos y desbloqueo. Son ventanas de observación propuestas, no umbrales de batería o garantía de frecuencia.
4. Detener desde notificación y desde UI en ensayos separados; verificar ausencia de listener/servicio y no reactivación. Revocación, si se ensaya, manual desde ajustes con supervisión. Sin grant/revoke ADB automático.
5. No conducir ni capturar coordenadas/logs personales. Interrumpir ante calor/consumo anómalo, fallo o distracción. Detención inmediata mediante Detener de la notificación; alternativamente detener app desde Android. No borrar datos.

## Limitaciones y alcance preservado

Cadencia LocationManager 5 s/5 m, auditoría 3 s, timeout de handshake 10 s y política silenciosa 100/200 m son parámetros experimentales, no calibrados en campo ni promesas de precisión/batería. Ubicación aproximada depende del proveedor de red disponible; ausencia segura aborta. FlutterEngine dedicado agrega recursos pendientes de medición. La ruta debe tener snapshot elegible (TTL existente); no se prolonga automáticamente.

Backend/API/DB/infra, P12, Photon, Excel, documentación externa, contratos congelados y dependencias permanentes: sin cambios B1. No Continuous Tracking, TTS, cámara pasiva Driving, nuevas capacidades de navegación ni pruebas dinámicas.

Siguiente gate mínimo: confirmación humana de instalación y validación estacionaria supervisada del artefacto identificado. No declarar B1 validado físicamente hasta observar resultados reales.
