# Infraestructura del Motor de Rutas

GraphHopper 11.0 se ejecuta como servicio independiente en Docker y es consumido
únicamente por el backend mediante el adaptador de `RoutingProvider`. ADR-028 registra
su selección como motor inicial.

## Implementación vigente

- Imagen local: `geoguide-ai/graphhopper:11.0` sobre Java 21.
- Servicio Compose: `graphhopper`, conectado únicamente a la red interna `data`.
- Puertos 8989/8990 no publicados en el host.
- PBF montado en solo lectura en `/data/input.osm.pbf`.
- Grafo persistente en `/data/graph-cache` y proceso sin privilegios (UID/GID 10001).
- Health check interno sobre `/info` verificado.

OSRM y Valhalla permanecen como alternativas técnicas sustituibles.

La precisión de ETA sigue requiriendo contraste futuro con rutas reales del territorio.

## Datos
Los datos de OpenStreetMap necesarios para routing deben descargarse, procesarse y
versionarse operacionalmente.

El primer arranque operativo generó un grafo de aproximadamente 42 MB. P1 validó una
ruta interna de 10 615.548 m, una solicitud inválida con HTTP 400 y la reutilización del
grafo después del reinicio; el servidor inició en aproximadamente 2 s. P4 completó el
adaptador backend, la configuración externa, la normalización de distancia/duración y
errores, y `POST /api/v1/routes/plan` con GeoJSON `LineString`.

El procedimiento de actualización del PBF y reconstrucción del grafo permanece
diferido. P4 no modificó el PBF ni el bounding box y no implementó Route Discovery.

## Consideraciones
- tamaño del extracto;
- RAM durante importación;
- almacenamiento;
- tiempo de build del grafo;
- actualización de datos;
- perfiles de vehículo.

El motor no debe exponerse directamente al móvil.
