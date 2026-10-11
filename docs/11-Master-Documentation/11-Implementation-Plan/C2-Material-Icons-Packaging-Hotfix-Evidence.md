# C2 — Hotfix de empaquetado Material Icons

Fecha: 2026-10-11. Entrada local: `5563ee0548d241f5cd376495f39de1bb05c59b37`,
rama `feature/gps-camera-tracking-proximity-core`.

## Incidente y alcance

El usuario observó mapa y textos visibles, controles sin iconos que respondían al
tocar su posición y ausencia de iconos de ubicación, ruta, categorías y lista en
HONOR LLY-NX3/API 36. Las capturas son evidencia humana; no constituyen PASS de voz
ni validación dinámica. La captura del consentimiento muestra una sesión activa.

Antes del hotfix, el usuario confirmó Detener desde la notificación. ADB de solo
lectura confirmó servicio RouteSessionService ausente, cero NotificationRecord
del paquete y ausencia de registros del paquete en las secciones actuales de
proveedores de ubicación. La comprobación previa también excluyó registros
actuales GNSS/geofence. No se usaron eventos históricos como prueba de detención.
No se conservaron coordenadas, identificadores del dispositivo ni dumps completos.

Autorización: investigación, corrección de empaquetado, pruebas y commits locales.
Sin instalación, permisos nuevos, cambios B1/C1/C2 funcionales, Driving, backend,
P12, Photon, push, PR, merge ni conducción.

## Causa y evidencia reproducible

APK defectuoso SHA-256:
`0FBEC80949B174D41096A6DC4B1F0CADAEB6F200E865A637F9D098AF839DB886`.

La causa directa confirmada es un bundle Flutter incompleto entregado dentro del
APK: solo isolate_snapshot_data, vm_snapshot_data y kernel_blob.bin. No contiene
MaterialIcons-Regular.otf, FontManifest.json ni AssetManifest.bin. Todos los
controles afectados usan Icons de Material. pubspec.yaml ya declara
uses-material-design: true; no se encontraron exclusiones Android de esas fuentes.

Los outputs.json/depfiles locales declaraban assets que no existían. Registraban
rutas C:\Users\…\Codex y D:\Codex; la primera es una junction hacia la segunda,
no dos repositorios independientes. El build incremental verbose detectó
outputMissing para fuente, manifiestos, shaders y logo y los regeneró. Su APK
contenía 11 assets Flutter y MaterialIcons de 1 645 184 bytes. Esto demuestra que
la configuración vigente permite incluir la fuente sin cambiar UI ni TTS.

Reproducción causal: tras clean/pub get, ejecutar controles Gradle B1/C2 y después
flutter build apk con HTTPS reprodujo el APK con solo tres assets. El control nuevo
falló con «APK is missing MaterialIcons». El stamp de debug_android_application
mezclaba ocho outputs C: (assets) y tres D: (runtime). El SDK instalado,
packages/flutter_tools/lib/src/build_system/build_system.dart, compara outputs por
texto y elimina previousOutputs que ya no aparecen en outputFiles después de
regenerarlos. Ambos alias apuntan a los mismos archivos físicos: eliminar el output
«anterior» elimina el asset recién escrito por el otro alias. El bundle Android
aporta los tres outputs runtime explícitos; el resto procede del depfile de assets.
La pérdida coincide con ese grupo de ocho outputs, no con selección de glifos.

Este mecanismo se reprodujo en el workspace actual; no hay traza completa de la
invocación histórica que produjo el APK instalado. No se atribuye el defecto a
tree shaking, TTS o GPS. El pipeline anterior carecía de control del bundle entregado.

## Corrección permanente

- flutter clean y flutter pub get regeneran outputs locales; lockfile sin cambios.
- flutter.source usa file("../..").toPath().toRealPath().toString(): resuelve la junction antes de
  entregar el proyecto al compilador Flutter Android. No cambia el SDK global,
  dependencias, código de aplicación ni directorios del dispositivo.
- android/build.gradle.kts resuelve también el padre del directorio build con
  toRealPath antes de añadir build; todos los subproyectos derivan sus outputs de
  esa raíz. No se cambia la ubicación física, solo se evita su alias textual.
  Normalizar únicamente source no bastaba: la salida seguía mezclando ocho C: y
  tres D:. Se valida la corrección completa, no esos intentos parciales.
