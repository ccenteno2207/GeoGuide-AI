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
| P7 | First Vertical Slice | IN PROGRESS |
| P8 | POI Experience | PLANNED |
| P9 | Offline + Driving | PLANNED |
| P10 | Quality + Security | PLANNED |
| P11 | Linux Server Deployment | PLANNED |
| P12 | Real Road Pilot | PLANNED |

AI does not block the core MVP. Kubernetes, microservices, and mandatory public cloud remain out of scope.

P4 cerró el routing puro: `RoutingProvider`, adaptador GraphHopper 11,
`POST /api/v1/routes/plan`, geometría GeoJSON `LineString`, normalización y pruebas.
P5 cerró Route Discovery mediante el PR #14, con los checkpoints P5.0-A–P5.7 y los
23 criterios de Definition of Done completados. Su baseline resultante oficial es
`d50fb8e2d807dc97a16c81f4ffaa6fcfa89fbaca` (P0–P5 completados). P6 cerró el
bootstrap Flutter, mapa base e integración de ubicación puntual conforme a su contrato;
la evidencia canónica es `P6-Validation-Evidence.md`. P7 está en progreso: P7.1–P7.4
fueron integrados y P7.5 completó el gate de conectividad segura; P7.6 permanece no
iniciado. P8–P12 permanecen planificadas.

Roadmap position defines project progression, not implementation authorization. Every
major phase requires scope confirmation, freeze and approval before implementation.
