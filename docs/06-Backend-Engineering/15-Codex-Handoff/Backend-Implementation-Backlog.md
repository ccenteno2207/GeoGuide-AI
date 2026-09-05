# Backlog de Implementación Backend

## B01 – Bootstrap
- [x] `pom.xml` mínimo: Spring Boot 3.5.16 + Java 21.
- [x] Maven Wrapper 3.9.16 generado y validado con `mvnw.cmd validate`.
- [x] aplicación Spring Boot y prueba de contexto sin datasource/Flyway.
- [x] health endpoint mínimo; Actuator expone exclusivamente `health`.
- [x] JAR ejecutable generado y health temporal validado con HTTP 200 / `UP`.
- [x] Dockerfile multi-stage Java 21 implementado y revisado estáticamente, con build
  mediante Maven Wrapper y runtime no privilegiado `10001:10001`.
- [x] `.dockerignore` del backend creado; Compose permaneció sin cambios durante P2.6.
- [x] backend incorporado a Compose con healthcheck, datasource real y red interna sin
  publicar 8080/5432.
- estructura modular.

Checkpoint actual: P0–P4 están cerradas. P4 fue integrado por el PR #9 mediante
`f14ddc6` y superó la validación post-merge. P5 — Route Discovery es la siguiente fase,
pero no está iniciada.

## B02 – Database
- [x] dependencias JDBC, PostgreSQL y Flyway preparadas.
- [x] configuración común y perfil local mediante variables de entorno.
- [x] V001 mínima para `CREATE EXTENSION IF NOT EXISTS postgis;`.
- [x] conexión real backend→PostgreSQL/PostGIS.
- [x] baseline explícito versión 0, V001 y `flyway_schema_history` comprobados.
- [x] PostGIS 3.4.3 y health con datasource real validados en VM.
- [x] P3: V002–V004 crean Category, PointOfInterest, provenance e índices posteriores a
  V001; Testcontainers y el baseline heredado en VM fueron validados.

## Validación Docker
- [x] `docker build` real en VM: `17/17 FINISHED`.
- [x] inspección de `Config.User`: `10001:10001`.
- [x] ejecución de `id`: usuario y grupo `geoguide` con UID/GID 10001.
- [x] comprobación del propietario del JAR: `10001:10001`.
- [x] ausencia de contenedores de validación en ejecución e imagen conservada en VM.
- [x] arranque real del backend en Docker.
- [x] incorporación y healthcheck del backend en Compose.
- [x] datasource y conexión PostgreSQL/PostGIS dentro de la red interna.
- [x] Flyway, baseline 0, V001, `flyway_schema_history` y health real.
- [x] ausencia de publicación de 8080 y 5432 al host.
- [x] restart controlado e idempotencia Flyway.

## B03 – POI Data & Domain (P3)
- dominio mínimo `PointOfInterest` y value objects del baseline;
- puerto de persistencia y adaptador, sin fijar firma ni tecnología concreta;
- persistencia PostgreSQL/PostGIS;
- taxonomía, provenance y dataset Lima → Obrajillo;
- carga reproducible e idempotente;
- pruebas unitarias y de integración con PostgreSQL/PostGIS real.

GET de Places, endpoints HTTP, search y nearby quedan fuera de P3 y se planificarán en
fases posteriores. Routing, corredor, discovery y ranking permanecen en B04/B05.

## B04 – Routing
- [x] `RoutingProvider`.
- [x] adaptador GraphHopper 11.
- [x] `POST /api/v1/routes/plan` y GeoJSON `LineString`.
- [x] configuración de timeout y normalización de errores.
- [x] pruebas unitarias, de adaptador, contrato HTTP y smoke en VM.

## B05 – Discovery
- estado: **NOT STARTED**; este backlog no constituye contrato de alcance P5.
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
