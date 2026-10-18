# UI-2.3 — Convergencia visual y evidencia del inventario fotográfico

**Baseline:** `db29b127aa6b2eff1942c37276f88421de0b8323` (`origin/main` verificado al iniciar).
**Rama/worktree:** `codex/ui2-3-visual-convergence` — `D:\Codex\worktrees\GeoGuide-AI\ui2-3-visual-convergence`.
**Estatus:** evidencia de implementación y validación local; no equivale a integración ni validación física.

## Reconciliación visual y cambios

Esta tabla conserva el registro de la primera iteración UI23; la remediación visual final y sus APK se documentan más abajo como UI23R.

| Elemento actual | Dirección UI-1/UI-2 aprobada | Componente | Acción | Evidencia |
| --- | --- | --- | --- | --- |
| Título grande y banda dominante de seis iconos | Mapa protagonista, controles flotantes compactos | `mobile/lib/features/map/presentation/base_map_page.dart` | Retirar título de Explorer; reagrupar acciones preexistentes en panel flotante compacto | Capturas UI-2.3 `map-route`, `list`; tests `exploration_shell_test`, `widget_test` |
| Panel con coordenadas y texto técnico | Estado breve y accionable | `base_map_page.dart` | Mostrar distancia/duración planificadas y cantidad de resultados; conservar estado y acciones | `offline_ui_test`, capturas renderer |
| Control de voz ambiguo | Avisos existentes con identidad CEFI y etiqueta factual | `base_map_page.dart` | Control compacto violeta “Avisos de CEFI”, icono de ondas; mismo callback/consentimiento y tooltips accesibles | `b1_widget_test`, CEFI sin cambios funcionales |
| Marcadores de ruta/POI poco jerárquicos | Extremos legibles y POIs visibles | `base_map_page.dart` | Actualizar presentación de marcadores; no alterar selección ni geometría | capturas `map-route`; regresión de mapa/ruta |
| Placeholders amplios y bloques de tarjeta | Placeholder estable que no domina la ficha | `mobile/lib/features/discovery/presentation/poi_thumbnail.dart`, `poi_result_card.dart`, `poi_preview_sheet.dart`, `poi_detail_sheet.dart` | Área de tarjeta 72×54 dp; placeholder de ficha 160×90 dp; mejorar jerarquía de categoría y texto | `poi_visual_contract_test`, preview/detail y capturas |
| Vista, lista, filtro local, preview/detail | Conservar búsqueda local, orden, procedencia, selección I01 y estados existentes | componentes de Discovery/mapa | Solo presentación; sin fotos, geocodificación, DTO ni llamadas nuevas | suite UI-2, offline y selección I01 |
| Atribución cartográfica | Atribución visible | `base_map_page.dart` | Texto compacto “© OpenStreetMap contributors” | captura map y revisión semántica |

La geometría de ruta se conserva estática salvo el encuadre inicial previsto por el comportamiento actual. No se agregó seguimiento de cámara ni navegación giro a giro. El estado reducido Driving y los callbacks GPS/voz conservan sus implementaciones.

## CEFI

El control visual usa el color violeta aprobado y mantiene `_toggleVoiceConsent`; no activa conversación, escucha, micrófono ni permisos. La etiqueta funcional accesible es **«Avisos de CEFI»**, porque describe el único control operativo existente. En la remediación final se presenta como botón circular con tooltip de activar/desactivar avisos; la esfera luminosa/ondas exacta requiere un recurso oficial aún ausente. **«Habla con CEFI»** permanece reservado para la capacidad conversacional futura. La entrada de avisos sigue su consentimiento, guards y lifecycle previos.

## Evidencia de renderizado

Las capturas `FLUTTER_RENDERER_TEST_UI23-*.png` se generan con Flutter Widget Test, `RepaintBoundary` y fixtures sintéticos. Sirven para comparar composición y tamaños en renderer. No verifican tiles en red, ejecución APK ni dispositivo físico. Las capturas originales UI-2 se conservan intactas.

[Índice de evidencia visual UI-2.3](UI-2.3-Visual-Evidence/README.md)

## Inventario candidato de imágenes

Ruta examinada: `D:\Proyectos\Desarrollo\Ruteo\Imagenes`. Se leyeron nombres, bytes, dimensiones del encabezado PNG y SHA-256; no se inspeccionó visualmente el contenido, ni se copiaron archivos al repositorio, APK, MinIO o servidor. La posible asociación se deriva únicamente del nombre y queda pendiente confirmación del propietario. Formato compatible técnicamente (PNG); no se hallaron nombres duplicados exactos ni hashes duplicados.

