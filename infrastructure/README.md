# Infraestructura local — P1

Esta carpeta contiene la infraestructura local validada en P1 y la incorporación del
backend correspondiente a P2.7. Levanta PostgreSQL/PostGIS, el backend, Redis, MinIO y
GraphHopper. El backend se conecta únicamente a PostgreSQL en este checkpoint; no integra
Redis, MinIO ni GraphHopper. Nginx se incorporará en una fase posterior.

## Requisitos

- Docker Engine o Docker Desktop con Docker Compose v2.
- Un archivo OSM PBF compatible con la configuración de GraphHopper.
- Memoria suficiente para construir o cargar el grafo; el valor inicial de `-Xmx` es 4 GiB.

## Inicio

Desde esta carpeta:

1. Copiar `.env.example` como `.env`.
2. Reemplazar todos los valores `CHANGE_ME`.
3. Definir `ROUTING_PBF_PATH` y `ROUTING_GRAPH_DIR` como rutas absolutas existentes.
4. Conceder al UID/GID `10001:10001` acceso de escritura a `ROUTING_GRAPH_DIR`.
5. Validar con `docker compose config`.
6. Construir el backend y GraphHopper con `docker compose build backend graphhopper`.
7. Iniciar con `docker compose up -d`.
8. Confirmar con `docker compose ps` que los cinco servicios están `healthy`.

Los servicios no publican puertos en el host y la red Docker es interna. Esta
configuración es para desarrollo local, no para producción.

## Comprobaciones rápidas

- PostgreSQL/PostGIS: `docker compose exec postgres psql -U geoguide_app -d geoguide -c "SELECT PostGIS_Full_Version();"`
- Backend desde la red interna: `docker compose exec minio curl -fsS http://backend:8080/actuator/health`.
- Redis: `docker compose exec redis redis-cli ping`
- MinIO: `docker compose exec minio curl -f http://localhost:9000/minio/health/live`.
- GraphHopper: `docker compose exec graphhopper curl -f http://localhost:8989/info`.

La API de GraphHopper queda disponible para futuros servicios de la misma red como
`http://graphhopper:8989/route`; no se accede directamente desde el host.

## Backend P2.7

El servicio `backend`:

- se construye desde `../backend/Dockerfile` como `geoguide-ai/backend:p2.7`;
- se ejecuta con UID/GID `10001:10001`;
- activa el perfil Spring `local`;
- usa `postgres` como hostname Docker y reutiliza `POSTGRES_DB`, `POSTGRES_USER` y
  `POSTGRES_PASSWORD` sin versionar secretos;
- espera a que el healthcheck de PostgreSQL termine correctamente;
- expone su health solo dentro de la red `data`, sin publicar 8080 al host;
- comprueba `/actuator/health` internamente mediante Bash, `/dev/tcp` y `grep`, sin
  depender de `curl` o `wget` en la imagen backend.

La URL JDBC interna resultante es:

```text
jdbc:postgresql://postgres:5432/geoguide
```

Flyway está habilitado por la configuración común del backend y ejecuta las migraciones
al arrancar con el datasource disponible. La comprobación posterior de V001 puede
realizarse desde la VM sin publicar PostgreSQL:

```bash
docker compose exec postgres sh -lc \
'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
SELECT installed_rank, version, description, script, installed_by, success
FROM flyway_schema_history
ORDER BY installed_rank;
"'

docker compose exec postgres sh -lc \
'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "
SELECT extname, extversion FROM pg_extension WHERE extname = '\''postgis'\'';
SELECT PostGIS_Full_Version();
"'
```

El preflight de P2.7 confirmó que el rol actual `geoguide_app` tiene privilegios elevados
suficientes para el baseline y que PostGIS 3.4.3 ya existe. Esos privilegios no se
modifican en P2.7; reducirlos y separar un rol de migraciones es deuda técnica de
hardening posterior.

La integración real, Flyway/V001, `flyway_schema_history`, health con datasource y DNS
interno deben validarse en la VM antes de considerar cerrado el checkpoint. No ejecutar
`docker compose down -v` durante esa validación.

## Detención y datos

`docker compose down` detiene los contenedores y conserva los volúmenes. No usar
`docker compose down -v` salvo que se quiera eliminar deliberadamente todos los datos
locales.

## Motor de rutas

El routing spike de P1 se registra en `routing/ROUTING-SPIKE.md`. ADR-028 adopta
GraphHopper 11.0 como implementación inicial de `RoutingProvider`; OSRM permanece como
alternativa preferida de rendimiento y Valhalla como opción futura multimodal o
temporal. El PBF y el grafo generado permanecen fuera de Git.
