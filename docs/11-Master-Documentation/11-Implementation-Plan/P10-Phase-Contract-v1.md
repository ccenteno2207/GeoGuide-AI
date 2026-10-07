# GeoGuide AI — P10 Phase Contract v1 — Quality + Security Hardening

```ini
STATUS = APPROVED_FROZEN
APPROVAL = HUMAN_APPROVED
FROZEN = YES
P10_DISCOVERY_BASELINE = 25ac8d6aca1b2b39c9c87d57958454cb90025d80
P10_SCOPE = QUALITY_AND_SECURITY_HARDENING
P10_IMPLEMENTATION = NOT_AUTHORIZED_YET
P10 = NOT_STARTED_IMPLEMENTATION
P11 = NOT_STARTED
P12 = NOT_STARTED
PROJECT_GLOBAL_PROGRESS = 83%
```

## 1. Authority and purpose

The P10 contract is subordinate to `AGENTS.md`, `PROJECT_CONTEXT.md`, accepted ADRs and the P9 closure evidence. Its purpose is to improve reproducible quality and security controls over the closed P9 baseline without adding product capabilities.

## 2. Goals

- Establish repeatable Flutter and backend regression controls.
- Add objective dependency vulnerability and secret scanning controls after tool approval.
- Review permissions, manifests, storage, logging and sensitive-data handling.
- Produce a bounded threat model and documented mitigations.
- Preserve P7–P9 behavior and historical baselines.

## 3. In scope

- Existing Flutter analyzer/lints, format and tests.
- Existing Maven compiler/build/test configuration and Testcontainers tests.
- Reproducible static analysis, dependency scanning and secret scanning.
- Permission and Android manifest audit; local remediation only under D10-03.
- Logging and evidence redaction review.
- Threat model for implemented mobile, backend, cache and routing/discovery surfaces.
- Regression validation of routing, discovery, POI experience, cache, reduced Driving, one-shot location and accessibility.
- Documentation and evidence updates.

## 4. Explicit out of scope

Search, geocoding, reverse geocoding, CEFI, LLM, STT, TTS, microphone, wake word, continuous GPS, tracking, movement/follow camera, driver progress, live ETA, rerouting, turn-by-turn, proximity/arrival alerts, geofencing, offline routing/maps/tiles, favorites, history, sync, authentication, traffic, CarPlay, Android Auto, P11 deployment, P12 road pilot, API/OpenAPI, database/Flyway, PostgreSQL/PostGIS, RoutingProvider, GraphHopper, Docker/Compose, Nginx, DNS/TLS and deployment architecture.

## 5. Existing baseline

- Flutter SDK and Dart versions are pinned by repository metadata; `pubspec.lock` is tracked.
- `flutter_lints` is enabled through `analysis_options.yaml`.
- Mobile dependencies include Drift/SQLite/crypto and existing P9 packages.
- Backend uses Java 21, Spring Boot 3.5.16, Maven Wrapper, Spring tests and Testcontainers.
- No GitHub workflow or repository security scanner was found.
- Android manifest requests INTERNET, coarse location and fine location. Location is required for the implemented one-shot feature; no new permission is authorized.

## 6. Tooling design gate

| Control | Existing | Proposed P10 gate | Decision status |
|---|---|---|---|
| Dart static analysis | `flutter analyze`, flutter_lints | Preserve existing control; add rules only with evidence | Ready for human approval |
| Java static/build checks | Maven compiler/tests/Spring tests | Preserve Maven baseline; additional SAST only if justified | Ready for human approval |
| Dependency scan | No configured scanner found | Select one reproducible offline/CI-compatible tool after D10 approval | Design gate |
| Secret scan | No configured scanner found | Select one pinned scanner after repository/tooling discovery | Design gate |

No tool, version, external service, credential or paid account is frozen by this draft.

## 7. Vulnerability policy

- `CRITICAL` or `HIGH`: blocking; requires remediation, documented accepted exception by human gate, or STOP_AND_REPORT.
- `MEDIUM`: non-blocking only with owner, rationale and due checkpoint.
- `LOW`: may remain open with explicit technical-debt record.
- `INFORMATIONAL`: record when relevant to the threat model.
- Transitive findings follow the same severity policy. False positives require reproducible justification and evidence.
- “PASS” means no unaccepted blocking findings and complete evidence of the scan scope.

## 8. Secret and sensitive-data policy

Scan tracked content and the working tree, excluding generated build outputs only when the exclusion is documented. Fixtures and examples remain in scope. Do not print secret values. A possible real secret requires evidence sanitization and `STOP_AND_REPORT`; automatic rotation is forbidden.

Logs and evidence must not expose tokens, authorization headers, credentials, precise coordinates, route origin/destination, user identifiers, full request/response bodies or personal filesystem paths. Evidence uses redacted or synthetic values.

## 9. Threat model

Each threat record must contain: `ASSET`, `THREAT`, `ATTACK_SURFACE`, `LIKELIHOOD`, `IMPACT`, `EXISTING_CONTROL`, `GAP`, `MITIGATION`, `RESIDUAL_RISK`, `ACCEPTANCE`. Scope is limited to implemented product surfaces.

## 10. Regression baseline

P10 must preserve routing, Route Discovery, POI experience, one-snapshot offline cache, reduced Driving, one-shot location, permissions behavior and accessibility. Existing P7–P9 evidence is the baseline; physical repetition is not required unless an approved AC cannot be demonstrated otherwise.

## 11. Acceptance criteria draft

