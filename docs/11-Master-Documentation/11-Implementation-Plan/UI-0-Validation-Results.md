# UI-0 — Validación documental e integración controlada

Fecha: 2026-10-15. Checkpoint UI-0: IN_PROGRESS al preparar este registro pre-commit. Objetivo: integrar únicamente documentación reconciliada tras decisiones humanas A/B/C. El cierre formal y cualquier implementación quedan fuera de esta ejecución.

## Decisiones y archivos autorizados

DECISION A = APPROVED: separación conceptual/operativa confirmada. DECISION B = APPROVED: P9/GPS registrado y diferido como asunto contractual independiente. DECISION C = APPROVED: DR separado y NOT_AUTHORIZED, sin dependencia funcional para UI-1/2/3; revisión contractual específica antes de UI-4. La disposición documental está resuelta; la conformidad funcional P9/GPS no se declara PASS.

Los únicos cuatro archivos nuevos destinados al commit, bajo `docs/11-Master-Documentation/11-Implementation-Plan/`, son:

- [UI-0-Governance-and-Rutea-Inventory.md](UI-0-Governance-and-Rutea-Inventory.md): gobierno, originales protegidos y registro humano A/B/C.
- [UI-0-Rutea-Compatibility-Matrix.md](UI-0-Rutea-Compatibility-Matrix.md): clasificación y disposición del conflicto sin resolver su precedencia.
- [UI-0-Visual-Design-Contract-Proposal.md](UI-0-Visual-Design-Contract-Proposal.md): alcance visual, I01 obligatorio y cinco paquetes NOT_AUTHORIZED.
- `UI-0-Validation-Results.md`: este registro de controles y límites de integración.

No se incluyen los originales Rutea. No se modifican fuentes normativas congeladas, índices generales, código, pruebas, infraestructura o documentación externa existente.

## Baseline y comprobaciones ejecutadas

Baseline histórico de originales: `805cb17502583561f42eb4907e5a6bc6ac1a111c`. Baseline conocido e inicial verificado: `7edc494ba9bf578da07deec25ace1d625ecd5a5b`. HEAD principal, main, origin/main, remoto y HEAD documental coinciden antes del commit; no hay nuevo delta material.

| Control / comandos ejecutados | Resultado observado |
|---|---|
| `git status --porcelain=v1`, `git branch --show-current`, `git rev-parse HEAD origin/main`, `git ls-remote origin refs/heads/main`; `git fetch origin main` sin prune | PASS: principal en main con exactamente los tres originales untracked; worktree documental en la rama autorizada con los cuatro borradores; baseline coincidente |
| `git merge-base --is-ancestor 805cb17502583561f42eb4907e5a6bc6ac1a111c 7edc494ba9bf578da07deec25ace1d625ecd5a5b` | PASS, exit 0; I01/G01 incorporados previamente al análisis, no reinterpretados como aprobación UI |
| Python `hashlib.sha256(read_bytes())`, seis comparaciones contra `preflight.json` y hashes G02.1 | PASS: tres originales y tres respaldos idénticos; hashes completos en inventario |
| `git worktree list --porcelain`, comparación de registros y de `git status --porcelain=v1 --untracked-files=all` de cada worktree previo | PASS: once worktrees previos preservados con sus estados, incluido el archivo untracked ajeno de i01-r01-baseline |
| `git stash list --format=%H %gd %s` comparado con preflight | PASS: tres SHA, orden y mensajes intactos |
| `git branch --format=%(refname)` y `git ls-remote --heads origin` | Pre-push: nueve ramas locales, ocho remotas reales y doce worktrees; delta respecto a G02.1 limitado a rama/worktree UI-0. El push añade su rama remota, sin limpieza |
| `git diff --name-only`, `git diff --cached --name-only` antes del staging | PASS: ningún archivo rastreado ni índice modificado en ambos worktrees |
| Lectura Python UTF-8 estricta, ausencia de U+FFFD, resolución de enlaces Markdown relativos y balance de bloques de código | PASS para los cuatro documentos; no se certifica disponibilidad de enlaces web |
| `git diff --check`; `git diff --no-index --check -- NUL <archivo>` para cada nuevo Markdown | PASS: whitespace revisado también en archivos untracked, que diff normal omite |
| Revisión de contenido A/B/C, dependencias UI-1–5, selección/freeze I01 y estados protegidos | PASS documental: sin autorización funcional, nuevo consentimiento, precedencia P9/GPS o cambio de P12 y demás estados |

