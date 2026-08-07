# Project Context

## Status

First Operational Pilot.

## Approved MVP architecture

- Mobile: Flutter / Dart.
- Backend: Java 21, Spring Boot 3, Modular Monolith, Clean Architecture.
- Data: PostgreSQL + PostGIS, Redis, and MinIO.
- Maps/data: OpenStreetMap.
- Routing: `RoutingProvider`; GraphHopper, Valhalla, and OSRM are candidates.
- Infrastructure: Linux, Docker, Docker Compose, and Nginx.
- CI/CD: GitHub Actions.
- AI: optional and decoupled through `LanguageModelProvider`.

## Principles

- Route Discovery Engine is the core differentiator.
- Facts First, AI Second.
- Do not permanently store user GPS history by default.
- Architecture changes require an accepted ADR.

Kubernetes, microservices, mandatory public cloud, complex ML personalization,
and advanced traffic management are outside the MVP. See
`DOCUMENTATION_INDEX.md` for authority order: most recent accepted ADR, Entrega 04.6, specialized current documentation, Entrega 11, Foundation, then archive.
