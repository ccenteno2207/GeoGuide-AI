# Roadmap

The priority is the First Operational Pilot.

| Priority | Milestone | Status |
| --- | --- | --- |
| P0 | Repository & Documentation Readiness | CLOSED |
| P1 | Local Infrastructure | CLOSED |
| P2 | Backend Bootstrap | CLOSED |
| P3 | POI Data & Domain | CLOSED |
| P4 | Routing | CLOSED |
| P5 | Route Discovery | CLOSED |
| P6 | Mobile Bootstrap | CLOSED |
| P7 | First Vertical Slice | CLOSED |
| P8 | POI Experience | CLOSED |
| P9 | Offline + Driving | NOT STARTED IMPLEMENTATION |
| P10 | Quality + Security | PLANNED |
| P11 | Linux Server Deployment | CLOSED_WITH_OPEN_PRODUCTION_READINESS_DEBT |
| P12 | Real Road Pilot | DISCOVERY_SCOPE_GATE_REQUIRED |

AI does not block the core MVP. Kubernetes, microservices, and mandatory public cloud remain out of scope.

P4 cerró el routing puro: `RoutingProvider`, adaptador GraphHopper 11,
`POST /api/v1/routes/plan`, geometría GeoJSON `LineString`, normalización y pruebas.
P5 cerró Route Discovery mediante el PR #14, con los checkpoints P5.0-A–P5.7 y los
23 criterios de Definition of Done completados. Su baseline resultante oficial es
`d50fb8e2d807dc97a16c81f4ffaa6fcfa89fbaca` (P0–P5 completados). P6 cerró el
bootstrap Flutter, mapa base e integración de ubicación puntual conforme a su contrato;
la evidencia canónica es `P6-Validation-Evidence.md`. P7 — First Vertical Slice
cerró con P7.1–P7.6 completados, TLS productivo y E2E Android HTTPS PASS.
P8 — POI Experience cerró en `7dfb0293507dcfa1eef90533c4dc9dbdd4d2a229`
(PR #43), con P8.6/P8.7 COMPLETED, Android físico PASS y Docker integration PASS;
la fuente autoritativa es [P8.7 Final Audit and Closure](docs/11-Master-Documentation/11-Implementation-Plan/P8.7-Final-Audit-and-Closure.md).
P0–P8 están completadas. P9.0 realiza discovery / definición de contrato; P9 no
ha iniciado implementación y requiere aprobación humana. P10–P12 siguen planificadas.
El nombre Offline + Driving se conserva como dirección de producto; no define
por sí solo un alcance implementable.

Roadmap position defines project progression, not implementation authorization. Every
major phase requires scope confirmation, freeze and approval before implementation.

## P9 — cierre final

P9 queda cerrado tras la reconciliación documental y el gate humano final. P9.1, P9.2, P9.3 y P9.4 están cerradas. P10 permanece planificada y no iniciada.

