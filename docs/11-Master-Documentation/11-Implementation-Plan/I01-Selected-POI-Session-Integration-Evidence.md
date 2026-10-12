# I01 — integración de POIs elegidos en sesiones B1

## Alcance y baseline

Baseline autorizado: `805cb17502583561f42eb4907e5a6bc6ac1a111c`.
Rama: `feature/i01-selected-poi-session`.
Worktree: `D:\Codex\worktrees\GeoGuide-AI\i01-selected-poi-session`.
Autorizaciones humanas I01, I01-R01, I01-R02, I01-R03 e I01-R04: implementar, remediar,
validar, documentar, publicar PR y merge normal únicamente con todos los gates PASS.

## Implementación y fuentes de verdad

La vista previa ofrece «Elegir para este recorrido» y «Quitar de este recorrido»
fuera de Driving. Consultar ficha, marcador o lista no selecciona; las categorías
siguen siendo criterios de discovery. No se implementan favoritos persistentes.

SelectedPoiDraft es el único borrador en aplicación. Se vincula mediante identidad
de la instancia del snapshot, no solo queryKeySha256. Una respuesta nueva, incluso
con iguales criterios, invalida la selección. Los IDs deben pertenecer al snapshot
vigente. Al iniciar, se copia un conjunto inmutable; se bloquean edición y cambios
de discovery/caché durante B1. Inicio se bloquea si discovery o captura están
pendientes. La consulta visual de lista/fichas se mantiene disponible.

SelectedPoiSessionCodec versiona un contexto efímero con snapshot canónico en
base64, SHA-256 de asociación e IDs ordenados. Se rechazan versión, duplicados,
IDs ajenos, campos extra, representación no canónica, captura futura, vencimiento
y tamaño total superior a 5 MiB. No se rescata parcialmente ni se trunca. Base64
puede hacer que un snapshot válido para caché exceda el límite de sesión; se
rechaza el inicio, sin modificar ni borrar la caché anterior.

SnapshotCodec y el formato persistente offline permanecen intactos. Android recibe
y transporta bytes opacos con el límite existente; ningún consumidor Kotlin
interpreta el snapshot. No se cambia el nombre de canal/métodos ni su tipo ByteArray.
UI y worker usan el codec nuevo conjuntamente; no se acepta un frame antiguo como
si fuera un contexto nuevo. El payload nativo no se persiste y se borra tras ready.

El worker pasa chosenIds al ActiveRouteCoordinator existente. El contexto activo
es inmutable y pertenece al worker; la UI no mantiene una segunda selección editable.
Una UI recreada que no conoce el borrador muestra «Selección fijada al iniciar el
recorrido» en lugar de afirmar qué IDs están elegidos. No restaura selecciones ni
sesiones silenciosamente después de Stop o reinicio.

POIProximityEvaluator no cambia: elegidos prioritarios y sugeridos elegibles se
mantienen; selección no garantiza alerta. C1/C2 conserva entrega, cooldown, cola,
consentimiento independiente, cancelación y rechazo de callbacks tardíos. Revocar
voz no implica detener GPS. Stop/interrupción y caducidad invalidan el contexto.

## I01-R01 y fixtures

El fallo del selector localizado dejó de reproducirse con el archivo UTF-8
restaurado. Árbol y Semantics confirmaron un FilledButton con el rótulo exacto,
deshabilitado durante B1. El baseline confirmó cero casillas seleccionadas y
apertura del filtro. Una reproducción controlada demuestra que un texto mal
decodificado causa el finder vacío/StateError original. La prueba ahora usa una
ValueKey estable sin eliminar la aserción del texto exacto ni el bloqueo. Se eliminó
la espera arbitraria de 10 ms de la prueba nueva.

La suite inicial tuvo 166 PASS / 3 FAIL: pruebas nativas B1/R01 usaban captura
1800000000000 ms, equivalente a 2027-01-15T08:00:00Z, futura respecto al host.
SelectedPoiSession la rechaza antes del canal; la prueba de inicio tardío esperaba
una llamada que nunca ocurría. Se reprodujeron únicamente esos tres casos.
Se agregó capturedAtUtcMs opcional al fixture (default histórico intacto) y se
usó una captura vigente solamente en los tres escenarios de canal nativo.
Se conservan todas las aserciones de denial, status, ownership, Stop y callback tardío.
No se relaja la validación de vigencia de producción.

## Traslado I01-R03

Git worktree move devolvía Permission denied. ACL, lectura/escritura/movimiento
controlado de archivo y acceso DELETE al directorio pasaron; Restart Manager no
reportó locks de los archivos inventariados. La inspección de handles de disco
identificó cuatro handles de Explorer PID 7792 en los directorios de documentación.
El usuario cerró sus ventanas; se verificaron cero handles y Git move tuvo éxito.
No hubo terminación forzada, elevación, cambio de ACL ni protección desactivada.

Respaldo físico: `D:\Codex\backups\GeoGuide-AI\i01-r02-20261011-174826`.
ZIP SHA-256: `62b88a54a1216cb08df0e395f45edcdf3f43824a4afa27d3a51597b1ef5cd5bc`.
Se verificaron ZIP real y hashes de sus 199 entradas. Antes de remediar tests,
los 12 archivos I01 y 187 ignorados coincidieron; diff, rama y HEAD también.
Git registra el destino nuevo; origen ausente y ningún worktree registrado inexistente.
Se restauraron bytes originales tras normalización de finales de línea del stash.
Regeneraciones posteriores de cachés de Flutter/Gradle son artefactos de validación.

