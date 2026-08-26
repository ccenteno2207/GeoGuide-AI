# ADR Registry

Future ADRs use unique sequential identifiers. The next available identifier is `ADR-029`. Historical files retain their original names and content.

| Legacy ID | Title | Status | Current path | Domain | Authority | Notes |
| --- | --- | --- | --- | --- | --- | --- |
| ADR-0001 | Clean Architecture and DDD | Legacy, no explicit status | `ADR/ADR-0001.md` | Foundation | Foundation | Pre-baseline identifier. |
| ADR-001 | Open Source First | Legacy, no explicit status | `../../04-SolutionArchitecture/ADR/04.1-Enterprise-Architecture/ADR-001-OpenSource.md` | Enterprise | Specialized | ID collides with OpenStreetMap ADR. |
| ADR-001 | OpenStreetMap | Legacy, no explicit status | `../../archive/pre-baseline/solution-architecture-core/09-ADRs/ADR-001-OpenStreetMap.md` | Maps | Archived | Historical duplicate identifier; non-authoritative. |
| ADR-002 | Map Engine | Legacy, no explicit status | `../../04-SolutionArchitecture/ADR/04.1-Enterprise-Architecture/ADR-002-MapEngine.md` | Maps | Specialized | Historical identifier. |
| ADR-007 to ADR-012 | REST, JWT/RBAC, Nginx, Route Discovery, RoutingProvider, PostGIS | Accepted where stated | `../../04-SolutionArchitecture/ADR/` | Solution architecture | Current | Entrega 04 accepted ADR set. |
| ADR-013 to ADR-026 | Backend, mobile, DevOps, data, and AI decisions | Accepted where stated | `ADR/06-Backend-Engineering/` through `ADR/09-Data-AI/` | Cross-domain | Current | See original files for status and context. |
| ADR-027 | Channel-independent interaction and contextual voice | Accepted | `ADR/07-Mobile-Engineering/ADR-027-Channel-Independent-Interaction-and-Voice.md` | Mobile / Application / AI | Current | Voice is an adapter over shared GeoGuide use cases; it does not make an LLM mandatory. |
| ADR-028 | GraphHopper as initial routing engine | Accepted | `ADR/04-Route-Discovery/ADR-028-GraphHopper-Initial-Routing-Engine.md` | Route Discovery / Infrastructure | Current | Confirms GraphHopper 11.0 behind RoutingProvider; OSRM remains the performance alternative. |
