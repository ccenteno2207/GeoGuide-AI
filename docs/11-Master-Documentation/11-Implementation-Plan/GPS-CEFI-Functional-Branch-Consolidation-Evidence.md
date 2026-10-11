# GPS + CEFI — Consolidación funcional

Fecha: 2026-10-11. Veredicto: **READY_FOR_GPS_CEFI_PR_AUTHORIZATION**.

## Baseline y alcance

Rama `feature/gps-camera-tracking-proximity-core`, HEAD de entrada `0ce7c9ba07a30c4fb2bf21de4e71603264a62225`, worktree inicialmente limpio. Fetch al inicio y cierre confirma `origin/main = e19e17212c48ecf1b9604c512cac4f5b9fb64686`. La consulta remota no encontró la rama funcional publicada.

Diff de entrada: 50 archivos, nueve evidencias y 41 archivos móviles. Esta consolidación añade dos documentos y modifica tres archivos móviles ya incluidos: 52 archivos acumulados. No cambios fuera de mobile y documentos GPS/B1/B1.1/C1/C2/C2.1. Sin push, PR, merge, instalaciones o pruebas físicas nuevas. Contratos congelados, P12, Photon, backend, API, DB, infraestructura, permisos actuales y Excel sin cambios durante la consolidación.

Se revisaron arquitectura, canales, productores, lifecycle, consentimiento, entrega, manifest, empaquetado, tests y trazabilidad contra Entrega 04.6, ADR-027 y autorizaciones incrementales. La adopción Kotlin + engine dedicado sigue provisional conforme a B1; el contrato unificado permanece PROPOSED_NOT_APPROVED. No se congela ni acepta un ADR nuevo.

## Auditoría y corrección

Las políticas de cámara, sesión, proximidad y entrega residen en Application; adapters de plataforma en Infrastructure. UI no evalúa proximidad. B1 transfiere ownership tras cancelar el stream normal; el servicio privado posee un productor LocationManager y un FlutterEngine dedicado. C1 limita un vuelo y un pendiente, correlaciona generación/revisión/ID y aplica cooldown tras DELIVERED. C2 reutiliza esas reglas, exige consentimiento revocable y confirma finalización TTS. C2.1 es un diagnóstico aislado sin GPS ni POIs.

El servicio usa START_NOT_STICKY y stopWithTask=true; no persiste sesión ni registra boot receiver. Source manifest: INTERNET, COARSE/FINE y los tres permisos B1 aprobados FOREGROUND_SERVICE, FOREGROUND_SERVICE_LOCATION y POST_NOTIFICATIONS. Release fusionado contiene además DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION interno de AndroidX. Ausentes ACCESS_BACKGROUND_LOCATION, RECORD_AUDIO y RECEIVE_BOOT_COMPLETED. Servicio privado tipo location. No se autoriza iniciar una sesión nueva desde background.

Los métodos completos `_enterDriving`, `_exitDriving` y `_buildDrivingView` son idénticos a origin/main. Cámara adaptativa solo en mapa normal; la prueba de UI real verifica ausencia del diagnóstico en Driving.

Corrección `3f0930c5db0e7cc5ac871448b0b9d9c2570e7c87`: una solicitud normal de ubicación pendiente dejaba disponible iniciar B1 y podía crear un stream al terminar. Se añadió guard `_isRequestingLocation` y botón deshabilitado durante esa espera. La regresión comprueba cero permisos/inicios mientras espera y cancelación del listener anterior antes del start nativo. Se ajustó la espera asíncrona del test después de su primera ejecución fallida; suite final PASS. Esta corrección no se instaló ni tiene retest físico.

## Código experimental o no conectado

| Elemento | Decisión |
| --- | --- |
| GPSCameraConfig, cadencia 5s/5m, ProximityConfig | Retenidos como hipótesis experimentales sin calibración dinámica |
| SilentAlertSink | Doble técnico utilizado en pruebas; worker real usa AndroidCEFIAlertDelivery |
| Evaluador evaluate | Conveniencia de primer candidato que delega en evaluateCandidates, sin duplicar reglas |
| TrackingMode.continuous | Forma futura del core; UI no expone modo y puerto nativo lo rechaza |
| chosenIds | Prioridad probada en core, sin wiring desde UI al worker; diferido |
| Diagnóstico fijo | Solo debug, explícito y fuera de Driving |
| Temporales, dependencias nuevas o duplicación de proximidad | No encontrados en diff versionado; logs temporales fuera del repo |

## Validaciones finales

| Control | Resultado |
| --- | --- |
| Format lib/test | PASS, 67 archivos, cero cambios en última ejecución |
| Analyze | PASS, sin incidencias |
| Suite Flutter final | PASS, 132/132: 131 anteriores + regresión de exclusividad |
| UI Driving específica | PASS, 10/10 del archivo offline_ui_test.dart |
| JVM B1 / C2 / C2.1 | PASS, 50 / 80 / 43 aserciones |
| Tests Python assets | PASS, 5/5 |
| Build debug HTTPS y release HTTPS | PASS ambos, sin instalación ni distribución |
| Assets APK debug | PASS, MaterialIcons 1.645.184 bytes, 11 assets |
| Assets APK release | PASS, MaterialIcons 3.792 bytes por tree shaking, 8 assets |
| UTF-8 acumulado y links | PASS, textos decodificados estrictamente y enlaces relativos existentes comprobados |
| Driving intacto y diff check | PASS |

