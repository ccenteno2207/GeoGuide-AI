# GeoGuide AI – Entrega 04.4
## Route Discovery Engine

El Route Discovery Engine es el núcleo diferenciador de GeoGuide AI. Su misión es tomar
una ruta entre un origen y un destino, construir un corredor espacial alrededor de esa
ruta, localizar puntos de interés relevantes, clasificarlos y devolverlos en un orden
útil para el viajero. Posteriormente podrá estimar la distancia de desvío y el tiempo
adicional sin convertirlos en dependencias de la primera entrega.

## Objetivos del MVP
- Calcular o recibir una ruta.
- Normalizar la geometría a LineString/GeoJSON.
- Construir un corredor configurable.
- Buscar POIs con PostGIS.
- Clasificar inicialmente por categoría, proximidad, calidad y posición en la ruta.
- Evitar duplicados.
- Devolver POIs ordenados a lo largo de la ruta.
- Preparar geofencing para avisos en movimiento.

## Evolución posterior al núcleo MVP
- Estimar distancia de desvío y tiempo adicional.
- Incorporar esas estimaciones al ranking y filtros cuando estén disponibles.
- Mantener respuestas válidas aunque esas señales no se hayan calculado.

## Principios
- Open Source First.
- Motor de rutas desacoplado.
- PostGIS como motor geoespacial principal.
- Determinismo y explicabilidad del ranking.
- Caché donde aporte valor.
- Observabilidad por defecto.
