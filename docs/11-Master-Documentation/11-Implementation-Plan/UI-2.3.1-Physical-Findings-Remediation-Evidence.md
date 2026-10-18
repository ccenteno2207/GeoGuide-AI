# UI-2.3.1 — Remediación de hallazgos físicos

Fecha de ejecución: 2026-10-18. Estado: `COMPLETED`, listo para revisión local;
no representa integración ni cierre maestro UI-2.

## Alcance y baseline

Checkpoint correctivo UI-2.3.1, autorizado expresamente por el propietario para
diagnóstico, corrección Flutter localizada, regresiones, renderer, builds,
documentación y commits locales. No autoriza push, PR, merge ni otra sesión física.

- Baseline después de `git fetch origin`: `0b249514b99fdc4f2753d6dc8005516d8287bf93`.
- Contiene PR #88, merge `30ed7b92c9fafc14de4c0908deb1a7742146b98c`, y PR #89,
  merge `0b249514b99fdc4f2753d6dc8005516d8287bf93`; ascendencia comprobada.
- Rama nueva: `codex/ui2-3-1-physical-findings-remediation`.
- Worktree: `D:\Codex\worktrees\GeoGuide-AI\ui2-3-1-physical-findings-remediation`.
- Checkout principal preservado en `e443c0aa10987e04367dd15a1df259438426c3bc`,
  con sus tres borradores UI-0 sin seguimiento. No se sincronizó ni se limpió.
- El registro físico privado se consultó solo en lectura. Este documento extrae
  conclusiones técnicas; no reproduce el registro, identificadores privados ni capturas físicas.

Aplican AGENTS/G01, Entrega 04.6, ADR-016/019/027, [UI-0 visual](UI-0-Visual-Design-Contract-Proposal.md),
[UI-1](UI-1-Execution-and-Acceptance-Evidence.md), el [contrato UI-2 congelado](UI-2-Map-Search-and-POI-Experience-Contract-Proposal.md),
el [protocolo UI-2.2](UI-2.2-Physical-Validation-Protocol-Proposal.md), su
[matriz](UI-2.2-Physical-Validation-Traceability-Matrix.md) y la
[evidencia UI-2.3/UI23R](UI-2.3-Execution-and-Photo-Inventory-Evidence.md).
No se modifica ninguna de estas fuentes congeladas ni se abren otros milestones.

## UI231-L01 — Layout e insets

### Hallazgo original

La sesión física reportó panel `[161,1892][919,2330]`, región de navegación
`[0,2296][1080,2412]` y atribución `[326,2371][754,2404]`: superposición geométrica
de panel de 34 px, con los botones fuera de esa región; atribución dentro de ella.
El árbol de accesibilidad corrobora geometría. La oclusión visual física no fue
confirmada mediante captura limpia y no se afirma aquí.

### Causas y reproducción

**Panel:** `Scaffold.body`/`LayoutBuilder` ofrecían el viewport completo al `Stack`.
Su `Positioned(bottom: 32)` usaba un margen visual y no reservaba la navegación
Android. `Scaffold` no sustituye a `SafeArea` para esa composición.

**Atribución:** era el último hijo de una `Column` mapa+texto dentro del mismo
`Stack`, sin protección inferior. Además, la capa de lista podía ocupar su área.
Su problema no se corrige únicamente desplazando el panel.

La regresión con 360×800 e inset inferior de 48 dp falla en el baseline:
atribución termina en y=797 frente al límite seguro y=752. Se conservó una captura
renderer anterior con las mismas métricas. Antes de la corrección se ajustó el
harness de `path_provider`; ese error de plugin de test no es un defecto del APK.

### Corrección de presentación

- Atribución estática en el footer de `Scaffold`, protegida por `SafeArea`;
  el cuerpo se dimensiona por encima de ella y de la reserva inferior Android.
- `_ExplorationLayout` consume los insets laterales y conserva el mapa al borde
  superior; los grupos de acciones mantienen su `SafeArea` superior existente.
- Panel y lista se disponen dentro de ese viewport útil, sin tocar callbacks,
  controladores, filtros, cámara, snapshots ni sesiones.
- El límite proporcional vertical del panel en retrato pasa de 0.32 a 0.36 para
  conservar la tarjeta normal completa tras reservar footer/insets. En pantallas
  pequeñas o texto grande mantiene scroll; no se impone una altura del HONOR.
- No hay offset fijo de 34 px ni valores particulares de un dispositivo.
- `viewInsets` de teclado conserva el comportamiento de `Scaffold` y del filtro
  local; los tests existentes de teclado y orientación se ejecutan con la suite.
- La rama de Driving queda fuera de este wrapper y conserva su implementación.

### Trazabilidad de regresiones

