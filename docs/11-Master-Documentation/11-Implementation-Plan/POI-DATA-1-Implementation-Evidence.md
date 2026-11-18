# POI-DATA-1 — Evidencia de staging inicial MINCETUR

**Baseline:** `0d76dcf740e3558c4b7308dbb19139a6e9a1071e`

**Rama:** `codex/master-implementation-v2`
**Estado vigente (actualización 2026-11-17):** `SNAPSHOT_COORDINATE_CANDIDATES_STAGED_PENDING_REVIEW`

## Snapshot original perfilado

Se leyó sin modificar `D:\Proyectos\Desarrollo\Ruteo\Imagenes\Inventario_recursos_turisticos.csv`.

| Propiedad | Resultado |
|---|---|
| SHA-256 | `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66` |
| Tamaño | 1,565,274 bytes |
| Corte declarado | `20261110` en las 6,341 filas |
| Codificación detectada | Windows-1252; la decodificación UTF-8 estricta falla |
| Delimitador / encabezados | `;` / 12 encabezados esperados |
| Filas de datos | 6,341 |
| Códigos duplicados | 0 grupos duplicados |
| Nombre o URL vacíos; URL no HTTP(S) | 0 / 0 / 0 |
| Categorías raíz | 5 |

La huella del archivo local no coincide con la del snapshot de catálogo previamente verificado (`F66AE874…D263E`). No se asumió que ambos archivos sean intercambiables por compartir la fecha de corte.

## Hallazgo inicial de coordenadas — 2026-11-17

Las coordenadas locales no están representadas como decimales inequívocos. Por ejemplo, MINCETUR 237 aparece literalmente como `LATITUD=-7.576.291.501.522.060` y `LONGITUD=-14.087.854.051.458.200`; ambos valores contienen varios puntos. La forma es consistente con pérdida del separador decimal más puntuación de agrupación, pero no identifica qué software o paso de exportación lo causó.

El valor curado previo para la ficha 237 (`latitude=-14.087854051458233`, `longitude=-75.76291501522064`) no se usó como única fuente para reconstruir el archivo local. El snapshot raw anterior con SHA `F66AE874…D263E` no está disponible localmente; por ello no se afirma equivalencia entre snapshots.

## Recuperación de coordenadas para el snapshot exacto

Se comparó el CSV local (corte 2026-11-10, SHA arriba) con una descarga independiente del recurso oficial actual, corte 2026-11-16, SHA-256 `6FDCFF92C3E95A7EDA0960D0FDF8E6D540F91A8579AC646164171937B90D375B` (6,349 filas). No se asumió equivalencia de snapshots. Los 6,341 códigos locales existen en el archivo actual; 6,336 coinciden también en nombre y contexto administrativo exactos.

Para ese conjunto se probó una transformación de puntuación por registro, comparando cada resultado con la fila oficial correspondiente: el valor local de `LATITUD` se normaliza como longitud insertando el decimal después de dos dígitos; el valor local de `LONGITUD` se normaliza como latitud con inserción después de uno o dos dígitos, determinada y conservada por registro en el manifiesto. Un total de 6,331 filas pasó identidad/contexto y coincidencia numérica de ambos ejes dentro de `1e-10` grados. La diferencia máxima observada fue `9.9e-14` grados para latitud y `9.0e-14` para longitud. Nueve destinos del catálogo curado anterior también coinciden con la transformación. La ficha 237 se recupera como `latitude=-14.087854051458200`, `longitude=-75.76291501522060`; la pequeña diferencia con los valores curados no demuestra precisión geodésica.

Diez filas permanecen en cuarentena: `559`, `3923`, `6871`, `6905`, `14738`, `14707`, `14737`, `11104`, `14810`, `14798`. Hay discrepancias de identidad/contexto, dígitos, valores no plausibles o coordenadas ausentes. La causa de la transformación del CSV (hoja de cálculo, exportador u otro proceso) no está demostrada. El conteo de 6,331 es recuperación de candidatos contrastados, no validación de terreno, ni autorización de publicación.

