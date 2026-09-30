# Runbook – Deployment

## Contexto operativo de la VM de integración

- Usuario SSH: `manager`.
- Host privado: `192.168.1.106`.
- Target SSH: `manager@192.168.1.106`.

Este contexto no incluye credenciales, claves privadas, tokens ni contraseñas.

1. confirmar pipeline verde;
2. confirmar backup si hay migración riesgosa;
3. obtener versión/tag;
4. actualizar imagen;
5. validar `docker compose config`;
6. pull;
7. `docker compose up -d`;
8. revisar estado;
9. ejecutar health check;
10. smoke test de places/routes/discovery;
11. revisar logs y métricas.

## Rollback
- restaurar tag anterior;
- `docker compose up -d`;
- verificar health;
- si existe migración incompatible, aplicar procedimiento de DB documentado.
