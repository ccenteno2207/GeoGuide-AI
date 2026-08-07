# Auditoría y Logging

Eventos auditables:
- Login exitoso/fallido.
- Cambios de rol.
- Alta/modificación/baja de POIs.
- Operaciones administrativas.
- Errores de autorización.
- Cambios de configuración.

No registrar:
- contraseñas;
- tokens completos;
- secretos;
- coordenadas históricas sensibles sin necesidad.

Campos recomendados:
- timestamp
- correlationId
- actorId
- action
- resourceType
- resourceId
- result
