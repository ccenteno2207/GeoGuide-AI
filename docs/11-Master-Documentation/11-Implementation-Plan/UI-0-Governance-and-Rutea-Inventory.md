# UI-0 — Reconciliación de gobierno e inventario Rutea

Fecha de inspección: 2026-10-15. Baseline verificado: `7edc494ba9bf578da07deec25ace1d625ecd5a5b`.

## UI_0_GOVERNANCE_RECONCILIATION

| Evento | Estado | Evidencia y límite |
|---|---|---|
| G01, PR #81 | G01_GOVERNANCE_MERGED_PASS | Commit de política `e83d517f0dbb30259ff0737eda165d9db1568f9b`; merge `7edc494ba9bf578da07deec25ace1d625ecd5a5b`. [AGENTS](../../../AGENTS.md) y [guía](../../../AI_DEVELOPMENT_GUIDE.md) fijan nuevos worktrees en `D:/Codex/worktrees/GeoGuide-AI` |
| G02 | G02_AUDIT_ONLY | Inventario inicial; no eliminó ramas |
| G02.1 | G02_1_PARTIAL_CLEANUP — ACCEPTED_WITH_RESIDUALS | Estado aceptado por instrucción humana UI-0; limpieza selectiva, nunca total |

G02.1 eliminó 51 ramas locales (59 → 8) y 57 ramas remotas reales (65 → 8). Preservó 11 worktrees y 3 stashes. G02 había contado 66 referencias remotas sin origin/HEAD: una referencia local a origin/feature/gps-follow-mode ya no existía en el servidor; fue conservada sin prune. No confundir referencias de seguimiento con ramas remotas reales.

La comprobación de entrada UI-0 confirma 8 ramas locales, 8 remotas reales mediante `git ls-remote --heads`, 11 worktrees registrados y 3 stashes. La creación autorizada del worktree documental UI-0 añade una rama local y un worktree; no reescribe las cifras históricas G02.1 ni implica limpieza posterior.

Asociaciones pendientes conservadas: `feature/p2-backend-bootstrap` y `docs/p7-governance-reconciliation`. Su asociación persistida con sesiones requiere revisión humana; no se deduce ausencia de uso. `P9_CODEX_SESSION_BRANCH = UNVERIFIED`: no se infiere una rama por título de sesión, cwd o commit histórico.

Fuentes externas consultadas en solo lectura, no copiadas al repositorio ni modificadas:

- `D:/Codex/backups/GeoGuide-AI/g02-audit-20261012/G02_BRANCH_AUDIT_REPORT.md`.
- `D:/Codex/backups/GeoGuide-AI/g02-1-cleanup-20261012/G02_1_CLEANUP_REPORT.md`.
- Instrucción humana UI-0 para la aceptación con residuos.

Stashes preservados en este orden:

1. `11c05fdab7fa0fd8a0affcdbab66661534f12b46`.
2. `27f89dbafb07884b3533e62550fff07cd2d75d10`.
3. `583d0f593dda1b5d28ed5ed247431865e10837ac`.

## UI_0_RUTEA_DOCUMENT_INVENTORY

Origen real: `D:/Proyectos/Desarrollo/Ruteo/GeoGuide-AI/docs/11-Master-Documentation/11-Implementation-Plan/`. Los tres archivos son untracked y permanecen intactos en el repositorio principal. No se mueven, borran, sobrescriben ni incorporan automáticamente a Git.

| Archivo original | SHA-256 comprobado contra G02.1 |
|---|---|
| Rutea-Driving-Corrective-Package-Proposal.md | `959e74bb86ac19806d4d6d4c3ff2bb951097d7367e180e04ea6fc0ff521c94bd` |
| Rutea-UI-0-Contract-Reconciliation-Proposal.md | `eb23f94ac5ca646f4a9c23529a78def03be352d968bb2bf25afca055c9062c32` |
| Rutea-UI-UX-Contract-v1-Proposal.md | `a569c89f26c77e198e8d0115844be36b5ea38e62ce67073f75c152a4ee5161e9` |

