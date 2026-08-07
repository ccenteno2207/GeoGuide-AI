# AGENTS.md

Read `AGENTS.md`, `PROJECT_CONTEXT.md`, `DOCUMENTATION_INDEX.md`, Entrega 04.6, then task-relevant specialized documentation.

Authority: most recent accepted ADR; Entrega 04.6; Entregas 04.1-10; Entrega 11; Foundation; archive. Archived documents are non-authoritative.

The MVP uses Flutter/Dart, Java 21/Spring Boot 3, Modular Monolith, Clean Architecture, PostgreSQL/PostGIS, Redis, MinIO, OpenStreetMap, RoutingProvider, Linux, Docker Compose, Nginx, and GitHub Actions. Route Discovery is the priority; Facts First, AI Second.

`LICENSE` must never be modified, replaced, or re-licensed by an AI agent without explicit approval from the project owner. Do not change architecture, stack, or contracts without an ADR where applicable. Do not introduce Kubernetes, microservices, or mandatory public cloud. Preserve `RoutingProvider`, `ObjectStorageProvider`, `LanguageModelProvider`, repositories, and adapters. Use PostGIS where it adds value. Do not permanently store GPS history by default.

Documentation is in Spanish where practical; code is in English. Use OpenAPI for HTTP contracts and prefer PlantUML for new textual diagrams.

## Engineering Workflow

For every implementation task:

1. Inspect the repository and task-relevant documentation.
2. Check applicable ADRs.
3. Present a short implementation plan.
4. Modify only the required scope.
5. Add or update tests.
6. Run relevant validation commands.
7. Fix failures before progressing.
8. Update affected documentation/contracts.
9. Report changed files and validation results.
10. Do not automatically start the next milestone.

## Required Validation

Backend:

- `mvn verify`

Mobile:

- `dart format .`
- `flutter analyze`
- `flutter test`

Infrastructure:

- `docker compose config`

Documentation:

- `git diff --check`

Run only commands relevant to the current task.

## Definition of Done

A task is complete only when:

- architecture is respected;
- code builds;
- relevant tests pass;
- no secrets are introduced;
- security/privacy impact is considered;
- OpenAPI is updated when API contracts change;
- Flyway migration exists when database schema changes;
- documentation is updated when required.

## Current Project Priority

Current milestone progression:

- P0 Repository & Documentation Readiness
- P1 Local Infrastructure
- P2 Backend Bootstrap
- P3 POI Data
- P4 Routing
- P5 Route Discovery
- P6 Mobile Bootstrap
- P7 First Vertical Slice

The immediate objective is the First Operational Pilot.

Do NOT attempt to build the entire product in a single task.
