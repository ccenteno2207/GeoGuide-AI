# ADR-009 – Nginx como Reverse Proxy

Estado: Aceptado

Decisión:
Usar Nginx en el MVP como punto de entrada.

Responsabilidades:
- TLS
- reverse proxy
- headers de seguridad
- rate limiting básico
- access logs

Evolución:
Puede reemplazarse por un API Gateway dedicado si la escala lo exige.
