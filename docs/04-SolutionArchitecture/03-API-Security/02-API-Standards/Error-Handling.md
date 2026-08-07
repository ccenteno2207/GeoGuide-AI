# Manejo de Errores

Formato estándar compatible con Problem Details:

```json
{
  "type": "https://geoguide.local/errors/place-not-found",
  "title": "Place not found",
  "status": 404,
  "detail": "No se encontró el punto de interés solicitado.",
  "instance": "/api/v1/places/...",
  "correlationId": "..."
}
```

Reglas:
- No exponer stack traces.
- No devolver detalles internos de infraestructura.
- No revelar existencia de usuarios en errores de autenticación.
- Los errores de validación deben identificar el campo sin exponer internals.
