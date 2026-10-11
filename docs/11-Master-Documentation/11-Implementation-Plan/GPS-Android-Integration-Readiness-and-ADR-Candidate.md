# GPS Android Integration Readiness y ADR candidato

Fecha: 2026-10-10. Estado: PROPOSED_NOT_APPROVED. Baseline: e19e17212c48ecf1b9604c512cac4f5b9fb64686. Rama existente: feature/gps-camera-tracking-proximity-core. Documento de revisión local; no habilita manifest, servicio, dependencias, voz, continuo sin ruta, Driving pasivo, campo, push o PR.

## Auditoría A/B/C

Se revisó el diff completo de nueve archivos contra baseline: extensión de muestra y adapter existente, política de cámara, wiring del mapa normal, manager/puerto, evaluador/alerta y pruebas/evidencia. Domain mantiene valores sin SDK; Application contiene políticas y puertos; Infrastructure mapea Geolocator; Presentation aplica objetivos de cámara. B/C no están conectados a producción. No SQL, filesystem, network ni logs en componentes nuevos. La ubicación se conserva transitoriamente; no hay historia persistida ni upload.

A: arco angular corto, suavizado por muestra, zoom por pasos, histéresis, valores configurables experimentales. No animación por frame/calibración física. Driving usa mapa separado y conserva InteractionFlag.none, sin nuevas acciones. Lifecycle foreground continúa cancelando/resuscribiendo; no demuestra background real. Se reforzó rechazo de callback durante pausa y rechazo de timestamp futuro/antiguo antes de avanzar watermark, evitando bloquear muestras posteriores.

B: cola serial, gates explícitos, exclusividad, generaciones, start/stop activo idempotente, revocación durante start, errores de stop => interrupted. Estado y modo ahora son getters, sin modificación externa de la máquina. Cancelación real, pérdida de proceso y FGS necesitan adapter y pruebas Android.

C: snapshot elegible, prioridad elegido/sugerido, incertidumbre, dirección/velocidad válida para sugeridos, cooldown, deduplicación y banda de histéresis. Corregido reset prematuro ante snapshot inválido de otra consulta; regresión sintética. No catálogo sin ruta; reset explícito al iniciar nueva sesión. Coordenadas de POIs no certifican cobertura geométrica ni map matching. Un candidato aceptado se marca anunciado al producir PoiAlert; entrega/ack/supresión del canal requieren frontera adicional antes de emitir notificaciones reales. Sin TTS ni canal de alertas productivo.

No se reclama cobertura exhaustiva Android ni PASS dinámico. Sin cambios de contrato congelado.

## Contabilidad de pruebas y UTF-8

Baseline registrado: 70. Primera ejecución: 78 (8 unitarios nuevos). Segunda: 81 (+2 unitarios y 1 widget). Se agregaron prioridad/cooldown y transición completa => 83. Último test de histéresis => 84 = 70 + 14 (13 unitarios + 1 widget). La frase anterior 13 añadidas era un conteo intermedio, no un test omitido. Revisión actual añade 1 unitario de snapshot inválido y extiende el widget existente, por tanto total final ejecutado: 85 PASS / 0 FAIL / 0 SKIP.

Los dos documentos nuevos contenían mezcla de secuencias UTF-8 y bytes CP1252. Se normalizaron a UTF-8 estricto conservando textos y acentos; no se cambian documentos históricos. Validación por decode estricto y búsqueda de replacement/mojibake.

## ADR candidato — servicio de ubicación Android

Estado PROPOSED, sin número ADR aceptado. Relacionado con ADR-027 y propuesta v0.2; no sustituye el GPS foreground congelado. Decisión recomendada para aprobación: adapter Kotlin nativo estrecho, LocationManager de plataforma y FlutterEngine propiedad del servicio para ejecutar políticas Dart reutilizadas; no duplicar proximidad en Kotlin. No incorporar SDK comercial. No se implementa ahora. Servicio propuesto `exported=false`, `stopWithTask=true`, retorno `START_NOT_STICKY`; sin receivers de boot/package-replaced ni token activo persistido.

