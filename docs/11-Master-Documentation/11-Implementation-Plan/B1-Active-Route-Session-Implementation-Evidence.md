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

## Incidente físico y hotfix de arranque — 2026-10-10

Esta sección actualiza el estado de retest, sin sustituir los resultados históricos anteriores.

- APK original F02FD852C0FF61469FB2CEE1E586B6E74DE2D180840D9BB9394543B6FC0A3EC3: instalado mediante adb install -r, Success; sin desinstalación ni borrado. HONOR LLY-NX3/API 36 confirmado.
- Confirmación humana y captura: la app permanece en splash. B1_STATIONARY_FAIL en lanzamiento; resto de matriz estacionaria BLOCKED.
- Inspección read-only: proceso presente, ningún RouteSessionService activo. Log disponible mostraba espera del primer frame; no conservaba la excepción de arranque. No se adjudica esa excepción a un log físico inexistente.
- Causa de código confirmada por reproducción en flutter_tester nuevo: main construía GeoGuideApp antes de runApp; AndroidRouteSession.instance registraba MethodChannel sin binding. La prueba falló con la assertion de platform_channel.dart:589 y traza AndroidRouteSession -> GeoGuideApp -> main.
- Corrección funcional exacta: añadir WidgetsFlutterBinding.ensureInitialized() antes de runApp(GeoGuideApp()) en mobile/lib/main.dart. No cambia el entrypoint del worker, servicio, permisos ni lógica GPS.
- Regresión: mobile/test/b1_startup_test.dart comprueba que BindingBase.debugBindingType() sea null antes de invocar main real. No inicializa TestWidgetsFlutterBinding; falla si el harness ha inicializado un binding. Después invoca main, reemplaza la raíz por SizedBox y verifica WidgetsFlutterBinding. Detecta construcción de canales antes del binding; no acredita render nativo o funcionamiento físico. Fallo intermedio del harness por path_provider ausente al dejar montado el mapa se resolvió aislando el alcance del test; no se modificó el producto para ese fallo de entorno.
- Commit hotfix: 1d1d591702231a6ca81c9ddd9e1e6687b11de8c5 (main + test).
- Format: PASS, 60 archivos, cero cambios finales.
- Analyze: PASS, No issues found.
- Suite completa: 94/94 PASS, 0 fail, 0 skip. Regresión aislada final: 1/1 PASS.
- APK debug HTTPS: PASS, https://geoguide.getcom.pe:5443, build después de la corrección.
- Nuevo APK: mobile/build/app/outputs/flutter-apk/app-debug.apk.
- Nuevo SHA-256: 4FC746347E29F4DD31354A0859E98418DB146118463EFB859C145329F3C262FB.
- git diff --check: PASS. Dependencias/lockfile/manifest/servicio Android/backend/infra/contratos: sin cambios del hotfix. Sin push, PR ni merge.
- Estado actual: READY_FOR_B1_STARTUP_RETEST. PHYSICAL_STARTUP_RETEST=NOT_EXECUTED. No se instaló el APK corregido.
- Gate: nueva confirmación humana antes de actualización no destructiva en HONOR. El PASS automatizado de inicialización no revoca el fallo observado del APK anterior ni demuestra arranque físico. Persisten pendientes lifecycle, notificación, stop/limpieza y batería HONOR. P12.5 sigue NOT_AUTHORIZED.

## Retest estacionario supervisado — 2026-10-10

APK autorizado e instalado mediante actualización adb install -r: 4FC746347E29F4DD31354A0859E98418DB146118463EFB859C145329F3C262FB. Dispositivo HONOR LLY-NX3/API 36. Resultado instalación Success; sin desinstalación, borrado ni cambios de permisos ADB.

