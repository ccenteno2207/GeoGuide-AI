# C2 — Avisos de voz CEFI: implementación y validación

Fecha: 2026-10-10. Autorización: implementación C2, pruebas y commits locales. Sin push, PR, merge, instalación ni pruebas de carretera.

## Procedencia y alcance

- Rama: feature/gps-camera-tracking-proximity-core.
- HEAD de entrada verificado: 928faf12f99dbbdeacafb7b1ffa5ebe44f64e8ec.
- origin/main verificado: e19e17212c48ecf1b9604c512cac4f5b9fb64686.
- Worktree de entrada: CLEAN.
- Commit funcional C2: c7ad74d77b80ffcc4ddbb821490087d2888c68c3.
- Entrada técnica: [C1](C1-CEFI-Alert-Delivery-Core-Evidence.md) y [B1.1](B1.1-UX-Hardening-and-CEFI-Alert-Readiness.md).
- ADR-027 y Entrega 04.6: adaptador sustituible; reglas compartidas fuera de la pantalla y del proveedor de voz.
- P12.5 sigue NOT_AUTHORIZED. P11-BACKUP-01 sigue OPEN_DEFERRED.

## Arquitectura implementada

POIProximityEvaluator → ActiveRouteCoordinator → CEFIAlertDeliveryCoordinator → AndroidCEFIAlertDelivery → MethodChannel del worker → RouteVoiceAdapter → VoiceDeliveryController → AndroidVoiceOutput.

C1 conserva detección, prioridad, deduplicación, histéresis, cooldown tras DELIVERED y límites de un evento en vuelo/un pendiente. El adaptador no calcula proximidad ni incorpora otra cola o reintentos. El productor GPS B1 permanece único.

VoiceDeliveryController es una máquina de entrega independiente de Android, serializada en main por el adaptador real y probada con dobles verificables. El token correlaciona eventId, generación, revisión de snapshot y vencimiento. Android añade un utteranceId único por invocación; callbacks viejos no completan otro evento.

RouteSessionService es dueño del motor y del foco durante la sesión activa, incluidos Home/pantalla bloqueada. El cierre nativo detiene voz, libera foco y llama shutdown incluso cuando un acuse de canal falla; el worker/engine se destruyen como en B1.

## Consentimiento y modo silencioso

- Desactivado por defecto; solo memoria, sin preferencias persistentes.
- Botón de altavoz exclusivamente en la interfaz normal. Activar exige un diálogo independiente y confirmación “Activar avisos”.
- Desactivar no exige otro consentimiento; cancela voz y eventos pendientes.
- El canal de consentimiento exige Activity visible.
- Stop/interrupción/terminación reinician el consentimiento a false; no hay reactivación silenciosa tras reinicio.
- El control no se incorpora al árbol Driving ni modifica su cámara/interacciones.
- Cambiar consentimiento invalida los eventos pendientes con cancelOutstanding; conserva los POIs ya consumidos, cooldown y antirrepetición de C1. No reproduce lo acumulado.
- Sin consentimiento, el adaptador real devuelve SUPPRESSED sin solicitar foco ni hablar. SilentAlertSink de C1 permanece disponible para pruebas; C2 no utiliza su DELIVERED simulado como prueba de voz.

## Voz local y foco

Android TextToSpeech selecciona una voz española marcada como local, sin networkConnectionRequired ni datos pendientes de instalación. Se prefiere locale PE si existe; no se descargan voces ni se abren asistentes de instalación. Si no hay voz disponible, la sesión GPS continúa silenciosa. Una excepción al crear el motor tampoco invalida la sesión GPS.

Mensaje factual: “CEFI. Lugar cercano: <nombre del POI>.” El nombre procede del candidato elegible, se eliminan controles y se limita a 120 caracteres para acotar salida; no se inventan distancias, historia ni recomendaciones. No hay micrófono, STT, LLM, grabación o archivo de síntesis. No se pasan coordenadas al motor TTS.

Foco: AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK, atributos USAGE_ASSISTANCE_NAVIGATION_GUIDANCE / CONTENT_TYPE_SPEECH, sin ganancia demorada. Se usa la misma solicitud para adquirir y abandonar foco. Pérdida permanente, transitoria o duck cancela el aviso; recuperar foco no lo reproduce. No se cambian volúmenes ni ajustes del sistema.

| Situación | Resultado |
| --- | --- |
| Sin consentimiento, motor no disponible o foco denegado | SUPPRESSED, sin DELIVERED |
| speak aceptado / onStart | Continúa ACCEPTED; no consume |
| onDone correlacionado antes de vencer | DELIVERED; C1 consume e inicia cooldown |
| Error TTS o excepción de foco/speak | FAILED |
| Revocación, Stop o cancelación del evento | CANCELLED |
| Vencimiento del evento | EXPIRED |
| Acuse/token viejo o incorrecto | No completa el evento actual |
| Stop/abandono de foco no confirmado | FAILED y salida bloqueada; se cierra motor |