| Contrato/hallazgo | Presentación | Evidencia automatizada |
| --- | --- | --- |
| UI231-L01, UI2-AC-01/12/13 | `_ExplorationLayout`, panel | `ui231_system_insets_test`: 4 viewports × 2 escalas × 3 insets inferiores |
| Atribución y mapa | footer, `FlutterMap` | Límites seguros, semántica de atribución, ruta/POI presentes, mapa/lista sin superposición |
| Acciones del panel | botones existentes | Acciones alcanzables mediante scroll y hit test, fuera de reserva inferior |
| UI2-AC-06/14 e I01 | Preview/Detail/selección | Suite existente de Discovery e I01, sin cambiar selección |
| P9/B1/R01/C2 | árbol y servicios conservados | Suite completa de offline, GPS, Driving y CEFI |

Métricas simuladas: 360×640, 360×800, 640×360, 800×360; texto 1.0/2.0;
insets inferiores 0/24/48 dp y laterales 24 dp en horizontal. Representan geometría
sin reserva, gestos y una barra mayor de tres botones; no emulan la UI Android.
La prueba verifica también que la tarjeta normal 360×800 no quede recortada.

[Comparación renderer antes/después](UI-2.3.1-Renderer-Evidence/README.md).
Los PNG previos UI-2/UI23/UI23R se conservan intactos. Las capturas nuevas usan
fixtures sintéticos solo en tests; no verifican tiles ni hardware ni TalkBack.

## UI231-A01 — Idioma y TalkBack

### Observación y datos

`OWNER_OBSERVED`: navegación y Preview/Detail operativos sin mayores problemas;
detalle de POI leído en inglés y otras indicaciones en español. TalkBack fue
restaurado y su desactivación confirmada en la sesión anterior. No se accede al
teléfono ni se cambia ningún ajuste durante UI-2.3.1.

- Seed `backend/src/main/resources/data/p3/lima-obrajillo-v1.json`: los cinco
  nombres y descripciones curatoriales están en español.
- La procedencia conserva URLs, nombres propios y la atribución original
  `OpenStreetMap contributors` en inglés. No se sabe si el reporte físico se
  refería a esas cadenas, al contenido principal o a su pronunciación.
- Fixtures de experiencia UI: nombres/descripciones sintéticos en español.
  Algunos tests de mapper usan `Museum`/`Facts`: son pruebas de transporte de
  texto, no contenido de producción.
- Consulta pública a `POST /api/v1/routes/discover`, con coordenadas públicas del
  corredor Lima–Obrajillo: cinco nombres en español y descripción no disponible
  (ausente/nula al consultar el campo) en la
  respuesta observada. Es una consulta actual, no reconstruye el snapshot físico
  anterior. No hubo modificación de backend ni acceso a DB.
- `RouteDiscoveryResponseMapper` conserva nombre y descripción, solo recorta
  espacios opcionales; `SnapshotCodec` conserva el contenido. No hay traducción.
- `PoiPreviewSheet`/`PoiDetailSheet` muestran nombre/descripción originales;
  etiquetas de categoría, distancia, procedencia y acciones propias en español.

### Localización y semántica

`GeoGuideApp` utiliza `MaterialApp` sin locale/delegates personalizados, con
`supportedLocales` predeterminado `en_US`. La prueba con locale de plataforma
simulado `es_PE` confirma `Localizations.localeOf` igual a `en_US` en Preview.
El nodo semántico inspeccionado conserva la descripción española y no declara un
locale por texto (`locale=null`). App locale, texto presentado y voz seleccionada
por TalkBack/TTS son evidencias distintas.

Las pruebas nuevas comprueban preservación de acentos y de contenido en ambos
idiomas, etiquetas españolas de Preview, acceso a Detail y descripción sin cambios.
Un renderer no prueba qué idioma/voz usa TalkBack al pronunciar esos nodos.

**Causa de la observación física: UNCONFIRMED.** La configuración por defecto de
Flutter y la heurística/configuración del lector son hipótesis; no se demuestra
que el contenido vivo de esa sesión fuese inglés ni que una propiedad Flutter
forzase esa lectura. Se difiere la remediación; no se traduce contenido, no se
fuerza un idioma semántico sobre texto de lengua desconocida y no se añaden
dependencias o ajustes globales. Una localización completa de controles Material
necesita evaluar su alcance y recursos antes de autorizarla.

## Archivos y validación

Producción: únicamente [base_map_page.dart](../../../mobile/lib/features/map/presentation/base_map_page.dart).
Tests nuevos: [layout e insets](../../../mobile/test/features/map/ui231_system_insets_test.dart)
y [contenido, semántica y localización](../../../mobile/test/features/discovery/ui231_poi_language_test.dart).
Documentación: este registro, índice y tres PNG renderer nuevos.

