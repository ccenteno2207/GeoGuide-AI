# ADMIN-POI — Reapertura de expedientes y flujo OBSERVED

## Alcance

Esta ampliación del flujo editorial permite reabrir explícitamente un expediente `ARCHIVED` a `DRAFT`, y completar nuevamente las revisiones geográfica y de identidad cuando un expediente `OBSERVED` vuelve a edición. No modifica los datos raw de MINCETUR ni habilita publicación o activación automática. La evidencia histórica de Cantamarca se conserva sin ejecutar su reapertura durante esta implementación.

## Reapertura de archivados

- Endpoint: `POST /api/v1/admin/records/{id}/reopen`.
- Autorización: únicamente `ADMINISTRATOR`.
- Solicitud: `expectedVersion` y `reason` obligatorio (no vacío; máximo 1000 caracteres).
- La operación usa control optimista de versión y actualiza el mismo ID editorial.
- El expediente pasa de `ARCHIVED` a `DRAFT`; versión incrementada en uno.
- `active` queda `false`; las revisiones geográfica e identidad vuelven a `PENDING`, eliminando actor, fecha, motivo y evidencia previos de esas revisiones.
- Se conservan el vínculo de importación MINCETUR, código fuente, provenance y campos raw. El código MINCETUR no puede estar asignado a otro expediente editorial.
- Si existía un POI publicado, el vínculo se conserva como `target_poi_id`, se limpia `published_poi_id`, y el POI se mantiene inactivo. Una aprobación posterior actualiza el mismo POI; no crea otro.
- La reapertura genera auditoría `REOPEN` con actor, motivo, transición, versión e identificadores de procedencia. Si el POI vinculado estaba activo, su desactivación también queda auditada.
- Una versión obsoleta, estado diferente de `ARCHIVED`, vínculo inconsistente, POI faltante o conflicto duplicado se rechaza. No se alteran estados mediante SQL operativo.

## Matriz de transiciones editoriales

| Estado actual | Acción | Estado resultante | Rol | Condiciones principales |
| --- | --- | --- | --- | --- |
| `DRAFT`, `OBSERVED`, `REJECTED` | Revisión geográfica | mismo estado | `REVIEWER` o `ADMINISTRATOR` | Coordenadas y evidencia geográfica válidas; control de versión |
| `DRAFT`, `OBSERVED`, `REJECTED` | Revisión de identidad | mismo estado | `REVIEWER` o `ADMINISTRATOR` | Motivo y evidencia de identidad; control de versión |
| `DRAFT`, `OBSERVED`, `REJECTED` | `SUBMIT_FOR_REVIEW` | `PENDING_REVIEW` | `EDITOR` o `ADMINISTRATOR` | Geografía `APPROVED`, identidad `NO_DUPLICATE` con evidencia, licencia y atribución |
| `PENDING_REVIEW` | `OBSERVE` | `OBSERVED` | `REVIEWER` o `ADMINISTRATOR` | Motivo y evidencia de decisión |
| `PENDING_REVIEW` | `REJECT` | `REJECTED` | `REVIEWER` o `ADMINISTRATOR` | Motivo y evidencia de decisión |
| `PENDING_REVIEW` | `APPROVE` | `APPROVED` | `REVIEWER` o `ADMINISTRATOR` | Revisiones requeridas y procedencia/licencia; publicación queda desactivada |
| `APPROVED` | Activación | `APPROVED` | `ADMINISTRATOR` | Acción separada, versionada y auditada |
| `APPROVED`, `PUBLISHED` | `SUSPEND` | `SUSPENDED` | `ADMINISTRATOR` | Se desactiva el POI público |
| `SUSPENDED` | `RESTORE_APPROVAL` | `APPROVED` | `ADMINISTRATOR` | Sigue desactivado; activación requiere acción separada |
| `DRAFT`, `OBSERVED`, `REJECTED`, `APPROVED`, `PUBLISHED`, `SUSPENDED` | `ARCHIVE` | `ARCHIVED` | `ADMINISTRATOR` | Un POI asociado queda desactivado |
| `ARCHIVED` | `REOPEN` | `DRAFT` | `ADMINISTRATOR` | Motivo obligatorio, versión vigente, reinicio de revisiones, mismo expediente y sin duplicados |

La edición de un expediente en `OBSERVED` reinicia las revisiones geográfica e identidad. Por tanto, volver a `PENDING_REVIEW` requiere que ambas se ejecuten otra vez y cumplan sus evidencias. No se permiten otras acciones de revisión desde estados distintos a `DRAFT`, `OBSERVED` o `REJECTED`.

## Validación y operación

Las pruebas automatizadas usan expedientes y datos MINCETUR sintéticos. La capacidad se despliega en el portal de integración para validación. El expediente real MINCETUR 1851 — Sitio Arqueológico Cantamarca — no se modifica ni se reabre automáticamente; su eventual reapertura debe ser iniciada manualmente por un administrador después de verificar el despliegue.
