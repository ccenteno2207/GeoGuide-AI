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

## Retest físico autorizado — resultados consolidados

Entrada local: 2df0dda988cc433f467a8093d3bdbbcd7cb8b100. HONOR LLY-NX3,
Android API 36. APK instalado mediante adb install -r con Success, sin borrado de
datos ni cambios de permisos. El SHA-256 leído del base.apk instalado coincide
exactamente con 5E6DAFD27B4EAFC18FDF7F60BB8D9519BD5D001C7201D94441A891EC37563172.
Arranque Activity COLD: Status ok; interfaz disponible. Preflight técnico: servicio,
notificación y registros actuales de ubicación ausentes. Permisos de ubicación
precisa/aproximada y notificaciones ya concedidos, sin intervención por ADB.

| Escenario | Resultado | Procedencia de evidencia |
| --- | --- | --- |
| Instalación/hash/arranque | PASS | ADB, lectura de hash instalado |
| Ruta manual y lista | PASS | Confirmación humana, sin inyección |
| Abrir/cerrar ficha y desplazar lista | PASS | Confirmación humana |
| Cerrar lista y ver mapa | PASS | Confirmación humana; ruta y POIs conservados |
| Cancelar consentimiento CEFI | PASS | Confirmación humana; altavoz desactivado; UI ADB consistente |
| Inicio GPS explícito y consentimiento | PASS | Acción humana y estado activo por ADB |
| Notificación persistente y botón Detener | PASS | Humano y servicio foreground/notificación por ADB |
| Controles normales GPS deshabilitados | PASS | Humano: gris; UI ADB enabled=false en ambos controles |
| Exclusividad de controles/productor normal | PASS acotado | UI inhibida; arquitectura/pruebas previas de productor único, no conteo inferido de proveedores |
| Home y retorno | PASS | Confirmación humana: misma sesión activa; ADB confirma servicio posterior |
| Activar voz con consentimiento | PASS | Humano: cambio de icono; UI ADB Desactivar avisos de voz CEFI |
| Entrega audible de POI | BLOCKED_NO_ELIGIBLE_POI | Ningún POI genuinamente elegible/aviso observado en sesión estacionaria; no se fuerza candidato |
| Stop desde notificación | PASS | Acción humana; Recorrido detenido y icono iniciar por humano/ADB |
| Reinicio del consentimiento a desactivado tras Stop | PASS | Humano y UI ADB Activar avisos de voz CEFI |
| Limpieza servicio/notificación/ubicación | PASS acotado a ventana | Dos lecturas ADB posteriores separadas al menos cinco segundos |
| Ausencia de voz audible después de Stop | PASS observado | Confirmación humana; no prueba cancelación de una locución previamente activa |
| Voz real, finalización TTS y coexistencia de audio | NOT_VALIDATED | No se produjo locución real; dobles automatizados no sustituyen audio físico |
| Movimiento/conducción | NOT_EXECUTED | Fuera de autorización |

Durante la sesión, ADB confirmó RouteSessionService presente, isForeground=true,
una notificación del paquete y registros actuales de ubicación. Dos menciones del
paquete en la sección de proveedores no se interpretan como dos productores GPS:
esa salida no prueba exclusividad por sí sola. Se preserva el alcance de la prueba
de UI/exclusividad automatizada, sin atribuir datos personales o coordenadas.

Después de Stop, ambas lecturas mostraron servicio ausente, cero NotificationRecord
del paquete y ausencia del paquete en secciones actuales de Location Providers y
GNSS/geofences. No se usaron Event Log ni Historical Aggregate como prueba. La UI
mostró Recorrido detenido, Iniciar recorrido GPS disponible, Detener ausente y voz
desactivada. No se guardaron dumps completos, coordenadas, audio ni identificadores
personales. No se modificó código durante el retest ni se reinstaló otra versión.

BLOCKED_NO_ELIGIBLE_POI registra falta de candidato genuino observado para realizar
la prueba audible estacionaria, no una causa técnica demostrada del silencio. No
se afirma que el motor TTS local o el audio focus físico hayan pasado. Tampoco se
inspeccionó directamente la cola interna TTS: la limpieza del servicio y la ausencia
audible humana no equivalen a observar cancelación de un evento en vuelo.

Veredicto integral: C2_UX_STATIONARY_PARTIAL. Cierre físico de lista, consentimiento,
GPS/Home/Stop y limpieza observada: PASS. Voz audible real pendiente. No errores
nuevos reportados ni autorizaciones nuevas. Siguiente gate: resolver cómo obtener
evidencia audible genuina dentro de un alcance expresamente autorizado; no usar
este cierre UX para habilitar movimiento, conducción, P12.5 o features adicionales.
