# GPS Accelerated Delivery — Evidencia local de paquetes A/B/C

Fecha: 2026-10-10. Autorización: instrucción humana `ACCELERATED GPS + BACKGROUND TRACKING + CEFI DELIVERY` de esta conversación. No se congela la propuesta ni se autoriza integración operativa.

```ini
REFERENCE_BASELINE = e19e17212c48ecf1b9604c512cac4f5b9fb64686
IMPLEMENTATION_BRANCH = feature/gps-camera-tracking-proximity-core
DOCUMENT_BRANCH = docs/gps-camera-background-cefi-contract-20261010
CONTRACT = PROPOSED_NOT_APPROVED_V0_2
P12_CONTRACT = UNCHANGED
P12_5 = NOT_AUTHORIZED
PHOTON_SCOPE = UNCHANGED
LAB_08 = OPEN
PUSH = NOT_EXECUTED
PR = NOT_CREATED
MERGE = NOT_EXECUTED
```

## A — Cámara foreground

`LocationSample` transporta heading, velocidad y sus incertidumbres opcionales. El adapter Geolocator mapea los campos existentes sin nueva dependencia. `GPSCameraPolicy` centraliza rechazo de muestras no válidas, futuras, antiguas, repetidas y de mala precisión; suavizado por arco angular corto y pasos acotados de zoom, con histéresis de velocidad. En detenciones conserva zoom/orientación. El mapa normal aplica el objetivo; conserva pausa por gesto, reanudación explícita y cancelación del stream existente.

Valores experimentales del constructor, no criterios de aceptación aprobados: edad 10 s, precisión 50 m, velocidad mínima 2 m/s, incertidumbre heading 30°, incertidumbre velocidad 3 m/s, entrada/salida rápida 15/12 m/s, zoom 15/13, factor angular 0.25 y paso zoom 0.2. Son configurables mediante `GPSCameraConfig`; no hay calibración física, animación interpolada por frames, heading de brújula ni desplazamiento del vehículo fuera del centro. Driving mantiene mapa/cámara/restricciones previos: no utiliza esta política.

Commit local A: `2ac2a542c6a3c597b29d9821bd35923d66331988`.

## B — Núcleo de sesiones

`TrackingSessionManager` y `TrackingServicePort` son independientes de UI y SDK Android. Estados off/starting/active/stopping/interrupted; operaciones serializadas stop-await-start, exclusividad, gates explícitos, generaciones contra callbacks tardíos, revocación, cierre y finalización sin activación automática del otro modo. Un fallo de stop produce interrupted, no off. Las pruebas usan un servicio simulado, incluyendo start pendiente y fallos. No hay wiring del manager al stream productivo, FGS, notificación, reinicio persistente ni permiso nuevo. Los estados reales de disponibilidad Android, lifecycle background y UX de consentimiento requieren integración posterior autorizada.

## C — Núcleo de proximidad

`POIProximityEvaluator` solo consume un `RouteSnapshot` elegible. `ProximityConfig` exige parámetros explícitos de entrada/salida, precisión, edad, cooldown, dirección y calidad de velocidad; no hay valores productivos aprobados. Prioriza seleccionados sobre sugeridos y luego distancia/ID; sugeridos requieren curso/velocidad válidos y dirección compatible. Usa incertidumbre conservadora e histéresis espacial; mantiene deduplicación por ID durante la sesión/consulta, incluso si se reconstruye el snapshot de la misma consulta. `reset()` inicia una sesión limpia; cambiar consulta también reinicia. No hay catálogo sin ruta (U5 bloqueado), integración productiva, TTS, audio focus, notificaciones ni almacenamiento. `PoiAlert` es un contrato de datos de salida.

Los fixtures sintéticos no constituyen cobertura de POIs reales ni calibración de alertas.

## Validaciones realmente ejecutadas

| Control | Resultado |
|---|---|
| `flutter pub get` | PASS; manifiesto de dependencias y lockfile sin diff |
| `dart format --output=none --set-exit-if-changed mobile/lib mobile/test` | PASS, 53 archivos, 0 cambios |
| `flutter analyze` desde mobile | PASS, No issues found |
| `flutter test --reporter expanded` | PASS, 84 tests, 0 fallos, 0 skips reportados |
| `git diff --check` | PASS |
| Build debug HTTPS | PASS; assembleDebug 322.5 s |

Baseline tenía 70 tests. Se añadieron 13: 12 unitarios de políticas/núcleos y 1 widget que usa el controlador real del mapa para observar rotación, zoom, centrado, pausa por gesto, reanudación y detención. Las pruebas cubren timestamps inválidos, precisión, arco angular corto, detenciones, histéresis, exclusividad, idempotencia activa, transición pendiente, revocación durante start, callback anterior, cierre, error de stop, gates, prioridad, cooldown, snapshot vencido y deduplicación. La primera pasada analyze detectó 12 lints de llaves, corregidos; las pasadas finales son PASS. No se presenta cada estado de plataforma como probado por estos tests.

El format se limita a fuentes/tests; no se usa el directorio generado de build como fuente. Build: `flutter build apk --debug --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`. Compilar no verifica conectividad real con el endpoint.

## Privacidad, scope y gates

Nuevos componentes sin imports de filesystem/network, logs de coordenadas, almacenamiento de trayectorias ni upload. Datos de muestra se mantienen transitoriamente en memoria; deduplicación conserva IDs POI, no una historia GPS. No se ha verificado privacidad en un dispositivo ni se modifica el mecanismo foreground anterior. Sin cambios backend/API/DB/infra/AndroidManifest/dependencias, Excel, documentos externos o contratos congelados. Sin ADB, pruebas estacionarias/dinámicas, despliegue o progreso P12 atribuido.

