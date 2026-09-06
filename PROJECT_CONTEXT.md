# Project Context

## Status

First Operational Pilot. P0–P5 están cerradas. El baseline oficial resultante de P5 es
`d50fb8e2d807dc97a16c81f4ffaa6fcfa89fbaca`; el PR funcional #14 fue integrado y la
validación post-merge de P5 terminó correctamente. P5.1–P5.7 están completados y sus
23 criterios de Definition of Done están satisfechos. El privilegio elevado actual de
`geoguide_app` permanece registrado como deuda de hardening posterior.

P4 implementó routing puro sin persistencia: el backend depende de `RoutingProvider`,
GraphHopper 11 se integra mediante un adaptador sustituible y
`POST /api/v1/routes/plan` devuelve distancia y duración normalizadas junto con una
geometría GeoJSON `LineString`. La URL, el perfil y el timeout backend → proveedor son
configurables; timeout, indisponibilidad, ausencia de ruta, respuesta inválida y errores
del proveedor se normalizan sin filtrar detalles internos. Las pruebas de aceptación y
la validación real en VM están completadas.

P5 — Route Discovery está **CERRADA**. P5.0-A–P5.0-D y P5.1–P5.7 están cerrados;
corredor PostGIS, selección de candidatos POI, ranking `DISCOVERY_V1`, progreso de ruta
y `POST /api/v1/routes/discover` fueron implementados y validados localmente y en VM.
P6 — Mobile Bootstrap **NO ESTÁ INICIADA NI AUTORIZADA**; P7–P12 permanecen
planificadas. El roadmap indica progresión, no autorización de ejecución.

## Product definition

GeoGuide AI is a mobile platform for intelligent geographic discovery built with an
Open Source First technology strategy. This strategy does not determine the product
license, whose current legal status is governed by `LICENSE`. The product helps people
understand what is worth discovering around their current location and along a planned
or active route. It is neither a replacement for Google Maps/Waze nor a generic chatbot.

The product covers cultural, historical, archaeological, natural, gastronomic, and other useful POIs. Enriched place cards distinguish reliable sourced facts from generated summaries. Route Discovery analyzes POIs near a route corridor; detour distance and additional time may be introduced incrementally.

### Conversational identity

- **Product:** GeoGuide AI.
- **Conversational identity:** CEFI.
- **Role:** CEFI is GeoGuide AI's voice-oriented conversational copilot for the rutero. It uses shared GeoGuide capabilities to communicate information, context, and recommendations while preserving user control.
- **Boundary:** CEFI does not replace Routing, Route Discovery, POI Data, or other technical and factual sources.
- **Status:** Product concept and future experience capability. Implementation is **NOT AUTHORIZED** unless an approved phase contract explicitly includes it. CEFI remained outside the closed P5 scope and was not implemented.

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
`DOCUMENTATION_INDEX.md` for the current authority model and navigation. Authority
is scoped by domain: accepted ADRs govern architecture, approved phase contracts govern
authorized phase scope, `PROJECT_CONTEXT.md` records current state, and `ROADMAP.md`
defines progression without authorizing implementation.
