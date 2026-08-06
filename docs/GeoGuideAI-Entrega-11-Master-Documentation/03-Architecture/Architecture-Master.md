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

## Infra
Linux + Docker Compose.

## CI/CD
GitHub Actions.

## Regla
Ningún componente externo debe atravesar directamente los límites del dominio.
