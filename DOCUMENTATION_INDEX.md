# Documentation Index

## Authority order

1. Most recent accepted ADR.
2. Entrega 04.6: `docs/04-SolutionArchitecture/06-Master-Architecture/`.
3. Specialized documentation in Entregas 04.1 through 10.
4. Entrega 11 Master Documentation.
5. Foundation documentation.
6. `docs/archive/`, which is non-authoritative.

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
| Architecture decision | Accepted ADR, then Entrega 04.6 |
| Route Discovery | `docs/04-SolutionArchitecture/04-Route-Discovery-Engine/` |
| Database and PostGIS | `02-Geospatial-Data-Model/` and Backend Engineering |
| Mobile | `docs/07-Mobile-Engineering/` |
| DevOps | `docs/08-DevOps-Cloud/` |
| Data and AI | `docs/09-Data-AI/` |
| Commercial | `docs/10-Roadmap-Comercial/` |
| Implementation plan | `docs/11-Master-Documentation/` |

Archived documents must not be used as current architecture or implementation
guidance unless explicitly requested.