Un intento inicial de sustitución textual con Python falló antes de escribir por no encontrar una cadena (`ValueError`); se aplicaron parches explícitos y se validó el contenido resultante. Un parche de reemplazo del registro también fue rechazado antes de escribir por operaciones duplicadas sobre la misma ruta; se reemplazó únicamente este archivo mediante escritura UTF-8. No se declara PASS de aquellos intentos.

## Auditoría e integración

La aprobación humana permite staging exclusivo de los cuatro archivos, commit documental, validación post-commit, push, PR hacia main, auditoría maestra del PR y merge normal sin bypass. Se conserva rama/worktree; no se eliminan stashes ni respaldos. Un fallo de protección/checks o un hallazgo material nuevo detiene el merge.

Estado de este snapshot pre-commit: PR y merge todavía no ejecutados. Los SHA de commit/head, URL del PR, auditoría y resultado post-merge se registrarán en el propio PR y en el informe final de esta ejecución; este snapshot no anticipa esos resultados. La evidencia post-merge debe identificar SHA y padres del merge, main local/remoto, delta exacto de cuatro documentos y nueva comprobación de integridad. Se usa ese registro posterior para evitar escribir un SHA de merge todavía inexistente dentro de su propio commit.

Rama: `docs/ui0-documentation-reconciliation`. Worktree: `D:/Codex/worktrees/GeoGuide-AI/ui0-documentation-reconciliation`. Respaldo y preflight: `D:/Codex/backups/GeoGuide-AI/ui0-reconciliation-20261015`.

El principal conserva expresamente originales untracked: no debe declararse limpio. Tras sincronización solo debe avanzar su HEAD por fast-forward al merge documental; su estado porcelain debe permanecer idéntico al inicial. El worktree documental debe quedar sin cambios pendientes. Los otros diez worktrees y tres stashes no deben alterarse.

## Límites, riesgos y siguiente autorización

No se ejecutaron Flutter, compilación, tests funcionales, Docker, validación física o conducción: no hay implementación. Las pruebas y capturas definidas en los paquetes son planes futuros, no evidencia actual. I01 físico sigue NOT_EXECUTED; UI-5 no transforma mocks en validación física.

```ini
P12 = IN_PROGRESS / 45%
P12_5 = NOT_AUTHORIZED
P11_BACKUP_01 = OPEN_DEFERRED
V01 = STATIONARY_PARTIAL
I01_PHYSICAL_VALIDATION = NOT_EXECUTED
PRODUCTION_READINESS = NOT_DECLARED
DRIVING_FUNCTIONAL_PACKAGE = NOT_AUTHORIZED
UI_1_TO_UI_5_IMPLEMENTATION = NOT_AUTHORIZED
UI_1_IMPLEMENTATION = NOT_AUTHORIZED
```

P9/GPS permanece CONTRACT_CONFLICT_RECORDED, pendiente de disposición independiente; DR permanece FUNCTIONAL_DRIVING_NOT_AUTHORIZED. No hay nuevo gate humano para integrar estos documentos después de A/B/C. El veredicto UI_0_READY_FOR_MASTER_CLOSURE solo procede con merge normal y evidencia post-merge satisfactoria; de lo contrario UI_0_BLOCKED. Merge no equivale a cierre formal ni inicia UI-1.
