# Project Context

## Status

First Operational Pilot. P2 (Backend Bootstrap) está técnicamente completada en la rama
`feature/p2-backend-bootstrap`, basada en `e21aeab`; su último checkpoint Git previo a
la auditoría es `095413f`. P2.0–P2.8 están completados y validados según su alcance;
P2.7A está completado y validado. El backend Java
21/Spring Boot 3.5.16 se ejecuta como UID/GID `10001:10001`, está incorporado a Compose
sin publicar 8080 y se conecta a PostgreSQL/PostGIS por la red interna. Flyway adoptó
controladamente el esquema P1 mediante baseline explícito `0`, con descripción
`P1 pre-Flyway PostGIS state`, ejecutó V001 y demostró idempotencia tras reinicio.
`mvnw.cmd verify` terminó con `BUILD SUCCESS`: 2 pruebas, 0 fallos, 0 errores y
0 omitidas. M03 — API base disponible: **CUMPLIDO TÉCNICAMENTE**. Checkpoint Git
documental de P2.8/M03: **PENDIENTE**. P3: **NO INICIADO**. El privilegio elevado
actual de `geoguide_app` queda registrado como deuda de hardening posterior. No se ha
creado PR ni realizado merge.

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
