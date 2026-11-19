# POI-DATA-2 — Evidencia de implementación del filtro MINCETUR

## Estado

```ini
POI_DATA_2_IMPLEMENTATION = PASS
POI_DATA_2_ACCEPTANCE = TD-AC-01..09 PASS
MINCETUR_PUBLICATION = NOT_EXECUTED
VM_TEMPORARY_STACK_CLEANUP = PASS
WINDOWS_TEMPORARY_STAGING_CLEANUP = BLOCKED
```

Rama local: `codex/poi-data-2-filter-implementation`
Baseline: `69f3d28704d0bc41bb9749950810a8f954c4c15b`
Contrato: `MINCETUR-TAXONOMY-FILTER-v1`, sin cambios.

## Implementación

- `MinceturTaxonomyFilter` aplica el ruleset versionado únicamente al snapshot aprobado por SHA-256, fecha de corte, tamaño y columnas requeridas. Los snapshots no reconocidos reciben `CLASSIFICATION_REVIEW_REQUIRED` con `SNAPSHOT_NOT_APPROVED`.
- Las nueve exclusiones primarias usan igualdad normalizada del tipo, con aliases explícitos. TD-EX-10, TD-EX-11 y TD-EX-12 requieren coincidencia exacta de categoría, tipo y subtipo. No se usa `contains`, búsqueda parcial ni fuzzy matching.
- La clasificación temática se guarda en columnas distintas del estado geográfico existente. Cada lote registra la versión del filtro. La importación conserva todas las filas y campos raw; los registros excluidos permanecen en staging y no se convierten en contenido cultural consumible por CEFI.
- La migración V009 es aditiva. La clave idempotente del lote incorpora SHA del snapshot, versión del parser y versión del filtro. Los conflictos por fila no sobrescriben registros existentes ni decisiones previas.
- No se modificaron los cinco POIs P3, los nueve destinos curados, contratos API, reglas editoriales, publicación o Route Discovery.

## Criterios de aceptación

| Criterio | Resultado | Evidencia |
| --- | --- | --- |
| TD-AC-01 | PASS | Snapshot local SHA `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66`; 6.341 filas clasificadas y raw preservado. |
| TD-AC-02 | PASS | Pruebas de nueve tipos excluidos, igualdad exacta y aliases de plural/singular. |
| TD-AC-03 | PASS | Tres reglas secundarias exactas; subtipos vecinos de Artísticos y Ferias permanecen elegibles. |
| TD-AC-04 | PASS | 1.768 excluidos y 4.573 elegibles para revisión; cero casos de clasificación pendiente en el snapshot aprobado. |
| TD-AC-05 | PASS | Parejas desconocidas requieren revisión; reglas exactas sin coincidencia parcial ni fuzzy matching. |
| TD-AC-06 | PASS | Las diez cuarentenas geográficas se mantienen; intersección temática/geográfica = 2. Los otros ocho no se liberan. |
| TD-AC-07 | PASS | La elegibilidad no crea geometrías, publicaciones, destinos ni POIs. |
| TD-AC-08 | PASS | Las 6.341 filas raw permanecen en staging; no se crea catálogo cultural ni consumo de CEFI. |
| TD-AC-09 | PASS | Reimportación del mismo snapshot y ruleset es idempotente; conteos, raw, P3 y destinos curados permanecen estables. |

## Validación

Snapshot de entrada: `Inventario_recursos_turisticos.csv`, el original local de solo lectura. La prueba comprobó su SHA aprobado y fecha de corte; el proceso de importación volvió a ejecutar el parser y el normalizador existentes.

Pruebas locales:

- `MinceturTaxonomyFilterTests`: 6/6 PASS.
- `MinceturSnapshotParserTests`: 6/6 PASS.
- `MinceturSnapshotCoordinateNormalizerTests`: 3/3 PASS.
- `mvn verify` con la suite completa y PostGIS externo aislado: 110 pruebas, 0 fallos, 0 errores, 0 omitidas.
- `PostgisIntegrationTests`: 15/15 PASS; Flyway V001–V009 aplicadas en base vacía, carga completa e idempotencia verificadas.
- `git diff --check`: PASS.

Durante la primera ejecución focalizada, la prueba `migrationsCreateApprovedPostgisBaseline` falló porque esperaba ocho migraciones. Al agregar V009, la expectativa quedó obsoleta; se actualizó a nueve y la regresión completa pasó.

## Entorno PostGIS temporal y limpieza

Se utilizó un stack Compose exclusivo en la VM de desarrollo previamente autorizada: un contenedor PostgreSQL/PostGIS temporal, con base efímera tmpfs, red y nombre de proyecto propios, límite de 1 GiB y 0,5 CPU, puerto ligado a loopback y túnel SSH loopback. No se conectó a las redes ni bases de los servicios persistentes.

Después de las pruebas se retiraron el contenedor, la red, el directorio temporal remoto y el túnel SSH creado para esta sesión. Los seis contenedores preexistentes permanecieron ejecutándose y saludables antes y después. No se usaron fotografías reales ni se transfirieron secretos productivos.

La limpieza del directorio Windows `D:\Codex\poi-data-2-v009-validation-20261118-69f3d287` quedó pendiente: el intento de retirar el directorio fue rechazado por el control automático de comandos. Contiene únicamente el Compose temporal y dos logs generados para esta ejecución; el Compose incluye una credencial sintética del servicio temporal ya detenido. No se versiona ningún archivo de ese directorio. No se intentó otro método de borrado.

## Archivos funcionales

- `backend/src/main/java/ai/geoguide/poi/infrastructure/dataset/mincetur/MinceturTaxonomyFilter.java`
- `backend/src/main/java/ai/geoguide/poi/infrastructure/dataset/mincetur/JdbcMinceturSnapshotStagingRepository.java`
- `backend/src/main/resources/db/migration/V009__version_mincetur_taxonomy_eligibility.sql`
- `backend/src/test/java/ai/geoguide/poi/infrastructure/dataset/mincetur/MinceturTaxonomyFilterTests.java`
- `backend/src/test/java/ai/geoguide/poi/infrastructure/persistence/PostgisIntegrationTests.java`

La implementación es local y no publicada. `MINCETUR_PUBLICATION` permanece `NOT_EXECUTED`.
