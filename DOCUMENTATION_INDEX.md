# Documentation Index

## Ámbitos de autoridad y orden de lectura

1. `AGENTS.md`: reglas globales y punto de entrada de agentes.
2. `PROJECT_CONTEXT.md`: estado técnico y de producto vigente.
3. `ROADMAP.md`: progresión oficial P0–P12; no autoriza implementación.
4. ADR aceptados aplicables: decisiones arquitectónicas.
5. Entrega 04.6: baseline arquitectónica.
6. Contrato de fase aprobado: alcance autorizado de la fase actual, sin poder
   contradecir los ADR ni la arquitectura.
7. `AI_DEVELOPMENT_GUIDE.md`, handoffs y documentación especializada: método y detalle.
8. Entrega 11 y documentación Foundation: soporte y trazabilidad.
9. `docs/archive/`: historia no autoritativa.

## Documentation domains

| Path | Purpose | Authority | When to read |
| --- | --- | --- | --- |
| `docs/00-Executive/` | Vision, principles, licensing status | Foundation | Product scope and governance |
| `docs/01-Business/` | Business, market, product, commercial roadmap | Foundation + Entrega 10 | Product and commercial decisions |
| `docs/02-Architecture/ADR/` | Accepted and legacy ADR records | Highest when accepted | Any architecture decision |
| `docs/02-Architecture/` | Portability and architecture governance | Current | Technology boundaries |
| `docs/03-Requirements/` | Rules, cases, and navigation requirements | Foundation | Requirement implementation |
| `docs/04-SolutionArchitecture/` | Enterprise, geospatial, API, Route Discovery, diagrams, master architecture | Current | System architecture |
| `docs/05-UX-UI/` | UX/UI design and handoff | Current specialized | UX and mobile interface work |
| `docs/06-Backend-Engineering/` | Backend engineering | Current specialized | Backend work |
| `docs/07-Mobile-Engineering/` | Mobile engineering | Current specialized | Flutter work |
| `docs/08-DevOps-Cloud/` | DevOps, deployment, and runbooks | Current specialized | Infrastructure and operations |
| `docs/09-Data-AI/` | Data, AI, governance, and evaluation | Current specialized | Data and AI work |
| `docs/10-Roadmap-Comercial/` | Commercial roadmap | Current specialized | Pilot and market planning |
| `docs/11-Master-Documentation/` | Consolidated index, traceability, and implementation plans | Supporting | Cross-domain planning |
| `docs/archive/` | Historical pre-baseline material | Non-authoritative | Traceability only |

## Where should I look?

| Need | Read |
| --- | --- |
| Current phase and implementation status | `AGENTS.md`, `PROJECT_CONTEXT.md`, and `ROADMAP.md` |
| Architecture decision | Accepted ADR, then Entrega 04.6 |
| Product scope and MVP boundaries | `PROJECT_CONTEXT.md`, `docs/00-Executive/MVP_SCOPE.md`, and Product Master |
| CEFI product identity | `PROJECT_CONTEXT.md` for current status; Product Master for the canonical product definition; UX Vision and AI UX for experience and safety principles |
| Route Discovery | `docs/04-SolutionArchitecture/04-Route-Discovery-Engine/` |
| Voice, contextual interaction, and Driving Mode | `ADR-027`, `docs/07-Mobile-Engineering/10-Driving-Mode/`, and AI UX |
| Database and PostGIS | `02-Geospatial-Data-Model/` and Backend Engineering |
| Mobile | `docs/07-Mobile-Engineering/` |
| DevOps | `docs/08-DevOps-Cloud/` |
| Data and AI | `docs/09-Data-AI/` |
| Commercial | `docs/10-Roadmap-Comercial/` |
| Implementation plan | `docs/11-Master-Documentation/` |
| P4 routing implementation | `PROJECT_CONTEXT.md`, Backend Engineering, Routing Infrastructure, Test Catalog, and Decision Register |
| P5 frozen scope and execution contract | `docs/11-Master-Documentation/11-Implementation-Plan/P5-Phase-Contract-v1.md` and `P5-Governance-Decisions.md` |
| P6 frozen scope and execution contract | `docs/11-Master-Documentation/11-Implementation-Plan/P6-Phase-Contract-v1.md` |
| P6 validation and closure evidence | `docs/11-Master-Documentation/11-Implementation-Plan/P6-Validation-Evidence.md` |
| P7 final state and closure evidence | `docs/11-Master-Documentation/11-Implementation-Plan/P7-Validation-Evidence.md`, `PROJECT_CONTEXT.md`, `ROADMAP.md`, `CHANGELOG.md` and PR #31 |
| Historical post-P7 reconciliation and DNS incident resolution | `docs/11-Master-Documentation/11-Implementation-Plan/Post-P7-Documentation-Reconciliation.md` |
| P8 frozen contract | `docs/11-Master-Documentation/11-Implementation-Plan/P8-Phase-Contract-v1.md` |
| P8 final state and closure evidence | `docs/11-Master-Documentation/11-Implementation-Plan/P8.7-Final-Audit-and-Closure.md` and PR #43 |
| UI-2.3.2 local search and accessibility corrective evidence | `docs/11-Master-Documentation/11-Implementation-Plan/UI-2.3.2-Local-Search-and-Accessibility-Corrective-Evidence.md`; S01 locally remediated, A01 TalkBack language cause unconfirmed and deferred |
| P5 validation and master closure evidence | `docs/11-Master-Documentation/11-Implementation-Plan/P5-Validation-Evidence.md` |
| P9 approved contract (human approval after documentary snapshot) | [Contract v1](docs/11-Master-Documentation/11-Implementation-Plan/P9-Phase-Contract-v1.md), [local cache design](docs/11-Master-Documentation/11-Implementation-Plan/P9-Local-Cache-Design-v1.md), [documentary evidence](docs/11-Master-Documentation/11-Implementation-Plan/P9.0-Contract-Finalization-Evidence.md) |
| P9.1 local cache implementation and validation | [P9.1 evidence](docs/11-Master-Documentation/11-Implementation-Plan/P9.1-Validation-Evidence.md); merged at `80cb217b0c2818a4a13861ba4a6457e21c5b9043`, post-merge validation PASS, closure ready |
| P9.2 reduced-interaction Driving evidence | [P9.2 evidence](docs/11-Master-Documentation/11-Implementation-Plan/P9.2-Validation-Evidence.md); closed at `756c0f33cabb1558c22d353ecaf6793194b93dd6`, 68/68 tests PASS |
| Current or future phase scope | Approved phase contract when one exists; roadmap placement alone is insufficient |
| Codex execution method | `AI_DEVELOPMENT_GUIDE.md` and current Codex handoff documents |
| P3 completion and R3 acceptance | `docs/11-Master-Documentation/11-Implementation-Plan/P3-Definition-of-Done.md` — canonical normative source |
| P3 validation evidence | `docs/11-Master-Documentation/11-Implementation-Plan/P3-Validation-Evidence.md` |

