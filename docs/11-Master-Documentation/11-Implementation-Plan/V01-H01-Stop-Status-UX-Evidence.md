# V01-H01 — indicación única de recorrido detenido

## Baseline y causa confirmada

Baseline: `f45ae2ec5cc2a999c86fcf3bed3ceaaa4b2f7589`.
Commit funcional: `e31e57240582324d373c8596581d1399dc74dadf`.
Autorización humana: investigación, corrección mínima, pruebas, PR y merge normal
condicionado a controles satisfactorios. Worktree aislado; checkout del usuario
con `infrastructure/compose.yaml` preexistente preservado.

Origen: V01_STATIONARY_PARTIAL, HONOR LLY-NX3/API 36. El usuario confirmó
el texto duplicado al detener desde aplicación y notificación. Las lecturas ADB
sanitizadas confirmaron servicio B1 ausente, notificación ausente y cero solicitudes
actuales de ubicación después de ambas vías de Stop. No se almacenaron dumps,
coordenadas ni información de otras aplicaciones.

En [BaseMapPage](../../../mobile/lib/features/map/presentation/base_map_page.dart),
la tarjeta muestra `_b1StatusText` y `_locationStatus`. El callback de Stop asigna
«Recorrido detenido» a la ubicación y el estado de sesión produce el mismo texto.
Son dos indicadores renderizados por un único estado: no hay evidencia de callback
ni servicio duplicado. Dos regresiones previas al cambio encontraron exactamente
**dos** Text widgets cuando se esperaba uno (Stop UI y callback del doble nativo).

## Corrección mínima

La tarjeta conserva el indicador de sesión y presenta el indicador de ubicación
cuando su texto es distinto, o cuando no existe estado de sesión. No se modifica
la máquina de estados R01, callbacks, ownership ni strings. Se mantienen los Text
existentes y su semántica estándar; no se ocultan estados de interrupción o errores.
Los estados starting, active, interrupted y falta de frescura conservan información
independiente. El cambio se limita al árbol de UI normal; Driving permanece intacto.

## Validaciones automatizadas

- `dart format .`: 68 archivos; formato final aplicado.
- `flutter analyze`: PASS, sin incidencias.
- `flutter test`: **151/151 PASS** (149 previos y dos variantes adicionales).
- B1 + R01 específicas: **22/22 PASS**, incluidas las **17 regresiones R01**.
- B1 final tras acortar únicamente el nombre del test: **5/5 PASS**.
- Stop por botón y callback de notificación del doble: una única indicación.
- Consentimiento cancelar/activar/revocar, exclusividad del stream, controles
  deshabilitados, lifecycle Home/retorno, starting/active/interrupted y frescura:
  aserciones preservadas y ampliadas.
- `git diff --check`: PASS.

No cambia Kotlin, manifest, permisos, servicio, POIs, TTS/audio focus ni assets.
No se requiere nueva compilación APK ni controles JVM para este diff de presentación
Dart probado por widgets. No se instala APK ni se ejecuta nueva validación física.
La prueba de notificación modela el callback nativo; no sustituye un retest físico.

## Gobierno y brechas residuales

V01_STATIONARY_PARTIAL permanece sin elevar a PASS por esta corrección automatizada.
El retest físico del mensaje corregido está NOT_EXECUTED. Recuperación de frescura
natural: BLOCKED por falta de evidencia; recreación real de Activity: NOT_EXECUTED.
Alertas reales de proximidad, convivencia de audio, Doze/batería y conducción no
quedan validadas por este paquete. No se declara Production Readiness.

P12 = IN_PROGRESS / 45%; P12.5 = NOT_AUTHORIZED;
P11-BACKUP-01 = OPEN_DEFERRED. Photon, contratos congelados, documentación externa
y Excel no se modifican. El SHA definitivo de merge se registra en el PR y el
informe de integración, sin una cadena adicional de PR documentales.