| POI piloto candidato | Archivo | Dimensiones | Bytes | SHA-256 | Procedencia/derechos |
| --- | --- | ---: | ---: | --- | --- |
| Iglesia San Juan Bautista de Obrajillo | `Iglesia San juan Bautista de obrajillo.png` | 584×434 | 559067 | `14742670885d8f782ca2013908abedfa365fb29f249b5f83886c9cca58e4f875` | `PENDING_OWNER_CONFIRMATION` |
| Petroglifos de Checta | `petroglifos de checta.png` | 1348×569 | 1782463 | `3b2940f2ad8ec60f0cf877f74f82dc3e307e8843250af4e55140ed6dcdab74be` | `PENDING_OWNER_CONFIRMATION` |
| Plaza de Armas de Canta | `Plaza de armas de canta.png` | 1037×635 | 1495827 | `b09d081fda65691a1d4ba0ea528b6eb875dfb2145f28846c3adf7ac31d955858` | `PENDING_OWNER_CONFIRMATION` |
| Plaza de Armas de Obrajillo | `Plaza de Armas de obrajillo.png` | 1063×740 | 1937791 | `d8ba0829948f38cb0dcdad5520f2059387614d94c0d07311b424db20db01ff16` | `PENDING_OWNER_CONFIRMATION` |
| Santuario de Santa Rosa de Quives | `Santa rosa de quives.png` | 1020×598 | 1247218 | `0ee69a45559a9e4a715f7b4193930eafb79145d277a18d8543d57e4dc592c5` | `PENDING_OWNER_CONFIRMATION` |

Los nombres sugieren cinco posibles coincidencias con los POI de prueba, pero no prueban que el archivo represente el lugar ni que se permita su uso. La futura estrategia recomendada es un catálogo de pruebas separado y no versionado que requiera registro explícito de POI, autor/fuente, licencia, atribución y autorización antes de usar cada archivo. No se integró ninguna foto.

## Validación y límites

- `dart format`: ejecutado en `mobile`; formateó `base_map_page.dart` y `poi_visual_contract_test.dart`. `dart format --output=none --set-exit-if-changed .` pasó después sin cambios.
- `flutter analyze --no-pub`: PASS, sin issues.
- `flutter test --no-pub --reporter expanded --dart-define=UI23_CAPTURE=true`: PASS, 202 pruebas; generó 19 capturas.
- `flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`: PASS; 167840957 bytes; SHA-256 `7f7247214152bbfbed83f6a19b3e0dcc392c012afa4b9c180f3d89267b216d5d`.
- `flutter build apk --release --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`: PASS; 60472029 bytes; SHA-256 `0a686f3905b0760268d64796f30aaa758acc5e4442f9cc8b945cd64786a6bd9e`.
- `verify_apk_icons.py` en ambos APK: PASS. El único PNG de `assets/flutter_assets` es el logo preexistente de `flutter_map`; no hay fotos piloto ni marcadores de fixtures `TEST_ONLY`/`synthetic-`. Recursos Android del sistema/plugin y launcher permanecen.
- Regresión de Preview/Detail, I01, filtros, offline/caducidad, mapa, ruta y B1: cubierta por las 202 pruebas Flutter.
- Accesibilidad automatizada: guías Flutter de tap target, etiquetas y contraste en tests pertinentes; suite responsive cubre 360×640, 360×800, 640×360 y 800×360 con escala 1.0/2.0; revisión física con lector de pantalla pendiente.
- Dispositivo HONOR: el propietario reportó que el APK previamente instalado calcula ruta y muestra cinco POI después de reiniciar la VM. Esta compilación UI-2.3 no se instaló; su validación física permanece pendiente.
- La prueba renderer no representa una sesión real ni una respuesta backend. El binding bloqueó tiles HTTP con respuestas 400; no se interpreta como fallo de la VM. No se afirma validación física ni de producción.

## Remediación visual final solicitada tras revisar las 19 capturas UI23

Las observaciones R01–R04 se evaluaron sobre las capturas UI23 anteriores. La nueva evidencia está en el [índice comparativo UI23R](UI-2.3-Remediation-Visual-Evidence/README.md); se conserva íntegra la serie UI23 original. Los cambios siguientes solo afectan presentación y pruebas Flutter.

| Observación | Antes UI23 | Después UI23R | Veredicto |
| --- | --- | --- | --- |
| R01 controles superiores | Una pastilla blanca de dos filas con seis acciones en debug. | Dos grupos flotantes de hasta 144 dp: acciones contextuales de diagnóstico/recorrido/copia a la izquierda y CEFI/ubicación/seguimiento a la derecha. Cada IconButton conserva al menos 48 dp; el grupo primario mide 48 dp de alto en el estado normal. | `PASS` |
| R02 panel inferior | Cuatro botones apilados, mensajes redundantes y resumen oculto por scroll en 360×800. | Etiquetas visuales breves «Categorías» y «Conducción», con el estado completo en tooltip; las cuatro acciones caben en dos filas con fuentes reales. El resumen factual de distancia/duración/POI es de una línea. Se suprime el estado de Discovery repetido cuando ya se muestra la disponibilidad de la copia, sin eliminar error ni «Reintentar». En la captura 360×800, la tarjeta mide 208 dp y el resumen es visible. | `PASS` |
| R03 identidad CEFI | Pastilla violeta con texto «Avisos de CEFI» e icono de voz. | Control circular violeta de 48 dp, etiqueta accesible «Avisos de CEFI» y tooltip según consentimiento; se mantiene `_toggleVoiceConsent`. No hay recurso oficial de esfera luminosa/ondas en el repositorio, por lo que no se representa aún esa ilustración exacta. | `PARTIAL` |
| R04 POI y fichas | Placeholders compactos existentes. | Preview, Detail, lista, búsqueda local, nombres/descripciones largos, procedencia, distancia al trazado y selección explícita I01 verificados con fixtures sintéticos y matriz 360×640, 360×800, 640×360, 800×360 a texto 1.0/2.0. No se integraron fotografías. | `PASS` |

