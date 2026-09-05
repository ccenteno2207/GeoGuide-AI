# Reusable Checkpoint Contract

Use this record to define, execute, and audit a checkpoint. Keep each field explicit; use `N/A` with a reason when a field does not apply.

## Identity and state

- **ID:** Stable identifier defined by the phase contract.
- **Name:** Short checkpoint name.
- **Status:** `PROPOSED`, `APPROVED`, `IN_PROGRESS`, `COMPLETED`, or `BLOCKED`.
- **Objective:** Observable outcome.
- **Preconditions:** Required state and approvals before execution.

`CLOSED` is not a normal checkpoint status; it is reserved for formal phase closure.

## Scope and authorization

- **In Scope:** Work explicitly included.
- **Out of Scope:** Nearby work explicitly excluded.
- **Authorized actions:** Mutations allowed by the frozen contract.
- **Protected actions:** Actions forbidden or requiring a master decision.

## Execution record

- **Files inspected:** Sources used to make decisions.
- **Files modified:** Exact paths changed.
- **Commands:** Material commands executed.
- **Tests:** Relevant validations selected from project rules and the contract.
- **Expected result:** Objective pass condition established before validation.
- **Actual result:** Observed output, including failures.
- **Evidence:** Proportional `DOC`, `CODE`, `TEST`, `GIT`, `VM`, `DOCKER`, `DATABASE`, `HTTP`, `LOG`, `PR`, `COMMIT`, or `SCREENSHOT` evidence.
- **Git state:** Branch, base, HEAD, and working-tree state as relevant.
- **Commit:** Commit identifier when one exists.
- **VM evidence when applicable:** Environment identity, deployed revision, service checks, and non-regression evidence required by contract.

## Completion decision

- **Risks:** Remaining risk, uncertainty, or follow-up within the approved scope.
- **Exit criteria:** Conditions required to mark the checkpoint complete.
- **Verdict:** `PASS`, `FAIL`, `BLOCKED`, or another verdict explicitly defined by the phase contract.

A checkpoint is `COMPLETED` only when its exit criteria have objective evidence. A blocked checkpoint must name the blocking condition and use the mandatory escalation format from `SKILL.md` when a master decision is required.