`mincetur-20261110-coordinate-recovery-v1.json` conserva SHA/corte/encoding/delimitador, una regla decimal por código y excepciones de cuarentena. El normalizador solo se aplica si el SHA-256, corte, encoding, delimitador y conteo corresponden exactamente al snapshot local; otro snapshot queda en los estados de cuarentena del parser. Las coordenadas candidatas persisten únicamente en `geo.mincetur_import_record` con estado `NORMALIZED_PENDING_REVIEW`, rangos de plausibilidad de Perú, regla y evidencia; no se crea geometría ni se escribe a `geo.destination` o `geo.point_of_interest`.

## Incremento local implementado

- Parser CSV sin dependencia nueva: valida encabezados, conserva campos raw, detecta UTF-8/Windows-1252, delimitador, corte, códigos repetidos, filas mal formadas y formato de coordenadas.
- Migración aditiva `V006__create_mincetur_import_staging.sql`: tablas separadas de staging de lote y filas; SHA de origen y versión de parser para idempotencia; candidatos numéricos permitidos solo con `NORMALIZED_PENDING_REVIEW`, rangos plausibles y evidencia; el staging no tiene geometría ni operación de publicación.
- Runner de importación opt-in, desactivado por defecto. Lee un path configurado; el archivo original no se copia al repositorio.
- No escribe en `geo.destination` ni `geo.point_of_interest`, no altera los cinco seeds P3, y no publica registros en búsqueda o Route Discovery.

## Validación y límites

- Pruebas focalizadas `MinceturSnapshotParserTests` + `MinceturSnapshotCoordinateNormalizerTests`: 9/9 PASS con el CSV local suministrado. Incluyen preservación raw, ficha 237, una fila con decimal en posición 1, otro SHA sin normalización, diez excepciones y rechazo de manifiesto inconsistente.
- `mvn verify`: PASS, 77 tests, 0 failures, 11 skipped. Los 9 tests PostGIS/Testcontainers se omitieron porque Docker no está instalado/disponible; 2 pruebas de perfil de snapshot requieren una ruta opt-in. Por tanto V006 y la importación idempotente siguen sin validación real contra PostgreSQL/PostGIS.
- El recuento de 74 informado antes correspondía al estado previo a añadir tres tests focalizados; ya no representa este HEAD. El recuento verificable vigente de Maven es 77.
- No se atribuye la transformación a una herramienta concreta ni se considera que los dígitos recuperados expresen exactitud geográfica. Los candidatos permanecen pendientes de revisión y publicación.

## Dependencias fuera de este incremento

- ADMIN-1 no se implementó: los artefactos ADMIN-0 consultados aún presentan decisiones de identidad/issuer, roles efectivos y frontend como propuestas pendientes. La API de Spring Security no está en las dependencias actuales; no se creó un portal ni endpoints sin autenticación aprobada.
- POI-MEDIA-1 productivo no se implementó: la política vigente exige derechos verificables por activo y publicación aprobada; no se proporcionó evidencia de derechos para las cinco fotos locales. No se copiaron fotos ni se modificó MinIO o Flutter.
- No se hicieron push, PR, merge, despliegue, instalación física o cambios en bases compartidas.

## Continuación local POI-DATA-1 / ADMIN-1 / POI-MEDIA-1 — 2026-11-17

### Coordenadas y staging

El normalizador de coordenadas por hash exacto y el manifiesto de recuperación están en este cambio. En la regla por fila, la columna fuente `LATITUD` produce longitud con punto tras dos dígitos; la columna fuente `LONGITUD` produce latitud con punto tras uno o dos dígitos. Se conserva raw y el valor transformado queda como candidato `NORMALIZED_PENDING_REVIEW`. La migración V006 ya no prohíbe guardar estos dos escalares de staging, pero exige estado pendiente, límites de plausibilidad, regla y evidencia; no almacena geometría. No escribe ni publica en tablas existentes.

