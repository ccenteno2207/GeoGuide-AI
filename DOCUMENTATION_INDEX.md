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
| P5 validation and master closure evidence | `docs/11-Master-Documentation/11-Implementation-Plan/P5-Validation-Evidence.md` |
| P9 contract awaiting final human approval | [Contract v1](docs/11-Master-Documentation/11-Implementation-Plan/P9-Phase-Contract-v1.md), [local cache design](docs/11-Master-Documentation/11-Implementation-Plan/P9-Local-Cache-Design-v1.md), [documentary evidence](docs/11-Master-Documentation/11-Implementation-Plan/P9.0-Contract-Finalization-Evidence.md) |
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
P9 is NOT_STARTED_IMPLEMENTATION; P9.0 is AWAITING_FINAL_CONTRACT_APPROVAL. Contract v1 is READY_FOR_FINAL_HUMAN_REVIEW; D01–D05 are resolved documentally, D06 is DEFERRED. P9.1 is NOT_STARTED and implementation is NOT_AUTHORIZED. P10–P12 remain planned. No active instruction may turn this
progression into automatic scope.

The P7 phase contract is an immutable normative snapshot. Its historical TLS and
checkpoint statuses are preserved; the later final state is recorded by the P7
validation evidence and the current-state sources listed above. The post-P7
reconciliation records subsequent DNS evidence without rewriting that contract.

“AI optional in the core MVP” means route, POI, corridor, ranking, and factual place cards cannot depend on an LLM. It does not negate the strategic voice channel: voice remains an adapter over the same channel-independent GeoGuide use cases used by Flutter and future clients.
