# Estrategia de Datos

## Dominios
1. Geospatial: POIs, rutas, coordenadas.
2. Content: descripción, historia, multimedia.
3. Operational: horarios, precios, accesibilidad.
4. User preference: categorías/favoritos.
5. Telemetry: rendimiento y uso agregado.

## Golden Record POI
PostgreSQL/PostGIS será la fuente canónica del POI consolidado.

Cada atributo enriquecido debe poder registrar:
- fuente;
- fecha de obtención;
- confianza/calidad;
- método de incorporación;
- licencia cuando aplique.

## Regla
Nunca mezclar silenciosamente un dato factual con texto generado.
