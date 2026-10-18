# UI-2.2 — Propuesta de protocolo de validación física

Fecha de preparación: 2026-10-18. Protocolo aprobado por autorización humana expresa para su integración documental.
Autoridad: encargo humano «UI-2.2 — Physical Validation Protocol & Execution Readiness».
Solo análisis, preparación, documentación y commit local; **ninguna ejecución física autorizada**.
Esta propuesta no congela requisitos nuevos ni aprueba instalación o validación.

## Objetivo, alcance y checkpoint

Checkpoint UI-2.2-DOC: preparar una futura sesión estacionaria en Android para UI-2.1 ya integrada.
Precondiciones documentales: contrato UI-2 congelado, integración verificable, aislamiento seguro.
Incluye protocolo, matriz, checklist y plantilla de resultados. Excluye interacción con teléfono,
ADB/discovery de dispositivos, builds, tests funcionales nuevos, cambios de producción/contratos,
permisos/dependencias, backend/infra, GPS/voz funcionales, ADMIN, push/PR/merge y cierre UI-2.
Evidencia actual: DOC/CODE/GIT/PR y lectura de TEST/LOG históricos; DEVICE/SCREENSHOT físicos: N/A, no ejecutados.
Salida del checkpoint: cuatro documentos consistentes, trazables y validados, con todos los casos NOT_EXECUTED.
La futura ejecución tendrá su propio registro, aprobación y veredicto; este checkpoint no la inicia.

## Baseline e integración verificados

