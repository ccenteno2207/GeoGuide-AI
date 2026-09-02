# Changelog

## Unreleased

### Added
- Aplicación Spring Boot ejecutable con `spring-boot-starter-web` y Actuator limitado
  exclusivamente al endpoint `health`.
- Preparación JDBC/Flyway para PostgreSQL con configuración común y perfil local
  basado únicamente en variables de entorno.
- Migración `V001__enable_postgis.sql`, limitada a habilitar PostGIS sin crear tablas
  ni dominios futuros.
- Dockerfile multi-stage del backend con Temurin Java 21, build mediante Maven Wrapper
  y runtime no privilegiado con UID/GID `10001:10001`.
- `.dockerignore` del backend para excluir `target/`, secretos locales, archivos IDE y
  artefactos innecesarios del contexto de build.
- Bootstrap Maven mínimo del backend con Spring Boot 3.5.16, Java 21, `groupId`
  `ai.geoguide` y `artifactId` `geoguide-backend`.
- Maven Wrapper 3.9.16 reproducible, validado con `mvnw.cmd validate` y resultado
  `BUILD SUCCESS`.
- ADR-028 selecciona GraphHopper 11.0 como motor inicial de routing.
- GraphHopper integrado al Compose interno con health check y grafo persistente.
- Evidencia de ruta válida, error HTTP 400 y reutilización del grafo tras reinicio.
- Backend incorporado a Docker Compose en la red interna, sin publicar 8080 ni 5432,
  con datasource PostgreSQL/PostGIS real y healthcheck interno.
- Adopción controlada de Flyway sobre el esquema P1 mediante baseline explícito versión
  `0`; V001 registrada con checksum `-1627021776` y evidencia P1 preservada.

### Changed
- P1 y M02 están completados. P2.0–P2.8 están completados y validados según su alcance
  sobre `feature/p2-backend-bootstrap`; P2.7A completó y validó la adopción controlada
  de Flyway. `mvnw.cmd verify` terminó con `BUILD SUCCESS`: 2 pruebas, 0 fallos,
  0 errores y 0 omitidas. M03 — API base disponible: **CUMPLIDO TÉCNICAMENTE**.
  Checkpoint Git documental de P2.8/M03: **PENDIENTE**. P3: **NO INICIADO**.
- P2.5 fue revisado técnicamente en modo de solo lectura y no se encontraron
  correcciones bloqueantes para iniciar P2.6.
- `backend/.gitkeep` fue retirado y el checkpoint P2.0–P2.6 quedó registrado en
  `05f5c33` sobre la rama feature.
- La descripción del producto aclara que Open Source First es una estrategia
  tecnológica y no determina la licencia del producto.

### Known limitations
- `geoguide_app` conserva privilegios elevados utilizados durante el bootstrap. La
  separación de un rol de migraciones y la reducción de privilegios son deuda de
  hardening posterior, fuera del alcance de P2.8.
- El staging, commit y push del checkpoint documental de P2.8/M03, así como cualquier
  PR o merge, no forman parte de esta auditoría y requieren aprobación posterior.

## 0.1.0 - Foundation

### Added
- Documentación inicial.
- Definición de la estrategia tecnológica Open Source First.
- Contexto del proyecto.
- Roadmap.
