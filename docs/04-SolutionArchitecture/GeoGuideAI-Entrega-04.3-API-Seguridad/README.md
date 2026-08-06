# GeoGuide AI – Entrega 04.3
## Arquitectura de APIs y Seguridad

Esta entrega define la arquitectura de integración, estándares REST, contratos OpenAPI,
seguridad de aplicación, autenticación/autorización, protección de datos, auditoría,
amenazas y criterios de implementación para el MVP de GeoGuide AI.

### Alcance
- API REST versionada.
- Convenciones de diseño API First.
- Contratos OpenAPI.
- JWT y RBAC.
- Seguridad por capas.
- Rate limiting.
- Validación y manejo de errores.
- Auditoría y trazabilidad.
- OWASP API Security Top 10.
- Modelo de amenazas.
- ADR de decisiones clave.
- Checklist de implementación y pruebas.

### Stack de referencia
- Java 21
- Spring Boot 3
- Spring Security 6
- PostgreSQL + PostGIS
- Redis
- Nginx
- Docker
- OpenAPI 3.1
- Flutter como cliente móvil

### Principio rector
Todas las APIs deben diseñarse con enfoque API First, seguridad por defecto,
mínimo privilegio, contratos versionados y observabilidad desde el inicio.
