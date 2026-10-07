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
P6 — Mobile Bootstrap está **CERRADA**. El bootstrap Flutter, `flutter_map 8.3.2`,
mapa base, interacción, permiso de ubicación aproximada y ubicación puntual fueron
validados en Android; la evidencia está en `P6-Validation-Evidence.md`.
`TILE_PROVIDER_GOVERNANCE` permanece pendiente. P7 — First Vertical Slice está
**CERRADA**: P7.1–P7.5 fueron integrados y P7.6 completó la auditoría y el cierre
formal. TLS productivo, renovación y E2E Android exclusivamente HTTPS están validados.
El incidente histórico de delegación del parent fue verificado nuevamente el
5-oct-2026: ambos parent autoritativos devolvieron exactamente `ns1.desec.io` y
`ns2.desec.org`. Estado actual: `PARENT_DELEGATION_INCIDENT = RESOLVED_WITH_EVIDENCE`,
`PARENT_DELEGATION_RISK = CLOSED`, `PARENT_DELEGATION_P8_IMPACT = NONE`.
Los comandos y resultados están en la [reconciliación post-P7](docs/11-Master-Documentation/11-Implementation-Plan/Post-P7-Documentation-Reconciliation.md).
P8 — POI Experience está **CERRADA** en
`7dfb0293507dcfa1eef90533c4dc9dbdd4d2a229` (PR #43), conforme a
[P8.7 Final Audit and Closure](docs/11-Master-Documentation/11-Implementation-Plan/P8.7-Final-Audit-and-Closure.md).
El [contrato P8](docs/11-Master-Documentation/11-Implementation-Plan/P8-Phase-Contract-v1.md)
permanece congelado; sus estados de apertura son históricos. P8.6 y P8.7 están
COMPLETED; Android físico, ubicación precisa puntual y accesibilidad están en PASS.
La evidencia de cierre registra Testcontainers 6/6, backend 59/59, Flutter 27 tests,
Flutter analyze y APK HTTPS en PASS; son resultados del cierre P8.
P0–P8 están completadas. P9.0 COMPLETED: contrato y anexo aprobados por decisión humana e integrados mediante PR #45 en `c6f774c7121632c46c412ffc6faca83e715b1d10`. Los estados pendientes dentro del contrato congelado reflejan su preparación anterior a esa aprobación y se preservan como evidencia histórica.
P9.1 implementa exclusivamente Offline Data / Local Cache en la rama `feature/p9-1-offline-cache`, pendiente de revisión e integración. Véase [evidencia P9.1](docs/11-Master-Documentation/11-Implementation-Plan/P9.1-Validation-Evidence.md). No se declara P9.1 integrado en main ni P9 cerrado. P9.2 NOT_STARTED; D06 DEFERRED y dispositivo físico no utilizado.
P10–P12 permanecen planificadas.
El roadmap indica progresión, no autorización de ejecución.

El baseline de cierre P7 es `ada26c8881cdefb2d8f0ede679a8ebb3996ab61c` (PR #31).
El contrato P7 es un snapshot normativo congelado e inmutable: sus estados históricos
no sustituyen el cierre posterior registrado en `P7-Validation-Evidence.md`, este
contexto, `ROADMAP.md` y `CHANGELOG.md`.

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