Copias temporales protegidas por escritura exclusiva y comprobación SHA-256 en `D:/Codex/backups/GeoGuide-AI/ui0-reconciliation-20261015/originals/`; son copias de referencia, no documentos normativos ni archivos destinados al PR. No se cambiaron permisos/ACL. `preflight.json` del directorio padre registra hashes, procedencia, listado de worktrees, HEAD/ramas y estados locales, más IDs/orden de stashes. Esta evidencia operativa permanece fuera de Git.

Worktree de trabajo: `D:/Codex/worktrees/GeoGuide-AI/ui0-documentation-reconciliation`; rama `docs/ui0-documentation-reconciliation`, creada desde el baseline actual. Los documentos reconciliados usan nombres nuevos para evitar sobrescribir originales durante una futura sincronización de main.

Los originales fueron preparados sobre `805cb17502583561f42eb4907e5a6bc6ac1a111c`, ancestro de main actual. I01 (PR #80) añadió selección explícita, `chosenIds`, codec de sesión y guards de B1. G01 (PR #81) añadió gobierno de directorios. El rediseño debe preservar I01 y sus pruebas; el borrador previo no constituye inventario vigente de esas funciones.

## Resolución humana y trazabilidad de remediación

El 2026-10-15 el responsable del proyecto emitió «UI-0 — MASTER DECISION RESOLUTION, DOCUMENTATION REMEDIATION & CONTROLLED AUTONOMOUS COMPLETION». Fuente original: adjunto local `C:/Users/CC_Laptop/.codex/attachments/8a715d0e-0331-4d65-9671-04df18ff7e56/Texto pegado.txt`; se registra su contenido decisorio aquí para no depender del acceso al adjunto.

- DECISION A = APPROVED: Rutea Explorer + CEFI Smart conceptual; «Avisos de CEFI» operativo sobre TTS consentido; «Habla con CEFI», búsqueda textual y geocodificación diferidos. Sin simulaciones, STT, micrófono ni nuevos consentimientos. CEFI permanente, Rutea candidato comercial e identificadores técnicos GeoGuide AI preservados.
- DECISION B = APPROVED: registrar P9 §7/GPS Follow como contradicción independiente pendiente de disposición, sin modificar contratos congelados o comportamiento y sin afirmar conformidad funcional por implementación.
- DECISION C = APPROVED: DR separado y NOT_AUTHORIZED; no es requisito de UI-1/2/3; UI-4 requiere revisión específica de DR y P9/GPS antes de ejecutarse. Ningún guard, callback, frescura, encuadre, retorno, TTS o interacción cambia por esta aprobación visual.

La instrucción autoriza remediar únicamente estos cuatro documentos, validarlos, hacer staging/commit/push/PR, auditoría y merge normal sin bypass, sincronizar main y registrar evidencia. No autoriza eliminar ramas, worktrees, stashes o respaldos ni implementar UI-1 a UI-5. Se continúa en la misma rama/worktree; no se crea una reconciliación paralela.

El resultado anterior UI_0_REQUIRES_PRODUCT_DECISION se conserva como antecedente, no como gate vigente de integración. A/B/C resuelven su disposición documental; el conflicto funcional no se convierte en PASS. Véanse [matriz actualizada](UI-0-Rutea-Compatibility-Matrix.md), [contrato visual](UI-0-Visual-Design-Contract-Proposal.md) y [validación e integración](UI-0-Validation-Results.md). Las cifras G02.1 y estados históricos no cambian por esta aprobación; el push documental añadirá una rama remota propia, sin limpieza.

## Estados que esta tarea no modifica

```ini
P12 = IN_PROGRESS / 45%
P12.5 = NOT_AUTHORIZED
P11-BACKUP-01 = OPEN_DEFERRED
V01 = STATIONARY_PARTIAL
I01_PHYSICAL_VALIDATION = NOT_EXECUTED
P9_CODEX_SESSION_BRANCH = UNVERIFIED
UI_1_TO_UI_5_IMPLEMENTATION = NOT_AUTHORIZED
```

No se declara Production Readiness. La conservación de estas cifras no confunde aprobación conceptual, prueba automatizada y prueba física. No hay cambios en documentación externa, Excel, código, permisos o dependencias.