La pantalla muestra «Categorías» y «Conducción» para reducir anchura; sus tooltips mantienen «Categorías: N categorías» y «Entrar en modo conducción». Los controles normales GPS, offline, ubicación y seguimiento mantienen los callbacks, guardas y estados de habilitación anteriores. El control de avisos CEFI no incorpora STT, conversación, micrófono ni activación automática. Las capturas de renderer comprueban composición, no lector de pantalla ni dispositivo físico. `APK_BUILD` y `PHYSICAL_DEVICE` deben distinguirse expresamente de `FLUTTER_RENDERER_TEST_UI23R`.

La limitación visual pendiente es obtener e integrar el recurso oficial de esfera luminosa/ondas de CEFI bajo autorización de diseño; no se creó una identidad alternativa. La validación física de este APK y la revisión con lector de pantalla siguen pendientes.

### Validación de la remediación UI23R

- `dart format --output=none --set-exit-if-changed .`: PASS, 83 archivos comprobados sin cambios.
- `flutter analyze --no-pub`: PASS, sin issues.
- `flutter test --no-pub --dart-define=UI23_REMEDIATION_CAPTURE=true --reporter expanded`: PASS, 202 pruebas. La suite generó 19 PNG `FLUTTER_RENDERER_TEST_UI23R`; los 19 PNG UI23 previos permanecen intactos. Los PNG nuevos abren correctamente y sus enlaces relativos se comprobaron.
- Matriz automatizada de cuatro viewports y escalas de texto 1.0/2.0, mapa/ruta, lista, filtro local, Preview/Detail, offline/error, I01, GPS, Driving reducido y avisos CEFI: PASS. La revisión visual de las capturas confirma el estado compacto y la atribución OpenStreetMap visible; las pruebas del renderer no sustituyen validación física ni lector de pantalla.
- `flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`: PASS, 167840957 bytes; SHA-256 `c6121a6244eab9a55837d81d9afd6e02a5ee7214d7a0ac346f9af4423568da0a`.
- `flutter build apk --release --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`: PASS, 60472029 bytes; SHA-256 `1e3beb2f04022f33866b3b4197c952f404ae20cec0a04062ea3432948cd6d3fb`.
- `verify_apk_icons.py` en ambos APK: PASS. El único PNG de `assets/flutter_assets` sigue siendo el logo preexistente de `flutter_map`; no hay fotografías piloto ni nombres de fixtures `synthetic-`/`TEST_ONLY`.
- `git diff --check`, UTF-8 de los documentos y enlaces Markdown: PASS. Los cinco PNG del inventario externo conservan los SHA-256 registrados arriba; no se copiaron al repositorio ni se empaquetaron en los APK.

```ini
UI_2_3_R01_TOP_CONTROLS = PASS
UI_2_3_R02_BOTTOM_PANEL = PASS
UI_2_3_R03_CEFI_IDENTITY = PARTIAL
UI_2_3_R04_POI_COMPOSITION = PASS
UI_2_3_AUTOMATED_VALIDATION = PASS
UI_2_3_VISUAL_REFINEMENT = PARTIAL
UI_2_3_PHOTO_INVENTORY = PASS
UI_2_3_PHOTO_APK_INTEGRATION = NOT_AUTHORIZED
UI_2_3_PHOTO_PUBLICATION = NOT_AUTHORIZED
UI_2_3_PUSH = NOT_AUTHORIZED
UI_2_3_PR = NOT_AUTHORIZED
UI_2_3_MERGE = NOT_AUTHORIZED
UI_2_3_PHYSICAL_INSTALLATION = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```

## Alcance preservado y pendientes

No se modificaron contratos congelados, backend/API/DTO/DB, dependencias, permisos, GPS, Driving funcional ni recursos fotográficos. No hubo push, PR, merge, instalación ni publicación. La incidencia del servidor de la VM se considera resuelta conforme a la verificación y prueba reportadas por el propietario.

Pendiente para integración: autorización de procedencia/derechos antes de usar cualquiera de las cinco imágenes; instalación y validación física de este APK UI-2.3 en HONOR; lector de pantalla; integración remota en una fase autorizada.