Decisiones humanas pendientes: aprobar la propuesta v0.2; definir integración FGS/permisos/notificación/distribución y consentimiento por modo; gate independiente de continuo/catálogo sin ruta; autorizar cámara pasiva Driving; aprobar canal TTS/audio focus; parámetros y protocolo de calibración física. Push/PR/merge requieren nueva autorización.

El borrador v0.2 permanece en su rama documental previa sin commit; se reporta como archivo no versionado, no como contrato congelado. La evidencia y la implementación tienen commits locales únicamente.

## APK

Artefacto local: `mobile/build/app/outputs/flutter-apk/app-debug.apk` (ignorado por Git; no instalado).

SHA-256: `1B6C082BBBBF7B516CA732B86AA411F0AB6ADF17F5A5175D82621E297CA3D85F`.

Build completado con warnings no fatales de SDK XML, acceso nativo Java y source/target 8 de dependencias Android. No se cambiaron SDK, Java, Gradle ni configuración para silenciarlos.

## Inventario de archivos

A: `mobile/lib/features/location/domain/location_repository.dart`, `mobile/lib/features/location/infrastructure/geolocator_location_repository.dart`, `mobile/lib/features/location/application/gps_camera_policy.dart`, `mobile/lib/features/map/presentation/base_map_page.dart`, `mobile/test/features/location/gps_camera_widget_test.dart`.

B/C: `mobile/lib/features/tracking/application/tracking_session_manager.dart`, `mobile/lib/features/tracking/application/poi_proximity_evaluator.dart`, `mobile/test/features/tracking/accelerated_core_test.dart`.

Evidencia: este documento. Borrador contractual: un único archivo no versionado en la rama documental existente. Total implementación: nueve archivos (cinco A, tres B/C, uno evidencia).

Self-review: detectado y corregido el caso de idempotencia mientras hay transición en cola; deduplicación preservada al reconstruir snapshot de la misma consulta; calidad de velocidad exigida en sugeridos. Tests adicionales demuestran estos casos y la histéresis espacial de candidatos pendientes. Baseline remoto verificado nuevamente sin avance concurrente. Revisión humana pendiente; no se atribuye PASS Android a los fakes.

## Revisión Accelerated Core y readiness Android — 2026-10-10

Autorización humana posterior: auditar A/B/C, corregir menores/UTF-8, validar y preparar integración/ADR candidato. Sin nuevos permisos, FGS/TTS/continuo/Driving/campo/push/PR/merge. Baseline remoto reconfirmado e19e17212c48ecf1b9604c512cac4f5b9fb64686, sin delta.

Correcciones locales: snapshot inválido de otra consulta ya no borra deduplicación antes de su rechazo; estado/modo del manager de solo lectura; callbacks durante pausa y muestras futuras/antiguas no avanzan watermark del mapa. Widget extendido verifica muestra futura seguida de válida y lifecycle pausa/retorno. Nuevo unitario reproduce reset indebido. Commit: `37af1153db0ff5eafc4a26d02b5538ee5a78ef90`.

Reconciliación: 70 baseline + 14 anteriores = 84; 13 era conteo intermedio previo al test de histéresis. Esta revisión añade un unitario y extiende el widget, total **85 PASS / 0 FAIL / 0 SKIP**. Format lib/test: 53 archivos / 0 cambios. Analyze: No issues found. Diff check: PASS. Build APK HTTPS: PASS, assembleDebug 35.8 s; endpoint https://geoguide.getcom.pe:5443. Sin instalación ni conectividad/privacidad física probadas.

APK de esta revisión: `mobile/build/app/outputs/flutter-apk/app-debug.apk`; SHA-256 `AD52795F5E83771B528E1BDD578A8C322E9A4E9EA608720CF5072E105E3E4983`. El hash previo arriba es evidencia histórica del build anterior, no este artefacto.

Incidencias intermedias de edición/validación: getters renombrados accidentalmente, codificación en fuente/widget y fixture con corredor no permitido, corregidos antes de las verificaciones finales. Un intento de build desde raíz falló sin pubspec; se repitió desde mobile. No se presentan esas ejecuciones fallidas como PASS. No queda fallo sin resolver. Se conserva como límite la ausencia de ensayo Android real de B/C.

UTF-8: documentos nuevos tenían bytes CP1252 mezclados con UTF-8; normalizados conservando acentos y contenido. Decode UTF-8 estricto y ausencia de replacement/mojibake PASS en evidencia, readiness y borrador de rama documental. No se alteran fuentes históricas ni contratos congelados.

[Diseño mínimo y ADR candidato](GPS-Android-Integration-Readiness-and-ADR-Candidate.md): propietario único service-engine, Kotlin nativo recomendado frente a plugin mantenido; permisos/consentimientos por API y wiring/teardown propuestos. ADR PROPOSED; no se instala nada. Proximidad productiva precisa parámetros y política de entrega/ack; TTS/continuo/Driving/campo siguen gates independientes.

Archivos de este checkpoint: cinco fuentes/tests del commit de correcciones, esta evidencia y un readiness nuevo en rama funcional. En rama documental previa únicamente normalización UTF-8 del borrador v0.2, aún no versionado. Sin ramas adicionales, backend/API/DB/infra/dependencias/manifest/Excel ni modificaciones P12/Photon. Sin progreso P12 atribuido.

VERDICT = READY_FOR_ANDROID_INTEGRATION_GATE