Comandos: `dart format lib test`, `flutter analyze --no-pub`, `flutter test --no-pub`; gradlew con JDK 21, dos workers y tareas `:app:b1PolicyChecks :app:c2VoiceChecks :app:c21DiagnosticChecks`; `python -m unittest discover -s mobile/tool -p test_verify_apk_icons.py`; `python mobile/tool/verify_apk_icons.py <apk>`. Build: `flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443 -v` y equivalente `--release`. Guard Gradle MaterialIcons sigue obligatorio en assembleDebug. Warnings AGP/Kotlin preexistentes y aviso de tiles en tests no se resolvieron fuera de alcance.

Release: aapt2 badging confirma ausencia de application-debuggable. En libapp.so empaquetado para arm64-v8a, armeabi-v7a y x86_64 aparece el marcador positivo GeoGuide AI y no aparecen Probar voz CEFI ni geoguide/voice_diagnostic, buscando UTF-8 y UTF-16LE. Diagnóstico Dart eliminado del AOT; Android rechaza el canal mediante FLAG_DEBUGGABLE=false, con gate de política probado. No se afirma desaparición de todas las clases Kotlin del DEX ni ejecución física release. Firma debug preexistente: artefacto de comprobación, no distribución/Production Ready.

| APK | SHA-256 |
| --- | --- |
| mobile/build/app/outputs/flutter-apk/app-debug.apk | C0DB04E01093FCFC4A60D5D7AE335A00D62FF8CECA2B57D00104CA37CBE99D97 |
| mobile/build/app/outputs/flutter-apk/app-release.apk | F83926926346B5E1DA6EE273E8A29EA902B66EB5E97832EAD15905207CBF0AE8 |

Ambos corresponden al código de 3f0930c. La evidencia física anterior C2.1 corresponde al APK 0E10EFE53BFC323654F6497C40330F6B446748478A176284DF79CC2EB72124C1, no al binario final corregido.

## Clasificación de capacidades

| Escenario | Clasificación | Alcance |
| --- | --- | --- |
| Cámara normal, gates/exclusividad B1, entrega C1 y adapter C2 | IMPLEMENTED_AND_AUTOMATED_PASS | Políticas y dobles; no calibración dinámica |
| B1/B1.1 estacionario HONOR/API 36 | PHYSICALLY_VALIDATED_STATIONARY | Histórico: inicio, notificación, Home, bloqueo/desbloqueo, Stop y observaciones ADB delimitadas |
| Iconos y cierre de lista | PHYSICALLY_VALIDATED_STATIONARY | Confirmación humana/capturas en APK anteriores; regresiones PASS |
| C2.1 voz única/COMPLETED/Stop activo/Home/revocación | PHYSICALLY_VALIDATED_STATIONARY | Diagnóstico fijo; no proximidad real |
| Avisos reales por proximidad | NOT_VALIDATED | Ensayos previos BLOCKED_NO_ELIGIBLE_POI; no candidatos artificiales |
| Convivencia con Waze/Maps/llamadas/música | NOT_VALIDATED | No extrapolar de foco concedido al diagnóstico |
| Liberación física independiente de foco/TTS | NOT_VALIDATED | Acuses y silencio posterior observados; sin medición independiente |
| Seguimiento prolongado, Doze, batería, revocación Android real, proceso/reinicio y otras API físicas | NOT_VALIDATED | Política/tests no sustituyen hardware |
| Dinámica, conducción y calibración | NOT_VALIDATED | No autorizadas ni ejecutadas |
| Continuo sin ruta, cámara pasiva Driving, wiring de POIs elegidos y voz propia futura CEFI | DEFERRED | Fuera del paquete integrado |

## Trazabilidad y riesgos

Se conservan commits e historia de fallos/correcciones sin squash ni force push. NOT_EXECUTED en documentos antiguos refleja su preparación, no todo el estado actual. Referencias: [B1](B1-Active-Route-Session-Implementation-Evidence.md), [B1.1](B1.1-UX-Hardening-and-CEFI-Alert-Readiness.md), [C1](C1-CEFI-Alert-Delivery-Core-Evidence.md), [C2](C2-CEFI-Voice-Alerts-Implementation-Evidence.md), [iconos](C2-Material-Icons-Packaging-Hotfix-Evidence.md), [lista](C2-POI-List-UX-Hotfix-Evidence.md), [C2.1](C2.1-Controlled-Voice-Diagnostic-Evidence.md).

Persisten riesgos OEM/Doze, disponibilidad de voz, permisos/canales revocados, energía, calibración, convivencia audio y distribución. No se promete supervivencia universal ni batería de viaje. Llegada automática a destino no se añadió: Stop/caducidad están cableados. P12.5 NOT_AUTHORIZED y P12 permanece en curso al 45%; P11-BACKUP-01 sigue abierto.

[Descripción de PR preparada](GPS-CEFI-Functional-PR-Draft.md). Siguiente decisión humana: autorizar push y creación del PR para revisión; no implica merge, distribución, congelación de contrato ni carretera.