| ID | Requirement | Validation | Pass condition | Blocking |
|---|---|---|---|---|
| P10-AC-01 | Quality baseline is reproducible | format/analyze/tests/Maven | All required commands pass with captured versions | Yes |
| P10-AC-02 | Dependency risk is assessed | pinned dependency scan | No unaccepted Critical/High findings | Yes |
| P10-AC-03 | Secret exposure is assessed | tracked/worktree secret scan | No confirmed secret; false positives documented | Yes |
| P10-AC-04 | Static analysis is effective | Dart and Java analysis review | No new blocking issue; configuration recorded | Yes |
| P10-AC-05 | Permissions are justified | manifest and runtime mapping | No unnecessary/new sensitive permission | Yes |
| P10-AC-06 | Sensitive data is protected | logging/evidence inspection | No prohibited data leakage | Yes |
| P10-AC-07 | Threat model is complete | threat-model review | Required fields complete for implemented surfaces | Yes |
| P10-AC-08 | P9 regression is absent | existing automated suites | Routing, discovery, cache, Driving and accessibility remain passing | Yes |
| P10-AC-09 | Historical contracts remain intact | hashes/diff audit | P7–P9 contracts and baselines unchanged | Yes |
| P10-AC-10 | Closure evidence is complete | document and human review | All AC evidence linked; no unaccepted blocker | Yes |

## 12. Checkpoints

- **P10.1 Baseline and audit:** inventory commands, dependencies, permissions, logs and existing controls. No remediation.
- **P10.2 Tooling gate:** propose and human-approve pinned dependency/secret scanners. No implementation until approved.
- **P10.3 Remediation:** configuration, test hardening, dependency or permission fixes strictly within approved findings. API/DB/infra/provider/new capability findings STOP.
- **P10.4 Regression and evidence:** execute approved suites and scans; produce sanitized evidence.
- **P10.5 Closure:** reconcile documentation, audit residual risk and obtain human closure.

## 13. Remediation policy

Autonomous work may include configuration remediation, test hardening, dependency remediation, permission remediation and logging remediation only when the approved finding is objective and remains inside this contract. New capabilities, API/DB/infra/provider changes, paid services or new sensitive permissions require STOP_AND_REPORT.

P9 residuals remain open unless a checkpoint explicitly includes them:
`TECH_DEBT_P9_1_001 = LOW / OPEN_NON_BLOCKING`; TalkBack mixed-language observation remains non-blocking; no-backup remains an accepted P9 limitation.

## 14. Human gates and STOP_AND_REPORT

Human approval is required for scanner/tool selection, any permission or manifest change, any blocking vulnerability exception, scope expansion, external service, new dependency with material impact, or physical-device validation.

Stop on any Critical/High unresolved finding, confirmed secret, material privacy defect, contract regression, API/DB/infra change, new capability, contradictory evidence or requirement to start P11/P12.

## 15. Closure conditions

P10 may close only after all blocking ACs pass, evidence is sanitized and reproducible, P7–P9 contracts remain intact, residual risks have human disposition, documentation is reconciled and human closure is approved. This document remains a draft until that gate.

## 16. Human approval and frozen decisions

```ini
D10_01_SCOPE = APPROVED
D10_02_SECURITY_CAPABILITIES = APPROVED
D10_02_TOOL_SELECTION = DEFERRED_TO_P10_2_HUMAN_GATE
D10_03_PERMISSION_REMEDIATION = APPROVED_ONLY_FOR_OBJECTIVELY_DEMONSTRATED_EXCESS
D10_04_API_DB_INFRA = OUT_OF_SCOPE
D10_05_SEARCH_GEOCODING = OUT_OF_SCOPE_P10
D10_06_CEFI_VOICE = OUT_OF_SCOPE_P10
D10_07_PHYSICAL_VALIDATION = NOT_REQUIRED_BY_DEFAULT
P9_RESIDUALS = NOT_AUTOMATICALLY_INCLUDED_IN_P10
STALE_SECONDARY_DOCUMENTATION = RECONCILE_WHEN_TOUCHED_OR_AT_P10_CLOSURE
GIT_HISTORY_SECRET_SCAN = DECIDE_AT_P10_2_TOOLING_GATE
P10_IMPLEMENTATION = NOT_AUTHORIZED_YET
```

The human-approved vulnerability policy is: Critical and High are blocking; Medium is non-blocking only with an owner, rationale and due checkpoint; Low may remain explicit technical debt; Informational findings are recorded when relevant to the threat model. False positives require reproducible justification, transitive findings follow the same policy, and exceptions to blocking findings require a human gate.

The approved checkpoints are P10.1 Baseline and Audit, P10.2 Tooling Gate, P10.3 Remediation, P10.4 Regression and Evidence, and P10.5 Closure. P10.2 depends on P10.1; P10.3 requires known findings and approved scanner decisions where applicable; P10.4 requires reconciled remediation; P10.5 requires P10.1–P10.4 and human closure.

This contract is approved and frozen, but implementation remains unauthorized. Scanner selection, versions, licensing, network requirements, local/CI operation, false-positive handling and failure policy remain deferred to the P10.2 human gate. No scanner is installed or configured by this contract-freeze action.

## Canonical declarations

```ini
DEPENDENCY_SCANNER = DEFERRED_TO_P10_2_HUMAN_GATE
SECRET_SCANNER = DEFERRED_TO_P10_2_HUMAN_GATE
P10.1 = BASELINE_AND_AUDIT
P10.2 = TOOLING_GATE
P10.3 = REMEDIATION
P10.4 = REGRESSION_AND_EVIDENCE
P10.5 = CLOSURE
GIT_HISTORY_SECRET_SCAN = DECIDE_AT_P10_2_TOOLING_GATE
```
