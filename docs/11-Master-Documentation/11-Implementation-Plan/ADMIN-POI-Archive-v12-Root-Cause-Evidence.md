# ADMIN-POI — expediente MINCETUR 1851 archivado

Fecha de investigación: 2026-11-19
Expediente: `fdfeb867-576f-4fb5-bcbf-8784e54c2f3a`
Vínculo de staging: `e4dfcb1f-7b18-482c-b955-ce917f9a0cba` · MINCETUR `1851`

## Resultado de la consulta de solo lectura

El registro persistido está en `ARCHIVED`, `active=false`, versión 12, categoría
`ARCHAEOLOGICAL_SITE`, con revisiones geográfica e identidad `PENDING` y sin
`published_poi_id`. El registro de origen MINCETUR sigue presente en staging,
elegible para revisión, con clasificación `NORMALIZED_PENDING_REVIEW`. La
provenance permanece vinculada y no existe POI público asociado.

La auditoría registra estas transiciones relevantes:

| Versión | Acción | Estado resultante | Actor | Fecha registrada |
| --- | --- | --- | --- | --- |
| v5 | `SUBMIT_FOR_REVIEW` | `PENDING_REVIEW` | `poi-admin-demo` (`ADMINISTRATOR`) | 2026-11-19 20:52:30 |
| v6 | `OBSERVE` | `OBSERVED` | `poi-admin-demo` (`ADMINISTRATOR`) | 2026-11-19 21:58:50 |
| v7 | `SUBMIT_FOR_REVIEW` | `PENDING_REVIEW` | `poi-admin-demo` (`ADMINISTRATOR`) | 2026-11-19 21:59:29 |
| v8 | `OBSERVE` | `OBSERVED` | `poi-admin-demo` (`ADMINISTRATOR`) | 2026-11-19 22:07:10 |
| v9 | `UPDATE` | `OBSERVED` | `poi-admin-demo` (`ADMINISTRATOR`) | 2026-11-19 22:07:16 |
| v10 | `UPDATE` | `OBSERVED` | `poi-admin-demo` (`ADMINISTRATOR`) | 2026-11-19 22:07:53 |
| v11 | `UPDATE` | `OBSERVED` | `poi-admin-demo` (`ADMINISTRATOR`) | 2026-11-19 22:08:39 |
| v12 | `ARCHIVE` | `ARCHIVED` | `poi-admin-demo` (`ADMINISTRATOR`) | 2026-11-19 22:10:17 |

La v9 registra el cambio persistido de categoría `WATERFALL` a
`ARCHAEOLOGICAL_SITE`; las actualizaciones v10–v11 mantienen la categoría
arqueológica. Por tanto, el valor WATERFALL mostrado en una captura anterior
corresponde a una vista/edición anterior y no al valor persistido actual.

La operación que archivó el expediente fue una solicitud administrativa explícita
a `POST /api/v1/admin/records/{id}/archive`, no un archivado automático. La
auditoría asocia la acción al usuario sintético `poi-admin-demo`, rol
`ADMINISTRATOR`. El motivo registrado describe mantener el candidato sin activar
mientras se revisan los controles; no constituye por sí solo una instrucción de
reapertura.

## Causa del HTTP 409 y límites del flujo

Los 409 observados después de la v12 provienen de operaciones incompatibles con el
estado archivado (edición, revisiones y nuevas transiciones). El repositorio solo
permite `ARCHIVE` desde estados explícitos distintos de `ARCHIVED`; la máquina de
estados no define transición de salida desde `ARCHIVED`. La operación existente
`restore-approval` trata la restauración de aprobación de un registro suspendido,
no la reapertura de un expediente archivado. El contrato/API vigentes no ofrecen
una acción de reapertura para este caso.

Los accesos posteriores al archivado registran 409 para `PUT
/api/v1/admin/records/{id}`, `POST /api/v1/admin/records/{id}/geographic-review`,
`POST /api/v1/admin/records/{id}/identity-review` y otra solicitud a `POST
/api/v1/admin/records/{id}/archive`. Los intentos posteriores de revisión también
incluyeron respuestas 401 tras expirar autenticación; estos no son el 409. El
anterior 409 de aprobación observado antes de v12 fue un incidente distinto,
corregido previamente en la validación de licencia/atribución.

No se cambió el backend ni se escribió en la base. La recuperación queda
`NOT_AUTHORIZED` hasta una decisión editorial explícita y un contrato que defina
actor permitido, motivo, estado de retorno, reinicio de revisiones, versionado y
auditoría. No crear otro registro para MINCETUR 1851.

Durante la misma cronología, el código de revisión geográfica/de identidad acepta
estados de origen más limitados que los aceptados por edición. Las solicitudes de
revisión desde `OBSERVED` pueden por ello recibir conflicto incluso antes del
archivo. Es un hallazgo de flujo separado; no se modificó en esta corrección
focalizada y debe revisarse con el contrato editorial antes de cambiarlo.

## Corrección de experiencia del portal

- El detalle informa que el expediente está archivado, que el flujo actual no
  permite reabrirlo y que se conserva el vínculo MINCETUR; indica no crear otro.
- El formulario y las acciones editoriales quedan deshabilitados para
  `ARCHIVED`.
- Ante HTTP 409, el portal vuelve a consultar el estado/versionado actuales. Si
  está archivado, muestra la causa concreta; si cambió de versión por otra causa,
  muestra la versión recargada. El contenido aún no guardado se conserva en el
  formulario.
- Se añadieron pruebas sintéticas de expediente archivado y de cambio concurrente
  a `ARCHIVED`; no se ejercieron mutaciones contra el expediente real.

## Estado

```ini
ADMIN_POI_ARCHIVE_ROOT_CAUSE = IDENTIFIED
ADMIN_POI_ARCHIVE_RECOVERY = NOT_AUTHORIZED
ADMIN_POI_EDITORIAL_UI = PASS
ADMIN_POI_REAL_RECORD_MUTATED = NO
```
