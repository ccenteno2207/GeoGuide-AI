# GeoGuide AI – Entrega 04.4
## Route Discovery Engine

El Route Discovery Engine es el núcleo diferenciador de GeoGuide AI. Su misión es tomar
una ruta entre un origen y un destino, construir un corredor espacial alrededor de esa
ruta, localizar puntos de interés relevantes, estimar su costo de desvío, clasificarlos
y devolverlos en un orden útil para el viajero.

## Objetivos del MVP
- Calcular o recibir una ruta.
- Normalizar la geometría a LineString/GeoJSON.
- Construir un corredor configurable.
- Buscar POIs con PostGIS.
- Clasificar por categoría, distancia y desvío.
- Evitar duplicados.
- Devolver POIs ordenados a lo largo de la ruta.
- Preparar geofencing para avisos en movimiento.

## Principios
- Open Source First.
- Motor de rutas desacoplado.
- PostGIS como motor geoespacial principal.
- Determinismo y explicabilidad del ranking.
- Caché donde aporte valor.
- Observabilidad por defecto.
