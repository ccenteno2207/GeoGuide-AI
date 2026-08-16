# GeoGuide AI

GeoGuide AI is an Open Source mobile platform for intelligent geographic discovery. It reveals trustworthy cultural, historical, archaeological, natural, gastronomic, and other POIs around the user's location and along a route. It is not a replacement for Google Maps/Waze and not a generic chatbot.

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

P0 (preparación documental) está completada y P1 (infraestructura local) está en curso.
La configuración inicial de PostgreSQL/PostGIS, Redis y MinIO, junto con sus instrucciones
de operación, se encuentra en [infrastructure/README.md](infrastructure/README.md).
