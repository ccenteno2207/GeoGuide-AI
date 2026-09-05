# GeoGuide AI

GeoGuide AI is a mobile platform for intelligent geographic discovery built with an
Open Source First technology strategy. This strategy does not determine the product
license; `LICENSE` is the current legal file. The platform reveals trustworthy
cultural, historical, archaeological, natural, gastronomic, and other POIs around the
user's location and along a route. It is not a replacement for Google Maps/Waze and not
a generic chatbot.

GeoGuide AI is the product and application. CEFI is its conversational copilot identity:
a future voice-oriented experience designed to help the rutero understand relevant
places, context, and available options with minimal distraction. CEFI uses GeoGuide AI
capabilities and does not replace Routing, Route Discovery, or factual POI data.

The First Operational Pilot centers on the Route Discovery Engine: it calculates or receives a route, builds a spatial corridor, finds relevant candidates, and returns explainable results. Detour distance and additional travel time can be added incrementally; real-time traffic is not required for the MVP.

Voice is a strategic hands-free channel, especially during driving. The intended flow is STT -> contextual intent using location, route, and POIs -> channel-independent GeoGuide services -> short TTS responses. Flutter UI, voice, and future clients share the same application logic.

## MVP stack

- Flutter/Dart; Java 21/Spring Boot 3; Modular Monolith; Clean Architecture.
- PostgreSQL/PostGIS, Redis, MinIO, OpenStreetMap, and `RoutingProvider`.
- Linux, Docker, Docker Compose, Nginx, and GitHub Actions.
- AI is optional and decoupled. Facts First, AI Second.

Kubernetes, microservices, mandatory public cloud, advanced AI/personalization and itinerary generation, CarPlay/Android Auto, and real-time traffic are outside the MVP.

Start at [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md). Architecture follows accepted ADRs and Entrega 04.6. Licensing status is in [LICENSING-STATUS.md](docs/00-Executive/LICENSING-STATUS.md); `LICENSE` remains the current legal file.

## Estado de implementación

P0–P4 están completadas y cerradas. El baseline posterior a P4 incluye el dominio y los
datos POI, la infraestructura local y routing desacoplado mediante `RoutingProvider`,
con GraphHopper 11 como implementación inicial.

La siguiente fase es P5 — Route Discovery, que **no está iniciada**. P6–P12 permanecen
planificadas.
La configuración inicial de PostgreSQL/PostGIS, Redis y MinIO, junto con sus instrucciones
de operación, se encuentra en [infrastructure/README.md](infrastructure/README.md).
