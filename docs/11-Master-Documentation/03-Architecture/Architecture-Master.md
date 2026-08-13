# Arquitectura Consolidada

## Mobile
Flutter.

## Edge
Nginx + HTTPS.

## Backend
Java 21 + Spring Boot 3, Modular Monolith, Clean Architecture.

## Data
PostgreSQL + PostGIS.

## Cache
Redis.

## Objects
MinIO.

## Routing
GraphHopper/Valhalla/OSRM sujeto a spike técnico.

## Maps
OpenStreetMap con cliente Flutter compatible.

## AI
LanguageModelProvider desacoplado; modelos open source cuando se habiliten.

## Interacción
Servicios de aplicación independientes del canal. Flutter UI, voz y clientes futuros
reutilizan casos de uso de proximidad, rutas, descubrimiento y fichas. Voz usa
adaptadores STT/TTS alrededor de interpretación contextual; el LLM es opcional. Véase
ADR-027.

## Infra
Linux + Docker Compose.

## CI/CD
GitHub Actions.

## Regla
Ningún componente externo debe atravesar directamente los límites del dominio.
Pantallas, prompts y adaptadores STT/TTS tampoco contienen lógica de dominio o de
aplicación.
