# Arquitectura de Seguridad

## Principios
- Security by Design
- Secure by Default
- Least Privilege
- Defense in Depth
- No secretos en código
- Trazabilidad completa

## Capas
1. Dispositivo móvil
2. Transporte HTTPS/TLS
3. Nginx
4. Spring Security
5. Servicios de dominio
6. PostgreSQL/PostGIS
7. Redis/MinIO
8. Sistema operativo Linux

## Controles principales
- TLS obligatorio.
- JWT de vida corta.
- Refresh token rotado.
- RBAC.
- CORS restringido.
- Validación estricta de entrada.
- Queries parametrizadas/JPA.
- Límites de payload.
- Rate limiting.
- Logs de auditoría.
- Gestión segura de secretos.
