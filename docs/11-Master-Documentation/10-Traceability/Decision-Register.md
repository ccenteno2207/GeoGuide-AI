# Registro Consolidado de Decisiones

Decisiones clave:
- Flutter mobile.
- Java 21/Spring Boot backend.
- Modular Monolith.
- PostgreSQL/PostGIS.
- Flyway.
- Testcontainers.
- Docker Compose MVP.
- Cloud-agnostic core.
- GitHub Actions.
- Facts First, AI Second.
- pgvector inicial para vectores.
- LLM provider abstraction.
- LLM no requerido para core MVP.
- Riverpod recomendado.
- Drift/SQLite baseline.
- Map library pendiente de spike.
- Routing engine: ADR-028 adopta GraphHopper 11.0 como implementación inicial de
  `RoutingProvider`, después del benchmark y la revisión visual de 18 geometrías.
  OSRM 26.8.0 MLD queda como alternativa preferida de rendimiento y Valhalla 3.8.2
  como opción futura para multimodalidad o routing temporal. La decisión permanece
  aceptada; la infraestructura Compose quedó disponible en P1 y la integración backend
  contractual mediante `RoutingProvider` y su adaptador quedó completada en P4. El
  procedimiento operativo de actualización del PBF y reconstrucción del grafo permanece
  diferido; no forma parte del cierre P4.

Consultar ADR originales para contexto completo.
