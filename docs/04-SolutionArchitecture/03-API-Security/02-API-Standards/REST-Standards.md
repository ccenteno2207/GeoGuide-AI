# Estándares REST

## Recursos
Usar sustantivos en plural y minúsculas.

## Métodos
- GET: lectura
- POST: creación o proceso no idempotente
- PUT: reemplazo/actualización idempotente
- PATCH: actualización parcial
- DELETE: eliminación lógica o física controlada

## Códigos HTTP
- 200 OK
- 201 Created
- 204 No Content
- 400 Bad Request
- 401 Unauthorized
- 403 Forbidden
- 404 Not Found
- 409 Conflict
- 422 Unprocessable Entity
- 429 Too Many Requests
- 500 Internal Server Error
- 503 Service Unavailable

## Fechas
ISO-8601 en UTC.

## Identificadores
UUID.

## Paginación
`page`, `size`, `sort`.

## Filtros geoespaciales
- lat
- lon
- radiusMeters
- category
- maxDetourKm

## Correlation ID
Todo request debe aceptar/generar `X-Correlation-Id`.
