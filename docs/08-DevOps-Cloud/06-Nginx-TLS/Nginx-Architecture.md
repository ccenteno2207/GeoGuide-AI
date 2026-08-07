# Nginx y TLS

Responsabilidades:
- TLS termination;
- reverse proxy;
- security headers;
- request size;
- timeouts;
- rate limiting básico;
- access logs;
- HTTP → HTTPS.

## Certificados
Usar ACME/Let's Encrypt cuando exista dominio público compatible.

## Backend
Nginx → backend por red Docker privada.

## Headers
- X-Content-Type-Options
- Referrer-Policy
- políticas adicionales según cliente/API.

No asumir HSTS hasta validar correctamente HTTPS y dominio.
