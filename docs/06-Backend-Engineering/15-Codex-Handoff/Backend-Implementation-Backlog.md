# Backlog de Implementación Backend

## B01 – Bootstrap
- [x] `pom.xml` mínimo: Spring Boot 3.5.16 + Java 21.
- [x] Maven Wrapper 3.9.16 generado y validado con `mvnw.cmd validate`.
- [x] aplicación Spring Boot y prueba de contexto sin datasource/Flyway.
- [x] health endpoint mínimo; Actuator expone exclusivamente `health`.
- [x] JAR ejecutable generado y health temporal validado con HTTP 200 / `UP`.
- [x] Dockerfile multi-stage Java 21 implementado y revisado estáticamente, con build
  mediante Maven Wrapper y runtime no privilegiado `10001:10001`.
- [x] `.dockerignore` del backend creado; Compose permanece sin cambios.
- estructura modular.

Checkpoint actual: P2.0–P2.5 implementados y validados; P2.6 implementado y validado
estáticamente. La validación dinámica Docker en VM está pendiente. P2.7 no iniciado,
P2 sigue en curso y M03 no está cumplido.

## B02 – Database
- [x] dependencias JDBC, PostgreSQL y Flyway preparadas.
- [x] configuración común y perfil local mediante variables de entorno.
- [x] V001 mínima para `CREATE EXTENSION IF NOT EXISTS postgis;`.
- [ ] conexión real backend→PostgreSQL/PostGIS.
- [ ] ejecución real de Flyway y comprobación de `flyway_schema_history`.
- [ ] permisos de extensión y health con datasource real en VM.
- category.
- point_of_interest.
- índices.

## Pendientes de validación Docker
- [ ] `docker build` real en VM.
- [ ] inspección de `Config.User`.
- [ ] ejecución de `id` dentro de la imagen o contenedor.
- [ ] comprobación del propietario del JAR.
- [ ] arranque real del backend en Docker.

## B03 – Places
- dominio.
- repository.
- GET /places/{id}.
- nearby.
- tests.

## B04 – Routing
- RoutingProvider.
- adapter.
- /routes/plan.
- timeout/error handling.

## B05 – Discovery
- corridor.
- spatial query.
- ranking.
- route progress.
- /routes/discover.

## B06 – Security
- Spring Security.
- JWT.
- roles.
- tests.

## B07 – Favorites
- persistence.
- API.
- authorization.

## B08 – Observability
- correlationId.
- metrics.
- structured logs.

## B09 – CI
- mvn verify.
- dependency scan.
- container build.

## MVP backend ready
Cuando B01–B09 estén implementados, probados y documentados.
