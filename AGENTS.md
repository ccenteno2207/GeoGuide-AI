# AGENTS.md

Read `AGENTS.md`, `PROJECT_CONTEXT.md`, `DOCUMENTATION_INDEX.md`, Entrega 04.6, then task-relevant specialized documentation.

Authority is scoped rather than a single linear chain: `AGENTS.md` defines global agent rules; `PROJECT_CONTEXT.md` defines current technical/product state; `ROADMAP.md` defines progression; accepted ADRs govern architecture; an approved phase contract governs the authorized scope of the current phase; `AI_DEVELOPMENT_GUIDE.md` defines the execution method; specialized documentation supplies technical detail. Entrega 04.6 remains the architecture baseline. Archived documents are non-authoritative.

The MVP uses Flutter/Dart, Java 21/Spring Boot 3, Modular Monolith, Clean Architecture, PostgreSQL/PostGIS, Redis, MinIO, OpenStreetMap, RoutingProvider, Linux, Docker Compose, Nginx, and GitHub Actions. Route Discovery is the priority; Facts First, AI Second.

GeoGuide AI is a mobile platform for intelligent geographic discovery built with an Open Source First technology strategy. This strategy does not determine the product license; `LICENSE` is the current legal file. It is not a Google Maps/Waze replacement and not a generic chatbot. It discovers trustworthy cultural, historical, archaeological, natural, gastronomic, and other POIs around the current location and along a route. Real-time traffic is not an MVP requirement.

GeoGuide AI remains the official product and application name. CEFI is the conversational copilot identity within GeoGuide AI, not a separate product. CEFI may communicate information and recommendations produced by shared GeoGuide capabilities, but it does not replace Routing, Route Discovery, or factual data sources. Documenting CEFI does not authorize implementation or add it to the current phase scope.

Voice is a strategic hands-free channel, especially while driving: STT -> contextual intent -> channel-independent GeoGuide services -> TTS. Location, active route, nearby POIs, preferences, and travel state form the authorized session context. Keep spoken responses brief and visual distraction minimal in Driving/Travel Mode. Do not put domain or application logic in Flutter screens, STT/TTS adapters, or prompts; visual UI, voice, and future clients reuse the same application services. Advanced AI, complex personalization, generated itineraries, CarPlay, and Android Auto are later evolution unless explicitly brought into scope.

`LICENSE` must never be modified, replaced, or re-licensed by an AI agent without explicit approval from the project owner. Do not change architecture, stack, or contracts without an ADR where applicable. Do not introduce Kubernetes, microservices, or mandatory public cloud. Preserve `RoutingProvider`, `ObjectStorageProvider`, `LanguageModelProvider`, repositories, and adapters. Use PostGIS where it adds value. Do not permanently store GPS history by default.

Documentation is in Spanish where practical; code is in English. Use OpenAPI for HTTP contracts and prefer PlantUML for new textual diagrams.

## Engineering Workflow

Roadmap placement does not authorize implementation. Future architecture does not automatically belong to the current phase. Proposal does not equal approval. Before implementing a major phase: audit documentation -> identify contradictions -> define and freeze scope -> obtain approval -> implement -> validate -> integrate -> validate post-merge -> formally close. A merged PR does not by itself close a phase.

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

- P0 Repository & Documentation Readiness — CLOSED
- P1 Local Infrastructure — CLOSED
- P2 Backend Bootstrap — CLOSED
- P3 POI Data — CLOSED
- P4 Routing — CLOSED
- P5 Route Discovery — CLOSED
- P6 Mobile Bootstrap — CLOSED / COMPLETED
- P7 First Vertical Slice — CLOSED / COMPLETED — 100%
- P8 POI Experience — NOT STARTED
- P9 Offline + Driving — PLANNED
- P10 Quality + Security — PLANNED
- P11 Linux Server Deployment — PLANNED
- P12 Real Road Pilot — PLANNED

P0–P7 are completed. The P7 closure baseline is `ada26c8881cdefb2d8f0ede679a8ebb3996ab61c` (PR #31): P7.5 is CLOSED, P7.6 is COMPLETED and P7-AC-01–P7-AC-11 passed. `P7-Validation-Evidence.md`, `PROJECT_CONTEXT.md`, `ROADMAP.md` and `CHANGELOG.md` record the final state. The frozen P7 contract remains an immutable normative snapshot; its historical execution/TLS statuses do not override the subsequent closure evidence. See [post-P7 reconciliation](docs/11-Master-Documentation/11-Implementation-Plan/Post-P7-Documentation-Reconciliation.md).

P8 remains NOT STARTED, without a phase contract. Its planning source is `preview/detail/filter`; this reconciliation does not authorize implementation. Verify the effective `main` and `origin/main` before authorized work instead of treating a recorded SHA as permanent.

Do NOT attempt to build the entire product in a single task.
