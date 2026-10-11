# Descripción preparada — no se ha creado PR

Título propuesto: `feat(mobile): GPS camera, active route sessions and opt-in CEFI voice`

Base prevista: `main` (`e19e17212c48ecf1b9604c512cac4f5b9fb64686`). Rama: `feature/gps-camera-tracking-proximity-core`. Requiere autorización humana posterior para push y creación de PR; merge no autorizado.

## Descripción

GeoGuide AI incorpora una sesión GPS de ruta iniciada explícitamente que continúa al pasar a Home o bloquear la pantalla y puede detenerse desde la app o la notificación. El servicio Android location privado posee un único productor, un FlutterEngine dedicado y el coordinador de proximidad Dart; exige snapshot elegible, permisos y consentimiento. No restaura sesiones tras terminación o reinicio ni solicita ACCESS_BACKGROUND_LOCATION.

La cámara del mapa normal incorpora heading-up suavizado y zoom por velocidad con validación de calidad e histéresis. Driving mantiene su implementación e interacciones anteriores. Los controles normales de ubicación quedan deshabilitados mientras el recorrido posee el GPS; un nuevo guard impide iniciar la sesión mientras está pendiente la solicitud normal de ubicación.

C1 limita la entrega a un evento en vuelo y uno pendiente, separa detección de confirmación y rechaza acuses tardíos. C2 añade voz española local voluntaria y revocable, con Android TTS y audio focus: DELIVERED exige finalización, no solo aceptación. C2.1 ofrece un diagnóstico fijo únicamente debug y fuera de Driving. Incluye correcciones de arranque, empaquetado MaterialIcons y cierre accesible del panel POI, con sus regresiones.

## Validación

- Format y analyze PASS; suite Flutter 132/132 (131 previas más una regresión de exclusividad).
- JVM: B1 50, C2 80 y C2.1 43 aserciones PASS.
- Tests del verificador de assets 5/5 PASS; guard MaterialIcons sigue conectado a assembleDebug.
- Driving: métodos idénticos al baseline y regresión de UI real sin diagnóstico debug.
- Builds debug HTTPS y release PASS. APK release no depurable, AOT de las tres ABI sin texto ni canal Dart del diagnóstico y guard nativo por FLAG_DEBUGGABLE. Assets verificados en ambos artefactos. Sin instalación ni distribución.
- Evidencia estacionaria histórica HONOR LLY-NX3/API 36: B1 inicio/Home/bloqueo/Stop y limpieza delimitada; iconos y salida de lista; C2.1 mensaje único, COMPLETED, cancelación activa y Home, revocación. La corrección nueva de exclusividad no se ha instalado ni probado físicamente.

## Límites y riesgos

- Proximidad POI audible real NOT_VALIDATED: los ensayos anteriores quedaron BLOCKED_NO_ELIGIBLE_POI. El diagnóstico fijo no sustituye esa validación.
- Convivencia con navegación/llamadas/música y liberación física independiente del foco NOT_VALIDATED.
- Seguimiento prolongado, Doze, batería, revocación Android real, pérdida de proceso/reinicio y cobertura física de otras API NOT_VALIDATED.
- Valores de cámara, frecuencia y proximidad son hipótesis experimentales sin calibración dinámica. Cámara pasiva Driving, continuo sin ruta y wiring de POIs elegidos al worker DEFERRED.
- La arquitectura Kotlin/engine-service fue autorizada provisionalmente para B1; el contrato unificado continúa propuesto, sin congelarse por este trabajo.
- Release conserva la firma debug existente; es un artefacto de comprobación, no de distribución. La compatibilidad Google Play y firma productiva requieren su propio gate.
- Sin micrófono, STT, LLM, nuevas dependencias, historial de posiciones o transmisión continua. P12, Photon, backend, API, DB, infraestructura, contratos congelados y Excel sin cambios. P12.5 NOT_AUTHORIZED.

Evidencia consolidada: [GPS-CEFI-Functional-Branch-Consolidation-Evidence.md](GPS-CEFI-Functional-Branch-Consolidation-Evidence.md).
