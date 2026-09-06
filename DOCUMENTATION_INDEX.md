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
| P5 validation and master closure evidence | `docs/11-Master-Documentation/11-Implementation-Plan/P5-Validation-Evidence.md` |
| Current or future phase scope | Approved phase contract when one exists; roadmap placement alone is insufficient |
| Codex execution method | `AI_DEVELOPMENT_GUIDE.md` and current Codex handoff documents |
| P3 completion and R3 acceptance | `docs/11-Master-Documentation/11-Implementation-Plan/P3-Definition-of-Done.md` — canonical normative source |
| P3 validation evidence | `docs/11-Master-Documentation/11-Implementation-Plan/P3-Validation-Evidence.md` |

Archived documents must not be used as current architecture or implementation
guidance unless explicitly requested.

Current state: P0–P5 are closed. The official post-P5 baseline is
`d50fb8e2d807dc97a16c81f4ffaa6fcfa89fbaca`; P6 is not started and not authorized,
and P7–P12 are planned. No active instruction may turn this progression into automatic scope.

“AI optional in the core MVP” means route, POI, corridor, ranking, and factual place cards cannot depend on an LLM. It does not negate the strategic voice channel: voice remains an adapter over the same channel-independent GeoGuide use cases used by Flutter and future clients.
