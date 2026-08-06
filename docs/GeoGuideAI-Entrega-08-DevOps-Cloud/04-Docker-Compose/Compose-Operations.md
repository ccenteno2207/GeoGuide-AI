# Operación Docker Compose

Comandos operativos:
- validar configuración: `docker compose config`
- levantar: `docker compose up -d`
- estado: `docker compose ps`
- logs: `docker compose logs`
- actualizar: pull/build + `docker compose up -d`
- detener: `docker compose down`

No usar `down -v` en ambientes con datos salvo operación deliberada y respaldada.
