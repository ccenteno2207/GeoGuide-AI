# ADR-008 – JWT + RBAC

Estado: Aceptado

Decisión:
Usar JWT de corta duración y control de acceso basado en roles.

Riesgos:
Revocación y robo de tokens.

Mitigación:
Refresh token rotado, expiración corta, TLS y almacenamiento seguro en cliente.
