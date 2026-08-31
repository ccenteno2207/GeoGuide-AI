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

### Changed
- P1 y el hito M02 están completados. P2.0–P2.5 están implementados y validados sobre
  `feature/p2-backend-bootstrap`; P2.6 está implementado y validado dinámicamente en
  la VM `srv-geoguide-ai`, P2.7 no se ha iniciado y M03 no está cumplido.
- P2.5 fue revisado técnicamente en modo de solo lectura y no se encontraron
  correcciones bloqueantes para iniciar P2.6.
- `backend/.gitkeep` fue retirado y el checkpoint P2.0–P2.6 quedó registrado en
  `05f5c33` sobre la rama feature.
- La descripción del producto aclara que Open Source First es una estrategia
  tecnológica y no determina la licencia del producto.

### Known limitations
- P2.5 valida configuración y preparación, no integración real con PostgreSQL.
- La ejecución de V001, `flyway_schema_history`, permisos de `CREATE EXTENSION`,
  conexión backend→PostgreSQL y health con datasource real siguen pendientes.
- El build de la imagen P2.6, `Config.User`, `id` y propietario del JAR fueron validados
  dinámicamente en la VM. Siguen pendientes el arranque real del backend en Docker, su
  incorporación a Compose y la integración con PostgreSQL/Flyway.

## 0.1.0 - Foundation

### Added
- Documentación inicial.
- Definición de la estrategia tecnológica Open Source First.
- Contexto del proyecto.
- Roadmap.
