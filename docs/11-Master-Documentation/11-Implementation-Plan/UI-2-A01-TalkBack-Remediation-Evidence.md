# UI-2 — A01 TalkBack Remediation Evidence

Fecha: 2026-10-24, America/Bogota. Diagnóstico focalizado autorizado por el
propietario. La selección de corrección queda detenida por evidencia física
insuficiente; no se introduce una solución especulativa.

## 1. Baseline y autorización

- `origin/main` tras fetch y `refs/heads/main` remoto:
  `a17734f665d72b99e1f901c6634f8dcdc4b31288`, baseline esperado y técnico de partida.
- Rama nueva: `codex/ui2-a01-talkback-remediation`.
- Worktree nuevo: `D:\Codex\worktrees\GeoGuide-AI\ui2-a01-talkback-remediation`.
- Se verificó la auditoría local `6b8134311186979dd3efcad3c8d43274c9471c04`
  y la propuesta documental `fca0faf4708e65373393e73231ac24691eca47fe`, descendientes
  del baseline. Se consultaron mediante Git en lectura; no se integraron en esta rama.
- El checkout principal permanece en `main` y su HEAD histórico
  `e443c0aa10987e04367dd15a1df259438426c3bc`; no se sincroniza ni se toca su contenido.

Aplican AGENTS, PROJECT_CONTEXT, DOCUMENTATION_INDEX, AI_DEVELOPMENT_GUIDE, Entrega
04.6 y ADR aceptados por su ámbito. Se consultaron el
[contrato UI-2](UI-2-Map-Search-and-POI-Experience-Contract-Proposal.md),
[decisiones U2-D01–D06](UI-2-Decision-Register.md),
[evidencia UI-2.3.1](UI-2.3.1-Physical-Findings-Remediation-Evidence.md),
[cierre UI-2.3.2](UI-2.3.2-Local-Search-and-Accessibility-Corrective-Evidence.md#cierre-documental-2026-10-24)
y [matriz física](UI-2.2-Physical-Validation-Traceability-Matrix.md#seguimiento-vigente-2026-10-24).
No se reabre discovery general ni se alteran contratos o resultados físicos.

## 2. Diagnóstico y límites causales

| Dimensión | Evidencia técnica o física previa | Conclusión permitida |
| --- | --- | --- |
| TEXT_LANGUAGE | El propietario confirmó textos visibles españoles y pronunciación inglesa en lista/detalle. Mapper y fichas conservan originales; fixtures incluyen español e inglés. | No es un defecto demostrado de traducción o sustitución factual. No se debe traducir ni normalizar nombres propios para corregir voz. |
| APP_LOCALE | `GeoGuideApp` usa MaterialApp sin locale/delegates propios; supportedLocales por defecto es en_US, incluso al simular dispositivo es_PE. | Configuración reproducible, pero no prueba que sea la causa de A01. El mismo MaterialApp contiene controles/marcadores reportados en español. |
| SEMANTICS_LOCALE | Los widgets POI no asignan idioma por campo ni atributos de lengua. Los controles superiores y marcadores tampoco lo declaran expresamente. | La ausencia de metadatos es una hipótesis compartida, no una explicación discriminante de la pronunciación diferente. Deben inspeccionarse tanto locale de nodo como atributos del label. |
| TALKBACK_SPEECH_LOCALE | Observación humana histórica: lista/detalle con pronunciación inglesa; controles superiores/marcadores en español; navegación operativa reportada. | No se dispone de reproducción instrumental de voz ni transcripción equivalente por nodo; comprensión completa y causa real siguen no confirmadas. Widget tests no ejecutan TalkBack Android. |

Archivos inspeccionados: [MaterialApp](../../../mobile/lib/app/app.dart),
[tarjeta](../../../mobile/lib/features/discovery/presentation/poi_result_card.dart),
[Preview](../../../mobile/lib/features/discovery/presentation/poi_preview_sheet.dart),
[Detail](../../../mobile/lib/features/discovery/presentation/poi_detail_sheet.dart),
[lista, controles y marcadores](../../../mobile/lib/features/map/presentation/base_map_page.dart),
[modelo POI](../../../mobile/lib/features/discovery/domain/discovery_poi.dart) y
[mapper](../../../mobile/lib/features/discovery/infrastructure/route_discovery_response_mapper.dart).

`DiscoveryPoi` y el mapper no transportan idioma por nombre, descripción, fuente
o atribución. Categorías, acciones y prefijos UI son españoles conocidos; los
campos factuales pueden ser multilingües. Los nombres propios no permiten inferir
de forma fiable el idioma de una descripción. El código no implementa traducción
ni selección propia de voz TalkBack que permita atribuirle la diferencia observada.

El SDK local inspeccionado es Flutter 3.47.2, framework `d3b14c8769`, Dart 3.13.2.
`TextSpan.computeSemanticsInformation` genera `LocaleStringAttribute` cuando el
span tiene un locale efectivo explícito. Esto permite representar idiomas por
segmentos conocidos; no detecta la lengua de campos externos ni demuestra qué voz
se oirá en el HONOR. Véanse las API oficiales de
[TextSpan.locale](https://api.flutter.dev/flutter/painting/TextSpan/locale.html) y
[LocaleStringAttribute](https://api.flutter.dev/flutter/dart-ui/LocaleStringAttribute-class.html).

La comparación automatizada sí distingue **cómo se transporta el texto**: control
superior y marcador exponen `tooltip` con label vacío; «Ver lista» usa label y las
fichas agrupan varios textos en un label, con acciones hijas separadas. En todos
los nodos inspeccionados el locale es null y los atributos del label están vacíos.
No debe confundirse label vacío con control sin etiqueta: el texto está en tooltip.

Se contrastó además el bytecode del `flutter.jar` Android arm64 local con el
[AccessibilityBridge de la revisión del framework](https://github.com/flutter/flutter/blob/d3b14c8769/engine/src/flutter/shell/platform/android/io/flutter/view/AccessibilityBridge.java)
y su [constructor de cadenas accesibles](https://github.com/flutter/flutter/blob/d3b14c8769/engine/src/flutter/shell/platform/android/io/flutter/view/AccessibilityStringBuilder.java).
El puente construye labels con atributos y locale efectivo; tooltip tiene una
ruta Android distinta. Esto sustenta una hipótesis de tratamiento diferente, no
confirma la voz elegida. `getEffectiveLocale` puede recurrir a un default del
puente; su valor durante la sesión física no se conoce. En el SDK local,
`Localizations.build` no marca el locale de aplicación en ese subárbol y contiene
un TODO sobre notificarlo al engine. Por tanto, **no es válido inferir que el
en_US de MaterialApp se haya convertido necesariamente en una voz inglesa**.

## 3. Hipótesis y decisión de implementación

| Hipótesis / alternativa | Evaluación | Disposición |
| --- | --- | --- |
| El contenido fue convertido a inglés. | Texto visible español confirmado y preservación del mapper/fichas cubierta. | No sustentada para el caso reportado; no modificar datos factuales. |
| en_US global basta para explicar la diferencia. | Correlación reproducible, pero no explica por sí sola los controles/marcadores que se oyeron en español. | No confirmada. No cambiar idioma global ni añadir delegates/dependencias. |
| Falta locale explícito en textos POI. | Ausencia reproducible; también afecta nodos que se oyeron correctamente. API permite atributos por segmentos conocidos. | Hipótesis plausible, sin vínculo causal probado con A01. |
| Forzar español en toda ficha o lista. | Aplicaría lengua supuesta a nombres, descripciones y atribuciones sin metadatos; podría perjudicar inglés u otros idiomas legítimos. | Descartada como solución indiscriminada. |
| Añadir locale solo a prefijos/categorías/acciones UI españoles. | Puede representar correctamente esos segmentos, pero no se ha demostrado que remedie pronunciación del contenido factual ni la diferencia entre superficies. | No presentar una mejora teórica parcial como corrección fundada de A01. |
| Configuración/heurística de TalkBack, TTS o tratamiento de nodos Android. | No observable mediante widget tests ni inspección Dart. | Permanece abierta; no cambiar configuración del teléfono ni sustituir motor. |
| Diferencia entre tooltip y label agrupado al construir información Android. | Se confirma la diferencia de campos y rutas del puente; no se reproduce la decisión de voz del servicio. | Hipótesis técnica adicional, no causa física confirmada ni motivo para reemplazar la semántica de todas las fichas por tooltips. |

**Causa raíz: UNCONFIRMED. Remediación: BLOCKED_PENDING_EVIDENCE.** Conforme a §6
del encargo, se detiene la elección de solución especulativa. No se cambia código
de producción, idioma global, S01, selección I01, backend/DTO, caché, GPS, Driving,
CEFI, permisos o contratos. El bloqueo es de investigación causal, no una nueva
afirmación de impedimento físico efectivo ni una dispensa de AC-12.

## 4. Pruebas automatizadas y resultados

Se amplía exclusivamente el
[diagnóstico de idioma existente](../../../mobile/test/features/discovery/ui231_poi_language_test.dart):

- Registra locale y atributos de label de control superior, marcador POI, control
  «Ver lista», nombre en tarjeta, encabezado Preview y descripción Detail.
- Conserva la verificación de texto factual español/inglés, acentos, labels y
  navegación lista → Preview → Detail con locales de plataforma es_PE/en_US.
- Añade prueba de capacidad API con segmentos español/inglés de idiomas conocidos,
  verificando atributos separados y texto original intacto. Es un diagnóstico de
  representación, no una corrección de producción ni simulación de voz.

| Comando / verificación | Resultado comprobado |
| --- | --- |
| `flutter pub get --offline` desde mobile | PASS; restauración local conforme al lockfile, sin cambios de dependencias/versiones. Un primer intento desde la raíz no encontró proyecto Flutter; se corrigió el directorio, sin cambiar configuración. |
| `flutter test --no-pub test/features/discovery/ui231_poi_language_test.dart --reporter expanded` | PASS, 3 pruebas. Incluye mapping multilingüe, atributos por segmentos conocidos y diagnóstico/navegación bajo plataforma es_PE/en_US. |
| `flutter analyze --no-pub` | PASS, sin issues; 98,0 s reportados por la herramienta. |
| `dart format --output=none --set-exit-if-changed test/features/discovery/ui231_poi_language_test.dart` | PASS, sin cambios pendientes de formato. |
| `git diff --check` y revisión de paths | PASS; solo test diagnóstico, este documento e índice. Árbol de producción y lockfile intactos. |

Los logs del diagnóstico y análisis se conservan fuera del repositorio en el
directorio de validación `ui2-a01-talkback-remediation`. Los resultados de esta
tabla prueban el diagnóstico automatizado, **no una remediación de pronunciación**.
No se elevaron estados históricos de la matriz física.

No se repiten suite completa ni build: no existe una corrección candidata de
producción que justificaría APK. La preservación del árbol de producción acredita
ausencia de modificaciones en S01/teclado, mapa/marcadores, Driving y demás fronteras;
no equivale a una nueva validación funcional de todos esos subsistemas.

## 5. Pregunta técnica y protocolo físico mínimo propuesto

**Pregunta pendiente:** en el mismo APK y sin cambiar idioma/voz/ajustes, ¿qué
pronuncia exactamente TalkBack para el mismo nombre español al enfocarlo en el
marcador, tarjeta, Preview y Detail, y se entiende la información necesaria y se
pueden completar sus acciones? ¿La diferencia afecta al texto factual, al prefijo
español o también al nombre de la acción? Registrar frases literales permite
contrastar nodos equivalentes; no atribuye por sí solo la causa a locale.

Solo bajo autorización física posterior, sin ejecutarlo en este encargo:

1. Confirmar presencia del propietario, dispositivo estacionario y estado que debe
   preservarse. Usar el APK ya validado y un POI español del recorrido; no instalar
   un APK nuevo ni modificar ajustes globales como remedio.
2. Registrar texto visible y pronunciación literal del mismo POI en marcador,
   tarjeta, Preview y Detail; distinguir nombre, categoría, distancia y descripción
   cuando exista. Comparar con un control superior. No inventar campos ausentes.
3. Confirmar comprensión de la información necesaria y acceso a cerrar/volver,
   abrir detalle y acciones disponibles, sin activar GPS, Driving o CEFI. Revisar
   que el foco permita completar y abandonar cada superficie.
4. Si hay contenido legítimo en otro idioma, registrar su lengua y lectura sin
   traducirlo ni fabricar datos en el servidor. Si no existe, marcar no observado.
5. Registrar el estado inicial/final del lector y preservar la sesión del usuario.
   Esta propuesta no autoriza activar TalkBack, ADB, capturas o instalación.

No se repiten los 36 casos UI-2.2. Si se confirma un impedimento efectivo de
comprensión o uso, A01 es BLOCKER y debe revisarse una remediación autorizada;
ningún estado documental sustituye esa corrección. Si continúa sin distinguirse
la causa, presentar la evidencia y la siguiente comparación mínima antes de
elegir una solución que marque lenguas por suposición.

## 6. Gobierno, riesgos y reversión

Riesgo residual: menor inteligibilidad o imposibilidad de comprensión para personas
que dependen del lector; alcance no cuantificado. No se declara corrección A01,
PASS físico, WCAG AA global ni accesibilidad integral. La propuesta A01 local sigue
sin aceptación humana; R01 P07 ya aceptado conserva sus límites y no se reabre.
La deuda visual CEFI sigue futura UI-3.

No hay cambio de producción que revertir ni APK candidato generado. Si una futura
corrección introduce pérdida de texto, lengua incorrecta en campos multilingües,
acciones inaccesibles o regresión de foco, debe retirarse esa corrección específica
y reabrir el diagnóstico, preservando trabajo ajeno y sin reset/clean generales.

Decisión humana necesaria: autorizar por separado la comprobación física focalizada
anterior para resolver la incertidumbre técnica; no se solicita aceptar A01 como
alternativa automática a investigar. Seguimiento: `OWNER_PENDING_ASSIGNMENT`.

Validaciones documentales: UTF-8, enlaces/anclas, coherencia de estados,
`git diff --check` y alcance limitado a este informe, índice y test diagnóstico.
Los resultados físicos anteriores y los dos informes locales permanecen íntegros.
Snapshots y hashes de preservación se conservan fuera del repositorio.

```ini
A01_ROOT_CAUSE = UNCONFIRMED
A01_REMEDIATION = BLOCKED_PENDING_EVIDENCE
A01_AUTOMATED_VALIDATION = PASS
A01_PHYSICAL_VALIDATION = NOT_AUTHORIZED
A01_RISK_DISPOSITION = PENDING_HUMAN_DECISION
R01_P07_RISK_DISPOSITION = ACCEPTED_WITH_DOCUMENTED_LIMITATION
UI2_AC_12 = AUTOMATED_PASS_PHYSICAL_PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

STOP_AND_REPORT

## 7. Validación física focalizada — 2026-10-31

Esta sección es el seguimiento posterior autorizado y prevalece para el estado
actual de esta sesión. Las secciones 1–6 y su bloque de estados describen el
diagnóstico del 2026-10-24 y se conservan como historial.

### Autorización, preparación e identidad del artefacto

El propietario autorizó una única sesión manual en HONOR LLY-NX3, Android 16
según el encargo, usando exclusivamente la aplicación ya instalada. Confirmó
presencia junto al teléfono estacionario y TalkBack inicialmente apagado. Ante
la ausencia inicial de ruta, se detuvo la comparación; el propietario autorizó
expresamente preparar Lima–Canta mediante selección manual y cálculo de ruta.
No se instaló, actualizó o sustituyó un APK.

Preparación comunicada por el propietario: «Ruta: 97.7 km - 104 min - 5 lugares»,
«Online». Confirmó Plaza de Armas de Canta disponible en marcador, tarjeta,
Preview y Detail antes de activar el lector. Esa navegación preparatoria no
equivale a validar comprensión ni acciones con TalkBack.

Worktree limpio al inicio en `ebb2367cce1835189b85fa0e0156dc21958fd194`;
`origin/main` y remoto verificados en `a17734f665d72b99e1f901c6634f8dcdc4b31288`.
El diagnóstico de octubre 24 solo añadió test/documentación y no alteró el árbol
de producción respecto del correctivo `3b4ee6f985edd5f7f7af7621a98be6d7ccce9358`.
La evidencia integrada anterior identifica el APK debug `1.0.0 / versionCode 1`,
package `com.geoguideai.geoguide_ai`, SHA-256
`32F2D62A4B7E6A007E92CB89F2DB6990F8D9E4E2AE6E0983BAEA045E1FDB70B5`.
Son datos históricos del artefacto verificado en la tercera sesión: **no se ha
verificado de nuevo hash, versión ni identidad binaria del APK actualmente
instalado**. En esta sesión el propietario confirmó que la aplicación existente
abre y calcula la ruta. No se usó ADB para identificarla ni extraer datos.

### Observaciones y detención de la comparación

Fuente: **OWNER_OBSERVED**, observación directa del propietario comunicada por
texto; Codex no escuchó el audio ni capturó pantalla, audio o video. Las
transcripciones siguientes son aproximadas según el propietario, no grabaciones.
POI constante: **Plaza de Armas de Canta**.

| Caso / superficie | Texto visible o etiqueta esperada | Pronunciación comunicada | Idioma/acento percibido | Comprensión | Acción accesible | Resultado y límite |
| --- | --- | --- | --- | --- | --- | --- |
| A01-P01 — Marcador | Etiqueta esperada «Vista previa de Plaza de Armas de Canta». | «Vista previa de Plaza de Armas de canta - botón - tocar dos veces para activar». | Español neutro, según propietario. | El propietario transcribió el nombre; no reportó dificultad en el marcador. | PASS: el marcador abrió Preview. | Completado para el alcance observado, sin atribuir causa técnica. |
| A01-P02 — Tarjeta de lista | Nombre/categoría/distancia no transcritos durante este caso. | UNDETERMINED; no hay comparación de tarjeta registrada. | Indeterminado. | NOT_OBSERVED. | NOT_OBSERVED. | NOT_OBSERVED: al restaurar, el propietario indicó que solo pulsó adicionalmente «Ver lista»; no precisó el momento ni informó lectura/activación de una tarjeta. No se considera el caso completado. |
| A01-P03 — Preview, contenido | Ficha del mismo POI; nombre/categoría/datos individuales no transcritos con lector. | El propietario indicó «todo el audio fue en ingles»; sin frases del contenido suficientes para transcribir segmentos. | Inglés según propietario; no equivale a texto visible inglés. | No se midió comprensión de cada campo. | Apertura observada desde marcador; acciones posteriores según filas siguientes. | PARTIAL: observación incidental al abrir Preview desde P01; no recorrido completo. |
| A01-P03 — Preview, Cerrar | «Cerrar», identificado por el propietario. | Aproximadamente «cierrar», con r arrastrada. | Español percibido como extraño. | No se declaró incomprensible este botón. | NOT_OBSERVED: no consta activación de Cerrar durante el caso. | Pronunciación anómala reportada; no inferir fallo de activación. |
| A01-P03 — Preview, Ver detalle | «Ver detalle», identificado por el propietario. | Aproximadamente «view dedo»; el propietario afirma «no se entiende». | Pronunciación anómala, percibida dentro del audio inglés de Preview; idioma exacto de la frase UNDETERMINED. | **No comprensible para una acción esencial, confirmado por el propietario.** | NOT_OBSERVED: no se continuó su activación; el impedimento demostrado es de comprensión. | **BLOCKER** por el caso D del protocolo; detención inmediata. |
| A01-P04 — Detail | Disponible en la preparación sin lector; no recorrido en esta comparación. | UNDETERMINED. | Indeterminado. | NOT_OBSERVED. | NOT_OBSERVED. | NOT_EXECUTED tras la detención; no extrapolar desde Preview. |
| A01-P05 — Control superior | No se enfocó en esta comparación. | UNDETERMINED. | Indeterminado. | NOT_OBSERVED. | NOT_OBSERVED. | NOT_EXECUTED; el marcador P01 no sustituye el control superior P05. |
| A01-P06 — Restauración | Estado inicial de TalkBack: apagado. | Propietario: «Talkback desactivado», «no se reproduce ningún audio». | N/A. | N/A. | PASS según confirmación del propietario. | TalkBack apagado, Rutea utilizable y ruta conservada; restauración completada. |

Al regresar inicialmente a Rutea, el propietario también escuchó inglés y luego
español; no se identificó la frase o el nodo correspondiente. Se conserva como
observación contextual, sin usarla para atribuir causalidad global.

Se detuvo la comparación al recibirse «no se entiende» para «Ver detalle». No se
pidió repetir la lectura ni completar otros casos antes de restaurar el lector.
**La clasificación de A01 pasa a BLOCKER por impedimento efectivo de comprensión;
no se propone dispensa ni aceptación limitada de ese impedimento.** No se afirma
que el botón no sea activable: esa acción no fue observada.

### Restauración final confirmada

El propietario confirmó: «Talkback desactivado, Rutea se puede usar sin problemas
y no se reproduce ningún audio, se conserva la ruta, y no se presiono ningún boton
adicional solo \"Ver lista\"». La restauración al estado inicial apagado es
OWNER_CONFIRMED; no se inspeccionaron estados internos del teléfono. La mención de
«Ver lista» se registra sin atribuirle pronunciación, lectura de tarjetas o momento
de ejecución no comunicados. No se solicitó ninguna interacción física adicional
tras esta confirmación ni se reportó activación de GPS, Driving o CEFI.

### Análisis posterior y nivel de confianza

| Hipótesis / conclusión | Evidencia nueva | Nivel de confianza y límite |
| --- | --- | --- |
| Existe una diferencia por superficie para el mismo POI. | Marcador en español neutro y Preview con pronunciación anómala según propietario. | Sustentada por observación humana en esta sesión; no se reprodujeron las cuatro superficies completas. |
| Hay un impedimento efectivo de comprensión de una acción esencial. | «Ver detalle» se oyó aproximadamente «view dedo» y el propietario afirmó «no se entiende». | Confirmado por reporte directo; justifica BLOCKER. No implica que el callback o la activación táctil estén rotos. |
| El texto factual se convirtió a inglés. | El nombre del marcador se reconoció; el propietario identifica los textos de los botones como españoles y describe pronunciación, no traducción visible. | No sustentada para los segmentos reportados. No se transcribieron todos los campos de contenido; no generalizar a cada dato. |
| Todo se explica por una voz incorrecta uniforme en la aplicación. | El mismo marcador se oyó correctamente en español. | Debilitada como explicación uniforme; no descarta reglas del servicio dependientes del nodo. |
| Diferencia entre tooltip y labels agrupados o falta de atributos de idioma. | La distribución observada es compatible con las rutas semánticas inspeccionadas en octubre 24. | Hipótesis reforzada por correlación entre superficies, no prueba causal. No se modificaron metadatos ni se hizo comparación A/B. |
| MaterialApp en_US, fallback Android o configuración TalkBack/TTS son la causa raíz. | No se observaron valores efectivos del servicio ni se cambió configuración. | UNCONFIRMED. No atribuir causalidad por el locale de widget ni inferir la voz instalada. |

La causa técnica sigue UNCONFIRMED; el impacto ya no es solo un riesgo de
comprensión no cuantificado. El impedimento confirmado impide recomendar cierre
maestro o dispensa documental. Se conserva `UI2_AC_12 =
AUTOMATED_PASS_PHYSICAL_PARTIAL` para distinguir modalidades e historial, sin
convertirlo en cumplimiento físico ni ocultar el BLOCKER actual. La propuesta de
aceptación A01 del commit local `fca0faf4708e65373393e73231ac24691eca47fe` nunca fue
aprobada y no es una vía de dispensa para este impedimento. No se reescriben aquel
documento, la auditoría anterior ni los estados históricos de la matriz física.

### Corrección mínima recomendada y alcance técnico propuesto

Presentar para **autorización separada** una corrección candidata focalizada de
idioma semántico en etiquetas y acciones UI cuyo español es conocido —en primer
lugar «Ver detalle» y «Cerrar» de Preview—, evaluando atributos por segmento o nodo
con las API existentes. El vínculo causal aún no está demostrado: es una propuesta
de experimento correctivo acotado, no una solución garantizada. No se reemplazará
la semántica de todas las fichas por tooltips solo por esta correlación.

| Elemento del encargo técnico futuro | Propuesta para revisión humana |
| --- | --- |
| Problema y objetivo | El usuario debe comprender y activar las acciones esenciales de Preview mediante TalkBack, conservando el marcador correcto y la navegación a Detail/retorno. |
| Alcance mínimo candidato | Metadatos de idioma de etiquetas UI españolas conocidas en Preview; revisar su propagación/agrupación antes de elegir implementación. Si la evidencia exige tocar otras superficies, explicitarlo en el contrato posterior. |
| Fronteras intactas | Sin idioma global impuesto, traducción de hechos, detección heurística de lengua, dependencias nuevas, TTS propio, permisos, backend/DTO, GPS, Driving, CEFI, S01 o selección I01. |
| Contenido multilingüe | Preservar nombres, descripción, fuente y atribución originales. No asignarles español por estar dentro de una ficha española; no hay metadatos de lengua por campo. |
| Validación automatizada futura | Idioma semántico de los segmentos conocidos, texto factual multilingüe intacto, labels/acciones/foco y retorno; regresiones proporcionales de lista/mapa y S01 si el cambio los afecta. No equivale a pronunciación física PASS. |
| Validación física futura | Bajo autorización propia, verificar que «Ver detalle» resulte comprensible y activable, que Cerrar/retorno funcionen y el marcador/control superior conserven su pronunciación correcta. Observar tarjeta y Detail con el mismo POI antes de concluir sobre ellos. |
| Criterio de aceptación | No declarar A01 resuelto por corregir solo un botón: demostrar comprensión y acciones en el alcance afectado, preservar contenido multilingüe y registrar explícitamente cualquier superficie o campo pendiente. |
| Reversión | Retirar únicamente la corrección candidata si causa lengua errónea en contenido legítimo, pérdida de labels, acciones o foco; conservar evidencia y trabajo ajeno. No usar reset/clean generales. |

No se implementó esta propuesta, no se generó APK y no se ejecutaron nuevas
pruebas automatizadas/funcionales, ADB, instalaciones, capturas o grabaciones.
Los únicos cambios de este encargo son el seguimiento en este documento y su
referencia en DOCUMENTATION_INDEX. R01/P07 conserva la aceptación limitada y la
deuda visual CEFI permanece futura UI-3, sin autorización de ejecución.

Riesgo residual confirmado: dificultad efectiva para entender el nombre de una
acción esencial de Preview; alcance del contenido, tarjeta y Detail no completado.
Responsable: `OWNER_PENDING_ASSIGNMENT`. La decisión humana necesaria es autorizar
un encargo técnico focalizado y sus validaciones posteriores, no aceptar el
impedimento como limitación ni repetir la sesión actual.

Validación de este seguimiento: enlaces locales/anclas, UTF-8, coherencia de
estados, `git diff --check` y alcance exclusivamente documental. Snapshots de los
worktrees y hashes de registros privados permiten verificar preservación; los
resultados de las pruebas de octubre 24 siguen siendo históricos.

```ini
A01_PHYSICAL_DIAGNOSTIC = BLOCKED
A01_FINDING_CLASSIFICATION = BLOCKER
A01_ROOT_CAUSE = UNCONFIRMED
A01_REMEDIATION = BLOCKED_PENDING_EVIDENCE
A01_PHYSICAL_REMEDIATION_VALIDATION = NOT_EXECUTED
A01_RISK_DISPOSITION = PENDING_HUMAN_DECISION
A01_DEVICE_RESTORATION = OWNER_CONFIRMED
UI2_AC_12 = AUTOMATED_PASS_PHYSICAL_PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

STOP_AND_REPORT

## 8. Implementación correctiva candidata — 2026-10-31

Seguimiento autorizado por «UI-2 A01 TALKBACK CORRECTIVE CANDIDATE». Esta sección
describe la corrección posterior al diagnóstico físico; las secciones 1–7 y sus
resultados se conservan íntegros. Implementar una candidata no subsana por sí solo
el BLOCKER de comprensión ni confirma su causa raíz.

### Baseline, hipótesis y cambio mínimo

Se verificaron rama `codex/ui2-a01-talkback-remediation`, worktree limpio y HEAD
`497eac27100438f6c0df592546cdce6cee51c436`. El commit de sesión física está presente
y desciende de `a17734f665d72b99e1f901c6634f8dcdc4b31288`; tras fetch y consulta
remota, `origin/main` y main remoto coinciden en ese baseline. No se sincronizó
el checkout principal ni se incorporaron trabajos ajenos.

La hipótesis abordada es que declarar explícitamente el idioma de acciones UI
españolas conocidas ofrece al puente accesible una representación correcta y
verificable. No se afirma que el locale del widget prediga la voz real. Se usa
la API existente `Semantics.localeForSubtree` de Flutter 3.47.2 únicamente sobre
el Row que contiene «Cerrar» y «Ver detalle». No se requieren helper, traducción,
atributos inferidos por nombre, dependencia nueva ni cambio de MaterialApp.

Producción: [poi_preview_sheet.dart](../../../mobile/lib/features/discovery/presentation/poi_preview_sheet.dart).
El wrapper no añade label, tooltip, rol o callback: los botones conservan sus
labels originales, rol y acciones. Los datos factuales y el control de selección
I01 son hermanos anteriores al subárbol localizado, no descendientes suyos.

| Nodo / propiedad efectiva | Antes | Después comprobado automáticamente |
| --- | --- | --- |
| Botón Cerrar | Label «Cerrar», locale null, atributos de label vacíos. | Mismo label único, locale es_PE, atributos de label vacíos; rol botón y tap conservados. |
| Botón Ver detalle | Label «Ver detalle», locale null, atributos de label vacíos. | Mismo label único, locale es_PE, atributos de label vacíos; tap conservado cuando está habilitado, ausente cuando no hay callback. |
| Orden de acciones | Cerrar seguido de Ver detalle. | Mismo orden semántico y avance de foco de teclado de Cerrar a Ver detalle. |
| Encabezado con nombre, nombre y campos externos | Texto original sin idioma explícito impuesto. | Sin nuevo locale español ni atributos españoles en nombres propios, descripción, fuente, URL o atribución. |
| Control de elección y marcador | Semántica existente. | El control I01 no hereda el locale; tooltip/locale/label del marcador no cambian al abrir, navegar y cerrar. |

La señal nueva es **locale del nodo efectivo**, no LocaleStringAttribute en su
label. Las pruebas inspeccionan `getSemanticsData().locale` sobre los botones
renderizados, no solo el valor del constructor del wrapper. La propagación
observada en el framework y el consumo de locale por el puente Android son una
base técnica para la candidata; la respuesta audible de TalkBack sigue pendiente.

SHA-256 del único archivo de producción modificado:
`2358D94E21EB51ED1316348F8F3A14FB51CC400A28F81AEE2891F369FC5FA103`.
No cambia backend/API/DTO, datos, S01, selección I01, caché, GPS, Driving, CEFI,
permisos, idioma global, TTS, pubspec.yaml, pubspec.lock ni contratos congelados.

### Pruebas, regresiones y validación

Test nuevo: [a01_preview_actions_test.dart](../../../mobile/test/features/discovery/presentation/a01_preview_actions_test.dart).
Son cinco pruebas que cubren los criterios A01-T01–T06 con apoyo de regresiones
existentes, sin simular audio ni atribuir resultados físicos a Flutter tests.

| Criterio | Comprobación |
| --- | --- |
| A01-T01 | Locale es_PE presente en nodos efectivos de ambos botones; idiomas ajenos no reciben override español. |
| A01-T02 | Texto visible y label exactos, una sola aparición semántica de cada acción. |
| A01-T03 | Rol botón y acción tap; activación por SemanticsOwner y callback real; botón sin callback conserva estado sin tap. |
| A01-T04 | Orden semántico, foco de teclado, abrir Detail mediante acción semántica y retorno real en GeoGuideApp; cierre de Preview por acción semántica. |
| A01-T05 | Nombres propios/acentos, descripción, fuente/URL y atribución españoles/ingleses intactos en tarjeta/Preview/Detail según campos disponibles; sin locale o atributos españoles añadidos a hechos. |
| A01-T06 | Marcador conserva metadatos y source no recibe llamadas por navegar; regresiones proporcionales existentes cubren lista, I01, filtro local, teclado y Driving. |

| Validación ejecutada | Resultado |
| --- | --- |
| `flutter test --no-pub` sobre a01_preview_actions, poi_preview_sheet, poi_detail_sheet y ui231_poi_language | PASS, 15 pruebas en 7 s reportados. |
| `dart format --output=none --set-exit-if-changed` sobre los dos Dart modificados | PASS, sin cambios pendientes. |
| `flutter analyze --no-pub` | PASS, sin issues, 49,5 s reportados. |
| `flutter test --no-pub` sobre ui2_experience, i01_widget y poi_visual_contract | PASS, 23 regresiones en 15 s reportados; incluye lista, teclado/insets, callbacks/Driving, marcador y selección. |
| `flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` | PASS, Gradle 359,9 s reportados. Misma configuración de backend documentada; sin instalaciones ni acceso al servicio/dispositivo para probarla. |
| Inspección del APK con aapt, apksigner y ZIP | PASS: identidad/versiones, firma válida, MaterialIcons con cabecera OpenType válida y FontManifest/AssetManifest presentes. |

Un primer pase detectó cuatro fallos por
liberación tardía de SemanticsHandle en los tests nuevos; se corrigió su lifecycle
antes de la verificación final de cada prueba. No fue un fallo de producción y el
log inicial se conserva separado del pase final.

### Artefacto debug candidato

| Dato | Valor verificado |
| --- | --- |
| Ruta local, artefacto ignorado por Git | `D:\Codex\worktrees\GeoGuide-AI\ui2-a01-talkback-remediation\mobile\build\app\outputs\flutter-apk\app-debug.apk` |
| Variante / package | Debug / `com.geoguideai.geoguide_ai` |
| Versión | `1.0.0 / versionCode 1` |
| Tamaño en bytes | `167843221` |
| SHA-256 del APK | `0045313E8F8C8EDC023DCC252B49C6119053FA5B5C4CC1BCDF5F60CCD6ECF673` |
| SHA-256 del certificado verificado | `894975B5BC6751DA09B3D69923D4AE399192470D86C107106F65F6CB8D7EAB7E` |

No se instala ni se afirma que este APK esté en el HONOR. Firma válida no equivale
a haber comparado su certificado con el paquete actualmente instalado: esa
compatibilidad se verificará solo bajo autorización posterior. El build emitió
advertencias de acceso nativo Java, XML de SDK y source/target 8 de componentes;
finalizó correctamente y no se modificó el toolchain para silenciarlas.
Logs y manifest de identidad del artefacto se conservan fuera del repositorio en
el directorio de validación `ui2-a01-corrective-candidate-2026-10-31`.

### Riesgos, reversión y protocolo físico posterior

Se mantiene A01 como BLOCKER y su causa UNCONFIRMED. Esta candidata solo modifica
las dos acciones conocidas de Preview; no pretende corregir la pronunciación de
todos los campos de la ficha, tarjeta o Detail. La selección de voz por el servicio
y la comprensión real requieren evidencia correctiva física nueva.

Reversión focalizada: retirar únicamente el wrapper Semantics del Row de acciones
si introduce labels duplicados, cambios de foco/activación, idioma español en hechos
o regresión de navegación. No usar operaciones generales de reset/clean ni tocar
trabajos ajenos. Conservar los resultados de la sesión diagnóstica y las pruebas.

Protocolo recomendado, **no ejecutado** y sujeto a autorización física separada:

1. Confirmar presencia y teléfono estacionario, sesiones a preservar y estado
   inicial de TalkBack; verificar identidad/firma del APK candidato bajo permiso
   específico antes de una eventual instalación conservando datos.
2. Si se autoriza expresamente, actualizar mediante `adb install -r` el artefacto
   identificado por su SHA-256. La presente autorización no permite ejecutar ADB,
   conectar con HONOR ni instalar; este paso es solo una propuesta futura.
3. Usar el mismo POI español en ruta preparada manualmente; comparar marcador
   previamente correcto y Preview. Registrar texto visible, palabras oídas,
   comprensión de «Cerrar» y «Ver detalle» y activación de ambas acciones.
4. Verificar navegación a Detail y retorno, orden de foco, ausencia de anuncios
   duplicados y conservación de la pronunciación del marcador/control superior.
5. Observar tarjeta y Detail separadamente, sin extrapolar una mejora de los dos
   botones a superficies o contenido no corregidos. Verificar contenido legítimo
   multilingüe si está disponible; no fabricar datos y marcar lo no observado.
6. Ante impedimento de comprensión o uso, detener y conservar BLOCKER; restaurar
   TalkBack a su estado inicial y confirmar usabilidad/ruta. No cambiar idioma,
   voz, motor, velocidad, permisos, GPS, Driving ni CEFI para forzar un PASS.

Decisión humana pendiente: autorizar por separado la verificación del artefacto,
actualización conservando datos y sesión física focalizada en HONOR. No se pide
aprobar la aceptación de A01 ni el cierre UI-2. R01/P07 no cambia y la deuda visual
CEFI permanece futura UI-3. Seguimiento: OWNER_PENDING_ASSIGNMENT.

### Validación documental y estado vigente

Se verifican UTF-8, enlaces locales/anclas, estados, `git diff --check`, conservación
literal del historial previo y diff limitado al único archivo de producción,
test nuevo, este documento e índice. Snapshots y hashes externos comprueban que
el checkout principal, borradores UI-0, worktrees concurrentes, tres stashes y
registros privados se conservan. No hay push, PR, merge ni despliegue.

El PASS correctivo siguiente se refiere a representación semántica, comportamiento
automatizado y generación del artefacto; es distinto del PASS diagnóstico de la
sección 4. El hallazgo permanece BLOCKER hasta una validación física correctiva
satisfactoria y su decisión correspondiente; no se declara A01 resuelto.

```ini
A01_FINDING_CLASSIFICATION = BLOCKER
A01_ROOT_CAUSE = UNCONFIRMED
A01_REMEDIATION = IMPLEMENTED_PENDING_PHYSICAL
A01_AUTOMATED_CORRECTIVE_VALIDATION = PASS
A01_PHYSICAL_REMEDIATION_VALIDATION = NOT_EXECUTED
A01_RISK_DISPOSITION = PENDING_HUMAN_DECISION
R01_P07_RISK_DISPOSITION = ACCEPTED_WITH_DOCUMENTED_LIMITATION
UI2_AC_12 = AUTOMATED_PASS_PHYSICAL_PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

STOP_AND_REPORT

## 9. Validación física correctiva — gates previos, 2026-10-31

Encargo «PHYSICAL CORRECTIVE VALIDATION — HONOR LLY-NX3», con instalación
condicionada a identidad, firma compatible y preservación de datos. Este seguimiento
se detiene en GATE A; no se inicia la validación TalkBack ni se instala el APK.
Las secciones anteriores se conservan como historial. La candidata sigue pendiente
de validación física; un bloqueo de conexión no demuestra un fallo de la corrección.

### Baseline y artefacto autorizado

Rama `codex/ui2-a01-talkback-remediation`, worktree limpio al inicio en
`c781cdf01ce3d5f651306b9a5a9b88734433e1f4`. Se verificaron presencia y ascendencia
del commit candidato y `origin/main`/main remoto en
`a17734f665d72b99e1f901c6634f8dcdc4b31288`, sin sincronizar el checkout principal.

**CODEX_VERIFIED, lectura local:** el APK existe y coincide exactamente con el
autorizado, sin reconstrucción o sustitución:

| Dato | Resultado comprobado |
| --- | --- |
| Ruta | `D:\Codex\worktrees\GeoGuide-AI\ui2-a01-talkback-remediation\mobile\build\app\outputs\flutter-apk\app-debug.apk` |
| Package / versión | `com.geoguideai.geoguide_ai`, `1.0.0 / versionCode 1` |
| Tamaño en bytes | `167843221` |
| SHA-256 APK | `0045313E8F8C8EDC023DCC252B49C6119053FA5B5C4CC1BCDF5F60CCD6ECF673` |
| SHA-256 certificado candidato, firma válida | `894975B5BC6751DA09B3D69923D4AE399192470D86C107106F65F6CB8D7EAB7E` |

Estos datos identifican el **candidato local**, no el paquete instalado. No se
obtuvo certificado, versión o hash de la aplicación instalada en este intento.

### GATE A–E y condición de detención

| Gate | Resultado | Evidencia y límite |
| --- | --- | --- |
| A — Identidad del dispositivo | BLOCKED | Se ejecutó inicialmente `adb devices -l`. El gate contabilizó una entrada, pero no acreditó un único objetivo autorizado en estado `device`. El registro conserva contador y resultado, no el estado literal ni el serial; no se atribuye específicamente a unauthorized, offline u otra causa. No se consultaron modelo ni versión por getprop, ni se identificó inequívocamente el objetivo como HONOR. |
| B — Paquete instalado | NOT_EXECUTED | El helper se detuvo antes de las consultas de Package Manager. No se verificó identidad ni versión instalada. |
| C — Firma compatible / actualización sin borrado | NOT_EXECUTED | La firma válida del candidato no acredita compatibilidad con el instalado. `SIGNATURE_COMPATIBLE = NOT_VERIFIED`; no se intentó dry-run ni instalación como prueba de compatibilidad. |
| D — Instalación | NOT_EXECUTED | No se ejecutó `adb install -r` ni cualquier otra modalidad de instalación. No hay resultado Success ni identidad postinstalación. |
| E — Preparación física | PARTIAL_OWNER_REPORTED | El propietario confirmó teléfono detenido, TalkBack desactivado y ruta Lima–Canta activa. No se completaron las restantes comprobaciones de preparación ni se activó el lector. |

Se aplicó la detención del §4 del encargo antes de consultar el paquete, instalar
o modificar el teléfono. No se reintentó la conexión ni se consultaron otros
dispositivos. No se utilizó ADB para extraer APK instalado, datos privados o
configuración. El serial no se publicó ni se persistió.

**OWNER_OBSERVED:** el propietario informó «Si estoy detenido, el Talkback esta
desactivado, y si la ruta Lima Canta esta activa» y consultó si debía cerrarse la
sesión para instalar la candidata. No confirmó expresamente el resto de ajustes
de voz/idioma o la ausencia de sesiones GPS; no se infieren de «ruta activa».

Se aclaró que la sesión existente todavía no usa la candidata: para probarla
debe actualizarse el APK tras superar los gates. La instalación `-r` conserva
datos de aplicación, pero puede reiniciar el proceso; no garantiza conservar una
ruta o estado temporal en memoria. Se indicó no cerrar ni modificar Rutea mientras
la conexión y firma siguieran sin verificar. No se pidió recrear la ruta.

### A01-V01–V07 y estado del dispositivo

| Caso | Resultado | Pronunciación, comprensión y activación |
| --- | --- | --- |
| A01-V01 — Marcador | NOT_OBSERVED | No ejecutado en este intento; sin nueva transcripción. |
| A01-V02 — Cerrar | NOT_OBSERVED | No ejecutado; no extrapolar el PASS automatizado. |
| A01-V03 — Ver detalle | NOT_OBSERVED | No ejecutado; no atribuir mejora ni repetición del fallo previo. |
| A01-V04 — Detail y retorno | NOT_OBSERVED | No ejecutado; no hubo navegación física guiada. |
| A01-V05 — Tarjeta | NOT_OBSERVED | No ejecutado; continúa sin validación correctiva. |
| A01-V06 — Control superior | NOT_OBSERVED | No ejecutado; no se activaron sus funciones. |
| A01-V07 — Restauración | NOT_OBSERVED | La prueba no activó TalkBack ni cambió ajustes; no fue necesaria una operación de restauración. El propietario lo reportó apagado durante la preparación, sin nueva comprobación final del dispositivo. |

No se instaló un APK nuevo ni se comprobó preservación postinstalación de ruta
o datos. La ruta disponible es una observación del propietario previa a cualquier
actualización, no evidencia de preservación por `-r`. Codex no capturó imagen,
audio/video, no accedió a otras aplicaciones y no ejecutó GPS, Driving o CEFI.

### Riesgos, seguimiento y siguiente paso

La incertidumbre técnica es la conexión ADB no acreditada; la identidad y firma
instaladas permanecen desconocidas. Se conserva A01 como BLOCKER por la evidencia
física anterior, sin aceptar riesgos ni declarar fallo de la candidata no probada.
R01/P07, AC-12, cierre maestro y Production Readiness conservan sus estados.

Para retomar, el propietario deberá revisar conexión USB de datos y autorización
de depuración, y avisar cuando el HONOR esté listo. La autorización de instalación
ya existe en el encargo, pero no puede ejercerse hasta que A–C sean PASS. No se
solicita una dispensa de firma ni usar flags de downgrade o borrado. Si la ruta no
está tras la futura actualización, se registrará y se pedirá confirmación antes
de recrearla manualmente, conforme al gate E. Seguimiento: OWNER_PENDING_ASSIGNMENT.

Solo cambian esta sección y el índice. Se validan UTF-8, enlaces/anclas, estados,
historial conservado y `git diff --check`; snapshots/hashes externos verifican
preservación de worktrees, stashes, borradores UI-0 y registros privados. No hay
builds, tests funcionales nuevos, cambios de producción, push, PR o merge.

```ini
A01_TECHNICAL_GATE_A = BLOCKED
A01_TECHNICAL_GATE_B = NOT_EXECUTED
A01_TECHNICAL_GATE_C = NOT_EXECUTED
A01_TECHNICAL_GATE_D = NOT_EXECUTED
SIGNATURE_COMPATIBLE = NOT_VERIFIED
A01_INSTALLATION = NOT_EXECUTED
A01_REMEDIATION = IMPLEMENTED_PENDING_PHYSICAL
A01_AUTOMATED_CORRECTIVE_VALIDATION = PASS
A01_PHYSICAL_REMEDIATION_VALIDATION = NOT_EXECUTED
A01_FINDING_CLASSIFICATION = BLOCKER
A01_ROOT_CAUSE = UNCONFIRMED
A01_RISK_DISPOSITION = PENDING_HUMAN_DECISION
R01_P07_RISK_DISPOSITION = ACCEPTED_WITH_DOCUMENTED_LIMITATION
UI2_AC_12 = AUTOMATED_PASS_PHYSICAL_PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

STOP_AND_REPORT

## 10. Reanudación de la validación física correctiva — 2026-11-01

Seguimiento del encargo físico con hard gates, reanudado por autorización expresa
del propietario tras reconectar HONOR. La sección 9 conserva el intento bloqueado
de octubre 31; los resultados siguientes corresponden únicamente a esta reanudación.

### Verificación técnica y actualización autorizada

Worktree `ui2-a01-talkback-remediation` limpio al inicio en
`0c2326115b501c3593bcfbb98d2e002a1f666cba`; contiene el commit candidato
`c781cdf01ce3d5f651306b9a5a9b88734433e1f4`. Se usó exclusivamente el APK original,
sin builds, cambios de producción ni sustitución del archivo autorizado.

ADB se invocó por la ruta absoluta
`C:\Users\CC_Laptop\AppData\Local\Android\Sdk\platform-tools\adb.exe`.
Las operaciones sobre el objetivo utilizaron `-s <HONOR_TARGET>` con el serial
obtenido al identificar el único dispositivo autorizado; no se publica ni se
guarda ese identificador. La evidencia técnica se conserva sanitizada fuera del
repositorio en `ui2-a01-physical-corrective-validation-2026-11-01`.

| Gate | Resultado técnico comprobado | Evidencia y límite |
| --- | --- | --- |
| A — Dispositivo | PASS | `adb devices -l`: una entrada en estado device; getprop confirmó fabricante HONOR, modelo LLY-NX3 y Android 16. No se utilizó otro dispositivo. |
| B — Identidad instalada previa | PASS | Dumpsys limitado a `com.geoguideai.geoguide_ai`: versionName 1.0.0, versionCode 1. Estos valores solos no se usaron para acreditar firma. |
| C — Firma / actualización | PASS | Firma del candidato validada y certificado del binario instalado verificado directamente; un único certificado SHA-256 coincidente. Mismo package, versión sin downgrade y sin necesidad de desinstalar o borrar datos. |
| D — Instalación e identidad posterior | PASS técnico | Se ejecutó únicamente `adb -s <HONOR_TARGET> install -r "D:\Codex\worktrees\GeoGuide-AI\ui2-a01-talkback-remediation\mobile\build\app\outputs\flutter-apk\app-debug.apk"`. Resultado «Performing Streamed Install / Success»; package 1.0.0 (1) posterior y hash del base.apk instalado idéntico al autorizado. El propietario confirmó apertura posterior; la ruta previa no se conservó visible y fue recreada con autorización. No se declara preservación integral de datos. |

La consulta `cmd package get-app-links` no devolvió certificado para este paquete;
no se tomó como prueba negativa de existencia ni como compatibilidad. Para verificar
el certificado directamente, `pm path` identificó exclusivamente su `base.apk` bajo
`/data/app/`; se leyó una copia temporal de ese **binario de aplicación**, se verificó
con `apksigner verify --print-certs` y se retiró la copia local temporal después.
No se extrajeron datos de usuario, bases, preferencias, cachés, tokens ni archivos
personales. No se usó una instalación de prueba ni dry-run como sustituto de firma.
La comprobación criptográfica usa el mecanismo de
[verificación de apksigner](https://developer.android.com/tools/apksigner).

| Identidad criptográfica | Valor comprobado |
| --- | --- |
| APK instalado previo, SHA-256 | `32F2D62A4B7E6A007E92CB89F2DB6990F8D9E4E2AE6E0983BAEA045E1FDB70B5` |
| Certificado instalado previo y candidato, SHA-256 | `894975B5BC6751DA09B3D69923D4AE399192470D86C107106F65F6CB8D7EAB7E` |
| Candidato y APK instalado posterior, SHA-256 | `0045313E8F8C8EDC023DCC252B49C6119053FA5B5C4CC1BCDF5F60CCD6ECF673` |
| Candidato local | Package `com.geoguideai.geoguide_ai`, 1.0.0 (1), 167843221 bytes. |

El hash posterior se comprobó leyendo únicamente `sha256sum` sobre la ubicación
de código informada por Package Manager. No se ejecutó modificación de configuración
global, idioma, voz o permisos, ni borrado o edición directa de datos de usuario.
Esto no sustituye la comprobación funcional posterior. No se inició Rutea por ADB ni se activó
TalkBack automáticamente: apertura y observaciones requieren al propietario.

### Preparación y observaciones físicas

**OWNER_OBSERVED, gate E:** el propietario confirmó presencia junto al teléfono
estacionario y apertura de Rutea. La ruta Lima–Canta **no se visualiza** tras la
actualización. Transcribió: «Sin copia offline disponible», «Ubicación no solicitada»,
«No disponible», botón «Reintentar» y «No encontramos lugares de estas categorías
para esta ruta». Se conserva el reporte sin atribuirlo a backend, conectividad,
borrado de caché o un defecto nuevo sin evidencia.

No se declara preservación de la ruta ni de todos los datos por el Success de ADB.
La ausencia de ruta visible tampoco demuestra por sí sola eliminación de datos
persistentes; la actualización puede reiniciar estado temporal. No se comprobó
la existencia anterior de una copia offline consentida en esta reanudación.

El propietario confirmó TalkBack **apagado**, ausencia de cambios de ajustes y
ninguna sesión GPS/voz que deba preservarse. Se solicitó la confirmación expresa
prevista en el gate E; el propietario respondió «Sí, recrear manualmente Lima–Canta».
Posteriormente confirmó selección manual de origen/destino y cálculo, con resumen
«Ruta 97.7 km - 104 min - 5 lugares», «Online», Plaza de Armas de Canta visible en
mapa/lista y ausencia de errores en esos pasos. La disponibilidad actual corresponde
a una ruta **recreada manualmente**, no preservada automáticamente por la actualización.
Gate E queda completado para iniciar la comparación con el mismo POI y lector
inicialmente apagado.

Se indicó al propietario activar TalkBack manualmente, sin cambiar ajustes de voz
ni otras funciones. **OWNER_OBSERVED, A01-V01:** al volver desde Configuración oyó
la descripción de aplicación en inglés y luego botones en español; no transcribió
frases literales de ese contexto. El marcador de Plaza de Armas de Canta se oyó
en español latino comprensible y abrió Preview. Dentro de Preview reportó audio
de contenido en inglés y las etiquetas «Cerrar»/«Ver detalle» en español latino
sin problemas. La comprensión de todo el contenido no queda demostrada por la
lectura correcta de esos botones.

**OWNER_OBSERVED, A01-V02:** activó Cerrar, la ficha se cerró, volvió al mapa,
conservó la ruta y no observó bloqueo de foco. Reportó audio de descripción de
ventana en inglés al salir, sin transcripción literal. Reabrió Preview del mismo
POI y TalkBack retomó el foco en Cerrar, marcado al abrir; indicó que eso no sucedió
en la primera apertura. Se registra esa diferencia de foco sin atribuir causalidad
ni clasificarla como bloqueo de navegación no reportado.

**OWNER_OBSERVED, A01-V03:** «Ver detalle» se oyó en español latino sin problemas
y abrió Detail del mismo POI. Esto contrasta con la anterior pronunciación «view
dedo» incomprensible, sin demostrar una causa única. Las dos acciones corregidas
tienen observación favorable de comprensión y activación; no equivale a cierre
global A01.

**OWNER_OBSERVED, A01-V04:** el propietario reportó descripción leída en inglés,
añadiendo que sí la entiende. No transcribió un fragmento visible/literal que
permita decidir si ese contenido estaba escrito en inglés o pronunciado con tal
acento; esa distinción permanece sin confirmar para el fragmento de esta sesión.
Reportó «Volver» en español con acento inglés, lo activó y regresó al mapa. Al
regresar oyó audio en inglés atribuido por él a la descripción de ficha y después
botones en español latino. No se confirma qué nodo o evento produjo ese audio
de transición. No informó impedimento de comprensión ni bloqueo de retorno.

**OWNER_OBSERVED, A01-V05:** el propietario activó Ver lista y reportó que ahora
lo escuchó en inglés, frente al español que había percibido antes. Para la tarjeta
reportó descripción en inglés y nombre «Plaza de armas de canta» en español con
acento inglés. Activó la tarjeta y abrió Preview del mismo POI; volvió a oír
contenido en inglés. No transcribió categoría o distancia ni un fragmento literal
del contenido. Ante la aclaración sin repetir acciones, confirmó comprensión de
lo necesario, tanto en inglés como en español latino o con acento inglés. No se
reportó una acción esencial incomprensible o no activable en este caso. Se conserva
la variación de Ver lista como observación por revisar, sin atribuirla al cambio
del Row de Preview ni descartarla por inferencia de código.

**OWNER_OBSERVED, A01-V06:** el propietario enfocó Gestionar copia offline y oyó
claramente «Gestionar copia offline» en español latino. Se indicó solo enfocar,
sin activar el control; no se pretende validar funcionalidad de caché.

**OWNER_OBSERVED, A01-V07:** el propietario confirmó desactivación de TalkBack y
retorno a Rutea con ruta visible, cinco POIs, resumen «Ruta 97.7 - 104 min - 5 lugares»,
«Online» y la ficha de descripción conservada como estaba. No precisó si esa ficha
era Preview, Detail o lista; no se afirma cierre de todas las superficies. La
restauración al estado inicial apagado queda OWNER_CONFIRMED. No se solicitaron
interacciones físicas adicionales tras ese reporte.

El reporte final no detalló nuevamente todos los ajustes globales ni la ausencia
de cualquier audio; no se amplía a una certificación de esos estados internos.
En la preparación había confirmado que no se cambiaron ajustes y no había sesiones
GPS/voz que preservar; no reportó activaciones nuevas durante la prueba. Codex no
ejecutó esas funciones, cambios de voz/idioma o permisos, ni capturas/grabaciones.

### Matriz final A01-V01–V07

Los resultados siguientes se limitan a las observaciones del propietario; no son
mediciones instrumentales del audio. PASS de una acción comprensible no significa
pronunciación homogénea ni certificación integral de accesibilidad.

| Caso | Resultado del alcance observado | Comprensión / activación / límite |
| --- | --- | --- |
| A01-V01 — Marcador | PASS | Español latino comprensible; abrió Preview del mismo POI. No hay transcripción literal completa de la etiqueta en esta reanudación. |
| A01-V02 — Preview / Cerrar | PASS | Etiqueta en español latino sin problemas; activación cerró ficha y volvió al mapa, con ruta conservada y sin bloqueo. Al reabrir, el foco retomó Cerrar; diferencia registrada, sin bloqueo reportado. |
| A01-V03 — Preview / Ver detalle | PASS | Español latino comprensible y acción reconocible; activación abrió Detail. Mejora respecto de «view dedo» en la sesión anterior. |
| A01-V04 — Detail / retorno | PASS para comprensión y navegación observadas; caracterización de idioma parcial | Propietario entiende el contenido oído en inglés; Volver con acento inglés fue identificable y permitió regresar al mapa. No hay fragmento visible/literal suficiente para separar lengua escrita y pronunciación de cada campo, ni evidencia de todos los anuncios/focos. |
| A01-V05 — Tarjeta | PASS para comprensión y apertura observadas; variación de pronunciación pendiente | Propietario confirmó comprensión de lo necesario y apertura de Preview. Nombre con acento inglés y contenido oído en inglés; categoría/distancia no fueron transcritas. Ver lista se oyó en inglés frente al español previamente percibido: conservar la observación, sin declarar ausencia global de regresiones ni causalidad. |
| A01-V06 — Control superior | PASS de etiqueta observada | «Gestionar copia offline» claro en español latino; solo se enfocó. No acredita funcionamiento de caché ni todos los controles superiores. |
| A01-V07 — Restauración | PASS según propietario | TalkBack apagado y retorno a Rutea con ruta recreada, cinco POIs, ficha y estado Online visibles. No se afirma preservación de la ruta anterior a la instalación ni inspección de todos los datos. |

### Evaluación del resultado y límites de aceptación

**A01_PREVIEW_CORRECTIVE_VALIDATION = PASS:** las dos acciones corregidas se
comprendieron y activaron en el dispositivo, con navegación/retorno operativos.
Este resultado físico es nuevo y se distingue del PASS automatizado del candidato.
La comparación es compatible con beneficio de declarar idioma semántico en esas
acciones, pero una mejora audible no demuestra por sí sola una causa única:
**A01_ROOT_CAUSE permanece UNCONFIRMED**.

**Resultado físico global: PARTIAL.** No se reportó un impedimento efectivo de
comprensión o activación en esta sesión; no se inventa FAIL de las superficies
comprendidas. Se conserva el alcance limitado porque persisten pronunciaciones
inglesas o con acento inglés fuera del Row corregido, faltan transcripciones por
campo para caracterizarlas y hay una variación reportada de Ver lista frente a su
lectura anterior. No se demuestra que el cambio de código la causara; tampoco se
puede declarar «sin regresiones» de idioma descartando esa observación. Se requiere
revisión humana de esas limitaciones, no repetir automáticamente los casos ya
completados. La restauración está confirmada y la sesión física ha terminado.

Conforme a la instrucción de reanudación, **A01 se conserva como BLOCKER hasta
validación física satisfactoria y revisión humana**. El PASS de Preview no autoriza
levantar globalmente A01, aceptar riesgos, certificar WCAG AA o cerrar UI-2.
No se afirma un nuevo bloqueo funcional de Ver lista: el propietario confirmó que
fue comprensible. La deuda restante debe clasificarse por revisión, sin extender
por iniciativa propia el cambio de idioma a otras superficies o datos factuales.

La decisión humana siguiente es revisar el PASS limitado de Preview y disponer
la variación de pronunciación y el alcance pendiente fuera de esas dos acciones.
Si se requiere otra corrección, necesitará autorización focalizada independiente;
esta sesión no la concede. No se solicita dispensa de un impedimento efectivo ni
se convierte en aprobada la propuesta de aceptación A01 anterior. Responsable de
seguimiento: OWNER_PENDING_ASSIGNMENT. R01/P07 conserva su aceptación y límites;
CEFI visual sigue futura UI-3, sin nueva autorización.

### Integridad documental y estado vigente

Solo se actualizan este seguimiento y DOCUMENTATION_INDEX. El historial de las
secciones 1–9 y los resultados físicos anteriores permanecen intactos, sin cambios
a la matriz física congelada/histórica, contratos, código o tests. No hubo nuevo
build, despliegue, push, PR o merge. Validaciones de UTF-8, enlaces/anclas, estados,
alcance y `git diff --check`; snapshots/hashes externos comprueban preservación de
checkout principal, worktrees concurrentes, tres stashes, borradores UI-0 y registros
privados. Las observaciones de voz provienen exclusivamente del propietario; no
se guardan serial, datos personales ni contenido multimedia.

```ini
A01_TECHNICAL_GATE_A = PASS
A01_TECHNICAL_GATE_B = PASS
A01_TECHNICAL_GATE_C = PASS
A01_TECHNICAL_GATE_D = PASS
SIGNATURE_COMPATIBLE = PASS
A01_INSTALLATION = PASS
A01_PREVIEW_CORRECTIVE_VALIDATION = PASS
A01_PHYSICAL_REMEDIATION_VALIDATION = PARTIAL
A01_DEVICE_RESTORATION = OWNER_CONFIRMED
A01_FINDING_CLASSIFICATION = BLOCKER
A01_ROOT_CAUSE = UNCONFIRMED
A01_REMEDIATION = IMPLEMENTED_PENDING_PHYSICAL
A01_AUTOMATED_CORRECTIVE_VALIDATION = PASS
A01_RISK_DISPOSITION = PENDING_HUMAN_DECISION
R01_P07_RISK_DISPOSITION = ACCEPTED_WITH_DOCUMENTED_LIMITATION
UI2_AC_12 = AUTOMATED_PASS_PHYSICAL_PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

STOP_AND_REPORT

## 11. A01-B — Segunda candidata focalizada, 2026-11-01

Autorización humana «UI-2 A01-B — REMEDIACIÓN FOCALIZADA DE ACCESIBILIDAD TALKBACK».
Se continúa en `codex/ui2-a01-talkback-remediation`, worktree autorizado, desde HEAD
limpio `a63350f433e5e207849b3e607c7fed184bf72485`. Main remoto comprobado en
`a17734f665d72b99e1f901c6634f8dcdc4b31288`; no se sincronizan checkout principal ni
ramas ajenas. Las secciones 1–10 conservan literalmente su evidencia histórica.
No se contactó el HONOR ni se ejecutó ADB en esta etapa.

### Diagnóstico focalizado y alcance seleccionado

La sesión anterior acreditó comprensión/activación de Cerrar y Ver detalle, y
variaciones en Ver lista, Volver y contenido de tarjeta/Detail. El código de
Preview no se modifica: el subárbol español aprobado físicamente sigue intacto.
La hipótesis abordada es mejorar la representación explícita del idioma de las
etiquetas UI españolas conocidas, sin extenderla a textos factuales de lengua
desconocida ni atribuir a en_US toda la observación audible.

| Superficie / construcción | Hallazgo y decisión mínima |
| --- | --- |
| BaseMapPage, botón de lista | Ver lista es texto fijo español dentro de OutlinedButton.icon. Se añade Semantics.localeForSubtree es_PE solo a ese botón. La rama textual existente Ver mapa comparte el wrapper, sin cambiar cuándo aparece. El shell oculta el panel de estado al abrir la lista; el retorno sigue usando su icono de cierre existente, no una navegación nueva para hacer visible Ver mapa. |
| Detail, Volver | Acción fija española independiente del contenido. Se localiza únicamente el subárbol del botón, conservando callback, rol, etiqueta y área. |
| Tarjeta, categoría/distancia | friendlyPoiCategory y poiDistanceLabel producen cadenas UI españolas en código local. Se declaran con Text.locale; las diez categorías y el fallback propio son conocidos, no se toma la lengua de códigos/datos externos. |
| Tarjeta, Fuente: más procedencia | La cadena mezcla prefijo español y fuente externa. Text.rich separa un TextSpan español para «Fuente: » y otro sin locale impuesto para la fuente; el texto visible concatenado sigue idéntico. |
| Detail, encabezado y procedencia | «Detalle de » se anota como rango español en AttributedString, dejando el nombre sin atributo. La etiqueta fija «URL de la fuente» recibe atributos de idioma, no un locale de subárbol que pudiera imponerse a la URL seleccionable. El rol link se conserva. |
| Detail, categoría/distancia/motivos/Fuente | Son textos formateados o mapeados por helpers UI locales en español; se anota únicamente cada Text conocido. Nombre, descripción, fuente, atribución y URL permanecen sin idioma impuesto. |

Se inspeccionó [poi_presentation.dart](../../../mobile/lib/features/discovery/presentation/poi_presentation.dart)
como dependencia directa de las categorías, motivos y formato de distancia; no se
modifica ese archivo. La prioridad 2 se justifica por esas cadenas locales conocidas
y por separación verificable de rangos. No se infiere idioma por nombre, país,
caracteres o contenido del backend. No fue necesario alterar contratos, agrupar
de otro modo las acciones o reemplazar labels por tooltips.

### Archivos modificados y semántica efectiva

| Archivo | Cambio |
| --- | --- |
| [base_map_page.dart](../../../mobile/lib/features/map/presentation/base_map_page.dart) | Wrapper de idioma del botón de lista; handler y reglas de visibilidad intactos. |
| [poi_detail_sheet.dart](../../../mobile/lib/features/discovery/presentation/poi_detail_sheet.dart) | Volver, segmentos UI locales y atributos del prefijo/etiqueta de procedencia. |
| [poi_result_card.dart](../../../mobile/lib/features/discovery/presentation/poi_result_card.dart) | Categoría/distancia y prefijo Fuente: segmentado; InkWell/rol/callback intactos. |
| [poi_ui_language.dart](../../../mobile/lib/features/discovery/presentation/poi_ui_language.dart) | Helper pequeño de presentación para constante es_PE y AttributedString de prefijo español más sufijo factual sin idioma. Dependencia directa de tarjeta/Detail, no servicio ni localización global. |
| [a01_b_ui_language_test.dart](../../../mobile/test/features/discovery/presentation/a01_b_ui_language_test.dart) | Cuatro pruebas nuevas sobre nodos efectivos, rangos, categorías, navegación/foco y protección multilingüe. |
| [a01_preview_actions_test.dart](../../../mobile/test/features/discovery/presentation/a01_preview_actions_test.dart) | Refuerza protección por rango de cada dato factual en label y value; mantiene las pruebas previas de Preview. |
| Este informe / DOCUMENTATION_INDEX | Seguimiento nuevo e índice actual, sin reescribir observaciones físicas. |

El helper de pruebas anterior rechazaba cualquier atributo español en un nodo
mixto, aunque solo cubriera UI propia; ahora exige que ningún rango español se
solape con ninguna ocurrencia del dato externo y que el nodo no imponga español
al conjunto. Comprueba label y value porque SelectableText puede exponer la URL
como valor de un nodo separado del label del enlace. Esta comprobación distingue
la separación de idioma de una mera preservación de texto visible.

| Nodo / segmento efectivo | Antes de A01-B | Después comprobable por tests |
| --- | --- | --- |
| Ver lista | Label literal, locale null, rol y tap existentes. | Mismo label único, locale es_PE, rol/tap conservados; apertura de lista y cierre existente operativos. |
| Volver | Label literal, locale null, rol y tap existentes. | Mismo label único, locale es_PE; activación semántica cierra Detail y conserva query/contexto. |
| Tarjeta, label agregado | Locale null, sin atributos de lengua explícitos. | Locale global del nodo sigue sin español impuesto; atributos es_PE solo sobre categoría, distancia formateada y «Fuente: ». Nombre, descripción, fuente y atribución quedan fuera de esos rangos. |
| Detail, label agregado | Locale null, sin atributos explícitos. | Atributos es_PE en «Detalle de », categoría, distancia, motivos y título Fuente; sin solapamiento con hechos. |
| Link de procedencia | Etiqueta española sin idioma; URL seleccionable y rol link. | Atributo español en el label UI, sin locale de subárbol impuesto a URL; valor/nodo de URL sin atributo español, rol link intacto. |
| Preview y marcador | Cerrar/Ver detalle con es_PE, marcador sin cambio de idioma explícito. | Preview de producción idéntico al baseline; regresiones verifican sus acciones y que tooltip/locale/label del marcador permanecen iguales. |

Los atributos por segmento y el locale del nodo son representaciones diferentes.
Se inspecciona el resultado renderizado, no solo parámetros de constructores.
No se afirma que sus efectos audibles sean idénticos ni que un test elija la voz
de TalkBack. La causa raíz global permanece UNCONFIRMED.

### Pruebas y regresiones

| Validación ejecutada | Resultado comprobado |
| --- | --- |
| `flutter test --no-pub --reporter expanded` sobre a01_b_ui_language, a01_preview_actions, poi_preview_sheet, poi_detail_sheet y ui231_poi_language | PASS, 19 pruebas, 23 s reportados. |
| `dart format --output=none --set-exit-if-changed` sobre los cuatro Dart de producción y dos de tests modificados | PASS, seis archivos sin cambios pendientes de formato. |
| `flutter analyze --no-pub` | PASS, sin issues, 138,2 s reportados. |
| `flutter test --no-pub` sobre ui2_experience, i01_widget y poi_visual_contract | PASS, 23 regresiones, 30 s reportados. |
| `flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` | PASS, Gradle 235,2 s reportados. No se actualizan dependencias ni se modifica configuración de backend. |
| Inspección local con aapt, apksigner y ZIP | PASS: package/versión, firma válida, certificado esperado, MaterialIcons/FontManifest/AssetManifest y helper A01-B presente en kernel debug. |

La cobertura incluye etiquetas exactas y sin duplicar; rol/tap; foco por teclado;
apertura de lista y retorno real desde Detail; query S01 conservada; marcador
inalterado; todas las categorías y fallback; datos españoles, ingleses, nombres
con acentos/CJK, fuentes, atribuciones y URLs sin rangos españoles superpuestos.

En pases iniciales se corrigieron supuestos de los tests: URL en value en vez
de label; nodo link separado de la URL; y expectativa de Ver mapa visible cuando
el panel de lista ya oculta el estado. No se cambió navegación para satisfacer
esas expectativas. Los logs iniciales y el pase final se conservan separados.

### APK candidato y preservación del anterior

Antes de construir, se preservó y verificó el APK anterior en
`D:\Codex\validation-logs\GeoGuide-AI\ui2-a01-b-candidate-2026-11-01\a01-preview-candidate-0045313E.apk`,
SHA-256 `0045313E8F8C8EDC023DCC252B49C6119053FA5B5C4CC1BCDF5F60CCD6ECF673`.
La salida habitual app-debug.apk puede ser reemplazada por el build nuevo; las
tablas históricas describen su artefacto de entonces, que sigue disponible en
la copia preservada. No reutilizar una autorización ligada al hash anterior para
instalar la nueva candidata sin autorización expresa.

| Dato del nuevo APK A01-B | Valor verificado localmente |
| --- | --- |
| Ruta | `D:\Codex\worktrees\GeoGuide-AI\ui2-a01-talkback-remediation\mobile\build\app\outputs\flutter-apk\app-debug.apk` |
| Package / variante | `com.geoguideai.geoguide_ai` / debug |
| Versión | `1.0.0 / versionCode 1` |
| Tamaño en bytes | `193940574` |
| SHA-256 APK | `912E1DDB8936577F603FD8A3F4C00FBB742089A8F6B1F89F621ED95779B64FA5` |
| SHA-256 certificado | `894975B5BC6751DA09B3D69923D4AE399192470D86C107106F65F6CB8D7EAB7E` |

No se instala este artefacto ni se verifica en HONOR en esta etapa. La salida
local app-debug.apk ahora corresponde a A01-B, no al hash histórico 0045313E.
El archivo de Preview conserva su SHA-256 previo
`2358D94E21EB51ED1316348F8F3A14FB51CC400A28F81AEE2891F369FC5FA103`.
El manifest local de validación registra hashes de los cuatro archivos de
producción A01-B y de ambos APK, además de los logs de pruebas, análisis y build.

Se investigó el aumento de tamaño respecto del APK preservado: ambos contienen
las mismas 172 entradas ZIP y solo cambia el contenido lógico de kernel_blob.bin
(1760 bytes sin comprimir, 561 comprimidos). El kernel se reubicó; los offsets de
las demás entradas no cambian. Los 26096792 bytes adicionales de layout coinciden
exactamente con el tamaño del registro comprimido anterior del kernel, coherente
con empaquetado incremental. No son nuevos archivos multimedia o dependencias.
La firma y el ZIP se verificaron correctamente; no se repitió el build solo para
compactar esa salida debug. Las advertencias del toolchain Java/acceso nativo y
versiones XML de SDK no impidieron completar el build y no se alteró el entorno
para silenciarlas.

### Riesgos y protocolo físico futuro recomendado

El efecto de atributos parciales sobre la voz del servicio Android no está
validado físicamente. Texto externo sin lengua declarada seguirá sin idioma
impuesto; no se promete pronunciación española de nombres o descripciones.
El diagnóstico físico anterior sigue PARTIAL y A01 sigue BLOCKER hasta revisión.
La observación de Ver lista no se reinterpreta como fallo confirmado de una
línea de código ni como resultado ya corregido por este build.

Protocolo mínimo propuesto, no ejecutado:

1. Bajo autorización nueva, verificar APK A01-B exacto, identidad/firma y gates
   de actualización con datos preservados antes de instalar; no usar flags de
   downgrade/borrado ni cambiar idioma o voz para forzar resultados.
2. Con propietario presente y teléfono estacionario, registrar TalkBack inicial,
   app/ruta disponibles y preparar el mismo POI mediante mapa si se autoriza.
3. Comprobar pronunciación, comprensión y activación de Ver lista y Volver; lista,
   Preview, Detail y retorno, sin bloqueo ni pérdida de contexto válido.
4. Contrastar categorías y prefijos fijos de tarjeta/Detail con nombres, fuente,
   atribución y URL originales. Separar texto visible, pronunciación y comprensión;
   no fabricar campos ausentes o datos multilingües para completar evidencia.
5. Verificar que marcador, Cerrar y Ver detalle conserven su PASS previo; anotar
   variaciones de foco o anuncios de transición sin inferir causalidad.
6. Detener ante impedimento esencial; restaurar TalkBack al estado inicial y
   confirmar usabilidad/ruta. No repetir automáticamente los 36 casos UI-2.2.

Reversión focalizada: retirar únicamente las anotaciones de A01-B si imponen
idioma a hechos, duplican anuncios o alteran foco/acciones; conservar la corrección
de Preview y el historial. No reset/clean sobre trabajo ajeno. La decisión humana
pendiente es autorizar una sesión física del APK nuevo y revisar sus resultados,
no aceptar automáticamente A01 ni cerrar UI-2. Seguimiento OWNER_PENDING_ASSIGNMENT.

### Validación documental y gobierno vigente

Se verifican UTF-8, enlaces/anclas, estados, diff limitado a los ocho archivos
identificados, conservación literal de secciones 1–10 y `git diff --check`.
Snapshots y hashes externos comprueban integridad de los otros worktrees, stashes,
borradores UI-0, registros privados y checkout principal. No hay ADB, instalación,
prueba física, cambios de idioma/TTS/permisos, dependencias, contratos o backend,
ni push, PR, merge o cierre de fase.

La finalización siguiente es de la implementación **candidata** y sus verificaciones
automatizadas; no convierte la evidencia física global anterior en PASS. La
corrección Preview ya validada se conserva tanto en código como en su estado.

```ini
A01_B_IMPLEMENTATION = COMPLETED_PENDING_PHYSICAL
A01_B_AUTOMATED_VALIDATION = PASS
A01_B_PHYSICAL_VALIDATION = NOT_EXECUTED
A01_PREVIEW_CORRECTIVE_VALIDATION = PASS
A01_PHYSICAL_REMEDIATION_VALIDATION = PARTIAL
A01_FINDING_CLASSIFICATION = BLOCKER
A01_ROOT_CAUSE = UNCONFIRMED
A01_RISK_DISPOSITION = PENDING_HUMAN_DECISION
R01_P07_RISK_DISPOSITION = ACCEPTED_WITH_DOCUMENTED_LIMITATION
UI2_AC_12 = AUTOMATED_PASS_PHYSICAL_PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

STOP_AND_REPORT

## 12. A01-B — Validación física y revisión de prioridad del piloto, 2026-11-01 a 2026-11-02

Encargo humano «UI-2 A01-B PHYSICAL VALIDATION & PILOT PRIORITY REVIEW», con
CONTINUE_BY_DEFAULT_WITH_HARD_GATES. Las secciones 1–11 conservan su evidencia
histórica; esta sección registra exclusivamente la nueva instalación y sesión.

### Baseline, artefacto y gates técnicos

Rama `codex/ui2-a01-talkback-remediation`, worktree limpio al inicio en
`f17bcf5d1f26c8f2c001c6ea5d766a8c3efec004`; main remoto continúa en
`a17734f665d72b99e1f901c6634f8dcdc4b31288`. No se sincroniza el checkout principal
ni se reconstruye el APK. La inspección local verificó tamaño 193940574 bytes,
package `com.geoguideai.geoguide_ai`, versión `1.0.0 (1)`, firma válida y el
SHA-256 autorizado `912E1DDB8936577F603FD8A3F4C00FBB742089A8F6B1F89F621ED95779B64FA5`.
Certificado del candidato:
`894975B5BC6751DA09B3D69923D4AE399192470D86C107106F65F6CB8D7EAB7E`.

ADB se invocó por ruta absoluta de platform-tools. El serial del único objetivo
se fijó en memoria del mismo proceso para A–D y se usó con `-s` en todas las
operaciones sobre el dispositivo; no se publicó ni guardó ese identificador.

| Gate | Resultado técnico | Evidencia CODEX_VERIFIED |
| --- | --- | --- |
| A — Dispositivo | PASS | Una entrada autorizada device; fabricante HONOR, modelo LLY-NX3 y Android 16 confirmados por getprop. |
| B — Instalado previo | PASS | Package Manager identificó com.geoguideai.geoguide_ai, versionName 1.0.0 y versionCode 1. |
| C — Compatibilidad | PASS | Se verificó criptográficamente el certificado del base.apk instalado, ubicado por pm path; un único SHA-256 idéntico al del candidato y sin downgrade. Solo se leyó el binario de esa aplicación, sin datos privados; la copia local temporal se retiró tras la comprobación. |
| D — Instalación | PASS técnico | Ejecutado únicamente `adb -s <HONOR_TARGET> install -r "D:\Codex\worktrees\GeoGuide-AI\ui2-a01-talkback-remediation\mobile\build\app\outputs\flutter-apk\app-debug.apk"`. Resultado «Performing Streamed Install / Success», package/versión posteriores correctos y SHA-256 del APK instalado idéntico al autorizado. Apertura y usabilidad verificadas después por el propietario; ruta recreada con autorización, sin prueba de persistencia de la anterior. |

El APK instalado previo tenía SHA-256
`0045313E8F8C8EDC023DCC252B49C6119053FA5B5C4CC1BCDF5F60CCD6ECF673`;
no se reutilizó ese APK para esta actualización. El hash posterior A01-B se
verificó mediante sha256sum exclusivamente sobre la ubicación de código informada
por Package Manager. No hubo desinstalación, borrado de datos, downgrade, flags de
bypass, cambios de idioma/voz/permisos, capturas ni grabaciones.

### Preparación física y observaciones — sesión finalizada

Antes de instalar, el propietario confirmó estar junto al HONOR y estacionario,
TalkBack apagado, sin sesiones abiertas que preservar y Rutea cerrada.
**OWNER_OBSERVED, preparación posterior:** Rutea abrió sin problemas con el lector
apagado; el propietario transcribió «Sin copia offline disponible», «Ubicación no
solicitada», «No disponible», botón «Reintentar» y «No encontramos lugares de estas
categorías para esta ruta». Lima–Canta no está disponible como contexto visible de
preparación. No se presume conservación de la ruta por el Success de ADB ni se
atribuye ese estado a borrado de datos persistentes, backend o conectividad sin
evidencia. El propietario autorizó expresamente recrear la ruta; se indicó hacerlo
mediante mapa y Calcular ruta, sin ubicación actual, GPS continuo, Driving o CEFI.
El propietario recreó manualmente Lima–Canta y confirmó «Ruta: 97.7 km - 104 min -
5 lugares / Online», con Plaza de Armas de Canta visible en mapa y lista, sin error
y TalkBack todavía apagado. GATE E: PASS basado en OWNER_OBSERVED. La ruta actual
fue recreada con autorización; no constituye prueba de persistencia de la anterior.

La validación comenzó el 2026-11-01 y continuó con respuestas del propietario el
2026-11-02 (America/Bogota). No se presupone observación continua entre respuestas.
Las observaciones siguientes son OWNER_OBSERVED, sin captura ni audio registrados.

| Caso | Resultado OWNER_OBSERVED | Límite |
| --- | --- | --- |
| 1 — Ver lista | PASS de comprensión y activación: español latino claro; abrió la lista. | Dentro de la lista se anunció pronunciación mixta. |
| 2 — Tarjeta POI | PARTIAL: identificó y abrió Plaza de Armas de Canta; confirmó comprensión pese a mezcla de idiomas. Nombre en español con acento inglés; anuncio de selección en inglés; «Monumento» y «A 909 metros del trazado» en español latino. | Prefijo Fuente y valor no comunicados; NOT_OBSERVED. La distancia es al trazado, no tiempo ni distancia restante de viaje. |
| 3 — Preview | PASS de acciones: Cerrar y Ver detalle claros en español latino; cerró, regresó a lista y reabrió el mismo Preview. Confirmó comprensión de la información pese a audio mixto. | Persiste mezcla de inglés y español con acento inglés en descripción; no se certifica pronunciación uniforme. |
| 4 — Detail | PARTIAL: Ver detalle abrió el POI correcto y el propietario confirmó comprensión. Nombre con acento inglés; «categoría: Monumento», «A 909 m del trazado», «Cerca del trazado» y «Coincide con la categoría seleccionada» en español latino. | Fuente/URL no comunicadas; NOT_OBSERVED, sin asumir ausencia ni pronunciación. |
| 5 — Volver | PASS de activación y retorno: español latino; regresó a Ver lista y vio detrás la ruta activa y los POIs. | No se comunicó bloqueo; no se amplía a todos los recorridos de foco posibles. |
| 6 — Mapa y control superior | PASS focalizado: cerró la lista, retornó al mapa y enfocó marcador del POI y Gestionar copia offline; ambos claros en español latino. | No se solicitó activar el control offline ni se verifican otros controles. |
| 7 — Restauración | PASS: propietario desactivó TalkBack, confirmó cese de lectura, retorno a Rutea estable y ruta, resumen y POIs todavía visibles. Declaró que no cambió configuración o ajustes ni pulsó botones ajenos a la prueba. | No retranscribió los números del resumen final; el último resumen literal comunicado fue 97.7 km / 104 min / 5 lugares, Online. No se verificó por ADB ningún ajuste final. |

No se comunicó un impedimento esencial de comprensión o activación en estos
casos. Tarjeta, Preview y Detail fueron expresamente comprensibles para el
propietario, incluso con audio mixto. Las acciones probadas funcionaron, sin
bloqueo comunicado. Esto no equivale a certificar accesibilidad integral ni a
levantar A01. Los prefijos/campos Fuente y URL permanecen NOT_OBSERVED; no se
solicita otra sesión para completar artificialmente este resultado.

### Evaluación y disposición propuesta, sin aprobación aplicada

Resultado focalizado A01-B: **PARTIAL**. La ejecución manual concluyó y el lector
se restauró; los campos no comunicados y la pronunciación mixta impiden declarar
un PASS integral. La automatización anterior permanece PASS histórico; no se
repitieron builds, tests ni diagnóstico general en esta sesión física.

| Clase solicitada | Evaluación de esta sesión | Disposición propuesta |
| --- | --- | --- |
| A — Funcional/seguridad | No se comunicó impedimento nuevo en las acciones probadas. No se ensayó seguridad en movimiento ni conservación de datos persistentes. | Sin cierre de riesgos ajenos a esta prueba estacionaria. |
| B — Accesibilidad impeditiva | No se observó un nuevo impedimento esencial en esta sesión. El antecedente de Ver detalle incomprensible de §7 se conserva, y la corrección de Preview mantiene evidencia satisfactoria en §10 y esta sesión. | No borrar el antecedente ni levantar el BLOCKER vigente sin revisión humana. |
| C — Pronunciación irregular sin impedimento observado | Anuncio de selección en inglés, nombre propio con acento inglés y descripción Preview mixta; información necesaria expresamente comprendida por este propietario. Textos fijos probados de lista/Detail, acciones Preview/Volver, marcador y control offline en español latino claro. | Proponer deuda técnica de accesibilidad para la irregularidad residual observada; requiere decisión humana, no dispensa aplicada. |
| D — Caracterización insuficiente | Fuente/URL no comunicadas; no hay transcripción literal completa de anuncios de transición ni evidencia para distinguir texto factual inglés de voz inglesa en todos los segmentos. | Pendiente de evidencia; no afirmar fallo de traducción, ausencia de campo ni PASS de esos segmentos. |

Severidad propuesta para la irregularidad C: **Media provisional**, por inconsistencia
auditiva sin impedimento observado en el recorrido de este propietario. No demuestra
comprensión de usuarios monolingües ni de todos los usuarios de lector de pantalla;
ese riesgo residual permanece abierto. La causa raíz sigue UNCONFIRMED: mejoría
focalizada y anotaciones de idioma no prueban una causa única ni garantizan lectura
uniforme de hechos, anuncios del sistema o contenidos externos. No se concluye una
regresión causal solo por diferencias entre relatos de sesiones.

Condiciones propuestas para diferir C: decisión expresa del propietario, alcance
limitado a lo observado, propietario de seguimiento aprobado (hasta entonces
OWNER_PENDING_ASSIGNMENT), aceptación explícita de lectura mixta y revisión de D,
sin declarar accesibilidad certificada ni UI-2 cerrado. Revisar antes de aprobar un
alcance de piloto que dependa del lector de pantalla. Si no se asigna responsable,
no se considera gestionada la deuda. No se aprueba aquí la participación vial.

Criterios de reapertura o aumento de severidad: información o acción esencial
incomprensible, imposibilidad de identificar/activar controles, bloqueo de foco,
retorno imposible o pérdida de contexto, idioma impuesto indebidamente a datos
factuales, o regresión material en Preview/Volver/lista. Un impedimento confirmado
se clasificaría B o A según su efecto y no se diferiría automáticamente. Cualquier
remediación o prueba adicional requiere el alcance y autorización correspondientes.

### PILOT_PRIORITY_REVIEW

Esta revisión es documental. Se apoya en [estado técnico vigente](../../../PROJECT_CONTEXT.md),
[contrato congelado P12](P12-Phase-Contract-v1.md),
[protocolo P12.4](P12.4-Pilot-Readiness-Protocol.md),
[evidencia de preparación P12.2–P12.4](P12.2-P12.4-Preparation-Evidence.md),
[gobierno GPS/CEFI post-merge](GPS-CEFI-Post-Merge-Governance-Evidence.md) y
[evidencia posterior I01](I01-Selected-POI-Session-Integration-Evidence.md).
La evidencia I01 posterior prevalece para esa integración sobre su condición
histórica diferida en documentos anteriores. No se cambia ningún contrato.

#### 1. Capacidades operativas existentes

- Cálculo de ruta y descubrimiento de POIs con selección manual de extremos:
  Lima–Canta online, 97.7 km / 104 min / cinco lugares observados en esta sesión.
  Mapa, tarjeta, Preview, Detail, cierre y retorno comprobados de forma estacionaria.
  No implica navegación dinámica ni exactitud de ETA en movimiento.
- Filtrado por categorías y búsqueda local cuentan con evidencia previa automatizada
  y física delimitada, sin repetirse aquí. P07 mantiene su límite de red físico.
- GPS normal, sesión B1/B1.1, consentimiento revocable y voz local C2 están
  implementados y cubiertos por automatización y evidencia estacionaria histórica
  acotada. Esa evidencia corresponde a otros APK y no se revalida con este ensayo.
- I01 conecta POIs explícitamente elegidos al worker y tiene PASS automatizado;
  su validación física integral sigue NOT_EXECUTED. Un diagnóstico TTS audible no
  prueba avisos reales por proximidad ni convivencia con otras aplicaciones.

#### 2. Bloqueos reales para la prueba piloto

- P12.4 sigue PENDING_HUMAN_READINESS_REVIEW y P12.5 NOT_AUTHORIZED: falta decisión
  humana de preparación y autorización de campo específica. Ninguna de las
  instalaciones o pruebas TalkBack autoriza conducir o iniciar un piloto vial.
- A01 sigue pendiente de revisión humana. La propuesta C no levanta su BLOCKER;
  D tampoco desaparece. Si el alcance depende de accesibilidad auditiva uniforme,
  debe resolverse su compatibilidad antes de aprobar participantes/operación.
- GPS dinámico, muestras degradadas, lifecycle/background, batería y convivencia
  de audio conservan las lagunas registradas. No se consideran validados por este
  ensayo. El gate de preparación debe decidir qué es necesario para el alcance
  propuesto, qué está fuera y qué validación separada requiere autorización.
- P11-BACKUP-01 bloquea Production Readiness; el protocolo solo contempla datos
  reconstruibles no productivos para su alcance limitado. No presentar esta deuda
  como resuelta ni como autorización de uso productivo.

#### 3. Deudas técnicas que podrían diferirse

- Pronunciación residual C: solo bajo las condiciones, responsable y reapertura
  anteriores; no se acepta unilateralmente el riesgo. Fuente/URL continúan en D.
- R01/P07 ya fue aceptado con limitación documental, sin transformarlo en PASS
  físico. La red automatizada permanece PASS y la sesión física S01 PARTIAL.
- Identidad visual CEFI pendiente de evolución UI-3 permanece futura; no activa
  conversación, STT, micrófono ni avisos nuevos y no se implementa en este trabajo.

#### 4. Funcionalidades aún no implementadas o no acreditadas

Navegación giro a giro, ETA dinámica, rerouting, búsqueda/geocodificación global y
conversación contextual/STT no forman una capacidad terminada acreditada por estas
pruebas. Son evolución o exclusiones del contrato P12. No confundirlas con selección
manual, duración planificada, búsqueda dentro de resultados o TTS consentido existente.
Cámara pasiva Driving y continuo sin ruta siguen diferidos; seguimiento prolongado,
proximidad real audible, coexistencia con llamadas/música, Doze y reinicio/proceso
no tienen la validación física requerida para afirmar disponibilidad operativa.
Esto distingue implementación existente no validada de funcionalidad futura.

#### 5. Decisiones humanas y autorizaciones pendientes

1. Revisar A01-B PARTIAL, la propuesta C y el pendiente D; decidir remediación o
   diferimiento delimitado y asignar responsable. A01 no se acepta ni cierra aquí.
2. Priorizar el siguiente ciclo en **preparación P12.4 del piloto de ruta y
   descubrimiento**, con alcance existente, matriz de capacidades/evidencia,
   roles conductor/observador, privacidad, abortos y límites contractuales explícitos.
   Esta recomendación no ejecuta implementación ni un nuevo discovery general.
3. Resolver expresamente el alcance entre exclusiones del contrato P12 y capacidades
   GPS/voz de contratos posteriores antes de cualquier validación dinámica; el
   protocolo no concede por sí mismo autorización para implementar o ampliar GPS,
   alertas, Driving o navegación. Preservar contratos congelados.
4. Solo tras revisión de preparación, considerar autorización separada P12.5 con
   corredor, fecha/ventana, participantes, observador, APK/hash, privacidad y abortos.
   Lima–Canta–Obrajillo es candidato documental, no recorrido ejecutado.
5. Cierre maestro UI-2, integración Git y Production Readiness requieren decisiones
   propias; no se ejecutan ni se presumen a partir de esta recomendación.

### Estado vigente y límites de cierre

```ini
A01_B_IMPLEMENTATION = COMPLETED
A01_B_AUTOMATED_VALIDATION = PASS
A01_B_PHYSICAL_VALIDATION = PARTIAL
A01_B_DEVICE_RESTORATION = PASS_OWNER_OBSERVED
A01_PREVIEW_CORRECTIVE_VALIDATION = PASS
A01_PHYSICAL_REMEDIATION_VALIDATION = PARTIAL
A01_FINDING_CLASSIFICATION = BLOCKER
A01_ROOT_CAUSE = UNCONFIRMED
A01_RISK_DISPOSITION = PENDING_HUMAN_DECISION
A01_B_RESIDUAL_RISK_PROPOSAL = ACCESSIBILITY_TECHNICAL_DEBT_PENDING_HUMAN_REVIEW
A01_FOLLOWUP_OWNER = OWNER_PENDING_ASSIGNMENT
R01_P07_RISK_DISPOSITION = ACCEPTED_WITH_DOCUMENTED_LIMITATION
S01_NETWORK_AUTOMATED = PASS
S01_NETWORK_PHYSICAL = NOT_VERIFIED_PHYSICALLY
S01_THIRD_PHYSICAL_SESSION = PARTIAL
UI2_AC_12 = AUTOMATED_PASS_PHYSICAL_PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
P12_4 = PENDING_HUMAN_READINESS_REVIEW
P12_5 = NOT_AUTHORIZED
DYNAMIC_ROAD_VALIDATION = NOT_EXECUTED
```

### Validación documental y preservación

Solo se actualizan esta evidencia y su entrada en DOCUMENTATION_INDEX.md. Se
comprueban UTF-8, enlaces/anclas locales, estados, secciones 1–11 intactas,
`git diff --check`, hash del APK original y código candidato sin cambios. Los
snapshots externos verifican los 28 worktrees: los otros 27 conservan HEAD,
rama, status y hashes de pendientes, incluidos los tres borradores UI-0 del
checkout principal. Los tres stashes y los tres registros privados conservan
identidad y hashes. Validación documental: 60 enlaces/anclas locales válidos,
UTF-8 estricto, estados coherentes, historia intacta y diff sin whitespace. No se
reescribe la matriz física histórica, no se ejecutan nuevas
builds/tests ni se modifica código, contratos, dependencias o ajustes del teléfono.
El commit es exclusivamente local; sin push, PR, merge, piloto o cierre UI-2.

STOP_AND_REPORT

## 13. Disposición humana A01-B y reconciliación P12.4 — 2026-11-08

El propietario aprobó diferir la pronunciación residual mixta de TalkBack como
deuda de accesibilidad MEDIUM_PROVISIONAL para el alcance piloto que no dependa
operativamente de TalkBack. Fuente/URL sigue NOT_OBSERVED. El responsable es
PENDING_ASSIGNMENT. Esta decisión delimitada no constituye certificación de
accesibilidad integral. La evidencia física focalizada permanece PARTIAL, aunque
las acciones probadas fueron comprendidas y operativas para el propietario.
Se conserva el BLOCKER histórico y A01_ROOT_CAUSE = UNCONFIRMED.

```ini
A01_B_RESIDUAL_PRONUNCIATION = DEFERRED
A01_B_RESIDUAL_SEVERITY = MEDIUM_PROVISIONAL
A01_FOLLOWUP_OWNER = PENDING_ASSIGNMENT
A01_B_FUENTE_URL = NOT_OBSERVED
A01_B_PHYSICAL_VALIDATION = PARTIAL
A01_FINDING_CLASSIFICATION = BLOCKER_HISTORICAL_RETAINED
A01_ROOT_CAUSE = UNCONFIRMED
UI2_AC_12 = AUTOMATED_PASS_PHYSICAL_PARTIAL
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

Reabrir si una acción esencial resulta incomprensible, hay bloqueo de foco,
imposibilidad de retorno, pérdida de contexto o regresión material. La disposición
no cambia estados históricos ni cierra UI-2.

### Reconciliación P12.4 Gate 7

El contrato congelado P12 §3 prevalece y excluye GPS continuo, seguimiento y cámara
Follow. La decisión aprobada retira del protocolo P12.4 el requisito previo
obligatorio de activar GPS Follow antes del movimiento. El protocolo ahora limita
las interacciones a las capacidades incluidas en P12 y prohíbe tratar Follow como
prerrequisito. El contrato congelado no se modifica.

```ini
P12_4_GATE_7_DOCUMENTARY_CONFLICT = RECONCILED
P12_4_GATE_7_EXECUTION_VALIDATION = PENDING
P12_5 = NOT_AUTHORIZED
DYNAMIC_ROAD_VALIDATION = NOT_EXECUTED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

La evidencia del APK A01-B `912E1DDB8936577F603FD8A3F4C00FBB742089A8F6B1F89F621ED95779B64FA5`
se conserva como artefacto de la sesión física. Su correspondencia exacta con el
código que se proponga integrar queda pendiente del paquete funcional A01-B y no
se infiere aquí.
