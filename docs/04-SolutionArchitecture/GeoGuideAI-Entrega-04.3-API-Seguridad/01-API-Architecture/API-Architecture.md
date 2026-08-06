# Arquitectura de APIs

## Objetivo
Definir una capa de servicios estable y evolutiva entre la aplicación móvil, el panel
administrativo y los servicios internos de GeoGuide AI.

## Estilo
Se adopta REST sobre HTTPS para el MVP.

## Dominios principales
1. Identity
2. Users
3. Places / POIs
4. Categories
5. Routes
6. Route Discovery
7. Favorites
8. Reviews
9. Media
10. Administration
11. Health / Observability

## URL base
`/api/v1`

## Ejemplos
- `POST /api/v1/auth/login`
- `GET /api/v1/places/{id}`
- `GET /api/v1/places/nearby`
- `POST /api/v1/routes/plan`
- `POST /api/v1/routes/discover`
- `POST /api/v1/favorites`
- `GET /api/v1/users/me`

## API Gateway / Reverse Proxy
Nginx actuará como punto de entrada:
- Terminación TLS.
- Encabezados de seguridad.
- Límite de tamaño de payload.
- Rate limiting básico.
- Enrutamiento hacia backend.
- Logging de acceso.

## Evolución
La arquitectura debe permitir separar dominios en servicios independientes en el futuro
sin cambiar los contratos públicos de forma abrupta.
