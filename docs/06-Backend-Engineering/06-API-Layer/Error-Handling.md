# Manejo de Errores

Implementar `@RestControllerAdvice`.

## Excepciones de dominio/aplicación
- ResourceNotFoundException
- ValidationException
- ConflictException
- UnauthorizedOperationException
- ExternalServiceException
- RoutingUnavailableException

## Respuesta
Compatible con Problem Details.

Campos:
- type
- title
- status
- detail
- instance
- correlationId
- timestamp opcional

Nunca retornar:
- stack trace;
- SQL;
- secretos;
- clases internas.
