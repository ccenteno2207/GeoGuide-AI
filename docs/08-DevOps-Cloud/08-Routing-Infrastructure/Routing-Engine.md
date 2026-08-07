# Infraestructura del Motor de Rutas

El motor se ejecutará como servicio independiente en Docker y será consumido únicamente
por el backend mediante `RoutingProvider`.

## Candidatos
- GraphHopper
- Valhalla
- OSRM

La selección final debe validarse con rutas reales del territorio objetivo.

## Datos
Los datos de OpenStreetMap necesarios para routing deben descargarse, procesarse y
versionarse operacionalmente.

## Consideraciones
- tamaño del extracto;
- RAM durante importación;
- almacenamiento;
- tiempo de build del grafo;
- actualización de datos;
- perfiles de vehículo.

El motor no debe exponerse directamente al móvil.
