# Modelo de Amenazas

Amenazas:
- Robo de token.
- Fuerza bruta.
- Enumeración de usuarios.
- Abuso de endpoints geográficos costosos.
- Inyección.
- SSRF.
- Carga maliciosa de archivos.
- Exposición de datos personales.
- Escalada de privilegios.
- Denegación de servicio.
- Manipulación de coordenadas.

Mitigaciones:
- Rate limiting.
- Validación y normalización.
- Timeouts en llamadas externas.
- Allowlist de destinos externos.
- Validación MIME/tamaño.
- RBAC.
- Auditoría.
- Límites por usuario/IP.
- Caché de consultas costosas.
