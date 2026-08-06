# Correlation ID

## Header
`X-Correlation-Id`

## Flujo
1. Si llega un valor válido, conservarlo.
2. Si no existe, generar UUID.
3. Agregarlo al MDC.
4. Incluirlo en response.
5. Propagarlo a llamadas externas cuando sea apropiado.
6. Limpiar MDC al terminar el request.

No confiar en el correlation ID como credencial o dato de seguridad.