- Java canonicalPath no resuelve esta junction (comprobado con Java 21: conserva
  C:, mientras toRealPath devuelve D:). Una primera corrección con canonicalPath
  reprodujo el fallo y fue descartada; no se presenta como solución válida.
- assembleDebug finaliza con verifyDebugMaterialIcons: abre el APK empaquetado,
  exige fuente con firma OpenType OTTO, declaración en FontManifest y AssetManifest.
  El build falla si falta cualquiera de estos componentes.
- tool/verify_apk_icons.py permite verificar independientemente el APK destinado a
  instalación: manifiesto JSON, familia y asset correctos, fuente y SHA-256.
- Cinco pruebas del verificador cubren bundle aceptado, fuente ausente/corrupta,
  familia incorrecta y manifiesto de assets ausente. Fixtures sintéticos, sin GPS.
- El APK defectuoso real produce exit code 1 en el verificador (control negativo).

Comandos reproducibles desde mobile:

```text
flutter clean
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze --no-pub
flutter test --no-pub
python -m unittest discover -s tool -p test_verify_apk_icons.py
cd android
gradlew.bat :app:b1PolicyChecks :app:c2VoiceChecks
cd ..
flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443
python tool/verify_apk_icons.py build/app/outputs/flutter-apk/app-debug.apk
```

La inspección del ZIP, no una prueba widget, acredita empaquetado. La recuperación
visual real requiere un retest autorizado del móvil. El texto anterior de evidencia
C2 conserva los resultados históricos del build defectuoso; este documento registra
el incidente posterior y la corrección sin reescribir esa evidencia.

## Resultados finales

Commit de corrección: `85d97e5e3f24fd5c3757873bca8a5fcf65e78afd`.

| Control | Resultado |
| --- | --- |
| Formato Dart lib/test | PASS, 64 archivos, 0 cambios |
| flutter analyze --no-pub | PASS, sin incidencias |
| Suite Flutter completa | 118/118 PASS |
| Verificador de APK: pruebas | 5/5 PASS |
| APK defectuoso real: control negativo | PASS, rechazo con exit code 1 |
| b1PolicyChecks final | 50 assertions PASS |
| c2VoiceChecks final | 80 assertions PASS |
| Build APK debug HTTPS final | BUILD SUCCESSFUL |
| verifyDebugMaterialIcons en assembleDebug | PASS, 1 645 184 bytes |
| Verificador independiente sobre APK final | PASS |
| Outputs tras Gradle y build HTTPS | 11/11 presentes; 0 C:, 11 D: en ambos stamps |
| Fuente empaquetada frente a fuente completa SDK | Bytes idénticos |
| Manifest Android dentro de APK anterior/nuevo | Bytes idénticos |
| pubspec, lockfile, Dart funcional y src Android | Sin cambios contra entrada |
| git diff --check | PASS |
| Retest físico del hotfix | NOT_EXECUTED, instalación no autorizada |

La repetición final incluyó controles Gradle B1/C2 seguidos del build Flutter HTTPS,
la misma alternancia que reproducía el fallo. No se modificó la instalación del SDK.
Los errores iniciales de compilación del control Gradle/importación y de asignación
DirectoryProperty se corrigieron antes de los resultados finales; no se cuentan
como builds PASS. Las advertencias de deprecación de AGP/Java son ajenas al hotfix.

APK final: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
SHA-256: `09D9E0471F1123757F5BA75ED039685B0B0290761B252523C459C9F92D261A89`.
Fuente SHA-256: `D9865B671A09D683D13A863089D8825E0F61A37696CE5D7D448BC8023AA62453`.

| Bundle | APK anterior | APK corregido |
| --- | --- | --- |
| Total assets Flutter | 3 | 11 |
| MaterialIcons | Ausente | 1 645 184 bytes, fuente completa del SDK |
| FontManifest/AssetManifest | Ausentes | Presentes, familia MaterialIcons correcta |
| Logo flutter_map, shaders, NOTICES, NativeAssetsManifest | Ausentes | Presentes |
| Runtime Dart | Presente | Presente |

