# POI-CATALOG-1 — Discovery y propuesta de implementación

**Estado:** `READY_FOR_APPROVAL` — propuesta; no autoriza implementación funcional
**Baseline revisado:** `origin/main` `7b7fb9c9aec8efe4076a048fb224e4ec92681155` (PR #112 integrado)
**Fecha:** 2026-11-18

## 1. Propósito y gobierno

Definir una expansión controlada del catálogo turístico MINCETUR y su flujo de revisión para que recursos elegibles puedan publicarse, por decisión editorial, como destinos buscables, POIs descubribles en ruta o ambos. Esta propuesta reúne los hallazgos de POI-DATA-1, ADMIN-1 y POI-MEDIA-1 y especifica las decisiones necesarias para una implementación posterior.

Este documento no congela una fase ni autoriza código, migraciones, publicación, despliegue o integración. La aprobación humana de esta propuesta deberá identificar su revisión exacta antes de iniciar implementación. No modifica retrospectivamente P8, P9, UI2-SEARCH-001, V006/V007 ni la evidencia histórica. `P12_5`, cierre maestro UI-2 y Production Readiness permanecen fuera de alcance.

## 2. Baseline y hechos comprobados

El merge de MASTER IMPLEMENTATION v2 es PR #112. En la rama de descubrimiento, `origin/main` estaba en `7b7fb9c9aec8efe4076a048fb224e4ec92681155`. La evidencia integrada registra V001–V007, staging MINCETUR, revisión editorial con seguridad configurable, integración de medios privados y portal. La validación de integración se realizó en un entorno temporal aislado; no fue una importación al catálogo operativo ni un despliegue.

### 2.1 Flujo y dominios actuales

| Capacidad | Hecho verificado | Consecuencia para POI-CATALOG-1 |
|---|---|---|
| Búsqueda de destino | `POST /api/v1/destinations/search` lee `geo.destination`; normaliza acentos/caso; devuelve nombre, tipo, contexto, coordenadas y procedencia. El contrato UI2-SEARCH-001 conserva consulta explícita o sugerencias autorizadas contra este catálogo y no es geocodificación general. | Para que un recurso sea destino buscable necesita una fila `geo.destination` aprobada. No cambiar la semántica del endpoint ni tratar el staging como fuente pública. |
| Planificación de ruta | `PlanRoute` toma coordenadas de origen y destino y utiliza GraphHopper mediante la abstracción vigente. GraphHopper calcula la ruta; no resuelve nombres. | La calidad del punto de destino y su acceso vial requieren revisión propia; una coordenada numéricamente válida no demuestra que sea un acceso utilizable. |
| Route Discovery | `POST /api/v1/routes/discover` planifica y busca `geo.point_of_interest` activo dentro del corredor PostGIS, aplicando categorías y ordenamiento existentes. No consulta `geo.destination`. | Solo POIs revisados y publicados en el dominio POI participan. La importación o publicación de un destino no lo habilita para Discovery. |
| Staging MINCETUR | V006 conserva raw, hash/corte, normalización/regla/evidencia y estado; no crea geometría ni escribe en destino/POI. Reimportación se identifica por snapshot/hash y parser. | Mantener staging separado y append/evidence-aware; no promover automáticamente candidatos. |
| Revisión y publicación | V007 y ADMIN-1 mantienen borrador, revisión geográfica, revisión de identidad/duplicados, auditoría y versión. La publicación explícita crea un POI con provenance; no reemplaza destinos o POIs existentes. | Se requiere una acción editorial separada para crear un destino buscable o una relación verificada entre representaciones. |
| Seguridad | El acceso administrativo está denegado por defecto. Al habilitarse requiere OIDC issuer/audience configurables y roles; no hay issuer ni credenciales productivas fijados. | Preservar deny-by-default y configuración OIDC; los datos de demostración no son seguridad productiva. |
| Contrato administrativo | No se encontró un contrato normativo vigente denominado ADMIN-0. La implementación ADMIN-1 integrada por PR #112 y ADR-008 son los referentes existentes para seguridad/roles; esta propuesta define únicamente las brechas de catálogo. | No tratar una propuesta histórica de ADMIN-0 como aprobación contractual ni alterar ADR-008. |
| Medios | La gestión aprobada requiere derechos, atribución, revisión y almacenamiento privado. Las cinco imágenes del piloto local no tienen derechos públicos/comerciales acreditados. | No incluir esas fotos ni publicar un activo real sin evidencia de derechos para el uso/canal concreto. |
| Offline/Driving | El contrato P9 excluye multimedia de snapshots offline y limita cambios durante Driving. | Sin URL, bytes, descargas automáticas ni cambio de caché/Driving en este alcance. |

### 2.2 Inventario MINCETUR y procedencia

El CSV original local se trató como solo lectura: SHA-256 `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66`, 1,565,274 bytes, corte `20261110`, codificación Windows-1252, delimitador `;`, 12 encabezados y 6.341 filas. Contiene 5 categorías raíz, 35 tipos y 186 subtipos; cobertura administrativa declarada: 25 regiones, 190 provincias y 1.008 distritos. No contiene un campo que demuestre acceso vial.

La causa que deformó los separadores decimales del CSV local no está demostrada. Una comparación registro a registro con una descarga independiente posterior halló 6.331 coordenadas que pueden recuperarse como **candidatos numéricos** mediante reglas ligadas al hash exacto del snapshot; 10 filas permanecen en cuarentena. El caso 237 produce `latitude=-14.087854051458200`, `longitude=-75.76291501522060` a partir de tokens raw con puntuación múltiple. La coincidencia numérica no demuestra exactitud geográfica, y la mínima diferencia con un catálogo curado no certifica precisión de terreno. Los candidatos existentes permanecen `NORMALIZED_PENDING_REVIEW`; no están aprobados ni publicados.

El catálogo previo de nueve destinos provino de otro snapshot MINCETUR, con SHA diferente (`F66AE874…D263E`). Sus coordenadas fueron curadas/contrastadas bajo la evidencia UI2-SEARCH-001 y no se deben sustituir por los valores del CSV local. Los cinco UUID P3 conservan sus geometrías y provenance: MINCETUR aporta hechos descriptivos y OSM se usó como contraste cartográfico; el origen original de los valores numéricos de coordenadas de P3 no está documentado. El snapshot local y los nueve destinos no se consideran intercambiables.

| Fuente/registro | Identidad y contenido | Coordenada/origen | Estado y uso permitido |
|---|---|---|---|
| CSV local `20261110` | MINCETUR; 6.341 códigos | Tokens raw locales; regla recuperable solo para el hash identificado | Entrada inmutable de staging; 6.331 candidatos pendientes, 10 en cuarentena |
| Nueve destinos curados | Registros MINCETUR del snapshot anterior | Valores del catálogo curado; no reemplazables por el snapshot local | Búsqueda de destino según su estado/procedencia existente |
| Cinco POI P3 | UUID y contenido del fixture P3 | Fuente original de números no documentada; contraste OSM documentado | Conservar identidad/geometría; discrepancias requieren revisión explícita |
| Descarga MINCETUR posterior usada como contraste | Snapshot independiente posterior | Contraste de identidad/contexto y forma numérica | Evidencia de candidato, no sustituto del CSV ni prueba de campo |

### 2.3 Taxonomía

El CSV usa jerarquía propia (5/35/186). El catálogo P3 actual tiene 15 códigos: `WATERFALL`, `LAGOON`, `MOUNTAIN`, `FOREST`, `BEACH`, `MUSEUM`, `ARCHAEOLOGICAL_SITE`, `MONUMENT`, `HISTORIC_CHURCH`, `VIEWPOINT`, `FUEL`, `HEALTH`, `FOOD`, `LODGING`, `OTHER`. El mapeo MINCETUR→P3 debe ser versionado, explícito y revisable. Ningún subtipo desconocido se asigna automáticamente a `OTHER` para publicación; puede conservarse en staging hasta que una regla aprobada lo cubra.

## 3. Matriz de capacidades actuales y brechas

| Área | Existe en baseline | Brecha para catálogo ampliado | Tratamiento propuesto |
|---|---|---|---|
| Snapshot/ingesta | Parser, manifiesto exacto y V006 staging | Snapshot nuevo, corte distinto, actualización y revisión de diferencias | Inmutabilidad por hash/corte/parser; nuevo lote nunca altera el lote anterior |
| Calidad geográfica | Raw, candidato, regla/evidencia, cuarentena y controles de plausibilidad | Aprobación por registro y evidencia de contexto/ubicación accesible a editor/revisor | Cola asistida; todas las decisiones de publicación geográfica humanas y auditadas |
| Identidad/duplicados | ADMIN compara IDs/nombres y coincidencias existentes; flujo identidad evita publicación sin revisión | Reconciliación explícita entre `destination`, POI y nueva fuente sin deducir identidad por nombre | Revisión con candidatos de duplicado; decisión y vínculo explícitos, no merge automático |
| Destinos | Catálogo `geo.destination`, API y alias de fuente verificada | Publicación administrativa de nuevos destinos y protección explícita de coordenadas existentes | Crear destino separado solo con aprobación de destino y punto de llegada/accesso revisado |
| POIs | `geo.point_of_interest`, provenance, categorías y Route Discovery | Elegibilidad ampliada para los nuevos datos | Crear POI por flujo editorial aprobado, sin reemplazar P3 |
| Vínculo cross-domain | No hay reconciliación automática/modelo persistente conocido | Registrar que destino y POI representan el mismo recurso o relación aprobada | Tabla asociativa propuesta en §4; no compartir/coaccionar geometrías |
| Portal | Importaciones, borradores, cuarentena, revisiones, publicación, duplicados/medios | Vista asistida para regla, mapa/contexto y decisiones de destino/POI/link | Extender el portal actual; sin usuarios/issuer productivos incorporados |
| Multimedia | Pipeline de metadatos/derechos y almacenamiento privado | Derechos por foto real y canal todavía pendientes | Solo fixtures sintéticos hasta tener autorización y derechos registrados |
| Cliente/offline | Búsqueda, fichas, Discovery, caché y Driving existentes | Mostrar solo contenido publicado y derechos permitidos | Sin cambio Flutter necesario si las APIs y modelos actuales bastan; cualquier cambio API/UI se prueba aparte |

## 4. Política de revisión asistida MINCETUR

### 4.1 Principios y procedencia

1. Cada lote se identifica por archivo, SHA-256, corte declarado, codificación, delimitador, encabezados y versión de parser. El CSV recibido es inmutable y se guarda una referencia de procedencia, no una copia mutable.
2. Cada fila retiene campos raw, código oficial, texto de categorías, URL y fecha de corte; retiene aparte candidato de coordenadas, regla exacta aplicada, versión y evidencia/contraste.
3. El normalizador de coordenadas solo puede ejecutarse contra el manifiesto del hash ya verificado. Para cualquier snapshot distinto: nueva caracterización, sin reutilizar reglas por semejanza de nombre/fecha. Coordenadas ambiguas o fuera de plausibilidad permanecen en cuarentena.
4. La recuperación de formato es una sugerencia reproducible, no una validación de ubicación ni permiso de publicación. El mapa de revisión debe mostrar candidato y contexto administrativo/fuentes, sin alterar su valor raw.
5. Toda transición editorial registra actor, instante, estado anterior/nuevo, razón, versión y referencias de evidencia. La escritura con versión obsoleta se rechaza; revisión de lote solo se permite con filtros/criterios explícitos, vista previa y audit log por registro.

### 4.2 Clasificación de cola (prioriza, no aprueba)

| Clase de revisión | Señales automáticas permitidas | Acción humana requerida |
|---|---|---|
| `FORMAT_REVIEWABLE` | Snapshot/hash exacto conocido; regla de coordenada explícita; rangos mundiales y peruanos; campos requeridos | Confirmar ubicación y evidencia cartográfica/administrativa; no basta la regla |
| `CONTEXT_REVIEW` | Nombre/código presente, coordenada plausible, región/provincia/distrito compatibles con capas/fuentes aprobadas disponibles | Revisar evidencia geográfica y corregir con razón si corresponde |
| `IDENTITY_REVIEW` | Exactitud de código fuente; nombres normalizados y contexto; comparación por proximidad como señal | Determinar nuevo/duplicado/relacionado manualmente; similitud nunca une registros |
| `CATEGORY_REVIEW` | Mapeo versionado a código P3 existente con regla explicable | Confirmar tipo turístico y categoría destino/POI aplicable |
| `ACCESS_REVIEW` | Vista de mapa, distancia a red/ruta calculada, punto objetivo y contraste | Revisar si el punto es destino/ruta accesible; CSV no prueba acceso. Diferenciar punto de recurso y punto de llegada |
| `RIGHTS_REVIEW` | Capturar URL, licencia declarada/atribución y snapshot fuente | Revisar condiciones del dataset y cualquier activo multimedia por separado |
| `QUARANTINED` | Anomalía, dato ausente, discrepancia de identidad/contexto, excepción de normalización | No publicar; reprocesar solo mediante revisión con evidencia o dejar rechazado |

Automatizaciones prohibidas: inversión global de campos, uso de `OTHER` para eludir revisión, auto-merge por nombre/distancia, elección de coordenada “más nueva” y aprobación/publicación masiva sin criterio auditado. Ningún score agregado convierte un registro en publicable.

## 5. Integración propuesta con búsqueda y rutas

### 5.1 Mantener separadas las elegibilidades

- **Destino buscable:** requiere una fila `geo.destination` con coordenada de destino/acceso revisada, procedencia/licencia atribuida y elegibilidad explícita. El endpoint `POST /api/v1/destinations/search` mantiene request/response, límites, normalización y elección explícita de UI2-SEARCH-001. No consulta staging ni se transforma en geocoder general.
- **POI de Route Discovery:** requiere `geo.point_of_interest` activo, categoría P3 válida, geometry verificada y provenance. Se descubre solo si cae en el corredor de una ruta según el comportamiento existente. Publicar un destino no lo crea como POI.
- **Ambos:** creación en ambos dominios es explícita y revisada. No copiar coordenadas de una entidad a la otra automáticamente. Un destino puede ser un acceso/llegada distinto del punto representativo del atractivo.
- **Búsqueda y luego ruta:** Flutter selecciona un resultado destination, PlanRoute usa su destino y Route Discovery continúa consultando POIs activos. La consulta de destino no garantiza que el mismo recurso aparezca como POI en la ruta; esa elegibilidad requiere publicación POI separada.
- **Sin acceso confirmado:** puede publicarse solo como POI si geografía y categoría lo satisfacen; no debe ser destino de PlanRoute hasta que el punto de llegada/accesso se haya validado. Debe quedar claro en administración por qué una fila es elegible para cada canal.

### 5.2 Relación entre dominios — propuesta a aprobar

Añadir en migración aditiva posterior (candidata V008, solo tras aprobación) una relación explícita entre `geo.destination` y `geo.point_of_interest`. Campos propuestos: UUID; `destination_id`; `poi_id`; `relationship_type` (`SAME_RESOURCE` o `RELATED_RESOURCE`); estado solo aprobado/pending según decisión del flujo; actor, fecha, razón y referencia de evidencia; timestamps/versionado si se edita. Constraints/índices deben evitar duplicados y referencias rotas. La relación declara identidad o asociación; **no** sincroniza geometrías ni habilita publicación del otro lado.

Alternativa más simple: permitir filas sin relación cruzada y no reflejar asociaciones. Recomendación: adoptar asociación revisable porque evita inferir equivalencia y permite auditar casos de mismo recurso frente a POI relacionado. Se requiere aprobación de owner de esta decisión de modelo, sus tipos de relación y si se necesita el estado pending. No modificar V005/V006/V007; la secuencia real de migración se determinará con Flyway en una fase autorizada.

### 5.3 Contratos/API

Conservar `POST /api/v1/destinations/search` y `POST /api/v1/routes/discover` sin cambios breaking. Extender la API administrativa (OpenAPI) para exponer fuentes, raw/candidato/regla/evidencia, estado de cola, revisiones, decisiones de elegibilidad de destino/POI y vínculos cruzados. Cualquier nuevo endpoint/response requiere definición OpenAPI y autorización contractual antes de implementación. Los endpoints públicos solo sirven registros publicados; staging y borradores no son accesibles anónimamente.

## 6. Piloto editorial controlado (propuesta)

### Corredor y tamaño

Iniciar con un corredor `Lima–Canta–Obrajillo`, por afinidad con el dataset P3 existente y un caso verificable de población/destinos; esto es una recomendación, no una selección autorizada. Objetivo de planificación: 20–50 registros elegibles. No es cuota: si menos registros cumplen evidencia y revisión, no se relajan los criterios. No ampliar a segundo corredor hasta revisar resultados del primero.

### Selección

Incluir únicamente filas de un snapshot identificado con: código fuente único; identidad/contexto administrativo consistentes; candidato de coordenadas no quarantined y con regla/evidencia; revisión cartográfica y contexto geográfico satisfactorios; categoría mapeada a P3 o decisión de mantener staging; duplicados investigados; derechos/atribución del dato revisados; y decisión explícita de si es destino, POI o ambos. Los cinco P3 existentes y nueve destinos curados se usan como referencias protegidas; no se sobrescriben y sus coincidencias requieren decisión humana por registro.

Para destino: comprobar en el mapa el punto objetivo y su acceso vial/entrada apropiada, y que una ruta pueda planificarse sin atribuir al CSV información de accesibilidad que no contiene. Para POI: comprobar ubicación representativa y categoría; la aceptación para Route Discovery es por geometría y corredor, no por aparición universal en cualquier ruta.

### Aprobaciones editoriales

Editor prepara propuesta; revisor confirma geografía y evidencia; una revisión de identidad confirma `NO_DUPLICATE` o documenta una relación; publicación requiere todos los campos y estados válidos. Actor, razón, evidencia y versión se registran. El rol administrador puede actuar conforme a los permisos del sistema, pero la política de doble revisión (si el mismo actor puede cumplir más de una etapa) queda como decisión de gobierno del piloto.

### Aceptación del piloto

- Cada registro piloto tiene una ficha de decisión con snapshot, código, raw/candidato, regla, evidencia geográfica, categoría, duplicados y elegibilidad por dominio.
- Ningún estado pendiente/cuarentena aparece en catálogo público, mapa/Discovery o búsqueda.
- Un caso destino aprobado aparece en búsqueda con contexto y provenance/licencia; seleccionado, se usa para PlanRoute.
- Un caso POI aprobado aparece en Route Discovery cuando su ubicación está dentro del corredor de prueba y filtros elegibles.
- Si el mismo recurso aparece como ambos, hay relación explícita aprobada y geometrías independientes documentadas.
- Reimportar mismo snapshot/parser es idempotente y no sobrescribe decisiones editoriales o coordenadas curadas.
- Registros P3 y nueve destinos protegidos conservan IDs, datos y geometrías.

## 7. Alcance contractual propuesto

### Incluye

1. Recepción versionada de snapshots MINCETUR y staging raw/candidato/cuarentena, incluyendo estadísticas y errores por lote.
2. Cola de revisión asistida de geografía, identidad, categorías y elegibilidad por dominio con trazabilidad por registro.
3. Herramientas administrativas para comparar una fila con destinos/POIs existentes y registrar decisiones sin auto-merge.
4. Flujo editorial explícito para POI publicable con geometría/categoría/provenance comprobados y, separadamente, destino buscable con punto de llegada/accesso comprobado.
5. Relación cruzada destination↔POI únicamente por aprobación; API de búsqueda/Discovery conserva contratos actuales.
6. Actualización OpenAPI y pruebas de migración/importación/seguridad/integración según cambios aprobados.
7. Presentación Flutter solo si los contratos de búsqueda, Route Discovery y media existentes requieren ajustes compatibles; no cambiar Driving ni P9.
8. Fixtures multimedia sintéticos y solo datos multimedia productivos con derechos documentados y estado de publicación aprobado.

### Excluye

- Aprobación/publicación automática de 6.331 candidatos o procesamiento como lote sin revisión auditable.
- Alterar los raw o migraciones históricas V006/V007; reemplazar geometrías P3 o destinos curados.
- Geocodificación general, direcciones postales, proveedor de búsqueda nuevo o datos OSM como sustituto de fuente numérica no demostrada.
- Modificar backend distribuido, identidad/issuer productivo, infraestructura, DNS/TLS, despliegue o bases compartidas.
- Cambios en contratos congelados P8/P9, caché offline, Driving, GPS, CEFI, TalkBack o P12.5.
- Uso/publicación de las cinco fotos del piloto local sin derechos verificables para el canal/uso; incorporar miles de imágenes a APK.
- Reclamar acceso vial, precisión de campo, cobertura nacional completa o Production Readiness sin evidencia correspondiente.

## 8. Criterios de aceptación propuestos

| ID | Criterio verificable |
|---|---|
| PC-AC-01 | Cada lote conserva archivo/snapshot SHA-256, corte, encoding, delimitador, parser y conteos; entradas raw no se reescriben. |
| PC-AC-02 | La transformación de coordenadas solo corre en snapshot/hash/regla aprobados; candidatos distintos, ambiguos o excepciones quedan en cuarentena, con raw, candidato, regla y evidencia separados. |
| PC-AC-03 | La cola muestra región/provincia/distrito, fuentes y ubicación en mapa; los candidatos se etiquetan como pendientes y no equivalen a precisión real. |
| PC-AC-04 | Búsqueda de duplicados usa ID, contexto, nombre normalizado y distancia solo como indicios; ninguna coincidencia fusiona o reemplaza automáticamente. |
| PC-AC-05 | Mapeo MINCETUR→15 categorías P3 es explícito y versionado; subtipo sin regla no se publica por fallback. |
| PC-AC-06 | Revisión geográfica e identidad guarda actor, fecha, razón, evidencia, versión y resultado auditable; conflictos de versión se rechazan. |
| PC-AC-07 | Publicación de POI requiere geometría/rango, categoría activa, provenance/licencia aplicable, revisión geográfica e identidad aprobadas; persiste transaccionalmente y añade POI sin sustituir existentes. |
| PC-AC-08 | Publicación de destino requiere decisión separada, coordenada de llegada/accesso revisada, procedencia y elegibilidad pública; solo entonces aparece en el endpoint actual de búsqueda. |
| PC-AC-09 | Route Discovery solo devuelve POIs activos elegibles y dentro del corredor; destino publicado no se convierte implícitamente en POI. |
| PC-AC-10 | Cualquier relación destination↔POI requiere revisión, razón/evidencia y no sincroniza coordenadas, estados o publicación de forma implícita. |
| PC-AC-11 | Importar el mismo snapshot/parser no crea duplicados ni borra/retrocede decisiones editoriales; snapshots nuevos se comparan, no sobrescriben campos curados sin revisión. |
| PC-AC-12 | Los cinco IDs/geométricas P3 y nueve destinos curados quedan byte/value-equivalentes en los campos protegidos, salvo datos de prueba aislados. |
| PC-AC-13 | Acceso admin permanece deny-by-default; OIDC valida issuer/audience/expiry/roles y endpoints segregan read/write/review según roles aprobados. |
| PC-AC-14 | Staging/drafts no son públicos; aprobar sin evidencia o con requisitos incompletos se rechaza; auditoría append-only resiste cambios directos por API. |
| PC-AC-15 | Licencia/provenance del dataset y metadatos de imágenes se conservan; activos no autorizados no se publican y acceso a MinIO sigue privado. |
| PC-AC-16 | Búsqueda, PlanRoute, Route Discovery y portal se validan extremo a extremo con datos sintéticos/seleccionados; estados loading/error/empty/permisos son comprobables. |
| PC-AC-17 | Snapshot P9 permanece sin URI/bytes multimedia y conserva TTL, atomicidad, consentimiento, fallback y ausencia de background sync/descarga. |
| PC-AC-18 | Formato/análisis/tests afectados, Flyway V001–V007 más nueva migración aditiva si aplica, idempotencia, OpenAPI, diff/secret scan pasan; no se usa una base compartida. |
| PC-AC-19 | Piloto editorial no presenta menos de la evidencia requerida para alcanzar 20–50 como motivo para relajar criterio; resultado real puede quedar por debajo del objetivo. |
| PC-AC-20 | La evidencia distingue pruebas locales, integración aislada, portal navegador y pruebas físicas; no declara pruebas omitidas ni validación de terreno como PASS. |

## 9. Seguridad, privacidad, licencias y riesgos

- **Coordenadas:** un candidato plausible puede señalar el recurso equivocado; mantener quarantine/review y preservar raw.
- **Identidad:** ficha MINCETUR compartida o similitud no demuestra misma entidad (ejemplo P3 Iglesia y Plaza de Obrajillo); relación explícita evita unión destructiva.
- **Acceso vial:** no consta en CSV. Para un destino, revisar punto de llegada, routing y evidencia cartográfica; no prometer accesibilidad universal.
- **Cobertura:** el JSON de búsqueda tiene nueve registros curados, no un catálogo nacional; el dataset de 6.341 filas no es publicable por volumen.
- **Seguridad:** OIDC configurable, `issuer`/audience no predefinidos, secrets sintéticos solo en prueba; deny-by-default en ambientes sin configuración válida.
- **Multimedia:** derechos de foto, fuente, autoría, atribución y canal deben probarse por activo; licencia de datos no concede derechos fotográficos. Sin fotos reales hasta evidencia.
- **API/abuso:** paginación/límites/índices para crecimiento y errores seguros; staging no debe filtrarse públicamente.
- **P9:** snapshots sin medios; red/reintentos solo según contrato actual; no cambiar semantics de cache o Driving.
- **Operación:** VALIDATION-4B/4C usó aislamiento temporal; desarrollo futuro no equivale a ejecutar en integración compartida.

## 10. Plan de implementación tras aprobación

Los pasos siguientes son una secuencia propuesta ejecutable dentro del contrato cuando esté aprobado. Cada migración se aplica únicamente en base local/aislada. No se inicia automáticamente con este documento.

| Incremento | Alcance | Gate/resultado |
|---|---|---|
| 0 — Freeze de decisiones | Aprobación de la revisión exacta y decisiones de §11; verificar árbol/remoto al inicio | Contrato congelado con decisión de vínculo, política de doble revisión y piloto |
| 1 — Snapshot/revisión | Mejorar manifiesto/estadísticas de lote y cola asistida sobre V006; pruebas completas con snapshot conocido y fixtures de excepciones | Conservación raw, idempotencia, 6.331 pending/10 quarantine sin aprobar |
| 2 — Revisión editorial | Mejorar servicios/portal para evidencia geográfica, categoría, acceso, duplicados y versionado; seguridad OIDC/RBAC | Publicar únicamente registro sintético en base aislada; auditoría verificable |
| 3 — Destino y vínculo | Migración aditiva (candidata V008) y servicio explícito para fila de destino/accesso, relación y provenance | Revisión humana independiente; API de búsqueda sigue compatible |
| 4 — Pilot editorial local | Procesar registros del corredor aprobado; obtener revisión por caso | Conteo real y motivos de exclusión, sin publicar sobre entorno operativo |
| 5 — Integración end-to-end | Búsqueda → destino → ruta → POIs de corredor; validar portal, API, Flutter y Route Discovery en stack aislado | Pruebas aisladas PASS y evidencia; no física ni despliegue |
| 6 — Medios legales (opcional) | Solo activos sintéticos o activos con derechos/canal aprobados | Private storage, publicación/retirada, cliente y snapshot P9 intactos |
| 7 — Cierre local | Regresión pertinente, diff, seguridad, documentación y propuesta GitHub | `READY_FOR_PR_REVIEW` separado de autorización de publicación/merge |

No se propone automatizar PR, merge, despliegue, importación compartida ni aprobación física.

## 11. Decisiones para aprobación humana

1. Aprobar o rechazar la revisión exacta de este contrato y, con ello, autorizar (o no) una futura fase de implementación local.
2. Confirmar el modelo de relación destination↔POI propuesto, tipos `SAME_RESOURCE` / `RELATED_RESOURCE`, y si se registran borradores de relación o solo vínculos ya revisados.
3. Confirmar política de aprobaciones separadas para piloto (geo/identity/publication) y si un actor puede desempeñar más de un rol con motivo registrado.
4. Confirmar el piloto inicial recomendado Lima–Canta–Obrajillo y el objetivo orientativo 20–50 sin cuota mínima; o especificar otro corredor.
5. Confirmar si el piloto tiene como objetivo ambos canales (destino + Route Discovery) o si los resultados pueden aceptarse en solo uno cuando falte evidencia del otro.
6. Confirmar si una publicación editorial local es solo prueba aislada o si una integración futura compartida requerirá autorización separada por registro/lote. Esta propuesta presupone aprobación separada antes de cualquier entorno operativo.

Hasta resolver esas decisiones, cualquier implementación de persistencia destination↔POI, publicación de registros MINCETUR o selección definitiva del corredor permanece no autorizada.

```ini
POI_CATALOG_1_DISCOVERY = COMPLETE
POI_CATALOG_1_CONTRACT = READY_FOR_APPROVAL
POI_CATALOG_1_IMPLEMENTATION = NOT_AUTHORIZED
MINCETUR_6_331 = NORMALIZED_PENDING_REVIEW
MINCETUR_10 = QUARANTINED
MINCETUR_PUBLICATION = NONE
DESTINATION_AND_POI_DOMAINS = SEPARATE
P3_IDENTITIES_AND_GEOMETRIES = PRESERVE
P9_OFFLINE_MEDIA = EXCLUDED
TALKBACK = NOT_TESTED
P12_5 = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

## 12. Fuentes y referencias locales

- [POI-DATA-1 staging e identidad de coordenadas](POI-DATA-1-Implementation-Evidence.md)
- [Búsqueda UI2-SEARCH-001](UI2-SEARCH-001-Destination-Search-Contract.md)
- [Fuente/cobertura del catálogo de búsqueda](UI2-SEARCH-001-Catalog-Source.md)
- [Evidencia MASTER IMPLEMENTATION v2 / VALIDATION-4B/4C](MASTER-IMPLEMENTATION-v2-Continuation-3-Evidence.md)
- [Política congelada de multimedia UI-2](UI-2-POI-Media-and-Test-Fixture-Policy-Proposal.md)
- [Contrato P9](P9-Phase-Contract-v1.md)
- [ADR-008 JWT + RBAC](../../04-SolutionArchitecture/ADR/04.3-API-Security/ADR-008-JWT-RBAC.md)
- [Arquitectura maestra Entrega 04.6](../../04-SolutionArchitecture/06-Master-Architecture/01-Master/GeoGuideAI-Master-Architecture.md)
- [Licensing Status](../../00-Executive/LICENSING-STATUS.md)