- PR [#85](https://github.com/ccenteno2207/GeoGuide-AI/pull/85): MERGED, integración contractual `597950decddecef38dd4f6c44595b807a4087f14`.
- PR [#86](https://github.com/ccenteno2207/GeoGuide-AI/pull/86): MERGED, integración `083239649c86dd9efd9e0050dd3c955ae574b12a`.
- Padres del merge UI-2.1: `597950decddecef38dd4f6c44595b807a4087f14` y `838e3cd27a0b47143dbf59ec52f12b65fc249bc3`.
- Fetch en preparación: origin/main = `083239649c86dd9efd9e0050dd3c955ae574b12a`; ascendencia UI-2.1 comprobada; sin avance posterior.
- Rama documental: `docs/ui2-physical-validation-protocol`.
- Worktree nuevo: `D:\Codex\worktrees\GeoGuide-AI\ui2-physical-validation-protocol`.
- Ruta/rama libres y sin trabajo UI-2.2 localizado en historial/rutas antes de crear. Checkout principal preservado en `e443c0aa10987e04367dd15a1df259438426c3bc`.
- 19 worktrees preexistentes, 12 archivos pendientes y 3 stashes inventariados antes; comparación final exige mismos HEAD/rama/status y SHA-256 de pendientes. Solo se añade este worktree.

Los 202 tests, 15 casos renderer, 23 PNG y builds constan en UI-2.1; se revisa evidencia existente, no se reejecuta ni se traslada a PASS físico. Los 14 AC conservan PASS_AUTOMATED. La evidencia remota de la integración no equivale a CI configurada ni a cierre maestro.
El reporte UI-2.1 conserva estados históricos pre-merge; este documento registra el evento posterior sin editarlo.

## Entorno y artefactos

| Dato | Respaldo documental/estático | Estado |
| --- | --- | --- |
| HONOR LLY-NX3 | P9.3 registra DEVICE | Histórico; reconfirmar bajo G2 |
| Android 16 / API 36 | P9.3 registra ANDROID | Histórico; reconfirmar bajo G2 |
| arm64 | Reportado en encargo; P9.3 no lo acredita | PENDING_PHYSICAL_CONFIRMATION |
| 1080 × 2412, 408 dpi | Reportado en encargo; no localizado en P9.3 | PENDING_PHYSICAL_CONFIRMATION |
| Windows 10 Pro x64, Java 21, Android SDK existente | Entorno objetivo reportado; sin actualizar toolchain | Confirmar inventario antes de futura sesión |
| Flutter 3.47.2 stable / Dart 3.13.2 | sdk.json de UI-2.1 | Evidencia de build histórico, sin ejecutar toolchain ahora |
| Package y versión de ambos APK | aapt dump badging local, lectura estática 2026-10-18 | com.geoguideai.geoguide_ai; 1.0.0; versionCode 1 |
| SDK/ABI de ambos APK | aapt local | minSdk 24; target/compile 36; arm64-v8a, armeabi-v7a, x86_64 |

Se recalcularon localmente los hashes de los artefactos existentes sin reconstruir ni instalar:

| APK en ui2-implementation/mobile/build/app/outputs/flutter-apk | Bytes registrados | SHA-256 comprobado |
| --- | --- | --- |
| app-debug.apk | 167843977 | `635ab1225fe54b3a079196df5b87dd5cf1431966130f81195b386c9cffd92055` |
| app-release.apk | 60472029 | `88b4ae4da816ee2650f6e9b88d32a52511f8e4ce7d72af44e8e85a3af111fa3a` |

El perfil candidato y firma se aprobarán bajo G3; no intercambiar debug/release silenciosamente.
El Gradle vigente firma release con clave debug: son artefactos de desarrollo, no distribución aprobada.
La versión 1.0.0+1 es reutilizada; nunca identificar el build solo por esa versión.
BACKEND_BASE_URL del build se registra en logs como HTTPS `https://geoguide.getcom.pe:5443`; disponibilidad actual no consultada.
Compatibilidad de manifiesto/ABI no demuestra instalación ni funcionamiento Android.

## Precondiciones de la sesión futura

1. G1 aprobado para la revisión exacta del protocolo y subcasos; G2–G4 concedidos por operación según tabla.
2. Equipo estacionario y responsable presente; nunca manipulación en movimiento.
3. APK/hash/build/backend identificados; comprobar que no cambió código desde el aprobado.
4. Ruta pública y POIs reales del entorno autorizado; no usar ubicación personal, fotos nuevas ni datos inventados.
5. Ausencia de sesión GPS/B1/voz pendiente o activa. Si existe, no detener ni revocar una sesión ajena: pedir al responsable que resuelva el entorno.
6. Estado original de permisos, ubicación, accesibilidad, escala, orientación, red, depuración y copia local registrado sin PII.
7. No desinstalación, downgrade ni borrado para solucionar un fallo de instalación. Falta de un respaldo permitido no autoriza exportar DB; si los datos deben conservarse, bloquear reemplazo/borrado.
8. Confirmar servicios reales solo por flujos ya autorizados; no desplegar, cambiar TLS/DNS o simular éxito.
9. Datos/tiempo/logs insuficientes bloquean el subcaso; los tests complementarios se identifican como automatizados.

## Gates y permisos futuros

| Gate | Decisión única de sesión | Alcance |
| --- | --- | --- |
| G1 — Protocolo | Aprobar revisión y casos/subcasos | No implica G2–G4 |
| G2 — Dispositivo | Conexión e identificación HONOR | USB/depuración, alias privado |
| G3 — Instalación | APK exacto y política de datos | Perfil, hash, firma y actualización compatible |
| G4 — Permisos/accesibilidad | Aprobar cambios enumerados y captura/observabilidad | No concede GPS/B1/voz funcionales ni conducción |
| G5 — Cierre de sesión | Revisar resultados, restauración y evidencia | No equivale a cierre maestro UI-2 |

Una aprobación puede agrupar operaciones explícitas; no se pide permiso por cada toque ordinario de un caso autorizado.
La visita reducida Driving de PHY-35 requiere inclusión explícita en G1; B1 activo de PHY-21 queda separado y no autorizado por este protocolo.

| Operación | Aprobación | Impacto y límite |
| --- | --- | --- |
| Conectar dispositivo / habilitar depuración USB | REQUIRES_AUTORIZACION G2 | NO_DESTRUCTIVA; acceso sensible, restaurar estado |
| Instalar/actualizar APK | REQUIRES_AUTORIZACION G3 | POTENCIALMENTE_DESTRUCTIVA; validar firma/datos, no desinstalar |
| Aceptar/revocar permisos Android | REQUIRES_AUTORIZACION G4 | NO_DESTRUCTIVA respecto a archivos; cambia acceso y puede interrumpir flujos |
| Activar/desactivar ubicación | REQUIRES_AUTORIZACION G4 específica | NO_DESTRUCTIVA; no necesaria para selección de extremos por mapa; no iniciar GPS |
| Activar/desactivar TalkBack | REQUIRES_AUTORIZACION G4 | NO_DESTRUCTIVA; acordar salida antes de activar |
| Escala de texto / orientación | REQUIRES_AUTORIZACION G4 | NO_DESTRUCTIVA; registrar valores iniciales |
| Desconectar/reconectar red | REQUIRES_AUTORIZACION G4 | NO_DESTRUCTIVA; coordinar comunicaciones del usuario |
| Captura de pantalla, vídeo, audio o logs | REQUIRES_AUTORIZACION G4 por medio | NO_DESTRUCTIVA; riesgo de privacidad; audio no predeterminado |
| Lectura de access logs backend existentes | REQUIRES_AUTORIZACION G4 con responsable de entorno | NO_DESTRUCTIVA; solo ventana saneada, sin configurar infraestructura |
| Captura offline que reemplaza copia | REQUIRES_AUTORIZACION G4 | POTENCIALMENTE_DESTRUCTIVA para copia previa; solo datos de prueba |
| Borrar caché/copia/datos | REQUIRES_AUTORIZACION específica | POTENCIALMENTE_DESTRUCTIVA; solo borrado de copia de prueba por UI. pm clear/desinstalación fuera de sesión |
| Cierre real del proceso | REQUIRES_AUTORIZACION G4 | NO_DESTRUCTIVA en almacenamiento; pierde estado efímero. Prohibido con GPS/voz activos |

Nada de esta tabla se ejecutó durante la preparación.

## PERSONAL_DEVICE_MINIMUM_ACCESS — salvaguarda obligatoria

El HONOR LLY-NX3 es personal y contiene información privada y sensible. Aun después de G2–G4,
cada acceso se limita al propósito autorizado, a GeoGuide AI/Rutea y al dato mínimo necesario.
Que ADB permita una consulta no la autoriza. No ejecutar ADB exploratorio ni usar una shell
interactiva para explorar el equipo.

**Acceso permitido únicamente con autorización física específica y propósito anotado:**

- Identificar por alias privado; consultar solo fabricante/modelo, Android/API, ABI, resolución y
  densidad necesarios para compatibilidad. El serial completo no se conserva en el reporte.
- Verificar hash/firma del APK local y, si se requiere, la identidad del paquete de Rutea.
- Instalar una actualización compatible de Rutea mediante el método aprobado que conserva la
  instalación. No se promete preservación de datos; nunca se desinstala para resolver incompatibilidad.
- Iniciar y observar exclusivamente Rutea; no abrir otras apps.
- Capturar únicamente contenido de Rutea, con consentimiento previo, mientras está en primer plano.
  Revisar la imagen inmediatamente y descartarla de la evidencia si incluye notificaciones, ventanas,
  identificadores u otro contenido ajeno a la app.
- Consultar solo logs acotados al proceso de Rutea cuando sean necesarios y autorizados; sanearlos
  antes de conservarlos. La captura de logs no incluye volcados generales.
- Restaurar únicamente los ajustes cambiados durante la sesión, uno por uno, comparando con el
  registro inicial.

**Prohibido durante toda la sesión:**

- Explorar archivos personales o almacenamiento general; leer fotos, vídeos, documentos, descargas,
  contactos, mensajes, llamadas, correo, cuentas, contraseñas o información de otras apps.
- Inspeccionar bases de datos o datos privados ajenos a GeoGuide AI/Rutea; crear backups completos,
  extraer datos del teléfono o volcar almacenamiento.
- Volcar logcat completo, bugreport, notificaciones, portapapeles, ubicación histórica o datos de
  localización ajenos a las pruebas.
- Instalar herramientas de monitorización, certificados o apps auxiliares; modificar ajustes del
  sistema fuera de las operaciones G4 aprobadas.
- Borrar datos, desinstalar apps, restablecer el dispositivo, limpiar logs existentes o ejecutar
  comandos amplios para buscar información obtenible mediante una consulta específica.
- Publicar capturas, logs, seriales u otros identificadores. La evidencia permanece privada salvo
  autorización independiente para compartir una copia previamente saneada.

Si un caso necesita acceso adicional, se detiene solo ese caso y se reporta la finalidad, el dato
solicitado, el riesgo y la alternativa menos invasiva para aprobación específica. No se infiere
permiso desde G1, desde ADB ni desde una autorización para instalar Rutea.

## Secuencia y datos necesarios

Ejecutar A (01–04) antes de interacción; B/C (05–12) con datos reales; D/E (13–21) sin sesiones GPS;
F (22–26) solo con copia desechable consentida; G (27–32) con TalkBack/ajustes aprobados;
H (33–36) para regresión acotada y restauración. PHY-16/25 pueden requerir una segunda sesión tras 24 h,
con el mismo artefacto y hora original; nunca adelantar el reloj. PHY-21 queda solo como complemento automatizado.
PHY-35 es opcional, bloqueado hasta autorización explícita.

Guardar una ficha privada del snapshot real: alias de ruta, categorías, orden ID↔nombre, hora original y campos disponibles.
No subir coordenadas personales o identificadores del teléfono. Si falta descripción, nombre largo, diacríticos o vacío real,
marcar el subcaso no observado; no editar respuestas ni introducir fixtures en APK. Los cuatro viewports exactos y escalas 1.0/2.0
son cobertura automatizada; el HONOR acredita únicamente sus métricas y ajustes observados.

## Evidencia, resultados y aprobación futura

Convenciones: `UI2_PHYSICAL_ANDROID`, `UI2_TALKBACK_PHYSICAL`, `UI2_REAL_TILES`, `UI2_PHYSICAL_REGRESSION`.
Nombre sugerido privado: `<tipo>_UI2-PHY-NN_<sessionAlias>_<fecha-hora>_<paso>.<ext>`.
No reutilizar FLUTTER_RENDERER_TEST como categoría física. Cada prueba requiere APK/hash, baseline, alias del dispositivo,
Android/API, fecha/hora/zona, precondiciones, pasos realmente hechos, resultado observado vs esperado, responsable y evidencia.
La captura es complementaria al registro; transcripción manual puede documentar TalkBack sin grabar audio.
Capturas/vídeos/logs requieren consentimiento y revisión de PII, tokens, IP/serial/coordenadas sensibles antes de cualquier difusión.
Evidencia física privada fuera de Git; no subir automáticamente ni crear carpeta con evidencias ficticias.
Los logs actuales son exclusivamente históricos de automatización; capturas renderer no muestran tiles operativos.

Estados de ejecución: NOT_EXECUTED inicialmente; futuro PASS/FAIL/BLOCKED_BY_PRECONDITION por subcaso y caso.
NOT_APPLICABLE solo con justificación aprobada, nunca para ocultar un bloqueo. COVERED_AUTOMATED identifica evidencia complementaria,
no ejecución física. Un caso parcial conserva el detalle y no se agrega a PASS físico completo.
Un fallo debe incluir alcance UI-2 o posible preexistente, reproducción y evidencia; no corregir código dentro de esta autorización.

Aprobación del protocolo: 36 IDs estables, AC01–14 trazados, resultados vacíos, gates/privacidad/restauración claros.
Aceptación futura de la sesión: cada caso/subcaso aprobado cumple observaciones verificables o tiene bloqueo/fallo explícito;
no quedan fallos materiales sin resolver para afirmar PASS de ese alcance. Validación física, TalkBack y tiles se deciden
por separado con evidencia propia. Casos complementados únicamente por tests no se convierten en físicos.
El responsable revisa limitaciones y decide el siguiente gate; cerrar sesión no cierra UI-2.

## Riesgos y contingencias

Probabilidad: **no estimada (NE)** por ausencia de mediciones actuales, salvo hechos estáticos indicados; no inventar porcentajes.

| Riesgo | Probabilidad/fundamento | Impacto | Detección | Mitigación/contingencia | Bloqueo |
| --- | --- | --- | --- | --- | --- |
| APK distinto | NE; versión reutilizada comprobada | Alto | SHA/firma/baseline | Rechazar candidato; localizar artefacto auditado | Hash o procedencia no coincide |
| Backend no disponible | NE; no consultado ahora | Alto | Flujo HTTPS y control positivo | Registrar indisponibilidad; no desplegar | Casos dependientes sin respuesta real |
| TLS/conectividad fallida | NE | Alto | Error tipado / red autorizada | Restaurar red; nunca bypass TLS/DNS | No se obtiene entorno seguro |
| Tiles ausentes | NE; proveedor gobernado aparte | Medio | PHY-05, render real | Separar mapa/datos, reprogramar; sin cambiar proveedor | No PASS tiles |
| Sin POIs o variantes necesarias | NE | Medio | Response autorizado | Otro corredor ya aprobado o subcaso bloqueado; tests complementarios | Datos requeridos inexistentes |
| Permisos denegados | NE | Medio | Dialog/ajuste observado | No insistir ni conceder automáticamente; usar extremos por mapa | Caso que exige permiso no autorizado |
| TalkBack inaccesible | NE; P9.3 observó mezcla de idioma histórica | Alto | Ensayo con operador | Acordar método de salida; registrar anuncio exacto | No puede operarse/restaurarse lector |
| Orientación no disponible | NE | Medio | Ajuste bloqueado / tamaño observado | Registrar limitación; usar matriz automatizada aparte | Sin evidencia física de esa orientación |
| Copia caducada | TTL 24 h confirmado; probabilidad dependiente de hora | Medio | Hora original/elegibilidad | Preparar copia de prueba consentida o reprogramar | No snapshot elegible requerido |
| Pérdida de datos locales | NE | Alto | Inventario/firma/copia previa | No desinstalar/borrar; solo copia desechable | Conservación no garantizable |
| Captura sensible | NE | Alto | Revisión humana antes de exportar | Detener captura; mantener privado y acordar tratamiento | No hay consentimiento/redacción segura |
| Renderer difiere de Android | NE; renderer bloquea HTTP por diseño | Medio | Comparar secuencia física | Reportar diferencia con APK/métricas; sin retocar código aquí | Defecto material reproducible |
| Fallo preexistente GPS/Driving/voz | NE; límites históricos documentados | Alto | Baseline/diff/prueba mínima | No atribuir ni reparar unilateralmente; separar hallazgo | Requiere intervención funcional |
| Red sin observabilidad suficiente | NE | Medio | Control positivo / atribución de ventana | Spy automatizado como complemento; no inventar cero tráfico | PHY-18 no verificable |

## Detención y restauración

Detener el caso ante hash/baseline incompatible, pérdida de datos posible, sesión GPS/voz ajena,
permiso/captura no autorizado, ubicación sensible, error TLS, fallo material o necesidad de modificar código/servicios.
Marcar caso bloqueado/fallido según evidencia y STOP_AND_REPORT si requiere ampliar alcance.
No resolver defectos ni discrepancias P9/GPS mediante esta propuesta.

Restaurar con bitácora inicial: cerrar teclado/modales y salir explícitamente de Driving si se autorizó;
apagar TalkBack solo si estaba apagado inicialmente; restituir fuente/orientación/red y permisos/ubicación si se cambiaron;
cerrar proceso solo si se aprobó y sin sesiones activas; desconectar USB/restaurar depuración.
Comparar cada ajuste con el inicial y registrar cualquier diferencia y propietario.
Datos borrados no tienen undo garantizado: por eso no se permite borrar copia ajena.
No reinstalar versión anterior o desinstalar APK automáticamente como restauración.
Si una evidencia contiene datos sensibles, restringir acceso y consultar al responsable antes de borrarla o compartirla.

## Documentos operativos

- [Matriz de trazabilidad](UI-2.2-Physical-Validation-Traceability-Matrix.md)
- [Checklist y comandos futuros](UI-2.2-Physical-Validation-Session-Checklist.md)
- [Plantilla de resultados](UI-2.2-Physical-Validation-Results-Template.md)

## Fuentes y autoridad resueltas

- [AGENTS](../../../AGENTS.md), [contexto](../../../PROJECT_CONTEXT.md), [roadmap](../../../ROADMAP.md), [índice](../../../DOCUMENTATION_INDEX.md), [método](../../../AI_DEVELOPMENT_GUIDE.md) y [skill](../../../.agents/skills/geoguide-phase-execution/SKILL.md).
- [Entrega 04.6](../../04-SolutionArchitecture/06-Master-Architecture/01-Master/GeoGuideAI-Master-Architecture.md); [ADR-016](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-016-Flutter.md), [ADR-019](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-019-Map-Library.md) y [ADR-027](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-027-Channel-Independent-Interaction-and-Voice.md).
- [Contrato UI-2 §§3–7 y AC01–14](UI-2-Map-Search-and-POI-Experience-Contract-Proposal.md), [U2-D01–D06](UI-2-Decision-Register.md), [compatibilidad](UI-2-Compatibility-and-Dependency-Matrix.md), [medios](UI-2-POI-Media-and-Test-Fixture-Policy-Proposal.md), [Discovery](UI-2-Discovery-and-Scope-Evidence.md). Son los cinco documentos congelados; se conservan sin cambios.
- [UI-0 visual](UI-0-Visual-Design-Contract-Proposal.md), [compatibilidad UI-0](UI-0-Rutea-Compatibility-Matrix.md), [UI-1 y cierre](UI-1-Execution-and-Acceptance-Evidence.md). Sus estados históricos no sustituyen autorizaciones posteriores. Los borradores originales UI-0 del checkout principal no son contratos operativos.
- [P8 §§7–10 y AC01–15](P8-Phase-Contract-v1.md), [P9 §§6–8 y AC01–12](P9-Phase-Contract-v1.md), [anexo de caché](P9-Local-Cache-Design-v1.md), [P9.3 físico histórico](P9.3-Physical-Validation-Evidence.md), [cierre P9](P9.4-Audit-and-Closure-Evidence.md). Las anotaciones iniciales de aprobación pendiente en el snapshot P9 son históricas; contexto y cierre posteriores registran su aprobación/cierre.
- [I01](I01-Selected-POI-Session-Integration-Evidence.md), [B1](B1-Active-Route-Session-Implementation-Evidence.md), [R01](R01-GPS-Lifecycle-Remediation-Evidence.md), [C2/CEFI](C2-CEFI-Voice-Alerts-Implementation-Evidence.md), [gobierno GPS/CEFI](GPS-CEFI-Post-Merge-Governance-Evidence.md).
- [Ejecución UI-2.1](UI-2.1-Execution-and-Acceptance-Evidence.md), [logs](UI-2.1-Validation-Logs/flutter-tests.txt), [inventario de hashes](UI-2.1-Validation-Logs/artifact-sha256.json), [renderer y limitaciones](UI-2-Visual-Evidence/README.md).
- Código inspeccionado: [shell](../../../mobile/lib/features/map/presentation/base_map_page.dart), [filtro local](../../../mobile/lib/features/discovery/presentation/poi_result_filter.dart), [tarjeta](../../../mobile/lib/features/discovery/presentation/poi_result_card.dart), [detalle](../../../mobile/lib/features/discovery/presentation/poi_detail_sheet.dart), [placeholder](../../../mobile/lib/features/discovery/presentation/poi_thumbnail.dart), [copia offline](../../../mobile/lib/features/discovery/presentation/offline_cache_sheet.dart).

No se detectó una contradicción material nueva que impida redactar el protocolo. La discrepancia histórica P9/GPS Driving sigue separada por UI-0; no se resuelve mediante casos físicos ni se adopta una política funcional nueva. El caso Driving es opcional y sin sesión GPS.

## Catálogo de 36 casos propuestos

Todos los casos tienen estado inicial NOT_EXECUTED; una precondición sin cumplir no es un resultado de ejecución.

## UI2-PHY-01

- **Título:** Identidad del APK (grupo A).
- **Objetivo:** Vincular artefacto con el código integrado.
- **Referencia contractual:** UI2-AC-14; U2-D05; P9-AC-11.
- **Precondiciones:** G1 aprobado; artefactos locales disponibles; sin dispositivo.
- **Datos necesarios:** APK debug/release e inventario UI-2.1.
- **Pasos:**
  1. Calcular SHA-256 y tamaño del candidato.
  2. Consultar badging con aapt local; anotar package, versión, SDK y ABI.
  3. Comparar con inventario y registrar perfil elegido y baseline de fuentes.
- **Resultado esperado:** Hash y metadata coinciden; diferencia bloquea instalación. Versión idéntica por sí sola no prueba identidad.
- **Evidencia requerida:** Ficha de artefacto y salida estática saneada.
- **Riesgo:** Instalar un APK diferente al auditado.
- **Restauración:** N/A: lectura local.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-02

- **Título:** Conexión e identidad futura (grupo A).
- **Objetivo:** Identificar el equipo sin exponer su serial.
- **Referencia contractual:** UI2-AC-14; P9-AC-12; P9.3.
- **Precondiciones:** G2 concedido expresamente; operador presente.
- **Datos necesarios:** HONOR previsto y cable autorizado.
- **Pasos:**
  1. Registrar ajustes originales antes de cambiarlos.
  2. Conectar y autorizar depuración solo con permiso; consultar identidad mediante comandos futuros del checklist.
  3. Comparar modelo, Android/API, ABI, tamaño y densidad; guardar alias, no serial completo.
- **Resultado esperado:** Modelo/Android/API verificados; atributos no respaldados históricamente pasan a observados solo tras lectura. Discrepancia de compatibilidad se revisa antes de instalar.
- **Evidencia requerida:** Registro de dispositivo con alias y fecha.
- **Riesgo:** Acceso al teléfono o a datos ajenos.
- **Restauración:** Desconectar y restaurar depuración al estado previo.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-03

- **Título:** Actualización sin pérdida de datos (grupo A).
- **Objetivo:** Autorizar una instalación reversible en lo posible.
- **Referencia contractual:** UI2-AC-14; P9-AC-10/12.
- **Precondiciones:** G3 concedido para APK exacto; G2; sin sesión GPS/voz activa.
- **Datos necesarios:** Versión instalada, firma/certificado y datos locales identificados por responsable.
- **Pasos:**
  1. Registrar instalación previa y consentimiento respecto de copia offline/intención de viaje.
  2. Comparar firmas y versión; si incompatibles, detener sin desinstalar ni borrar.
  3. Solo si la actualización es compatible y se aprobó, ejecutar instalación -r; conservar salida.
- **Resultado esperado:** Instalación devuelve éxito sin desinstalación ni limpieza. No prometer preservación de datos solo por usar -r; el operador comprueba su contexto autorizado.
- **Evidencia requerida:** Resultado del instalador y ficha de firmas sin datos privados.
- **Riesgo:** Firma distinta, downgrade o pérdida de datos.
- **Restauración:** No desinstalar para resolver errores; conservar instalación previa y pedir decisión. Rollback requiere autorización propia.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-04

- **Título:** Arranque estacionario (grupo A).
- **Objetivo:** Observar apertura y shell en Android.
- **Referencia contractual:** UI2-AC-01/14; UI-1 shell.
- **Precondiciones:** G1–G3; dispositivo inmóvil; permisos/consentimientos previos registrados.
- **Datos necesarios:** APK identificado; endpoint compilado registrado.
- **Pasos:**
  1. Abrir GeoGuide AI manualmente.
  2. Esperar la vista de exploración; abrir/cerrar lista si está disponible.
  3. Anotar cierres, excepciones visibles, solicitudes Android y controles.
- **Resultado esperado:** Shell se presenta sin cierre inesperado; no aparece banner DEBUG; no se inicia GPS/voz por abrir la app. Petición inesperada se detiene y registra.
- **Evidencia requerida:** UI2_PHYSICAL_ANDROID: captura consentida y registro de arranque.
- **Riesgo:** Asumir que build implica funcionamiento físico.
- **Restauración:** Volver a exploración; no conceder permisos inesperados.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-05

- **Título:** Tiles reales y atribución (grupo B).
- **Objetivo:** Separar mapa real de renderer.
- **Referencia contractual:** UI2-AC-01/12/13; ADR-019; P8 §9.
- **Precondiciones:** Red autorizada; backend y proveedor no asumidos operativos; G4 para capturas.
- **Datos necesarios:** Zona pública no sensible del corredor elegido.
- **Pasos:**
  1. Abrir mapa en una zona autorizada; esperar tiles y registrar hora.
  2. Hacer un desplazamiento acotado manual para observar tiles de otra zona.
  3. Leer atribución en mapa y lista, vertical/horizontal.
- **Resultado esperado:** Tiles cartográficos reales distinguibles de fondo vacío; atribución legible y accesible en exploración. Indisponibilidad se registra sin cambiar proveedor ni declarar PASS.
- **Evidencia requerida:** UI2_REAL_TILES: captura y anotación de área pública, zoom/orientación y disponibilidad.
- **Riesgo:** Proveedor inaccesible o confusión con tiles previamente cacheados.
- **Restauración:** Restaurar viewport de partida; no descargar mapas ni tiles masivos.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-06

- **Título:** Ruta y lista sin oclusión (grupo B).
- **Objetivo:** Verificar coexistencia de trazado y resultados.
- **Referencia contractual:** UI2-AC-01/02/13; P8-AC-04.
- **Precondiciones:** Ruta y snapshot reales válidos del mismo envelope; sin sesión B1.
- **Datos necesarios:** Extremos por mapa y corredor público aprobado.
- **Pasos:**
  1. Elegir origen/destino por mapa y usar el planificador existente.
  2. Con ruta y resultados, abrir lista; comparar trazado/mapa con lista cerrada.
  3. Repetir vertical/horizontal y con teclado si procede.
- **Resultado esperado:** Mapa y parte reconocible del trazado conservan espacio propio; lista no se superpone ocultando su superficie; controles alcanzables sin overflow.
- **Evidencia requerida:** UI2_REAL_TILES y UI2_PHYSICAL_ANDROID: pares misma orientación/escala.
- **Riesgo:** Ausencia de ruta/POIs o atribuir al layout un fallo de proveedor.
- **Restauración:** Cerrar teclado/lista y restaurar orientación.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-07

- **Título:** Cámara y alternancia (grupo B).
- **Objetivo:** Comprobar gestos existentes y retorno.
- **Referencia contractual:** UI2-AC-02/06; P8 §7/9.
- **Precondiciones:** Exploración con ruta elegible; ubicación sin activar.
- **Datos necesarios:** Viewport inicial anotado sin coordenadas sensibles.
- **Pasos:**
  1. Hacer pan/zoom manual fuera de Driving.
  2. Alternar mapa/lista y abrir/cerrar Preview.
  3. Comparar posición relativa de referencias públicas y zoom antes/después.
- **Resultado esperado:** La consulta visual no introduce seguimiento ni recenter automático; retorno conserva viewport factible y ruta/filtros vigentes.
- **Evidencia requerida:** Secuencia corta consentida y registro comparativo.
- **Riesgo:** Confundir encuadre de ruta existente con política GPS nueva.
- **Restauración:** Restaurar encuadre manual inicial.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-08

- **Título:** Categorías y estados de consulta (grupo B).
- **Objetivo:** Preservar la semántica de filtros backend.
- **Referencia contractual:** UI2-AC-03/09; P8 §7, AC03/05.
- **Precondiciones:** Backend autorizado disponible para parte online; sin B1.
- **Datos necesarios:** Categorías actuales; ruta pública y resultados reales.
- **Pasos:**
  1. Anotar filtros y resultado inicial.
  2. Abrir categorías, editar y Cancelar; verificar contexto.
  3. Aplicar otra selección y Reset según controles existentes; observar loading y respuesta/estado.
- **Resultado esperado:** Cancelar no muta; Aplicar/Reset usan el flujo existente; carga/error/vacío no fabrican POIs ni mezclan criterios. No se exige duración mínima del loading.
- **Evidencia requerida:** Registro de acciones y respuestas autorizadas, captura de estado observable.
- **Riesgo:** Respuesta rápida impide capturar loading; falta de categoría en datos.
- **Restauración:** Restaurar categorías iniciales; no afirmar estado físico no observado.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-09

- **Título:** Identidad mapa/lista (grupo C).
- **Objetivo:** Comparar el mismo POI sin mostrar UUID al usuario.
- **Referencia contractual:** UI2-AC-02/04; P8-AC-01/04.
- **Precondiciones:** Snapshot real con dos o más POIs distinguibles; fuente de IDs autorizada.
- **Datos necesarios:** Listado privado ID↔nombre del mismo response, si disponible.
- **Pasos:**
  1. Abrir marcador y anotar nombre/categoría de Preview.
  2. Abrir su fila en lista y comparar la misma ficha.
  3. Cotejar ID técnico solo en evidencia privada del response, no en pantalla.
- **Resultado esperado:** Marker/fila abren el mismo POI; lista y marcadores representan el mismo subconjunto. Si solo hay nombres duplicados y no puede cotejarse ID, registrar bloqueo parcial.
- **Evidencia requerida:** Tabla privada de correspondencia y capturas redactadas.
- **Riesgo:** Inferir identidad solo por nombres duplicados.
- **Restauración:** Cerrar ficha sin seleccionar.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-10

- **Título:** Tarjeta factual y placeholder (grupo C).
- **Objetivo:** Comprobar contenido disponible y semántica de distancia.
- **Referencia contractual:** UI2-AC-04/05/10; U2-D02/D03; P8 §8.
- **Precondiciones:** POIs reales con campos disponibles y response autorizado.
- **Datos necesarios:** Nombre/categoría/distancia/fuente existentes; no fotos nuevas.
- **Pasos:**
  1. Comparar tarjeta con datos recibidos.
  2. Comprobar etiqueta de distancia, categoría legible y ausencia de score/UUID/routeProgress.
  3. Revisar área de miniatura y placeholder.
- **Resultado esperado:** Se muestran solo campos suministrados y significativos; distancia dice «A X m del trazado» según formato existente, sin ETA/desvío/distancia al viajero; placeholder no simula foto.
- **Evidencia requerida:** UI2_PHYSICAL_ANDROID: captura con cotejo privado de campos.
- **Riesgo:** Confundir procedencia textual con derechos de imagen.
- **Restauración:** Cerrar lista si estaba cerrada al inicio.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-11

- **Título:** Preview y Detail con contexto (grupo C).
- **Objetivo:** Validar recorrido de consulta sin selección implícita.
- **Referencia contractual:** UI2-AC-06/07; P8-AC-01/02.
- **Precondiciones:** Consulta local, filtros y viewport anotados; sin B1.
- **Datos necesarios:** POI real elegible.
- **Pasos:**
  1. Abrir Preview desde lista y «Ver detalle» mediante control existente.
  2. Leer y desplazar Detail; usar Volver y cerrar Preview.
  3. Comparar ruta/filtros/query/selección y viewport factible.
- **Resultado esperado:** Lectura accesible de datos reales; se conserva contexto válido y chosenIds no cambia por consultar. Campos ausentes no se inventan.
- **Evidencia requerida:** Secuencia consentida y registro antes/después.
- **Riesgo:** Perder contexto por cierre de modal o datos vencidos durante ensayo.
- **Restauración:** Cerrar modales; si venció snapshot no restaurarlo.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-12

- **Título:** Opcionales y nombres largos (grupo C).
- **Objetivo:** Revisar extremos de contenido disponibles.
- **Referencia contractual:** UI2-AC-04/10/13; U2-D02/D06.
- **Precondiciones:** Datos reales contienen variantes pertinentes; si no, subcasos bloqueados.
- **Datos necesarios:** Nombre largo; descripción/fuente presentes y ausentes, cuando existan.
- **Pasos:**
  1. Seleccionar cada variante real sin modificar backend.
  2. Revisar tarjeta, Preview y Detail en ambas orientaciones.
  3. Con texto grande autorizado, desplazar detalle y alcanzar Volver.
- **Resultado esperado:** No aparecen textos null/códigos crudos ni contenido inventado. Truncamiento acotado de descripción en tarjeta es permitido; detalle desplazable conserva contenido y acción.
- **Evidencia requerida:** Inventario de variantes observadas; subcasos ausentes NOT_EXECUTED y referencia widget/renderer.
- **Riesgo:** Crear fixture dentro de APK para suplir datos faltantes.
- **Restauración:** Restaurar texto/orientación; no inyectar datos.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-13

- **Título:** Normalización del filtro local (grupo D).
- **Objetivo:** Contrastar variantes de nombre reales.
- **Referencia contractual:** UI2-AC-08; U2-D01.
- **Precondiciones:** Snapshot real vigente; nombres adecuados disponibles; teclado sin dictado.
- **Datos necesarios:** Nombre real, variante mayúscula, sin tilde, espacios y subcadena derivadas de él.
- **Pasos:**
  1. Escribir nombre/subcadena, mayúsculas y variante sin diacríticos.
  2. Probar espacios iniciales/finales y múltiples solo donde el nombre lo permita.
  3. Anotar lista de coincidencias para cada variante.
- **Resultado esperado:** Las variantes normalizadas equivalentes producen mismos IDs en orden original; solo se filtra nombre. «canta» solo se usa si existe ese nombre/variante en el snapshot.
- **Evidencia requerida:** Tabla query→IDs privada y capturas; Unicode complejo no disponible queda automatizado.
- **Riesgo:** Confundir corrección del teclado con normalización de la app.
- **Restauración:** Vaciar campo con teclado; no usar micrófono.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-14

- **Título:** Subconjunto, orden y vacío local (grupo D).
- **Objetivo:** Validar alcance acotado y equivalencia.
- **Referencia contractual:** UI2-AC-02/08; U2-D01/D04.
- **Precondiciones:** Snapshot real con resultados; orden inicial anotado.
- **Datos necesarios:** Subcadena con coincidencias y texto que no coincide.
- **Pasos:**
  1. Anotar orden antes de filtrar.
  2. Introducir subcadena y comparar lista/marcadores; limpiar.
  3. Introducir texto sin coincidencias.
- **Resultado esperado:** Subconjunto preserva orden del snapshot y mismos POIs en mapa/lista; vacío exacto «No hay coincidencias en estos resultados»; al limpiar se recupera conjunto vigente, sin afirmar ausencia geográfica global.
- **Evidencia requerida:** Secuencia y tabla de orden/subconjunto.
- **Riesgo:** No distinguir vacío de backend y vacío del filtro.
- **Restauración:** Limpiar consulta.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-15

- **Título:** Retención y reemplazo del snapshot (grupo D).
- **Objetivo:** Separar continuidad de consulta y cambio de identidad.
- **Referencia contractual:** UI2-AC-06/08; U2-D01; I01.
- **Precondiciones:** Backend operativo; sin B1; query no vacía.
- **Datos necesarios:** Snapshot A, luego respuesta nueva B obtenida mediante flujo existente.
- **Pasos:**
  1. Con query activa abrir/cerrar Preview/Detail y alternar lista/mapa.
  2. Comprobar retención en la misma sesión.
  3. Aplicar filtro backend o recalcular extremos por mapa para obtener nueva respuesta; volver a lista.
- **Resultado esperado:** Consulta sobrevive consulta visual; nueva identidad de snapshot limpia query y resultados corresponden a B. No basta asumir reemplazo por un repintado.
- **Evidencia requerida:** Registro de respuestas A/B y query; caso misma queryKey/nueva instancia cubierto con test.
- **Riesgo:** No obtener nueva respuesta o mezclar POIs antiguos.
- **Restauración:** Restablecer ruta/filtros solo con nueva consulta explícita; no restaurar snapshots caducados.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-16

- **Título:** Expiración de consulta local (grupo D).
- **Objetivo:** Observar limpieza sin manipular reloj.
- **Referencia contractual:** UI2-AC-08/09; U2-D01; P9 §6.
- **Precondiciones:** Snapshot con recepción original documentada; sesión futura con tiempo suficiente.
- **Datos necesarios:** Hora original, query activa y elegibilidad conocida.
- **Pasos:**
  1. Programar observación antes/después de 24 h desde recepción sin recapturar.
  2. Mantener/reanudar Exploración y observar campo/resultados.
  3. No cambiar hora del SO, DB ni código para acelerar.
- **Resultado esperado:** Al perder elegibilidad no se muestran POIs vencidos; consulta se limpia. UI online puede mostrar «Resultados no disponibles. Reintenta para consultar datos nuevos»; no esperar purga física del objeto online.
- **Evidencia requerida:** Registro temporal y capturas; frontera ±1 ms permanece COVERED_AUTOMATED.
- **Riesgo:** Sesión insuficiente para 24 h o nueva respuesta renueva snapshot.
- **Restauración:** No recuperar copia vencida; retry solo manual tras ensayo.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-17

- **Título:** Salida y recreación de Exploración (grupo D).
- **Objetivo:** Verificar estado efímero sin iniciar GPS.
- **Referencia contractual:** UI2-AC-08/11; U2-D01.
- **Precondiciones:** Sin sesión B1/GPS/voz; autorización futura para cerrar proceso; contexto local protegido.
- **Datos necesarios:** Query activa y captura consentida registrada aparte.
- **Pasos:**
  1. Anotar query y contexto.
  2. Cerrar realmente proceso por acción aprobada del operador; reabrir app.
  3. No equiparar Home/minimizar con destruir Exploración.
- **Resultado esperado:** Query no persiste tras recreación; ninguna edición previa se ejecuta diferida. Entrada/salida Driving se cubre solo en PHY-35 si se autoriza.
- **Evidencia requerida:** Registro de terminación/reapertura y consulta vacía; complemento de teardown automatizado.
- **Riesgo:** Interrumpir sesión background o asumir muerte de proceso por Home.
- **Restauración:** No cerrar proceso con GPS/voz activos; volver a contexto válido explícitamente.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-18

- **Título:** Observación de red al escribir (grupo D).
- **Objetivo:** Observar tráfico recibido y limitar la conclusión.
- **Referencia contractual:** UI2-AC-08/14; U2-D01/D05.
- **Precondiciones:** Ventana autorizada de observación de access logs existentes; reloj correlacionado; sin otros clientes confundibles.
- **Datos necesarios:** Endpoints /api/v1/routes/plan y /api/v1/routes/discover, ventana control y ventana de escritura.
- **Pasos:**
  1. Confirmar que un retry explícito aparece como control positivo en el log disponible.
  2. Abrir snapshot ya cargado; marcar inicio/fin; tipear/limpiar filtro sin otras acciones ni refresh.
  3. Contar solicitudes recibidas por esos endpoints; separar tiles y otras sesiones; sanear consulta/IP.
- **Resultado esperado:** Ninguna solicitud recibida se asocia a tipear. Esto NO demuestra cero intentos cliente: si no hay observabilidad suficiente, BLOCKED_BY_PRECONDITION. La garantía cero llamadas se conserva como COVERED_AUTOMATED mediante spy repository, nunca PASS físico completo por silencio de servidor.
- **Evidencia requerida:** Conteos y ventanas redactadas; enlace al test «filter has zero source calls» UI2.1.
- **Riesgo:** HTTPS/pcap o logcat sin instrumentación no prueban ausencia; no instalar proxy, certificados ni cambiar backend.
- **Restauración:** Cerrar acceso a logs; no alterar logging/infra ni guardar IP/tokens.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-19

- **Título:** Selección explícita I01 (grupo E).
- **Objetivo:** Distinguir consulta de elección.
- **Referencia contractual:** UI2-AC-07; I01; P8 continuidad.
- **Precondiciones:** Snapshot vigente; sin B1; borrador conocido.
- **Datos necesarios:** POI inicialmente no elegido.
- **Pasos:**
  1. Abrir marcador y tarjeta y recorrer Preview/Detail sin elegir.
  2. Comprobar control «Elegir para este recorrido».
  3. Elegir explícitamente y comprobar «Quitar de este recorrido»; quitar.
- **Resultado esperado:** Solo la acción explícita cambia elección del POI actual; consultar no elige ni inicia recorrido GPS/CEFI.
- **Evidencia requerida:** Registro antes/después del control y chosenIds si observable sin nueva instrumentación.
- **Riesgo:** Tomar apertura por selección; iniciar recorrido accidentalmente.
- **Restauración:** Quitar únicamente la elección añadida para ensayo.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-20

- **Título:** Elegibilidad e invalidación I01 (grupo E).
- **Objetivo:** Evitar selección de IDs anteriores.
- **Referencia contractual:** UI2-AC-07/09; I01.
- **Precondiciones:** Sin B1; snapshot A elegido y posibilidad de nueva respuesta B.
- **Datos necesarios:** POI de A; B realmente obtenido.
- **Pasos:**
  1. Elegir un POI de A explícitamente.
  2. Obtener nueva respuesta B mediante categorías/extremos existentes.
  3. Abrir POI de B y comprobar que no hereda selección antigua; no intentar IDs inyectados.
- **Resultado esperado:** Borrador anterior se invalida por identidad nueva; no resucita elección de A. IDs ajenos y vencimiento exacto solo se completan con tests si no son observables.
- **Evidencia requerida:** Registro A/B y selección; i01_selection/widget como complemento.
- **Riesgo:** Confundir mismo ID presente en A y B con selección conservada.
- **Restauración:** Quitar selecciones de ensayo en contexto vigente.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-21

- **Título:** Freeze y restricciones B1 (grupo E).
- **Objetivo:** Mantener cobertura sin arrancar GPS para UI-2.2.
- **Referencia contractual:** UI2-AC-07/11/14; I01/B1/R01.
- **Precondiciones:** Revisión de tests archivados disponible; ejecución física B1 requiere autorización funcional separada.
- **Datos necesarios:** Evidencia i01_widget/i01_worker/b1_widget.
- **Pasos:**
  1. Cotejar tests y logs UI2.1 para freeze/ownership y bloqueo de edición/discovery/cache.
  2. Registrar estado físico NOT_EXECUTED.
  3. No iniciar recorrido GPS ni precrear sesión para esta prueba; solo diseñar extensión si el responsable la autoriza aparte.
- **Resultado esperado:** COVERED_AUTOMATED para invariantes; componente físico BLOCKED_BY_PRECONDITION de autorización B1. No se considera N/A ni PASS físico.
- **Evidencia requerida:** Referencia a tests/logs; decisión humana pendiente sobre extensión B1.
- **Riesgo:** Ampliar UI-2.2 a GPS funcional por una prueba.
- **Restauración:** N/A ahora; una extensión futura deberá definir Stop/restauración propios.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-22

- **Título:** Consentimiento y reapertura offline (grupo F).
- **Objetivo:** Validar captura explícita y coherencia P9.
- **Referencia contractual:** UI2-AC-09; P9 §6, AC01/05/08.
- **Precondiciones:** Operador aprueba reemplazar una copia local de prueba; sin datos que deban conservarse; sin B1.
- **Datos necesarios:** Ruta/query/POIs públicos válidos y captura no autorizada aún.
- **Pasos:**
  1. Abrir Copia offline y leer explicación; Volver sin autorizar.
  2. Reabrir y pulsar «Permitir copia offline durante esta sesión» bajo autorización.
  3. Obtener respuesta coherente y anotar recepción original; reiniciar proceso autorizado y revisar resumen.
- **Resultado esperado:** Cancelar no concede; captura es explícita; una copia reemplazable coherente. Reapertura no implica red automática ni selección/modal automático; nuevo permiso de captura por sesión.
- **Evidencia requerida:** Estado antes/después y horarios, sin exportar DB ni coordenadas privadas.
- **Riesgo:** Reemplazar copia del usuario; consentimiento inferido.
- **Restauración:** No borrar copia ajena. Copia de prueba se gestiona en PHY-26 con permiso específico.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-23

- **Título:** Desconexión y recuperación cached (grupo F).
- **Objetivo:** Observar datos disponibles sin exigir tiles offline.
- **Referencia contractual:** UI2-AC-09; P9-AC-01/02/03/04.
- **Precondiciones:** Copia elegible coherente; G4 autoriza corte/restauración de red; sin GPS.
- **Datos necesarios:** Criterios y ruta de captura.
- **Pasos:**
  1. Registrar conectividad inicial y desconectar red mediante operador.
  2. Abrir/reabrir datos y, si procede, retry manual de misma consulta.
  3. Comprobar rótulo cached y ficha; reconectar y reintentar explícitamente.
- **Resultado esperado:** Copia elegible de misma consulta conserva ruta/POIs/filtros con aviso de copia/error; no afirma refresco. Tiles pueden faltar: P9 no ofrece mapas offline.
- **Evidencia requerida:** UI2_PHYSICAL_ANDROID/REGRESSION: estados y acciones con tiempos.
- **Riesgo:** Corte afecta comunicaciones personales; copia no elegible.
- **Restauración:** Restaurar Wi-Fi/datos al estado inicial; no togglear modo avión sin autorización específica.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-24

- **Título:** Vacío, no disponible y error/retry (grupo F).
- **Objetivo:** Distinguir estados sin fabricar respuestas.
- **Referencia contractual:** UI2-AC-03/09; P8-AC-05; P9-AC-01/03/10.
- **Precondiciones:** Datos y condiciones reales autorizados; subcasos que no existan se bloquean.
- **Datos necesarios:** Consulta real vacía conocida; error de conectividad controlado; contexto sin copia solo si ya existe o PHY-26 autorizado.
- **Pasos:**
  1. Observar vacío backend en corredor/categoría que realmente lo devuelva.
  2. Sin copia elegible y sin red observar no disponible.
  3. Restaurar red y usar Reintentar; registrar TLS/seguridad solo si ocurre naturalmente, sin provocarlo.
- **Resultado esperado:** Vacío de consulta difiere de error/no disponible; retry manual recupera datos reales manteniendo criterios. Nunca bypass TLS ni éxito cacheado que oculte error de seguridad.
- **Evidencia requerida:** Registro por subcaso con respuesta/condición; tests cubren escenarios no reproducibles.
- **Riesgo:** Destruir copia solo para conseguir un estado; simular backend físico.
- **Restauración:** Restaurar red y filtros; no modificar servidor/certificados.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-25

- **Título:** Vigencia, límites y privacidad offline (grupo F).
- **Objetivo:** Separar observación temporal de fronteras automatizadas.
- **Referencia contractual:** UI2-AC-09/14; P9-AC-05/10.
- **Precondiciones:** Copia de prueba con hora original; ventana futura ≥24 h si se intenta físicamente.
- **Datos necesarios:** Recepción original; elegibilidad; anexo P9.
- **Pasos:**
  1. Leer/reabrir la misma copia antes de vencer, sin recaptura.
  2. Después de 24 h reabrir offline y comprobar no elegibilidad.
  3. Cotejar TTL 86.400.000 ms, payload 5.242.880 bytes, una fila y no-backup con evidencia automatizada/estática.
- **Resultado esperado:** Leer/reiniciar no renueva TTL; copia vencida no se sirve. No se promete tamaño total disco de 5 MiB ni prueba forense; límites exactos/backup real no se atribuyen a esta sesión.
- **Evidencia requerida:** Registro temporal separado de offline_cache_test y anexo; casos no realizados NOT_EXECUTED.
- **Riesgo:** Alterar reloj, llenar almacenamiento o exportar DB.
- **Restauración:** No manipular reloj/DB; reconectar/retry con permiso al finalizar.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-26

- **Título:** Borrado consentido de copia de prueba (grupo F).
- **Objetivo:** Verificar revocación sin destruir datos ajenos.
- **Referencia contractual:** UI2-AC-09; P9 §6, AC05/10.
- **Precondiciones:** Autorización específica potencialmente destructiva; solo copia de prueba; sin B1.
- **Datos necesarios:** Copia desechable identificada y contexto original documentado.
- **Pasos:**
  1. Abrir Copia offline y pulsar «Eliminar copia offline y desactivar captura» solo tras permiso.
  2. Comprobar mensaje/ausencia de copia disponible.
  3. Reabrir/reiniciar aprobado y comprobar que no reaparece sin nueva captura explícita.
- **Resultado esperado:** Ausencia lógica de copia y captura desactivada; no promesa de borrado forense. Nunca usar pm clear, desinstalar o extraer DB.
- **Evidencia requerida:** Registro de consentimiento, resultado y comprobación posterior; sin contenido privado.
- **Riesgo:** Pérdida irreversible de copia local.
- **Restauración:** No existe undo garantizado; recrear solo copia de prueba con consentimiento nuevo, nunca prometer recuperar original.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-27

- **Título:** TalkBack y orden de foco (grupo G).
- **Objetivo:** Acceder al shell y lista con lector real.
- **Referencia contractual:** UI2-AC-12; U2-D06; P8 §10; P9-AC-09.
- **Precondiciones:** G4 autoriza TalkBack; operador conoce cómo desactivarlo; capturas/audio separados.
- **Datos necesarios:** Configuración previa de accesibilidad y lista real.
- **Pasos:**
  1. Operador activa TalkBack desde Ajustes de accesibilidad siguiendo instrucciones locales del teléfono.
  2. Recorrer foco con deslizamientos, activar con doble toque y desplazarse con dos dedos.
  3. Llegar al cierre fijo de lista sin recorrer todos sus elementos.
- **Resultado esperado:** Orden permite entender y operar shell/lista; cierre accesible al principio; nombres/roles comprensibles. Anotar texto realmente anunciado, incluido idioma, sin inferirlo de semantics.
- **Evidencia requerida:** UI2_TALKBACK_PHYSICAL: transcripción manual; grabación solo consentida.
- **Riesgo:** Operador pierde capacidad de salir del lector.
- **Restauración:** Desactivar con método previamente identificado o ayuda del operador; restaurar ajuste original.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-28

- **Título:** Lectura de tarjetas y fichas (grupo G).
- **Objetivo:** Validar contenido y acciones con TalkBack.
- **Referencia contractual:** UI2-AC-04/05/06/10/12; U2-D02/D06.
- **Precondiciones:** PHY-27 y datos reales.
- **Datos necesarios:** Tarjeta y Preview/Detail del mismo POI.
- **Pasos:**
  1. Recorrer tarjeta y anotar nombre/categoría/distancia/placeholder anunciados.
  2. Abrir Preview y Detail con TalkBack, desplazar y volver.
  3. Comprobar foco de regreso y selección sin cambios.
- **Resultado esperado:** Anuncio de distancia se refiere al trazado; placeholder «Imagen no disponible»; datos y botones alcanzables. No exigir literal completo de lectura si Android agrega rol/estado.
- **Evidencia requerida:** Transcripción de orden/acciones y observaciones por control.
- **Riesgo:** Dato opcional ausente limita cobertura; doble anuncio.
- **Restauración:** Cerrar fichas y volver a lista; no activar voz CEFI.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-29

- **Título:** Filtro, teclado y estados anunciados (grupo G).
- **Objetivo:** Operar filtro sin depender del color.
- **Referencia contractual:** UI2-AC-08/09/12; U2-D01/D06.
- **Precondiciones:** TalkBack aprobado; snapshot elegible y teclado sin dictado.
- **Datos necesarios:** Query con coincidencias y sin coincidencias.
- **Pasos:**
  1. Enfocar «Buscar en estos resultados» y editar usando teclado.
  2. Comprobar identificación del campo, resultados y vacío; cerrar teclado.
  3. Observar loading/error reales y acción de recuperación cuando existan.
- **Resultado esperado:** Filtro/estado se comprende con lector; mensaje local exacto, acciones alcanzables, sin foco atrapado. Estados no reproducidos se mantienen pendientes.
- **Evidencia requerida:** Transcripción por estado, captura consentida opcional.
- **Riesgo:** Dictado del teclado activa micrófono fuera de prueba.
- **Restauración:** Vaciar consulta; cerrar teclado y restaurar TalkBack al acabar bloque.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-30

- **Título:** Texto grande y orientación (grupo G).
- **Objetivo:** Comprobar Android real sin equiparar tamaños lógicos.
- **Referencia contractual:** UI2-AC-01/12/13; U2-D06.
- **Precondiciones:** G4 autoriza escala/orientación; valores originales anotados.
- **Datos necesarios:** Escala base y grande seleccionables; vistas mapa/lista/Preview/Detail.
- **Pasos:**
  1. Recorrer vistas en escala original y grande autorizada; anotar valor real o limitación del preset.
  2. Rotar vertical/horizontal; abrir teclado en filtro y desplazar lista/ficha.
  3. Cerrar teclado y volver a acciones/estado.
- **Resultado esperado:** Sin overflow o recorte de acciones críticas; mapa/ruta y cierre de lista accesibles. Un teléfono no acredita los cuatro viewports exactos ni TextScaler 2.0 si no se conoce su equivalencia.
- **Evidencia requerida:** Capturas por orientación/escala y medidas observadas; matriz 4×2 automatizada complementaria.
- **Riesgo:** Cambiar tamaño de pantalla/densidad para forzar viewports.
- **Restauración:** Restaurar tamaño de fuente y bloqueo de rotación originales; no usar wm size/density para cambiarlos.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-31

- **Título:** Contraste y targets (grupo G).
- **Objetivo:** Comprobar legibilidad y geometría con método medible.
- **Referencia contractual:** UI2-AC-12/13; U2-D06; P9-AC-09.
- **Precondiciones:** Captura autorizada y métricas reales de densidad; sin alterar SO.
- **Datos necesarios:** Superficies opacas de controles, texto, iconos y cierre.
- **Pasos:**
  1. Revisar controles sobre tiles claros/oscuros disponibles.
  2. Medir colores de superficies/textos en zonas interiores sin antialias y contrastar tokens; calcular contraste con método WCAG ya usado en tests.
  3. Medir bounds táctiles mediante datos accesibles disponibles, no solo tamaño del glifo; si no medibles, mantener evidencia automatizada para 48 dp.
- **Resultado esperado:** 4.5:1 texto normal y 3:1 texto grande/elementos esenciales según P9; targets ≥48×48 dp cuando verificables. Densidad nominal o screenshot sola no prueba bounds táctiles ni toda cartografía.
- **Evidencia requerida:** Cálculo/medida anotados; guideline/token tests como COVERED_AUTOMATED.
- **Riesgo:** Declarar PASS por impresión visual o convertir px con densidad incorrecta.
- **Restauración:** N/A: no modificar colores ni métricas del dispositivo.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-32

- **Título:** Accesibilidad de estados y recuperación (grupo G).
- **Objetivo:** Alcanzar mensajes y retry sin mapa.
- **Referencia contractual:** UI2-AC-09/12; P8-AC-08/10; P9-AC-09.
- **Precondiciones:** TalkBack y estados reales autorizados.
- **Datos necesarios:** Copia/no disponible/error/vacío reproducibles.
- **Pasos:**
  1. En cada estado disponible recorrer foco y escuchar mensaje/acción.
  2. Intentar recuperar por acción existente sin usar mapa ni color.
  3. Registrar subcasos no disponibles en lugar de introducir fixtures.
- **Resultado esperado:** Estado comprensible y recuperación alcanzable; contexto válido se conserva. Cualquier falta de anuncio se registra como hallazgo con estado observado, no se corrige código.
- **Evidencia requerida:** UI2_TALKBACK_PHYSICAL: tabla estado→anuncio→acción.
- **Riesgo:** Confundir ausencia del estado con PASS de accesibilidad.
- **Restauración:** Restaurar conectividad/lector como al inicio.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-33

- **Título:** Navegación y estabilidad (grupo H).
- **Objetivo:** Comprobar regreso sin bucles o pérdida de contexto.
- **Referencia contractual:** UI2-AC-06/14; P8 continuidad; UI-1 shell.
- **Precondiciones:** Sin GPS/voz/B1; contexto elegible.
- **Datos necesarios:** Ruta/filtros y query existentes.
- **Pasos:**
  1. Repetir tres ciclos mapa/lista→Preview→Detail→Volver/cerrar.
  2. Usar Back para cerrar teclado/modal en Exploración según navegación existente.
  3. Anotar cierre inesperado, duplicación de modales o solicitudes repetidas observadas.
- **Resultado esperado:** Regreso conserva contexto elegible; no pila duplicada ni cierres/crash observados en los tres ciclos. No se inventa SLA de rendimiento o prueba prolongada.
- **Evidencia requerida:** UI2_PHYSICAL_REGRESSION: secuencia y eventos con fecha.
- **Riesgo:** Repetir sobre snapshot vencido y exigir restaurarlo.
- **Restauración:** Cerrar modales y limpiar solo query de ensayo.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-34

- **Título:** Permisos, GPS y CEFI sin activación nueva (grupo H).
- **Objetivo:** Detectar efectos no autorizados en flujos UI.
- **Referencia contractual:** UI2-AC-11/14; ADR-027; B1/R01/C2.
- **Precondiciones:** Estado original permisos/consentimientos conocido; no sesiones activas; sin pulsar controles GPS/voz.
- **Datos necesarios:** Manifest/diff y comportamiento de app integrada.
- **Pasos:**
  1. Durante casos ordinarios observar peticiones Android y aparición de indicadores de ubicación/micrófono/audio.
  2. Cotejar permisos declarados con baseline sin modificarlos.
  3. Si aparece activación inesperada, detener y registrar alcance/última acción.
- **Resultado esperado:** Ningún control UI-2 solicita permisos nuevos ni inicia GPS, micrófono o TTS; ausencia visible es observación acotada, diff/tests sostienen no regresión funcional.
- **Evidencia requerida:** Registro de observación y referencia a scope-audit/GPS/voz tests; no grabación de audio por defecto.
- **Riesgo:** Confundir servicio preexistente con regresión UI-2 o asumir toda ausencia por indicadores.
- **Restauración:** No revocar/detener sesiones ajenas; detener ensayo y avisar al responsable.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-35

- **Título:** Driving reducido estacionario opcional (grupo H).
- **Objetivo:** Observar exclusión de filtro sin probar GPS funcional.
- **Referencia contractual:** UI2-AC-08/11; P9 §7; UI-0 compatibilidad.
- **Precondiciones:** Autorización futura explícita para este subcaso; ruta válida; sin operación pendiente ni sesión GPS/voz; equipo estacionario.
- **Datos necesarios:** Query activa; baseline Driving existente.
- **Pasos:**
  1. Entrar manualmente en modo conducción reducido solo si el gate específico se concedió.
  2. Comprobar ausencia de filtro/lista/selección/controles nuevos, vista estática y salida explícita.
  3. Salir con «Salir de modo conducción»; comprobar que query no reaparece ni hay acciones diferidas.
- **Resultado esperado:** Se conserva árbol reducido existente y query se limpia; entrar no activa GPS/voz. Discrepancias P9/GPS conocidas se documentan, sin exigir política pasiva propuesta ni arreglos de atribución/retorno no aprobados.
- **Evidencia requerida:** UI2_PHYSICAL_REGRESSION: antes/durante/después; guards directos solo COVERED_AUTOMATED.
- **Riesgo:** Expandir a navegación, callbacks nativos, sesión B1 o movimiento.
- **Restauración:** Salir explícitamente; si entrada está bloqueada, no forzar guards. Sin gate, NOT_EXECUTED.
- **Estado inicial:** NOT_EXECUTED

## UI2-PHY-36

- **Título:** Restauración y cierre de sesión (grupo H).
- **Objetivo:** Devolver ajustes y reportar límites sin cerrar UI-2.
- **Referencia contractual:** P9-AC-10/12; U2-D05; gates UI-2.2.
- **Precondiciones:** G5; bitácora inicial completa; operador presente.
- **Datos necesarios:** Ajustes iniciales, evidencias privadas y lista de cambios autorizados.
- **Pasos:**
  1. Restaurar TalkBack, fuente, orientación, red, ubicación/permisos solo si se modificaron con permiso.
  2. Cerrar app y desconectar USB de forma aprobada; restaurar depuración.
  3. Revisar resultados/subcasos, hashes y redacciones; pedir aceptación del responsable.
- **Resultado esperado:** Ajustes comparados individualmente con inicio o discrepancia documentada; evidencias privadas; sin publicación automática, cierre maestro ni Production Readiness.
- **Evidencia requerida:** Checklist firmado/aceptado y resultado por caso; ningún caso no ejecutado se convierte en PASS.
- **Riesgo:** No poder restaurar datos borrados, voz/ajustes o capturas sensibles.
- **Restauración:** Registrar pendiente y propietario; no borrar evidencias ni datos ajenos para ocultarlo.
- **Estado inicial:** NOT_EXECUTED

## Auditoría documental de preparación

Validación estática del 2026-10-18: cuatro archivos UTF-8 estrictos; enlaces locales y anchors
comprobados; fences equilibrados; 36 IDs consecutivos únicos con los once campos exigidos;
36 filas de resultados NOT_EXECUTED; cobertura trazada de los 14 AC. Sin resultados físicos ficticios.
Revisión contractual: sin nueva funcionalidad o cambio normativo P8/P9/UI-2; restricciones B1/GPS/voz
y Driving conservadas como límites de ejecución. No se repitieron builds ni las 202 pruebas.

Inventario comparado antes/después de redacción: 19 worktrees preexistentes con mismos HEAD,
rama y status; 12 archivos pendientes con mismos SHA-256; 3 stashes con mismos OID y mensajes.
Solo se añadió el worktree UI-2.2. Los APK leídos conservaron sus hashes. Ninguna interacción ADB,
descubrimiento Flutter de dispositivos, instalación, captura física, ajuste o despliegue.
En el checkpoint inicial de preparación, el commit local 8da7c62eb69540400600d19d5b96cf5c30836f17
contenía exclusivamente estos cuatro documentos y aún no se había publicado. La autorización
humana posterior aprueba el protocolo y su integración documental; el SHA/PR/merge se informa
en el reporte final de esta integración.

## Gobierno al entregar

```ini
UI_2_CONTRACT = APPROVED_FROZEN
UI_2_1_CODE_INTEGRATION = PASS
UI_2_2_PROTOCOL = APPROVED
UI_2_2_PROTOCOL_APPROVAL = APPROVED
PERSONAL_DEVICE_MINIMUM_ACCESS = ENFORCED
UI_2_2_PHYSICAL_EXECUTION = NOT_AUTHORIZED
UI_2_PHYSICAL_VALIDATION = NOT_EXECUTED
UI_2_TALKBACK_VALIDATION = NOT_EXECUTED
UI_2_REAL_TILES_VALIDATION = NOT_EXECUTED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
UI_2_2_PUSH = NOT_AUTHORIZED
UI_2_2_PR = NOT_AUTHORIZED
UI_2_2_MERGE = NOT_AUTHORIZED
ADMIN_IMPLEMENTATION = NOT_AUTHORIZED
DRIVING_FUNCTIONAL_PACKAGE = NOT_AUTHORIZED
UI_3_IMPLEMENTATION = NOT_AUTHORIZED
```

Siguiente decisión humana: aprobar la revisión documental UI-2.2. La conexión, instalación,
permisos, capturas y ejecución física requieren autorización posterior independiente.

STOP_AND_REPORT