Archived documents must not be used as current architecture or implementation
guidance unless explicitly requested.

Current state: P0–P8 are completed and closed. P7 closed at
`ada26c8881cdefb2d8f0ede679a8ebb3996ab61c` (PR #31), with P7.5 CLOSED,
P7.6 COMPLETED and P7-AC-01–P7-AC-11 PASS. P8 closed at
`7dfb0293507dcfa1eef90533c4dc9dbdd4d2a229` (PR #43): P8.6/P8.7 COMPLETED,
physical Android PASS and Docker integration PASS, as recorded in P8.7 closure evidence.
The frozen P8 contract exists and remains unchanged; its opening statuses are historical.
P9.0 COMPLETED after explicit human approval and PR #45 merge at `c6f774c7121632c46c412ffc6faca83e715b1d10`. P9.1 is closed at documentary merge
`c659ed9ae4d31cbb58174c180bfcd9762f9d441f` after post-merge validation PASS.
P9.2 is closed at `756c0f33cabb1558c22d353ecaf6793194b93dd6` after post-merge
validation PASS; D06 remains DEFERRED. P10–P12 remain planned.

The P7 phase contract is an immutable normative snapshot. Its historical TLS and
checkpoint statuses are preserved; the later final state is recorded by the P7
validation evidence and the current-state sources listed above. The post-P7
reconciliation records subsequent DNS evidence without rewriting that contract.

“AI optional in the core MVP” means route, POI, corridor, ranking, and factual place cards cannot depend on an LLM. It does not negate the strategic voice channel: voice remains an adapter over the same channel-independent GeoGuide use cases used by Flutter and future clients.

## P9 final closure

La evidencia P9.4 registra `P9_4_AUDIT = PASS_WITH_NON_BLOCKING_ITEMS`, `P9_4_HUMAN_CLOSURE = APPROVED`, `P9_4 = CLOSED` y `P9 = CLOSED`. P9.1, P9.2 y P9.3 están cerradas. Los baselines históricos P9.0–P9.3 permanecen preservados; P10 sigue `NOT_STARTED` y `AUTONOMOUS_P10 = NOT_AUTHORIZED`.

| P10.2 tooling gate evidence | [P10.2 evidence](docs/11-Master-Documentation/11-Implementation-Plan/P10.2-Tooling-Gate-Evidence.md); OSV-Scanner 2.6.0 and Gitleaks 8.30.0 approved, Java SAST deferred |

| P10.3 remediation and security scan evidence | [P10.3 evidence](docs/11-Master-Documentation/11-Implementation-Plan/P10.3-Remediation-and-Security-Scan-Evidence.md); OSV/Gitleaks scans, format remediation, validation results |

| P10.4 regression and evidence | [P10.4 evidence](docs/11-Master-Documentation/11-Implementation-Plan/P10.4-Regression-and-Evidence.md); Docker/Testcontainers 6/6 real, security regression PASS |

| P10.5 closure audit evidence | [P10.5 evidence](docs/11-Master-Documentation/11-Implementation-Plan/P10.5-Closure-Audit-Evidence.md); audit PASS, ready for human closure |

| P11 contract proposal ||
| P11.1 baseline evidence | [P11.1 evidence](docs/11-Master-Documentation/11-Implementation-Plan/P11.1-Baseline-and-Discovery-Evidence.md); VM, service, exposure and public HTTPS baseline |
| P11.4 backup capacity and deferral | [P11.4 evidence](docs/11-Master-Documentation/11-Implementation-Plan/P11.4-Backup-Capacity-and-Deferral-Evidence.md); read-only capacity, Redis classification and approved Production Readiness deferral |
| P11.2–P11.6 operational evidence | [P11 operational evidence](docs/11-Master-Documentation/11-Implementation-Plan/P11.2-P11.6-Operational-Validation-Evidence.md); HTTPS, Compose, health, observability and deferred backup disposition |
| P11 closure evidence | [P11 closure](docs/11-Master-Documentation/11-Implementation-Plan/P11-Closure-Evidence.md); development closure with Production Readiness backup gate blocked |
| P12.0 discovery evidence | [P12.0 evidence](docs/11-Master-Documentation/11-Implementation-Plan/P12.0-Discovery-and-Product-Gap-Evidence.md); current capability gap, dependencies and scope decisions required |
| P12 phase contract | [P12 contract](docs/11-Master-Documentation/11-Implementation-Plan/P12-Phase-Contract-v1.md); frozen scope for controlled Real Road Pilot preparation |
| P12.2–P12.4 preparation evidence | [P12 preparation](docs/11-Master-Documentation/11-Implementation-Plan/P12.2-P12.4-Preparation-Evidence.md); route coverage PASS, P12.3 stationary device gate PASS, P12.4 readiness review pending; P12.5 not authorized |
| P12 current governance status | `P12_STATUS = IN_PROGRESS`; `P12_PROGRESS = 45_PERCENT` under the approved administrative deliverable model, not dynamic validation or functional closure; `GLOBAL_PROGRESS_MATHEMATICAL = 98.35_PERCENT`; `GLOBAL_PROGRESS_VISUAL = 98.4_PERCENT`; `P12_4 = PENDING_HUMAN_READINESS_REVIEW`; `P12_5 = NOT_AUTHORIZED`; `DYNAMIC_ROAD_VALIDATION = NOT_EXECUTED` |
| P12 multi-corridor discovery | [Multi-corridor evidence](docs/11-Master-Documentation/11-Implementation-Plan/P12-Multi-Corridor-Technical-Discovery.md); four candidate corridors, route/POI coverage and limitations |
| GPS Follow + Community POI discovery | [Proposal](docs/11-Master-Documentation/11-Implementation-Plan/GPS-Follow-and-Community-POI-Discovery.md); separate future capability discovery, Yaso candidate and governance gate |
| GPS Follow Mode contract proposal | [GPS proposal](docs/11-Master-Documentation/11-Implementation-Plan/GPS-Follow-Mode-Contract-Proposal.md); proposed-only contract, ACs, privacy and P12 gates |
| Photon LAB-08 ingestion feasibility | [Data-ingestion discovery](docs/11-Master-Documentation/11-Implementation-Plan/Photon-LAB-08-Data-Ingestion-Feasibility.md); documentary alternatives and cross-reference from the [isolated-lab proposal](docs/11-Master-Documentation/11-Implementation-Plan/Photon-Isolated-Lab-Resource-and-Execution-Contract-Proposal.md), LAB-08 remains open and execution is not authorized |

## GPS + CEFI — integración vigente

PR #76 integrado en `8a2e6cad14f2ae88111c0ba17dd89241894a5ee6`; implementación y pruebas automatizadas diferenciadas de evidencia estacionaria histórica y capacidades pendientes. P12.5 NOT_AUTHORIZED.

- [Gobierno y validación post-merge](docs/11-Master-Documentation/11-Implementation-Plan/GPS-CEFI-Post-Merge-Governance-Evidence.md).
- [R01: remediación de frescura y lifecycle GPS; evidencia y gate V01 pendiente](docs/11-Master-Documentation/11-Implementation-Plan/R01-GPS-Lifecycle-Remediation-Evidence.md).
- [Arquitectura Android y ADR candidato provisional](docs/11-Master-Documentation/11-Implementation-Plan/GPS-Android-Integration-Readiness-and-ADR-Candidate.md).

- [I01: selección explícita de POIs, contexto de sesión y validación automatizada](docs/11-Master-Documentation/11-Implementation-Plan/I01-Selected-POI-Session-Integration-Evidence.md); validación física I01 pendiente, sin nuevo crédito P12.
