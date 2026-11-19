# ADMIN-POI — remediación del HTTP 409 de aprobación

Fecha: 2026-11-19
Baseline de análisis: `bc6be218d42f3dee80348560db4022b88afb29f0`

## Causa raíz verificada

El expediente real MINCETUR 1851 (`fdfeb867-576f-4fb5-bcbf-8784e54c2f3a`) estaba persistido en versión 5 y `PENDING_REVIEW`, con revisión geográfica `APPROVED`, identidad `NO_DUPLICATE` y `active=false`. La secuencia de auditoría terminaba en `SUBMIT_FOR_REVIEW`; no había aprobación registrada. La licencia persistida tenía 162 caracteres. Durante la aprobación, el backend insertaba la procedencia en `geo.poi_provenance.license`, todavía limitada a `VARCHAR(160)` por V004. PostgreSQL rechazó la escritura; el manejador genérico de integridad la presentó como HTTP 409. Los logs de PostgreSQL y Nginx confirmaron el fallo; no se encontró evidencia de versión obsoleta ni de transición editorial inválida. La solicitud exacta no quedó capturada, por lo que no se atribuye un valor de versión enviado más allá de la versión vigente observada.

Se verificaron también los datos de categoría: el registro editorial efectivamente almacenaba `WATERFALL`, mientras su campo raw MINCETUR `TIPO DE CATEGORÍA` indica `Sitios Arqueológicos`. El portal compartía `categories[0]` (`WATERFALL`) como valor inicial y la creación desde importación enviaba ese valor sin mapear el tipo raw. No era solo un cambio no guardado de la interfaz.

## Correcciones locales

- V011 amplía aditivamente `geo.poi_provenance.license` de 160 a 240 caracteres, alineándolo con el campo editorial existente. La API limita `sourceLicense` a 240.
- Un mapeador exacto y conservador convierte `Sitios Arqueológicos` en `ARCHAEOLOGICAL_SITE`; tipos desconocidos requieren selección explícita. Backend y portal muestran y validan la misma sugerencia, y ya no se asigna una categoría por defecto.
- La aprobación vuelve a comprobar la coherencia entre el tipo MINCETUR y la categoría P3. Una discrepancia devuelve HTTP 409 con código `EDITORIAL_CATEGORY_MISMATCH` y una instrucción editorial segura. La UI extrae `detail` del Problem Details para presentar el motivo.
- El control de versión optimista, las revisiones de geografía/identidad, la procedencia, la auditoría y la separación entre aprobación y activación se mantienen.

## Validación

- `mvn verify`: BUILD SUCCESS, 121 pruebas, 0 fallos, 25 omitidas; 21 PostGIS se omitieron por no disponer de Docker local y otras cuatro dependen de fixtures opcionales.
- `PostgisIntegrationTests` contra una base temporal PostGIS 16 aislada en la VM: BUILD SUCCESS, 21 pruebas, 0 fallos, 2 omitidas. Flyway aplicó V001–V011 desde una base vacía. La prueba cubre licencia de 162 caracteres, rechazo de categoría incorrecta tanto al crear como al aprobar una fila legacy, control de versión, aprobación sin activación, categoría/procedencia/auditoría y activación separada. La prueba no altera el expediente real.
- Pruebas focalizadas backend: 12/12 PASS (seguridad, Problem Details y mapeador exacto).
- Portal: `npm test` 10/10 PASS; `npm run build` PASS.
- `git diff --check`: PASS.
- Despliegue, smoke test HTTPS y verificación posterior de la base de integración: pendientes de merge.

## Protección del expediente real

El expediente 1851 no se aprobó ni activó. La corrección no escribe directamente sus estados mediante SQL. Permanece pendiente e inactivo con la categoría previamente guardada `WATERFALL`; la nueva validación impedirá su aprobación hasta que el expediente se observe, se corrija mediante el flujo editorial y se repitan las revisiones requeridas.

```ini
ADMIN_POI_APPROVAL_409_ROOT_CAUSE = IDENTIFIED
ADMIN_POI_APPROVAL_409_FIX = LOCALLY_VALIDATED
ADMIN_POI_APPROVAL_E2E = PENDING
ADMIN_POI_VM_DEPLOYMENT = PENDING
```
