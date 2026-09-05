# GeoGuide AI – Entrega 06 – Backend Engineering

## Objetivo
Definir el estándar de construcción del backend del MVP de GeoGuide AI antes de iniciar
la implementación productiva.

Esta entrega convierte la arquitectura definida en las Entregas 04.x en reglas concretas
para Java 21 + Spring Boot 3 y proporciona a Codex una fuente de verdad para crear el
backend sin introducir decisiones inconsistentes.

## Stack base
- Java 21 LTS
- Spring Boot 3.x
- Spring Web
- Spring Security
- Spring Data JPA
- Hibernate Spatial
- PostgreSQL + PostGIS
- Flyway
- Bean Validation
- springdoc-openapi
- Micrometer
- Maven
- JUnit 5
- Mockito
- Testcontainers
- Docker / Docker Compose

## Estado de implementación P2

P2 alcanzó **CIERRE TÉCNICO AUDITADO** en `feature/p2-backend-bootstrap`, con base
`e21aeab` y checkpoint técnico P2.7 `095413f`. P2.0–P2.8 están completados y validados
según su alcance; P2.7A está completado y validado. M03 — API base disponible:
**CUMPLIDO TÉCNICAMENTE**. El PR #5 cerró P2. P3 está implementado y validado
técnicamente en `feature/p3-poi-data-domain`; su Pull Request de cierre está pendiente.

P2.4 incorporó `spring-boot-starter-web`, `spring-boot-starter-actuator` y
`application.yml`. Actuator expone exclusivamente `health`. `mvnw.cmd test` terminó
con `BUILD SUCCESS` (1 prueba; 0 fallos, errores u omitidas) y `mvnw.cmd package`
también terminó correctamente, generando
`backend/target/geoguide-backend-0.0.1-SNAPSHOT.jar`. La comprobación temporal de
`/actuator/health` devolvió HTTP 200 y `{"status":"UP"}`; Spring confirmó un único
endpoint bajo `/actuator` y el proceso se detuvo mediante graceful shutdown. Los
warnings Mockito/Byte Buddy y CRLF/LF fueron clasificados como no bloqueantes.

P2.5 incorporó `spring-boot-starter-jdbc`, PostgreSQL JDBC en runtime, `flyway-core` y
`flyway-database-postgresql` en runtime. Spring Boot 3.5.16 administra Flyway 11.7.2
y PostgreSQL JDBC 42.7.11. `application.yml` contiene la configuración común y
`application-local.yml` el datasource local mediante `SPRING_DATASOURCE_URL`,
`SPRING_DATASOURCE_USERNAME` y `SPRING_DATASOURCE_PASSWORD`, sin secretos ni URLs
JDBC reales versionados. `V001__enable_postgis.sql` contiene funcionalmente solo
`CREATE EXTENSION IF NOT EXISTS postgis;`. Las pruebas terminaron con `BUILD SUCCESS`
(2 pruebas; 0 fallos, errores u omitidas), el empaquetado fue exitoso y
`git diff --check` devolvió código 0.

P2.5 validó preparación, no integración PostgreSQL real. `GeoGuideApplicationTests`
excluye datasource/Flyway y `FlywayMigrationTests` solo verifica presencia y contenido
del SQL. PostgreSQL permanece en la red Docker interna, sin publicar 5432. Quedan
pendientes en ese checkpoint la ejecución de V001, `flyway_schema_history`, permisos
para `CREATE EXTENSION postgis` en la VM, conexión backend→PostgreSQL y health con
datasource real; P2.7 los validó posteriormente. Una revisión técnica posterior de solo lectura no encontró
correcciones bloqueantes; P2.5 quedó listo para iniciar P2.6.

P2.6 creó `backend/Dockerfile` con build multi-stage Java 21. La etapa de build usa
`eclipse-temurin:21-jdk-jammy`, ejecuta el Maven Wrapper y genera el JAR dentro del
build Docker, sin copiar `target/` local. La etapa runtime usa
`eclipse-temurin:21-jre-jammy`, copia solo el JAR con propiedad `10001:10001` y declara
`USER 10001:10001`. `backend/.dockerignore` excluye artefactos locales, IDE y secretos;
Docker Compose no fue modificado y no se detectaron secretos ni cambios fuera de
alcance.

La revisión técnica estática de P2.6 fue satisfactoria. `mvnw` usa LF, conserva el
shebang `#!/bin/sh` y el Dockerfile aplica `chmod +x`; Dockerfile y `.dockerignore`
también usan LF, protegidos por `.gitattributes`.

La validación dinámica se ejecutó posteriormente en la VM `srv-geoguide-ai`, sobre
`feature/p2-backend-bootstrap` y HEAD `05f5c33`, con working tree limpio. El comando
`docker build -t geoguide-ai/backend:p2.6-validation ./backend` completó `17/17
FINISHED` en aproximadamente 271.5 segundos durante el primer build. La imagen
`geoguide-ai/backend:p2.6-validation` quedó disponible con Image ID `c0937ddd6204` y
tamaño observado de 457 MB.

`docker image inspect` confirmó `User=10001:10001`; la ejecución dinámica de `id`
devolvió `uid=10001(geoguide) gid=10001(geoguide) groups=10001(geoguide)`. La
inspección de `/app` confirmó que `app.jar` pertenece a UID/GID `10001:10001`.
`docker ps --filter ancestor=geoguide-ai/backend:p2.6-validation` confirmó que no
quedaron contenedores de validación ejecutándose, mientras `docker image ls` confirmó
que la imagen permanece disponible en la VM.

Esta evidencia validó la construcción y el usuario runtime de P2.6. P2.7 incorporó el
backend a Compose, únicamente en `geoguide-ai_data`, sin bindings de host para 8080 o
5432. El backend resolvió `postgres`, abrió el datasource real y alcanzó Flyway.

La primera ejecución se detuvo de forma segura porque `public` contenía PostGIS y la
evidencia `p1_persistence_test`, pero no `flyway_schema_history`. Después de backup e
inventario se adoptó el esquema mediante Flyway OSS 11.7.2 con baseline explícito `0`,
descripción `P1 pre-Flyway PostGIS state`, sin habilitar permanentemente
`baseline-on-migrate`. El historial final contiene exactamente dos filas exitosas:
baseline `0` y V001 `001`, tipo SQL, checksum `-1627021776`.

PostGIS permaneció en 3.4.3 y la comparación before/after de `p1_persistence_test`
terminó sin diferencias. El backend quedó healthy y Actuator respondió
`{"status":"UP"}`. Tras un restart controlado, Flyway confirmó el schema en versión
`001` y ninguna migración pendiente; `flyway_schema_history` conservó exactamente
baseline `0` y V001. El backend volvió a healthy y los cuatro servicios P1 permanecieron
preservados.

P2.8 ejecutó `mvnw.cmd verify` con Java 21.0.12.1 y Maven Wrapper 3.9.16: `BUILD
SUCCESS`, 2 pruebas, 0 fallos, 0 errores y 0 omitidas. La cuenta `geoguide_app` conserva privilegios
elevados; separar el rol de migraciones y aplicar mínimo privilegio queda como deuda de
hardening posterior, no como bloqueo de M03.

## Principios
- Modular Monolith para el MVP.
- Clean Architecture.
- Domain-first.
- API First.
- Seguridad por defecto.
- PostGIS para lógica espacial.
- Puertos y adaptadores para servicios externos.
- Código simple antes que abstracción prematura.
- Migraciones versionadas.
- Tests automatizados.
- Observabilidad desde el primer incremento.
