# POI-DATA-1 — Evidencia de staging inicial MINCETUR

**Baseline:** `0d76dcf740e3558c4b7308dbb19139a6e9a1071e`

**Rama:** `codex/master-implementation-v2`
**Estado:** `RAW_STAGING_IMPLEMENTED_COORDINATES_QUARANTINED`

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

## Hallazgo de coordenadas y decisión segura

Las coordenadas locales no están representadas como decimales inequívocos. Por ejemplo, MINCETUR 237 aparece literalmente como `LATITUD=-7.576.291.501.522.060` y `LONGITUD=-14.087.854.051.458.200`; ambos valores contienen varios puntos. En la lectura sintáctica del snapshot, 6,336 valores `LATITUD` y 6,335 `LONGITUD` siguen ese patrón de puntuación agrupada. Los valores que parecen decimales tampoco se asignan a ejes porque el mapeo semántico solo está aprobado para el snapshot anterior y su hash exacto.

El valor curado previo para la ficha 237 (`latitude=-14.087854051458233`, `longitude=-75.76291501522064`) demuestra el mapeo de columnas para el snapshot anterior, pero no permite reconstruir el valor exacto ni la regla general de este archivo local. Por ello el parser preserva los textos originales y pone todos los registros en staging/quarantena; no genera coordenadas normalizadas ni geometrías.

## Incremento local implementado

- Parser CSV sin dependencia nueva: valida encabezados, conserva campos raw, detecta UTF-8/Windows-1252, delimitador, corte, códigos repetidos, filas mal formadas y formato de coordenadas.
- Migración aditiva `V006__create_mincetur_import_staging.sql`: tablas separadas de staging de lote y filas; SHA de origen y versión de parser para idempotencia; coordenadas normalizadas nulas y regla/check que impide publicar geometría desde staging.
- Runner de importación opt-in, desactivado por defecto. Lee un path configurado; el archivo original no se copia al repositorio.
- No escribe en `geo.destination` ni `geo.point_of_interest`, no altera los cinco seeds P3, y no publica registros en búsqueda o Route Discovery.

## Validación y límites

- `MinceturSnapshotParserTests`: 6 pruebas PASS, incluyendo perfil del CSV original, conservación de los campos agrupados de la ficha 237, cuarentena, mapeo no verificado, duplicados, encoding y CSV quoted.
- La prueba de persistencia idempotente contra PostGIS quedó añadida, pero no pudo ejecutarse en este entorno porque el comando `docker` no está disponible. La migración V006 no está validada contra un servidor PostGIS real en esta ejecución.
- No se ejecutó `mvn verify` completa todavía.
- La importación no produce ubicaciones utilizables; requiere una copia fuente íntegra o una regla de normalización específica del hash respaldada por evidencia. No se autoriza deducir la posición decimal por heurística.

## Dependencias fuera de este incremento

- ADMIN-1 no se implementó: los artefactos ADMIN-0 consultados aún presentan decisiones de identidad/issuer, roles efectivos y frontend como propuestas pendientes. La API de Spring Security no está en las dependencias actuales; no se creó un portal ni endpoints sin autenticación aprobada.
- POI-MEDIA-1 productivo no se implementó: la política vigente exige derechos verificables por activo y publicación aprobada; no se proporcionó evidencia de derechos para las cinco fotos locales. No se copiaron fotos ni se modificó MinIO o Flutter.
- No se hicieron push, PR, merge, despliegue, instalación física o cambios en bases compartidas.

```ini
MINCETUR_LOCAL_SNAPSHOT = PROFILED
MINCETUR_RAW_STAGING = IMPLEMENTED
MINCETUR_COORDINATE_NORMALIZATION = QUARANTINED_PENDING_VERIFIABLE_SOURCE_RULE
MINCETUR_PUBLICATION = NOT_EXECUTED
ADMIN_1 = PENDING_AUTHENTICATION_AND_PORTAL_DECISIONS
POI_MEDIA_1 = PENDING_ASSET_RIGHTS_AND_MEDIA_CONTRACT
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
