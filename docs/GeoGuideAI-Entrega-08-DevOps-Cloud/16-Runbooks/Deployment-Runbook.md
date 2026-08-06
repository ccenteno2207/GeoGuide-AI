# Runbook – Deployment

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
