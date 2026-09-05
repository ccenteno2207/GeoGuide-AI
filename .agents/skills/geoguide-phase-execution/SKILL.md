---
name: geoguide-phase-execution
description: Govern opening, auditing, executing, validating, remediating, or closing a GeoGuide AI phase or checkpoint under its approved scope and evidence gates.
---

# GeoGuide Phase Execution

## Purpose

Apply GeoGuide AI's reusable governance workflow to a phase or checkpoint without granting new scope or overriding project authority.

## When to Use

Use for requests to open, audit, execute, validate, remediate, or close a GeoGuide AI phase or checkpoint. Do not use it to infer permission from roadmap position or to begin a later milestone automatically.

## Required Source Resolution

Before work, locate the repository root and read `AGENTS.md` first, followed by `PROJECT_CONTEXT.md`, `ROADMAP.md`, and `DOCUMENTATION_INDEX.md`. Then resolve applicable accepted ADRs, the approved current phase contract, `AI_DEVELOPMENT_GUIDE.md`, relevant DoD or release gates, specialized documentation, and required evidence or runbooks. Do not copy these sources into the skill or treat archived material as current direction.

## Authority Domains

- `AGENTS.md`: global agent rules.
- `PROJECT_CONTEXT.md`: current state.
- `ROADMAP.md`: progression only.
- Accepted ADRs: architecture.
- Approved phase contract: authorized phase scope.
- `AI_DEVELOPMENT_GUIDE.md`: execution method.
- This skill: reusable procedure only.
- Specialized documentation: technical detail.
- Historical documentation: evidence and traceability only.

Roadmap is not authorization. Future architecture is not current scope. A proposal is not approval. `NEXT` and `PLANNED` do not authorize implementation. This skill never raises its own authority. Pause for a master decision when architecture and authorized scope conflict materially.

## Phase State Detection

Derive phase, approval, branch, environment, and validation state from current authoritative sources at runtime. Distinguish phase progression, contract status, execution authorization, PR state, post-merge validation, and formal closure.

## Controlled Governance Mode

Use this mode when the contract is absent or not frozen, approval is pending, autonomous execution is not authorized, or a material architecture or scope issue remains unresolved. Inspect, search, audit, compare, trace, record contradictions, and prepare proposals, contracts, or checkpoints. Do not implement functionality, create an implementation branch for the phase, expand scope, decide architecture autonomously, or start the next milestone.

## Scope Freeze Gate

Enter Autonomous Execution Mode only when current authoritative evidence contains all three gates:

```text
PHASE CONTRACT: FROZEN
PHASE APPROVAL: APPROVED
AUTONOMOUS EXECUTION: AUTHORIZED
```

If any gate is missing or ambiguous, remain in Controlled Governance Mode. Never infer authorization.

## Autonomous Execution Mode

Within the frozen contract, inspect, implement, test, fix, make small reversible refactors, validate, document, commit, push, prepare the PR, and advance approved checkpoints. Handle normal reversible technical failures without requesting approval. Never expand scope.

## Default Phase Lifecycle

Follow: phase opening -> documentation scope audit -> inherited technical state -> contradictions and decisions -> scope and execution contract -> approval gate -> autonomous execution -> implementation checkpoints -> pull request -> master audit -> remediation when required -> merge -> post-merge validation -> formal closure.

The phase contract determines checkpoint granularity; do not assume phase-specific checkpoint names.

## Checkpoint Lifecycle

Use `PROPOSED`, `APPROVED`, `IN_PROGRESS`, `COMPLETED`, or `BLOCKED`. Reserve `CLOSED` for formal phase closure. Read [references/checkpoint-contract.md](references/checkpoint-contract.md) whenever defining, running, reporting, or auditing a checkpoint.

## Evidence Requirements

Select objective evidence proportional to the contract from `DOC`, `CODE`, `TEST`, `GIT`, `VM`, `DOCKER`, `DATABASE`, `HTTP`, `LOG`, `PR`, `COMMIT`, and `SCREENSHOT`. Do not require every type. Statements such as “works”, “done”, or “looks correct” are not sufficient without objective validation.

## Git Lifecycle

Validate and fetch `main`, require a clean tree, and create the approved branch before normal implementation. Then execute checkpoints, tests, diff review, cohesive commits, push, PR, master audit, remediation, merge, main synchronization, post-merge validation, master closure, and branch cleanup. Never silently discard local changes or implement normally on `main`. Use the same PR for remediation unless explicitly instructed otherwise.

## VM Validation

Do not assume VM validation is required. When the contract requires it, verify branch and HEAD, clean state, services, and protected resources; run only authorized integration work; preserve persistent data; capture evidence; and check non-regression. Mocks do not replace contractually required real VM evidence. Rebuild or restart Docker only when authorized by the contract.

## Master Audit and Remediation

Treat master audit results as `APPROVED` or `REMEDIATION REQUIRED`. For remediation, remain on the same branch and PR, address only audit findings, add relevant tests or evidence, push, and request re-review. Do not create a replacement PR automatically.

## Post-Merge Validation

`PR MERGED` does not mean `PHASE CLOSED`. Perform contractually relevant checks, which may include origin, local, and VM main alignment; clean trees; tests or builds; runtime and non-regression; protected resources; and evidence updates. The highest status this skill may report before required master closure is:

```text
PHASE:
READY FOR MASTER CLOSURE
```

## Mandatory Escalation

Pause material execution for scope expansion, a new material architecture decision, an ADR or scope contradiction, a phase-boundary violation, an unexpected future-phase dependency, a destructive or protected operation, data-loss risk, a material security issue, an unresolvable regression, an impossible DoD, or an unexpected requirement outside the frozen contract. Report exactly:

```text
AUTONOMOUS EXECUTION:
PAUSED

CHECKPOINT:
<id>

REQUIRES MASTER DECISION:
<issue>

EVIDENCE:
<evidence>
```

Do not escalate normal compilation or test failures, formatting, imports, internal naming, fixtures, small reversible refactors, safe in-scope configuration or documentation corrections, or cohesive commits.

## Protected Resources

Discover protected resources from `AGENTS.md`, `PROJECT_CONTEXT.md`, the phase contract, and applicable runbooks. Do not hardcode infrastructure, datasets, migrations, or other project-specific protected resources here.

## Dynamic State Rules

Resolve all current phase, SHA, PR, branch, test counts, database counts, VM address, endpoint, service health, provider configuration, prior-phase decisions, and next-phase requirements at runtime. Never embed them in this skill.

## Non-Responsibilities

This skill does not authorize scope, approve architecture, replace ADRs or phase contracts, require a VM, close phases unilaterally, modify protected resources, install global copies of itself, or begin the next milestone. For contract validation scenarios, read [references/behavioral-tests.md](references/behavioral-tests.md).
