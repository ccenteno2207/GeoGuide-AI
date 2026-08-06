# Observabilidad

## Logging
Formato estructurado.

Campos recomendados:
- timestamp
- level
- application
- environment
- correlationId
- requestMethod
- requestPath
- status
- durationMs

## Micrometer
Métricas:
- HTTP server requests;
- JVM;
- datasource;
- routing provider;
- route discovery.

## Health
Spring Boot Actuator.

No exponer públicamente endpoints administrativos de Actuator.

## Route Discovery
Métricas de negocio/técnicas:
- discovery.duration;
- discovery.candidates;
- discovery.results;
- spatial.query.duration;
- routing.duration;
- routing.errors.
