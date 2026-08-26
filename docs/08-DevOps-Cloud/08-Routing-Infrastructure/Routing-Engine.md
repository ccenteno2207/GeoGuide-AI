# Infraestructura del Motor de Rutas

GraphHopper 11.0 se ejecuta como servicio independiente en Docker y será consumido
únicamente por el backend mediante `RoutingProvider`. ADR-028 registra su selección
como motor inicial.

## Implementación vigente

- Imagen local: `geoguide-ai/graphhopper:11.0` sobre Java 21.
- Servicio Compose: `graphhopper`, conectado únicamente a la red interna `data`.
- Puertos 8989/8990 no publicados en el host.
- PBF montado en solo lectura en `/data/input.osm.pbf`.
- Grafo persistente en `/data/graph-cache` y proceso sin privilegios (UID/GID 10001).
- Health check interno sobre `/info` verificado.

OSRM y Valhalla permanecen como alternativas técnicas sustituibles.

La selección final debe validarse con rutas reales del territorio objetivo.

## Datos
Los datos de OpenStreetMap necesarios para routing deben descargarse, procesarse y
versionarse operacionalmente.

El primer arranque operativo generó un grafo de aproximadamente 42 MB. Antes de cerrar
P1 todavía deben verificarse la primera ruta interna, el contrato y errores normalizados,
y la reutilización del grafo después de reinicio.

## Consideraciones
- tamaño del extracto;
- RAM durante importación;
- almacenamiento;
- tiempo de build del grafo;
- actualización de datos;
- perfiles de vehículo.

El motor no debe exponerse directamente al móvil.