El control Gradle se aplica al APK debug autorizado. El verificador independiente
admite otros APK como inspección, sin autorizar nuevos tipos de build o despliegue.

Veredicto técnico: READY_FOR_C2_ICON_HOTFIX_RETEST. No equivale a recuperación visual
confirmada en Android físico ni a CEFI_VOICE_STATIONARY_PASS.

## Retest estacionario propuesto

1. Obtener autorización del nuevo hash; confirmar sesión detenida y firma compatible.
2. Actualizar con adb install -r; sin borrar datos, caché ni permisos.
3. Confirmar mapa, todos los iconos del AppBar, categorías/lista y marcadores de
   ubicación/origen/destino/POI con ruta existente. Comparar textos y snapshot.
4. Voz inicialmente desactivada; cancelar consentimiento, activar y revocar
   conscientemente fuera de Driving; confirmar iconos/estado visibles.
5. Una sesión estacionaria: comprobar exclusividad B1.1 y estado de controles;
   Home/retorno y Stop. Repetir bloqueo o Driving solo para regresiones pertinentes.
6. Voz audible únicamente con POI genuinamente elegible. Si no existe, mantener
   BLOCKED_NO_ELIGIBLE_POI; no inyectar muestras, cambiar umbrales ni desplazarse.
7. Comprobar limpieza tras Stop sin registros de coordenadas ni grabación de audio.

No se repite como pendiente lo ya probado en B1; tampoco se extrapola esa evidencia
al nuevo APK. Sin instalación del hotfix en esta actividad. P12.5 NOT_AUTHORIZED;
P11-BACKUP-01 OPEN_DEFERRED. El fallo visual no autoriza cerrar C2 físico.

## Retest físico posterior autorizado — 2026-10-11

Esta sección registra la actividad posterior; no altera los resultados históricos
de preparación anteriores. Entrada: 1abf414081490f4d5b3a818a7ee5ea49fb08953e.

- ADB: HONOR LLY-NX3/API 36; sesión, notificación y registros actuales de ubicación
  ausentes antes de instalar. Permisos existentes concedidos, sin modificación.
- adb install -r: Success. Hash del base.apk instalado coincide con el APK final
  09D9E0471F1123757F5BA75ED039685B0B0290761B252523C459C9F92D261A89.
- Arranque: Activity COLD, Status ok; interfaz disponible. Voz desactivada según
  etiqueta técnica inicial. Inicialmente sin snapshot disponible; no se atribuye
  esto a borrado de datos. No se ejecutó borrado ni reinstalación destructiva.
- Confirmación humana y capturas: todos los iconos recuperados; mapa/textos visibles.
  Ruta real seleccionada manualmente: 97.7 km y 104 min planificados, cinco POIs.
  Origen/destino/POIs, categorías/lista visibles; fichas abren y cierran.
- Consentimiento: el usuario confirma activación/desactivación por cambio de icono.
  Cancelar el diálogo queda NOT_VALIDATED: se aclaró que Cancelar significa rechazar
  la activación en el diálogo Avisos de voz CEFI, no revocar una activación previa.
- Incidencia UX: el usuario no encuentra salida de la lista. El código contiene
  Ver mapa como toggle, pero la lista es un Positioned bottom:150/height:260 añadido
  al final del Stack, sin cierre propio. La captura muestra el panel sobre los
  controles normales: oculta el acceso al toggle. El mecanismo ya existe en el
  baseline remoto e19e17212c48ecf1b9604c512cac4f5b9fb64686; no fue añadido por el hotfix.
- Se detiene el retest ante esta incidencia; no se cambia código. Sesión breve,
  Home/retorno y limpieza posterior del nuevo APK: NOT_VALIDATED en este retest.
  Entrega audible: NOT_VALIDATED; no se observó candidato genuinamente elegible ni
  se ejecutó sesión para determinar BLOCKED_NO_ELIGIBLE_POI. No se fuerza PASS.

Resultado visual: PASS. Resultado integral: STOP_AND_REPORT por bloqueo UX de
salida de lista, con pruebas parciales conservadas. Propuesta mínima pendiente de
autorización: cierre explícito dentro del panel y regresión de acceso a Ver mapa,
sin cambios de GPS, voz, Driving o contratos. Sin push, PR, merge ni carretera.
