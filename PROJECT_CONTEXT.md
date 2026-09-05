# Project Context

## Status

First Operational Pilot. P1 y P2 están cerradas; M03 — API base disponible está
cumplido. El PR #5 fue integrado en `main` mediante el merge commit `07001b9`, que es el
baseline Git de P3. El privilegio elevado actual de `geoguide_app` permanece registrado
como deuda de hardening posterior.

P3 — POI Data & Domain está implementado y validado técnicamente en la rama
`feature/p3-poi-data-domain`. P3 comprende Domain + Persistence + Data para producir un
baseline POI canónico, versionado, geoespacial, trazable, reproducible, idempotente y
probado para Lima → Obrajillo. No incluye API HTTP, controllers, OpenAPI Places,
search, nearby, routing, RoutingProvider, Route Discovery, ranking, Flutter, UX móvil,
voz ni IA. R3 — Data: POIs piloto validados está cumplido. P3 fue cerrado mediante el
PR #7 y el merge commit `aaa4c6b`.

## Product definition

GeoGuide AI is a mobile platform for intelligent geographic discovery built with an
Open Source First technology strategy. This strategy does not determine the product
license, whose current legal status is governed by `LICENSE`. The product helps people
understand what is worth discovering around their current location and along a planned
or active route. It is neither a replacement for Google Maps/Waze nor a generic chatbot.

The product covers cultural, historical, archaeological, natural, gastronomic, and other useful POIs. Enriched place cards distinguish reliable sourced facts from generated summaries. Route Discovery analyzes POIs near a route corridor; detour distance and additional time may be introduced incrementally.

## Approved MVP architecture

- Mobile: Flutter / Dart.
- Backend: Java 21, Spring Boot 3, Modular Monolith, Clean Architecture.
- Data: PostgreSQL + PostGIS, Redis, and MinIO.
- Maps/data: OpenStreetMap.
- Routing: `RoutingProvider`; GraphHopper 11.0 is the initial implementation selected
  by ADR-028. OSRM and Valhalla remain replaceable alternatives.
- Infrastructure: Linux, Docker, Docker Compose, and Nginx.
- CI/CD: GitHub Actions.
- AI: contextual to location, route, POIs, preferences, and travel state; advanced generative capabilities remain optional and decoupled through `LanguageModelProvider`.

## Interaction architecture

- Flutter UI, voice, and future clients reuse channel-independent application services.
- Strategic hands-free flow: STT -> intent and context interpretation -> GeoGuide services -> TTS.
- Driving/Travel Mode prioritizes short spoken answers, minimal visual distraction, and no required phone manipulation while driving.
- Voice must not make an LLM, complex personalization, CarPlay, or Android Auto mandatory for the core MVP.

## Principles

- Route Discovery Engine is the core differentiator.
- Facts First, AI Second.
- Do not permanently store user GPS history by default.
- Architecture changes require an accepted ADR.

Kubernetes, microservices, mandatory public cloud, complex ML personalization,
advanced generated itineraries, CarPlay/Android Auto integrations, and real-time traffic are outside the MVP. See
`DOCUMENTATION_INDEX.md` for authority order: most recent accepted ADR, Entrega 04.6, specialized current documentation, Entrega 11, Foundation, then archive.
