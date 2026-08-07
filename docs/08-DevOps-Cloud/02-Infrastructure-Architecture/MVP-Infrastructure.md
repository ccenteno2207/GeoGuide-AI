# Arquitectura de Infraestructura MVP

Internet
→ Firewall/Host
→ Nginx :443
→ Backend Spring Boot
→ PostgreSQL/PostGIS
→ Redis
→ MinIO
→ Routing Engine

## Exposición
Solo Nginx debe ser públicamente accesible.

PostgreSQL, Redis, MinIO administrativo y Routing Engine deben permanecer en redes
internas de Docker salvo necesidad explícita.

## Mobile
Flutter consume exclusivamente la API HTTPS publicada.
