# Roadmap

The priority is the First Operational Pilot.

| Priority | Milestone |
| --- | --- |
| P0 | Repository & Documentation Readiness |
| P1 | Local Infrastructure |
| P2 | Backend Bootstrap — CERRADO; M03 cumplido; PR #5 integrado en `main` mediante `07001b9` |
| P3 | POI Data & Domain — CERRADO; R3 cumplido; PR #7 integrado mediante `aaa4c6b` |
| P4 | Routing |
| P5 | Route Discovery |
| P6 | Mobile Bootstrap |
| P7 | First Vertical Slice |
| P8 | POI Experience |
| P9 | Offline + Driving |
| P10 | Quality + Security |
| P11 | Linux Server Deployment |
| P12 | Real Road Pilot |

AI does not block the core MVP. Kubernetes, microservices, and mandatory public cloud remain out of scope.

P3 comprende Domain + Persistence + Data para producir un baseline POI canónico,
versionado, geoespacial, trazable, reproducible, idempotente y probado para el corredor
Lima → Obrajillo. R3 — Data: POIs piloto validados es el release gate para aceptar el
dataset resultante al cierre de P3 y cumple técnicamente. API, routing, Route Discovery
y experiencia POI pertenecen a fases posteriores.