| Caso | Resultado | Evidencia y límite |
| --- | --- | --- |
| Arranque físico corregido | PASS | Usuario confirma y aporta captura de interfaz principal/mapa; no se extrapola al funcionamiento completo |
| Ruta elegible | PASS | UI observada: ruta 97.7 km, 104 min planificados, cinco lugares; sin copiar coordenadas a esta evidencia |
| Inicio explícito y consentimiento | PASS | Usuario pulsó inicio y aceptó diálogo; capturas del flujo |
| Permisos | PASS | Aceptación manual de notificaciones; dumpsys package confirma POST_NOTIFICATIONS y ubicación coarse/fine concedidos |
| Indicador persistente | PASS | Usuario transcribe notificación recorrido activo con Detener; ADB confirma registro id41, foreground location, acción única, sin sonido/vibración |
| Cambio a otras apps y retorno | PASS | Usuario confirma icono Stop conservado; ADB confirma servicio foreground posterior. Ventana exacta no medida |
| Bloqueo 30 s/desbloqueo | PASS | Usuario confirma duración, retorno y UI operativa; ADB confirma servicio foreground posterior. No hubo sondeo continuo durante bloqueo |
| Stop desde notificación | PASS | Usuario/captura: Recorrido detenido, icono inicio restaurado; ADB servicio/notificación ausentes y evento de eliminación del registro nativo |
| Repetición de Stop notificación | PASS | Usuario repite sesión de aproximadamente dos minutos sin pulsar otros controles después; ADB sin solicitudes actuales del paquete |
| Stop desde app | PASS | Usuario confirma inicio, botón Stop y Recorrido detenido; ADB posterior: servicio=false, notificación id41=false, líneas de solicitudes activas del paquete=0 |

La inspección de ubicación se procesó en memoria y solo se comunicaron estados/registro técnico sanitizado, sin guardar coordenadas, historial de posiciones ni logs crudos. No se crearon capturas propias. Las capturas aportadas por el usuario son evidencia humana, no mediciones automáticas.

Incidencias/observaciones:
- Fallo de splash del APK previo preservado; corregido por hotfix y retest físico de arranque PASS.
- Botones normales de ubicación aparentan estar disponibles pero sus handlers no actúan mientras B1 posee el productor: bloqueo deliberado de exclusividad con comunicación UX insuficiente. No corregido en esta validación.
- Una solicitud foreground normal posterior al primer Stop fue investigada; el usuario confirmó que pulsó el botón normal de ubicación. No se atribuye a reactivación B1. Repetición sin pulsaciones posteriores y Stop desde app dejan cero solicitudes activas del paquete.
- UI mostró Señal de ubicación degradada. Sesión y ruta permanecieron operativas; no demuestra calidad GPS, precisión, recuperación ni desplazamiento dinámico.

Veredicto del alcance ejecutado: B1_STATIONARY_PASS. No implica cierre funcional global, aprobación del contrato v0.2 o certificación de background bajo todas las condiciones Android/HONOR.

Pendientes no ejecutados: revocación manual, terminación del proceso/reinicio, ahorro de batería/Doze prolongado, batería cuantificada, señal degradada inducida y movimiento dinámico. No se declara PASS de estos casos. El protocolo actual no requirió revocación. No se ejecutó conducción ni pruebas P12.5.

Estado final técnico del teléfono: B1 detenido, servicio y notificación ausentes, sin solicitudes activas de ubicación atribuibles al paquete en la inspección posterior. Sin modificaciones de código/manifest/infra durante retest; sin push/PR/merge. Siguiente gate: revisión de evidencia y autorización independiente de cualquier validación adicional; P12.5 NOT_AUTHORIZED, P11-BACKUP-01 OPEN_DEFERRED.

## Continuidad B1.1

El hardening UX y la auditoría del sink silencioso se registran en [B1.1 — UX y CEFI Alert Readiness](B1.1-UX-Hardening-and-CEFI-Alert-Readiness.md). Commit funcional dcb2b35684158fc5b76e78f128fdd6f30699be46; 95/95 tests y 50 controles JVM PASS. El nuevo APK no se instaló. El PASS estacionario B1 anterior se conserva como evidencia histórica de su artefacto; la UX B1.1 necesita retest separado. No se habilita salida audible, no se congela contrato CEFI ni se autoriza P12.5.
