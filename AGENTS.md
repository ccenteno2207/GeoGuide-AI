# AGENTS.md

Read `AGENTS.md`, `PROJECT_CONTEXT.md`, `DOCUMENTATION_INDEX.md`, Entrega 04.6, then task-relevant specialized documentation.

Authority: most recent accepted ADR; Entrega 04.6; Entregas 04.1-10; Entrega 11; Foundation; archive. Archived documents are non-authoritative.

The MVP uses Flutter/Dart, Java 21/Spring Boot 3, Modular Monolith, Clean Architecture, PostgreSQL/PostGIS, Redis, MinIO, OpenStreetMap, RoutingProvider, Linux, Docker Compose, Nginx, and GitHub Actions. Route Discovery is the priority; Facts First, AI Second.

`LICENSE` must never be modified, replaced, or re-licensed by an AI agent without explicit approval from the project owner. Do not change architecture, stack, or contracts without an ADR where applicable. Do not introduce Kubernetes, microservices, or mandatory public cloud. Preserve `RoutingProvider`, `ObjectStorageProvider`, `LanguageModelProvider`, repositories, and adapters. Use PostGIS where it adds value. Do not permanently store GPS history by default.

Documentation is in Spanish where practical; code is in English. Use OpenAPI for HTTP contracts and prefer PlantUML for new textual diagrams.
