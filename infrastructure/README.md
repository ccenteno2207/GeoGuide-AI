# Infraestructura local — P1

Esta carpeta contiene la entrega ejecutable de P1. Levanta PostgreSQL/PostGIS, Redis,
MinIO y GraphHopper como motor inicial de `RoutingProvider`. El backend y Nginx se
incorporarán en sus fases correspondientes; no se simulan aquí.

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
6. Construir GraphHopper con `docker compose build graphhopper`.
7. Iniciar con `docker compose up -d`.
8. Confirmar con `docker compose ps` que los cuatro servicios están `healthy`.

Los servicios no publican puertos en el host y la red Docker es interna. Esta
configuración es para desarrollo local, no para producción.

## Comprobaciones rápidas

- PostgreSQL/PostGIS: `docker compose exec postgres psql -U geoguide_app -d geoguide -c "SELECT PostGIS_Full_Version();"`
- Redis: `docker compose exec redis redis-cli ping`
- MinIO: `docker compose exec minio curl -f http://localhost:9000/minio/health/live`.
- GraphHopper: `docker compose exec graphhopper curl -f http://localhost:8989/info`.

La API de GraphHopper queda disponible para futuros servicios de la misma red como
`http://graphhopper:8989/route`; no se accede directamente desde el host.

## Detención y datos

`docker compose down` detiene los contenedores y conserva los volúmenes. No usar
`docker compose down -v` salvo que se quiera eliminar deliberadamente todos los datos
locales.

## Motor de rutas

El routing spike de P1 se registra en `routing/ROUTING-SPIKE.md`. ADR-028 adopta
GraphHopper 11.0 como implementación inicial de `RoutingProvider`; OSRM permanece como
alternativa preferida de rendimiento y Valhalla como opción futura multimodal o
temporal. El PBF y el grafo generado permanecen fuera de Git.
