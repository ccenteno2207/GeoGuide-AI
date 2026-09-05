# Roadmap

The priority is the First Operational Pilot.

| Priority | Milestone | Status |
| --- | --- | --- |
| P0 | Repository & Documentation Readiness | CLOSED |
| P1 | Local Infrastructure | CLOSED |
| P2 | Backend Bootstrap | CLOSED |
| P3 | POI Data & Domain | CLOSED |
| P4 | Routing | CLOSED |
| P5 | Route Discovery | NEXT / NOT STARTED |
| P6 | Mobile Bootstrap | PLANNED |
| P7 | First Vertical Slice | PLANNED |
| P8 | POI Experience | PLANNED |
| P9 | Offline + Driving | PLANNED |
| P10 | Quality + Security | PLANNED |
| P11 | Linux Server Deployment | PLANNED |
| P12 | Real Road Pilot | PLANNED |

AI does not block the core MVP. Kubernetes, microservices, and mandatory public cloud remain out of scope.

P4 cerró el routing puro: `RoutingProvider`, adaptador GraphHopper 11,
`POST /api/v1/routes/plan`, geometría GeoJSON `LineString`, normalización y pruebas.
Route Discovery permanece separado en P5.

Roadmap position defines project progression, not implementation authorization. Every
major phase requires scope confirmation, freeze and approval before implementation.
