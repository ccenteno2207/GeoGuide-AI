# Infraestructura local — P1

Esta carpeta contiene la primera entrega ejecutable de P1. Levanta únicamente los
servicios de datos que necesita el futuro backend: PostgreSQL/PostGIS, Redis y MinIO.
El backend y Nginx se incorporarán en sus fases correspondientes; no se simulan aquí.

## Requisitos

- Docker Desktop con Docker Compose v2.
- Puertos locales 5432, 6379, 9000 y 9001 disponibles, o valores alternativos en `.env`.

## Inicio

Desde esta carpeta:

1. Copiar `.env.example` como `.env`.
2. Reemplazar todos los valores `CHANGE_ME`.
3. Validar con `docker compose config`.
4. Iniciar con `docker compose up -d`.
5. Confirmar con `docker compose ps` que los tres servicios están `healthy`.

Los puertos se enlazan exclusivamente a `127.0.0.1`; no quedan expuestos a la red
externa. La red Docker también es interna. Esta configuración es para desarrollo local,
no para producción.

## Comprobaciones rápidas

- PostgreSQL/PostGIS: `docker compose exec postgres psql -U geoguide_app -d geoguide -c "SELECT PostGIS_Full_Version();"`
- Redis: `docker compose exec redis redis-cli ping`
- MinIO: abrir `http://127.0.0.1:9001` e ingresar con las credenciales de `.env`.

## Detención y datos

`docker compose down` detiene los contenedores y conserva los volúmenes. No usar
`docker compose down -v` salvo que se quiera eliminar deliberadamente todos los datos
locales.

## Motor de rutas

El routing spike de P1 se registra en `routing/ROUTING-SPIKE.md`. El motor no forma
parte de este Compose hasta seleccionar un extracto OSM pequeño del corredor piloto y
medir las alternativas. Cualquier motor se consumirá después mediante `RoutingProvider`.