Stashes preservados:
- I01 original: `27f89dbafb07884b3533e62550fff07cd2d75d10`.
- Checkpoint R03: `11c05fdab7fa0fd8a0affcdbab66661534f12b46`.
- Infraestructura: `583d0f593dda1b5d28ed5ed247431865e10837ac`.

La junction de Documents/Codex conserva destino D:/Codex. Conforme a I01-R04,
AGENTS.md permanece idéntico al baseline; la política de futuros worktrees se
presenta solo como propuesta. No se trasladan worktrees históricos ajenos a I01.

## Validación y gate físico

I01-R04 reprodujo el TypeError de RawTooltip al convertir el resultado de
find.byTooltip a IconButton. Se corrigió únicamente el finder del test: tipo
IconButton y propiedad tooltip exacta, con una única coincidencia requerida.
Se conservan onPressed == null y session.starts == 0. Un caso negativo prueba
que la misma aserción arroja TestFailure al habilitar el botón, y pasa al bloquearlo.
No se modifica producción para adaptar el selector ni se omiten aserciones.
AGENTS.md fue restaurado al baseline; la propuesta local anterior queda respaldada.

Pruebas específicas I01/B1/R01/V01-H01 después de corregir el finder: 48/48 PASS.
Commit funcional: `e75a4b7d8627664327207d43d655a1234ef8322e`.

| Gate final I01-R04 | Resultado |
| --- | --- |
| Specific I01/B1/R01/V01-H01 | 48/48 PASS |
| Suite Flutter completa | 170/170 PASS (151 baseline + 19 I01) |
| flutter analyze | PASS, sin incidencias |
| dart format | 73 archivos, cero cambios pendientes |
| JVM B1 / C2 / C2.1 | 50 / 80 / 43 aserciones PASS |
| Verificador de assets unitario | 5/5 PASS |
| APK MaterialIcons / manifiestos de assets | PASS; fuente 1 645 184 bytes, 11 assets Flutter |
| APK ZIP, firma debug y package | PASS; com.geoguideai.geoguide_ai, target API 36 |
| Código I01 final y define HTTPS dentro del kernel debug | PASS |
| Git diff --check, UTF-8 y enlaces locales | PASS |
| Driving, permisos, Android nativo, proximidad y SnapshotCodec | Comparación exacta PASS |

APK debug HTTPS: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, fuera de Git.
SHA-256: `F4457BB8CA4F941D6724359002B92B0FD0A728FFD88A939B107DCD9B3A2A7A65`.
Certificado debug SHA-256:
`894975b5bc6751da09b3d69923d4ae399192470d86c107106f65f6cb8d7eab7e`.
Compilación con `--dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`.
Warnings de SDK/Gradle/Java permanecen como limitación de tooling; build exitoso.

Las pruebas cubren elegir/quitar, ficha sin elección, cero categorías y filtro,
selección vacía, snapshots distintos con mismos criterios, invalidación del borrador
por sustitución/ausencia/caducidad, congelación, IDs inválidos/duplicados, canonicidad,
tamaño, transporte hasta el worker real con plataforma doble, prioridad elegido/sugerido,
calidad y muestras tardías, Stop/revocación, exclusividad y recovery R01. Guardas de
inicio durante discovery/captura pendientes y gestión de caché durante B1 verificadas.
La aceptación de elegidos se demuestra con muestras sintéticas; no es evidencia física.

Referencias de implementación: [selección](../../../mobile/lib/features/tracking/application/selected_poi_session.dart),
[codec](../../../mobile/lib/features/tracking/infrastructure/selected_poi_session_codec.dart),
[worker](../../../mobile/lib/features/tracking/infrastructure/route_session_worker.dart) y
[regresión widget](../../../mobile/test/features/tracking/i01_widget_test.dart).

La validación física I01 permanece NOT_EXECUTED. No se consulta ni instala en HONOR.
El retest futuro requiere autorización específica del APK/hash, inicio manual,
elección explícita antes de B1, controles congelados y Stop/limpieza por ambas vías.
Voz audible solo con un POI genuinamente elegible y consentimiento; no se fuerzan
posiciones ni umbrales. Sin candidato, BLOCKED_NO_ELIGIBLE_POI.

V01_H01_PHYSICAL_PASS conserva su alcance previo; V01 STATIONARY_PARTIAL no se eleva.
Proximidad real, convivencia de audio, liberación física de foco, Doze/batería,
recreación real de Activity y conducción permanecen pendientes. No se modifica
Driving, Android nativo, permisos, backend, infraestructura, contratos congelados,
documentación externa ni Excel. Arquitectura Android provisional sin ampliación.

P12 IN_PROGRESS / 45%; P12.5 NOT_AUTHORIZED; P11-BACKUP-01 OPEN_DEFERRED.
No Production Readiness. Merge SHA y validación post-merge se registran en el PR
para evitar una cadena adicional de PR documentales.