| Comprobación | Resultado |
| --- | --- |
| `dart format --output=none --set-exit-if-changed .` en `mobile/` | PASS, 85 archivos, cero cambios |
| `flutter analyze --no-pub` | PASS, cero issues; ejecución final 21.1 s |
| `flutter test --no-pub --reporter expanded --dart-define=UI231_CAPTURE_LABEL=after` | PASS, 228 pruebas (202 previas + 26 nuevas), 3 min 2 s de ejecución de casos |
| Layout e idioma focalizados | PASS, 26 pruebas; posteriormente se reforzó visibilidad de POI/geometría sin modificar producción |
| Layout final reforzado | PASS, 24 combinaciones; todas mantienen POI/mapa/ruta, acciones alcanzables y límites seguros |
| UTF-8 y enlaces Markdown nuevos | PASS, decodificación estricta y destinos locales existentes |
| PNG nuevos | PASS, 3 archivos abiertos y dimensiones verificadas; comparación equivalente 360×800 revisada |
| `git diff --check` | PASS |

Los warnings de tiles del binding de Flutter no validan ni invalidan cartografía
de red: los tests bloquean HTTP de tiles. No se ejecutaron pruebas backend porque
no se modificó ese módulo. `flutter pub get --offline` preparó el worktree sin
cambiar `pubspec.yaml` ni `pubspec.lock`.

Builds con `--no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`:

| APK | Resultado | Bytes | SHA-256 |
| --- | --- | --- | --- |
| Debug | PASS | 167843077 | `751b0e647d837f651b932e85299c25a7ffc5a67a077744327b713c8301ffded6` |
| Release | PASS | 60472029 | `5402633afd7c24628b700648d16333f2334208bb4cf7b41557f89abad12e29d3` |

`verify_apk_icons.py` en debug y release: PASS, MaterialIcons válido (1645184 y
4112 bytes respectivamente, este último reducido por tree shaking) y manifiestos presentes.
Auditoría ZIP en ambos APK: endpoint esperado presente; única imagen Flutter, el logo
preexistente de `flutter_map`; sin fotografías piloto ni marcadores `TEST_ONLY`,
`synthetic-1`, `synthetic-2` o `Museo Ámbar` en assets o `libapp.so`.

Los builds emitieron advertencias no bloqueantes de acceso nativo JDK, versiones
XML del SDK y source/target Java 8 de plugins. No se modificó el toolchain.
Los hashes nuevos corresponden a esta compilación, no al APK UI-2.3 anterior.
Son artefactos de validación local; no declaran distribución ni readiness.
Duración Gradle observada: debug 545.4 s; release 399.2 s. Los APK permanecen en
`mobile/build/app/outputs/flutter-apk/`, ignorados por Git. Logs locales conservados
fuera del repositorio; no se versiona el registro privado ni información del dispositivo.

Auditoría del alcance: solo el widget de exploración, dos tests nuevos y la nueva
evidencia/renderer. No se modificaron backend, DTO, DB, permisos, dependencias,
contratos congelados, assets previos ni servicios. El SHA-256 del registro físico
privado sigue intacto y el checkout principal mantiene sus tres borradores UI-0.

## Segunda comprobación física propuesta

Requiere autorización separada y APK nuevo verificado; no se ejecuta ahora.

1. En una ruta pública estacionaria, confirmar panel y atribución visibles fuera
   de navegación Android, con lista cerrada/abierta y orientación pertinente
   (UI2-PHY-04/05/06/30, solo sus aspectos afectados).
2. En un POI concreto, comparar el texto visible de Preview/Detail con lo leído
   por TalkBack y distinguir frases del sistema y contenido (UI2-PHY-27/28).
   Registrar el caso y sus campos públicos, sin cambiar el idioma global.
3. Completar únicamente subcasos UI-2.2 aún no observados que se autoricen:
   filtros/teclado/recuperación/targets y regresión estacionaria. No trasladar
   resultados automatizados a PASS físico ni repetir los 36 casos sin necesidad.

La esfera/ondas oficiales de CEFI continúa como deuda visual aceptada. Fotografías
piloto, integración de medios y cierre maestro UI-2 siguen pendientes y sin
autorización. Permisos, GPS, Driving, CEFI, contratos, datos y dependencias se preservan.

## Resultado de checkpoint

