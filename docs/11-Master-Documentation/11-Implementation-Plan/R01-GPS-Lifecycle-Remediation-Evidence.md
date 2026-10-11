# R01 — remediación de frescura y lifecycle GPS

## Alcance y baseline

Autorización humana R01 de 2026-10-11: implementación, regresiones, evidencia,
publicación y merge normal condicionado a controles satisfactorios.
Baseline verificado: `384d318763a0d12cc610bbee16459b101e4e7479`.
Rama: `investigation/r01-gps-lifecycle-20261011`, en worktree aislado.
Commit funcional: `73eaff5f19ce512033cc4cf2afbef8d71aa9f450`.
Referencia de discovery: `GPS_CEFI_DISCOVERY_COMPLETE_WITH_GAPS`.

El checkout original conserva su modificación en `infrastructure/compose.yaml`.
No se cambia Android nativo, manifiesto, permisos, POIs, TTS/audio focus,
Driving, backend, infraestructura, contratos congelados, documentación externa
ni Excel. P12 permanece IN_PROGRESS al 45%; P12.5 NOT_AUTHORIZED y
P11-BACKUP-01 OPEN_DEFERRED. No se otorga crédito adicional.

## Defectos y correcciones

| Hallazgo confirmado | Remediación mínima |
| --- | --- |
| R01-01: el estado de ubicación permanecía activo sin muestras ni errores después del límite de frescura | Un único temporizador sustituible vence según maxAge existente (10 s). Reloj inyectable para pruebas. Se distingue la frescura de ubicación de la sesión B1: el servicio no se detiene por silencio. Una muestra válida nueva restablece el estado; muestras vencidas, futuras, inválidas o duplicadas no mueven la cámara ni renuevan el plazo. Tampoco se recentra usando la última posición vencida. |
| R01-02: el refresh asíncrono dejaba una ventana para iniciar el productor normal antes de confirmar ownership nativo | Ownership pendiente desde init y al regresar a foreground; solicitudes y seguimiento normales bloqueados. Cancelación serializada y esperada antes de resolver el estado o transferir ownership. Las respuestas y errores del productor normal se filtran por revisión. El fallo de refresh mantiene el bloqueo; una comprobación válida posterior permite recuperación. |
| R01-03: una respuesta antigua de refresh podía restaurar active después de Stop | Revisión monotónica del cliente: Stop, inicio, refresh, consentimiento y notificaciones de estado nativo invalidan respuestas anteriores. Un refresh superado termina con StateError, sin aplicar estado ni consentimiento. La pantalla invalida recuperaciones al pausarse/destruirse y desconecta callbacks. La finalización de inicio no vuelve a marcar la pantalla activa si el cliente ya fue detenido. |

Precedencia: la operación o estado nativo más reciente invalida los resultados
pendientes anteriores. Una revocación o Stop invalida el consentimiento anterior.
Los callbacks de una pantalla destruida no se restauran. El orden de cancelación
del stream es una barrera efectiva, no una suposición basada en hasListener.
Ante incertidumbre se bloquea la creación de un nuevo productor; regresar a la app
permite repetir la comprobación. No se añaden reintentos automáticos ni persistencia.

Archivos funcionales: `mobile/lib/app/app.dart` (inyección del reloj),
`mobile/lib/features/map/presentation/base_map_page.dart` (frescura, barrera y
lifecycle) y `mobile/lib/features/tracking/infrastructure/android_route_session.dart`
(revisiones del canal existente). No se cambia la arquitectura Android provisional.

## Regresiones y reproducción

El archivo de investigación pendiente de versionar se conserva y transforma en
aceptación: `mobile/test/features/tracking/r01_investigation_test.dart`.
Las seis caracterizaciones originales reproducían los defectos; su PASS histórico
significaba reproducción, no corrección. Se ejecutaron antes de la remediación.
SHA-256 original: `3A08840471642305A81550053ED449367E5931954266ECD8AE8233C99A1AFA83`.

La aceptación cubre reloj controlado, silencio normal/B1, recuperación por muestra
válida, silencio sin primera muestra, rechazo de datos vencidos/futuros/inválidos
y duplicados, cámara vencida, refresh pendiente, B1 confirmado, Stop con respuestas
antiguas de refresh/inicio/consentimiento, respuestas en orden inverso, error de
refresh y recuperación, petición puntual tardía, dispose y cancelación diferida
real del doble de stream. Ubicaciones y plataforma son sintéticas; no se usa dispositivo.

Las pruebas anteriores de ubicación declaran explícitamente un owner nativo inactivo
y esperan su resolución; no se interpreta MissingPluginException como permiso.
La prueba del mapa proporciona el directorio de caché de plataforma.
La regresión B1 espera el refresh antes de enviar muestras tras resume.
No se eliminan aserciones funcionales ni se modifica el árbol de interacción Driving.

## Validación