`mvn verify` tras esta continuación: `PASS`, 85 tests, 0 fallos, 11 omitidos. Los 9 casos PostGIS/Testcontainers se omiten porque Docker no está disponible; dos perfiles de prueba requieren la ruta local opt-in. Pruebas focalizadas con el CSV proporcionado: parser + normalizador 9/9 PASS; políticas ADMIN/media + seguridad 8/8 PASS. La ejecución anterior con 74 pruebas antecede a las pruebas añadidas y no se usa como resultado vigente.

### ADMIN-1 — base de dominio segura, aún no portal operativo

Se añadieron roles de aplicación administrador/editor/revisor, estados editoriales, transición versionada con auditoría inmutable y política de revisión geográfica que mantiene candidatos plausibles en revisión humana. Estos componentes no escriben a `geo.point_of_interest.active` ni alteran Discovery.

El backend ahora tiene Spring Security OAuth2 Resource Server y configuración OIDC por issuer externo. `GEOGUIDE_ADMIN_SECURITY_ENABLED` es false por defecto y las rutas `/api/v1/admin/**` quedan denegadas hasta habilitarlo. Al habilitarlo se exige `GEOGUIDE_ADMIN_SECURITY_ISSUER_URI`; no se añadió issuer, usuario ni token ficticio. El claim de roles es configurable (`roles` por defecto), con política RBAC. Esto es solo el cimiento: no hay endpoints administrativos ni persistencia editorial, y no se ha probado contra un issuer real. El contrato ADMIN-0 conserva decisiones pendientes D01–D15; React+TypeScript sigue siendo una recomendación, no una selección aprobada.

### POI-MEDIA-1 — modelo y puerto, sin objetos reales ni servicio desplegable

Se añadieron metadatos de media con hash/tamaño/autor/fuente/licencia/atribución/referencia de derechos y estados de revisión/publicación/retiro. La política niega publicación si faltan derechos documentados, atribución y revisión. Se definió un puerto de almacenamiento privado con clave opaca, sin implementación MinIO, bucket, upload ni endpoints. No se copiaron fotografías ni se generó contenido visual.

La lectura pública de medios/API/Flutter sigue pendiente de reconciliarse con el límite multimedia de P8, snapshots P9 y las decisiones ADMIN-0 D08/D09. El adaptador MinIO requiere seleccionar e incorporar un SDK compatible y definir controles de carga (D07); no se introdujo otra dependencia para simularlo. No se declaran operación ni publicación de media.

### Límites de validación

No hay PostgreSQL/PostGIS, Docker ni conexión a base local disponible; V006 y persistencia/idempotencia no se han ejecutado realmente. Tampoco se desplegó aplicación, probó OIDC, conectado MinIO, creado UI web ni integrado APIs/Flutter multimedia. No se ejecutaron migraciones en bases compartidas.

```ini
MINCETUR_LOCAL_SNAPSHOT = PROFILED
MINCETUR_RAW_STAGING = IMPLEMENTED
MINCETUR_COORDINATE_NORMALIZATION = 6331_CANDIDATES_PENDING_REVIEW_10_QUARANTINED
MINCETUR_POSTGIS_VALIDATION = NOT_RUN_DOCKER_UNAVAILABLE
MINCETUR_PUBLICATION = NOT_EXECUTED
ADMIN_1_DOMAIN_SECURITY_FOUNDATION = IMPLEMENTED_LOCAL
ADMIN_CATALOG_API_PERSISTENCE = NOT_IMPLEMENTED
ADMIN_IDENTITY_ISSUER = NOT_CONFIGURED
ADMIN_FRONTEND_FRAMEWORK = PENDING_HUMAN_DECISION
POI_MEDIA_DOMAIN_AND_STORAGE_PORT = IMPLEMENTED_LOCAL
POI_MEDIA_STORAGE_ADAPTER_API_FLUTTER = PENDING
POI_MEDIA_RIGHTS = REAL_ASSETS_NOT_AUTHORIZED_WITHOUT_EVIDENCE
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
