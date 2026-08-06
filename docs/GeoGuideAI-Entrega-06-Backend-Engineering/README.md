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