| Control | Resultado |
| --- | --- |
| Baseline y checkout original | PASS; origin/main sin avance; compose.yaml original preservado |
| Format | PASS; 68 archivos formateados |
| Analyze | PASS; sin incidencias |
| Flutter completo | PASS; 149/149 = 132 baseline + 17 regresiones R01 |
| Regresiones R01 tras ajuste del doble de plataforma | PASS; 17/17 |
| JVM B1/C2/C2.1 | PASS; B1 50, C2 80 y C2.1 43 aserciones; JDK 21 |
| Build debug HTTPS | PASS; compilación final incremental tras cerrar el código |
| Verificador de assets | PASS; 5/5 tests; APK con 1.645.184 bytes de MaterialIcons y 11 assets Flutter |
| Driving | PASS; cuerpos de enter/exit/build idénticos al baseline; regresiones completas preservadas |
| Diff, UTF-8 y enlaces | PASS; solo alcance Dart/tests/evidencia/índice |
| Validación física R01/V01 | NOT_EXECUTED |

APK final: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
SHA-256: `91C8809C796254325BF8762E60DFFE95ACB7F89A92A68B68B80062ADEB8DB321`.
No se instala, distribuye ni incluye en Git.

Los fallos durante desarrollo se corrigieron: fixtures de ownership/caché,
orden de espera asíncrona, cierre del stream sintético, formato/lints y eliminación
de un texto adicional que desplazaba el botón de Driving. Ningún fallo permanece
abierto ni se elimina una aserción para obtener PASS. Los cuerpos de Driving y el
adaptador TTS/audio focus permanecen sin modificación.

SHA-256 de compose.yaml original, verificado sin escribirlo:
`2DEE319C09E2AE8FCAD40F16873F7203BAB4F56D37BF753181B4436CD7E5B448`.
El diagnóstico C2.1 conserva sus gates Dart kDebugMode, exclusión de Driving y
FLAG_DEBUGGABLE nativo. No se recompila release ni se atribuye evidencia física nueva.

Comandos desde `mobile`: `dart format lib test`,
`flutter analyze --no-pub`, `flutter test --no-pub`,
`python -m unittest discover -s tool -p test_verify_apk_icons.py`.
Build preparatorio: `flutter build apk --debug --no-pub
--dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`.
Verificación: `python tool/verify_apk_icons.py build/app/outputs/flutter-apk/app-debug.apk`.
Controles JVM desde `mobile/android`: `gradlew :app:b1PolicyChecks :app:c2VoiceChecks :app:c21DiagnosticChecks --max-workers=2`, con JDK 21.
También `git diff --check`, validación UTF-8 y enlaces relativos.

## Clasificación y riesgos residuales

- IMPLEMENTED_AND_AUTOMATED_PASS: las tres remediaciones R01; controles anteriores completados.
- NOT_VALIDATED: R01 en dispositivo físico, recreación real de Activity, señal
  silenciosa real, seguimiento prolongado, Doze, batería y recuperación bajo
  restricciones HONOR; alertas de proximidad real, convivencia con otro audio y
  liberación física independiente de audio focus.
- PHYSICALLY_VALIDATED_STATIONARY: únicamente la evidencia histórica B1/C2/C2.1,
  correspondiente a APK previos; no constituye validación física de este APK.
- DEFERRED: seguimiento continuo sin ruta y capacidades fuera de R01.

El límite de frescura existente es una configuración experimental, sin calibración
física nueva. Un timer Dart en la UI no garantiza ejecución durante suspensión del
proceso: al volver se consulta ownership y se reevalúa frescura con timestamps.
Una indisponibilidad del canal mantiene los controles normales bloqueados hasta
una comprobación válida. No garantiza entrega continua de GPS por Android.
Warnings preexistentes de toolchain/tiles no equivalen a aceptación física.

## V01 preparado, sin ejecución

1. Obtener autorización específica para el APK final y comprobar identidad/hash,
   dispositivo y ausencia de sesión; no instalar automáticamente.
2. Supervisión estacionaria: comprobar arranque y ownership inicial; una sesión
   explícita B1 mantiene indisponible el productor normal durante Home/retorno y
   recreación de Activity mediante procedimiento posteriormente autorizado.
3. Observar falta de señal solo si ocurre naturalmente, sin inyectar coordenadas:
   ubicación sin actualización reciente, sesión independiente, cámara sin usar
   una posición vencida y recuperación con señal válida. Registrar BLOCKED si no
   puede observarse; no fabricar PASS.
4. Detener desde app/notificación en ensayos separados y comprobar limpieza por
   ADB de solo lectura y ausencia de voz posterior; ninguna respuesta antigua
   debe restaurar la sesión o consentimiento.
5. No conducción, movimiento simulado, nuevos permisos ni cambios de código.

V01 NOT_EXECUTED. No se declara Production Readiness ni se autoriza P12.5.
El SHA definitivo del merge y verificación post-merge se registran en el PR y en
el informe de integración, evitando una cadena de PR documentales de cierre.