```ini
UI_2_3_1_LAYOUT_ROOT_CAUSE = CONFIRMED
UI_2_3_1_LAYOUT_REMEDIATION = PASS
UI231_A01_ROOT_CAUSE = UNCONFIRMED
UI_2_3_1_POI_LANGUAGE_ROOT_CAUSE = UNCONFIRMED
UI_2_3_1_POI_LANGUAGE_REMEDIATION = DEFERRED
UI_2_3_1_AUTOMATED_VALIDATION = PASS
UI_2_3_1_LOCAL_COMMIT = PASS
UI_2_3_1_PUSH = NOT_AUTHORIZED
UI_2_3_1_PR = NOT_AUTHORIZED
UI_2_3_1_MERGE = NOT_AUTHORIZED
UI_2_3_1_PHYSICAL_INSTALLATION = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

Recomendación: revisión de la corrección de layout y de la clasificación A01;
integración y segunda sesión física permanecen sujetas a autorización posterior.

## Reconciliación post-merge — 2026-10-18

El estado anterior conserva el alcance de la ejecución local. La autorización
humana posterior aprobó integración, revisión y merge normal, además de preparar
la segunda sesión; no autorizó ejecutarla. Este registro complementa la evidencia
sin reescribir contratos ni convertir las limitaciones físicas en PASS.

### Integración funcional verificada

- Auditoría pre-PR: `PASS / READY_FOR_INTEGRATION_WITH_DOCUMENTED_LIMITATION`.
- [PR #90](https://github.com/ccenteno2207/GeoGuide-AI/pull/90): `MERGED`.
- Baseline anterior: `0b249514b99fdc4f2753d6dc8005516d8287bf93`.
- HEAD funcional: `e1a9eb9ef12f36279a8f9e058c92098d94b5c976`.
- Merge técnico: `37d5ef23136610e896ad1ac000fdda2f1774c1e5`.
- Dos padres: `0b249514b99fdc4f2753d6dc8005516d8287bf93` y
  `e1a9eb9ef12f36279a8f9e058c92098d94b5c976`; ascendencia comprobada.
- Fecha remota de integración: 2026-10-18T23:50:40Z.
- El árbol del merge es idéntico al HEAD auditado; `origin/main` actualizado
  mediante fetch, sin sincronizar ni modificar el checkout principal.
- Los ocho blobs del PR coinciden con los archivos del commit local revisado.
  No hubo cambio funcional adicional ni conflicto de integración.
- Checks GitHub: `NOT_CONFIGURED`, cero check-runs y cero estados de commit,
  sin workflows versionados ni reglas de rama aplicables detectadas. El estado
  agregado de commit `pending` con cero contextos no representa una ejecución CI.
- Revisiones externas GitHub: ninguna registrada. Auditoría local ejecutada y
  autorización humana expresas; no se atribuye una aprobación GitHub inexistente.
- Merge realizado por el mecanismo normal de GitHub, sin squash/rebase,
  force push, bypass de controles ni borrado de ramas.

### Evidencia reutilizada y controles de esta integración

La implementación no cambió desde el commit validado. Se reutilizan formato,
analyze, 228 pruebas, regresión final de 24 combinaciones y ambos builds descritos
arriba. No se repitieron builds ni se afirma una suite post-merge nueva.
La verificación post-merge es de Git/alcance/evidencia y equivalencia de árboles.

En esta ejecución se revalidaron los hashes reales de ambos APK y se repitió
la auditoría ZIP de endpoint/assets/marcadores: `PASS`. Se comprobaron diff,
enlaces/UTF-8 de documentación y la ausencia de registros privados en el PR.

La preservación se controla contra un inventario local previo de 22 worktrees,
12 archivos pendientes, stashes y SHA-256 de pendientes/registro privado. El
checkout principal mantiene su HEAD y los tres borradores UI-0 sin seguimiento;
solo se añadió el worktree documental bajo el directorio oficial. La comparación
final y el SHA del merge documental se entregan en el reporte de esta ejecución.
No se incorpora el inventario privado al repositorio.

### Segunda sesión preparada

El [procedimiento focalizado](UI-2.3.1-Second-Physical-Validation-Protocol.md)
identifica el APK debug y hash, los gates de autorización, los aspectos L01,
la comparación precisa texto/voz A01 y las regresiones/casos UI-2.2 seleccionados.
No se ejecutó ADB, instalación, TalkBack ni acceso al HONOR en esta tarea.
La esfera/ondas CEFI, fotografías, casos físicos restantes y cierre UI-2 conservan
sus pendientes; no se amplió el alcance.

```ini
UI_2_3_1_PRE_PR_AUDIT = PASS
UI_2_3_1_PR = MERGED
UI_2_3_1_INTEGRATION = PASS
UI_2_3_1_GITHUB_CHECKS = NOT_CONFIGURED
UI_2_3_1_LAYOUT_AUTOMATED = PASS
UI_2_3_1_LAYOUT_PHYSICAL = NOT_EXECUTED
UI_2_3_1_TALKBACK_ROOT_CAUSE = UNCONFIRMED
UI_2_3_1_TALKBACK_REMEDIATION = DEFERRED
UI_2_3_1_SECOND_PHYSICAL_SESSION = PREPARED
UI_2_3_1_PHYSICAL_INSTALLATION = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```
