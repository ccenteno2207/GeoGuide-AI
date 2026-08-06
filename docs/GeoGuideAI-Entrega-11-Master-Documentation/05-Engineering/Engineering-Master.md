# Engineering Master

## Backend
Capas:
API → Application → Domain ← Infrastructure.

Módulos:
identity, users, places, routes, discovery, favorites, media, admin.

## Mobile
Features:
map, location, route_planning, discovery, places, favorites, driving, settings, offline.

## Contrato
OpenAPI es el contrato entre backend/mobile.

## Database
Flyway para cambios.

## Calidad
Backend: `mvn verify`.
Mobile: `dart format`, `flutter analyze`, `flutter test`.

## Regla
No avanzar a una nueva funcionalidad con la anterior rota.