| Alternativa | Ventajas | Coste/riesgo | Recomendación |
|---|---|---|---|
| Kotlin nativo + channels + engine del servicio | Control explícito de start/stop, permisos, notificación y lifecycle; sin paquete nuevo; location de plataforma | Mayor código Android y pruebas de teardown/engine/handshake; no garantiza por sí solo supervivencia OEM | Preferida para alcance Android mínimo y ownership auditable |
| flutter_foreground_task 11.0.3 | Servicio e isolate/puente UI documentados; mantenimiento reciente | Nueva dependencia permanente; revisar manifest fusionado, autostart y locks; no es proveedor de ubicación por sí solo | Alternativa viable, no instalada ni descartada |
| Geolocator existente sin owner de servicio | Reusa adapter actual | Stream ligado al lifecycle actual; no ejecuta por sí mismo proximidad Dart con UI suspendida | Insuficiente como integración completa |

El plugin documenta Flutter >=3.44, Dart >=3.12, Android >=21, Kotlin >=2.2.20 y Gradle >=8.11.1. Repo declara Dart ^3.13.2, Kotlin 2.4.0 y Gradle 9.3.1; compatibilidad de plugin no se ha ensayado. Sus ejemplos incluyen autoreinicio/locks que no deben copiarse sin revisión. [Fuente del mantenedor](https://pub.dev/packages/flutter_foreground_task). Kotlin reduce dependencia externa, pero necesita validar el comportamiento de LocationManager aproximado/preciso y motor headless; no se presenta como implementación probada.

## Matriz permisos y consentimiento Active Route Session

Propuesta limitada a inicio explícito desde Activity visible y continuación de la MISMA sesión. Sin arranque desde background, boot, alarma o restart automático.

| Android | Declaración propuesta | Runtime/consentimiento | Denegación/revocación |
|---|---|---|---|
| API 24–25 | COARSE/FINE existentes; servicio privado | Solicitud contextual; consentimiento sesión independiente | No start si ubicación denegada; cancelar al revocar |
| API 26–27 | Canal y notificación FGS; startForegroundService y promoción oportuna | Igual anterior | Stop y error seguro; no reintento silencioso |
| API 28 | Añadir FOREGROUND_SERVICE (normal) | Sin diálogo runtime para este permiso | No activar si preflight falla |
| API 29–30 | foregroundServiceType=location | Iniciar mientras app visible con permiso while-in-use | No arranque nuevo desde background |
| API 31–32 | COARSE+FINE cuando se solicita precisa; soportar aproximada | Usuario decide precisión; no exigir precisa para toda sesión | Degradar alertas/cámara por calidad; sin forzar ajustes |
| API 33 | Proponer POST_NOTIFICATIONS y consentimiento contextual | Recomendación producto: gate de visibilidad exige permiso/canal antes de sesión | Denegado => no iniciar esta propuesta; requisito de producto, no obligación OS |
| API 34–36 | Añadir FOREGROUND_SERVICE_LOCATION; tipo location; permisos antes de start | Comprobar servicios activos, COARSE o FINE efectivo e inicio visible | SecurityException/revocación => teardown, interrupted, acción explícita para reiniciar |

ACCESS_BACKGROUND_LOCATION = NOT_PROPOSED para este paquete de inicio visible/continuación. Su ausencia NO autoriza crear una nueva sesión desde background. Android diferencia permiso while-in-use y tipo de servicio; API34 exige tipo/permiso apropiado. [Tipos location](https://developer.android.com/develop/background-work/services/fgs/service-types), [restricciones de inicio](https://developer.android.com/develop/background-work/services/fgs/restrictions-bg-start).

POST_NOTIFICATIONS no es condición del SO para iniciar FGS: incluso denegado puede aparecer en Task Manager, no en drawer. El gate más estricto propuesto preserva stop visible. [Política Android](https://developer.android.com/develop/ui/views/notifications/notification-permission).

Consentimiento sesión: explica seguimiento mientras ruta activa, Home/pantalla bloqueada, duración hasta cancelar/finalizar, sin historial/upload y botón Detener. Consentimiento ubicación/precisión del SO es separado. Alertas y voz requieren opt-in separados; próximo paquete no incluye voz ni alerta audible. Revocar cualquier consentimiento aplicable detiene su capacidad. Force-stop/Task Manager/muerte de proceso => sesión terminada; no restaurar token/estado activo de disco. [Stop por usuario](https://developer.android.com/develop/background-work/services/fgs/handle-user-stopping). Sin RECEIVE_BOOT_COMPLETED, battery exemption, exact alarms o wake lock propuestos inicialmente. Google Play puede aplicar revisión de ubicación background incluso con FGS: [política de distribución](https://support.google.com/googleplay/android-developer/answer/9799150); aprobación de sideload no aprueba Play.

## Wiring mínimo propuesto — siguiente paquete B1

1. UI normal obtiene consentimiento y ruta/snapshot elegible; envía StartRouteSession con query/POIs/config y token efímero por canal privado. No GPS por network ni serialización a disco. Evitar logs de payload.
2. Activity visible verifica permisos y arranca servicio privado location. Servicio promueve notificación inmediatamente y crea engine headless dedicado; hasta handshake no solicita ubicación. Timeout/fallo => stop, no sesión fantasma.
3. Un único coordinator Dart en el engine del servicio posee TrackingSessionManager y POIProximityEvaluator. El puerto Kotlin start inicia LocationManager; stop quita listener y espera ack mientras engine vive. UI es observer/command client, NO crea segundo manager. Transferencia explícita cancela foreground stream antes de iniciar otro; salida/fin recupera foreground solo por acción explícita.
4. Cada sample usa generation/session token. Coordinator valida snapshot/consent y calidad, evalúa proximidad en memoria. PoiAlert va a un AlertSink neutral; primer B1 usa sink silencioso y estado visual en modo normal, sin TTS ni notificaciones POI reales. Si hay supresión, requerir reserva/ack o política explícita de descarte; no afirmar entrega por solo evaluar.
5. UI observa último valor efímero para marcador/cámara normal. Driving sigue mapa/restricciones anteriores. Home no detiene owner de servicio; detachment UI no rompe sesión. Servicio mantiene controles Detener vía notificación y acción en app fuera de Driving.
6. Stop/finalización/revocación invalida generaciones, cancela listener, borra snapshot/IDs/última muestra en memoria, ack al coordinator, quita notificación y destruye engine después; stop de usuario/muerte no reinicia. Dos owners activos es FAIL, nunca fallback silencioso. La acción nativa Detener cancela LocationManager aun si Dart no responde; teardown tiene timeout acotado configurable y termina el engine después, sin esperar indefinidamente. Valores de timeout/frecuencia y consumo necesitan criterios antes de distribuir.

Archivos futuros previsibles: Kotlin servicio/bridge y manifest (gate), adapter Dart de TrackingServicePort, coordinator application, canales de estado/AlertSink, composición app y pruebas Android. No implementar ahora ni instalar plugin. No cambiar APIs/DB/infra ni P12. Geolocator foreground anterior permanece fallback explícito fuera de sesión; no debe coexistir como segunda fuente.

## Evidencia exigida a B1 y decisiones mínimas

Tests de handshake/timeout/stop ordenado, exclusividad/late callbacks, snapshot vencido, consentimiento revocado, cambio precisión, notificación bloqueada, Activity recreate, Home/lock/return, stop Task Manager, proceso terminado/reboot sin autostart. Emulador API33/34/36 más estacionario HONOR autorizado; no conducción. Medición delimitada de callbacks en background sin guardar coordenadas; manifest fusionado exacto, APK hash, ausencia de upload/historia y recursos cerrados. No sustituir batería/privacidad Android por fixtures. Rollback APK previo preservando datos, detener servicio antes, no pm clear.

Aprobar específicamente: (1) ADR Kotlin/engine-service y paquete B1; (2) adiciones FOREGROUND_SERVICE/FOREGROUND_SERVICE_LOCATION y POST_NOTIFICATIONS con gate visible; (3) consentimiento/stop y validación estacionaria. Proximidad productiva requiere parámetros y política de entrega aparte; TTS, continuo, cámara Driving y campo mantienen gates independientes. No se necesita decidir LLM, proveedor externo o backend para B1.

P12, Photon, Excel, contratos congelados y permisos actuales permanecen intactos. Sin push/PR/merge.

## Seguimiento de integración

PR #76 integrado en `8a2e6cad14f2ae88111c0ba17dd89241894a5ee6`. Este ADR continúa candidato y la arquitectura autorizada para B1 sigue provisional. Véase [gobierno post-merge](GPS-CEFI-Post-Merge-Governance-Evidence.md); los estados de preparación anteriores se preservan como historia.