La cancelación C1 espera el resultado de voiceCancel. Si la detención no queda confirmada, recibe error y mantiene su barrera cerrada. No hay reproducción en lote, reintento automático o escucha de micrófono. La expiración nativa complementa el deadline C1 sin crear un nuevo límite de producto.

## Android y privacidad

El único cambio de manifest fuente es una consulta de visibilidad android.intent.action.TTS_SERVICE. Los uses-permission permanecen idénticos al baseline C1. No se añaden tipos de foreground service ni dependencias permanentes. El runner JVM reutiliza Kotlin stdlib ya disponible en el classpath del compilador.

Sin persistencia de eventos, historial GPS, logs de coordenadas, texto hablado en logs propios ni subida de ubicación. El transporte local de muestras B1 hacia la UI se conserva. La voz depende de la implementación del motor instalado; la selección se basa en metadatos Android de voz local, sin garantizar comportamiento de motores de terceros.

Fuentes oficiales consultadas:
- [TextToSpeech](https://developer.android.com/reference/android/speech/tts/TextToSpeech): inicialización, shutdown y consulta de motores en manifest.
- [UtteranceProgressListener](https://developer.android.com/reference/android/speech/tts/UtteranceProgressListener): onDone y callbacks por utteranceId.
- [Audio focus](https://developer.android.com/media/optimize/audio-focus): foco transitorio, callbacks y abandono; Android 15+ exige app superior o foreground service para solicitar foco.

## Validaciones y correcciones

| Control | Resultado real |
| --- | --- |
| dart format lib/test | 64 archivos, 0 cambios pendientes |
| flutter analyze --no-pub | PASS, sin incidencias |
| Suite Flutter completa | 118/118 PASS: 111 C1 + 7 pruebas de integración C2 |
| b1PolicyChecks | 50 assertions PASS |
| c2VoiceChecks | 80 assertions PASS, controlador real con dobles TTS/foco |
| Compilación Kotlin / controles JVM | BUILD SUCCESSFUL |
| APK debug HTTPS | PASS |
| git diff --check | PASS |
| Permisos fuente / archivos de dependencias | Sin cambios |
| Android físico C2 | NOT_EXECUTED; APK no instalado |

Cobertura Flutter: consentimiento cancelado/aceptado/revocado por UI sin iniciar GPS, aislamiento de productores B1.1, Driving sin controles alternativos (regresión existente), finalización por canal, prioridad elegido/sugerido, payload sin coordenadas, cooldown, FAILED/SUPPRESSED sin consumo, revocación con cancelación de pendiente/en vuelo, Stop, token equivocado y CANCELLED/EXPIRED diferenciados.

Cobertura nativa: silencio por defecto, motor no disponible, foco concedido/denegado/perdido, exclusividad, onDone correcto, generación/revisión equivocadas, callbacks duplicados/tardíos, error de speak/motor, excepción de foco, consentimiento revocado, cancelación, cierre, expiración, fallo de stop/abandono y cierre aunque falle el acuse. Los dobles no prueban altavoces, motor instalado, audio de otras apps ni políticas HONOR.

Correcciones durante validación: ajuste del runner JVM para usar stdlib del classpath de compilación en vez de resolver variantes Android runtime ambiguas; bloque de lint Dart; cierre ante fallos de cancelación/abandono, aislamiento de excepción de inicialización y protección del deadline contra entregas nativas simultáneas. No se cambió arquitectura ni se añadió librería.

APK: mobile/build/app/outputs/flutter-apk/app-debug.apk.
SHA-256: 0FBEC80949B174D41096A6DC4B1F0CADAEB6F200E865A637F9D098AF839DB886.
Manifest fuente SHA-256: 40DA0EA6EE2C76EB58B8A3726049C87526CAACEABE337E2E72C3F571B8B18A8E.
Manifest debug fusionado SHA-256: 49C0B7827F12E0B68E923B99D76D894AED36EFE75973F5C02E8B1447BA90A180.
Comando final: flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443.

## Archivos C2

- mobile/lib/features/tracking/infrastructure/android_cefi_voice.dart (nuevo).
- mobile/lib/features/tracking/infrastructure/route_session_worker.dart.
- mobile/lib/features/tracking/infrastructure/android_route_session.dart.
- mobile/lib/features/tracking/application/route_session_client.dart.
- mobile/lib/features/tracking/application/cefi_alert_delivery_coordinator.dart.
- mobile/lib/features/map/presentation/base_map_page.dart (UI normal; Driving intacto).
- mobile/android/app/src/main/kotlin/com/geoguideai/geoguide_ai/VoiceDeliveryController.kt (nuevo).
- mobile/android/app/src/main/kotlin/com/geoguideai/geoguide_ai/AndroidVoiceOutput.kt (nuevo).
- mobile/android/app/src/main/kotlin/com/geoguideai/geoguide_ai/RouteVoiceAdapter.kt (nuevo).
- mobile/android/app/src/main/kotlin/com/geoguideai/geoguide_ai/MainActivity.kt.
- mobile/android/app/src/main/kotlin/com/geoguideai/geoguide_ai/RouteSessionService.kt.
- mobile/android/app/src/main/AndroidManifest.xml (queries únicamente).
- mobile/android/app/build.gradle.kts (runner de pruebas).
- mobile/android/app/src/test/kotlin/com/geoguideai/geoguide_ai/C2VoiceChecks.kt (nuevo).
- mobile/test/features/tracking/c2_voice_test.dart (nuevo).
- mobile/test/features/tracking/b1_widget_test.dart.
- Esta evidencia.

## Protocolo B1.1 + C1 + C2: una instalación estacionaria supervisada

Estado: PREPARED, NOT_EXECUTED. Requiere autorización humana del APK/hash anterior antes de cualquier instalación. No conducción, simulación de movimiento ni inyección de POIs/samples en datos del móvil.

1. Verificar HONOR LLY-NX3/API 36, APK/hash, firma compatible, estado de ruta/caché y ausencia de sesión activa. No registrar identificadores personales ni coordenadas.
2. Con confirmación humana, adb install -r preservando datos. No pm clear, desinstalación, borrado ni cambios de permisos por ADB. Detener ante incompatibilidad de firma.
3. Abrir app: mapa y datos existentes; voz desactivada. Cancelar el diálogo de voz y confirmar silencio. Activar solamente con consentimiento manual en modo normal.
4. Seleccionar/conservar una ruta y snapshot reales elegibles. Iniciar recorrido con consentimiento GPS y permisos Android manuales. Confirmar notificación persistente y un único productor.
5. B1.1: controles normales de ubicación deshabilitados y motivo comprensible; estados iniciando/activo/interrumpido/detenido. Home → retorno; bloqueo de dos minutos → desbloqueo. No extrapolar a autonomía de viaje.
6. Driving estacionario: entrar tras activar sesión/voz, confirmar ausencia del nuevo control y controles secundarios, restricciones de interacción y salida explícita. No cambiar cámara Driving.
7. C1/C2 audible: solamente si muestras físicas válidas producen un POI genuinamente elegible. Observar un mensaje breve y correcto, finalización, ausencia de solapamiento/duplicados; revocar voz fuera de Driving y confirmar cese sin reproducción posterior. No publicar ubicación ni grabar audio.
8. Si el corpus/ruta/posición o la calidad/dirección/velocidad no permiten un candidato, registrar BLOCKED_NO_ELIGIBLE_POI para voz física. El worker actual no suministra chosenIds y el evaluador exige movimiento/dirección fiables para sugeridos: una prueba estacionaria puede no emitir voz. No forzar candidato, ruido GPS ni desplazamiento. Las pruebas automatizadas de C1/C2 no sustituyen esa evidencia.
9. Con otro audio permitido y observador estacionario, comprobar coexistencia únicamente si existe candidato real. Registrar efecto y cancelación; no afirmar denegación/pérdida de foco si no se observó. Escenarios no reproducibles: NOT_VALIDATED, conservando la evidencia de dobles.
10. Detener desde notificación; verificar desaparición del servicio/notificación, ausencia de voz posterior y consentimiento desactivado. Repetir inicio y Stop desde app, sin borrar datos.
11. Registrar PASS/FAIL/BLOCKED/NOT_VALIDATED por caso, tiempos mínimos de correlación y observaciones manuales. Sin grabaciones, coordenadas o historial de viaje.

Abortar ante calor, consumo anómalo, distracción, voz después de Stop/revocación, solapamiento, caída o sesión que no se detiene. Usar Detener en notificación/app; si no responde, informar y pedir intervención manual. No recurrir a borrado o permisos ADB.

## Riesgos y siguiente gate

La disponibilidad de voz española offline, latencia/fiabilidad del motor, volumen configurado, salida Bluetooth, llamadas, Waze/Maps y suspensión OEM HONOR requieren evidencia física. MAY_DUCK no garantiza convivencia perfecta ni prioridad sobre otra navegación. No se garantiza rendimiento o batería sin medición suficiente.

La selección de POIs elegidos todavía no está cableada desde UI al worker (limitación heredada C1); los sugeridos conservan los gates físicos de dirección/velocidad. No se amplió esa capacidad para hacer pasar la prueba.

READY_FOR_CEFI_VOICE_STATIONARY_VALIDATION significa código y pruebas listos, no PASS físico. Siguiente gate: autorización humana de instalación del APK identificado y supervisión estacionaria. P12.5, pruebas dinámicas y conducción siguen NOT_AUTHORIZED.
