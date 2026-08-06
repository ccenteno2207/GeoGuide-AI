# Resumen Ejecutivo

GeoGuide AI es una plataforma open source orientada al descubrimiento durante viajes
por carretera.

El usuario define origen y destino. El sistema calcula la ruta y encuentra lugares de
interés dentro de un corredor geográfico razonable, indicando cuáles puede visitar,
su relevancia y el desvío necesario.

## Diferenciación
No busca competir inicialmente con Waze o Google Maps en tráfico y navegación urbana.
Su núcleo es **Route Discovery**.

## MVP
- aplicación Flutter;
- ubicación GPS;
- mapa OpenStreetMap;
- origen/destino;
- routing open source;
- Route Discovery Engine;
- POIs PostGIS;
- fichas de lugares;
- modo de conducción;
- operación con conectividad limitada.

## Plataforma
Linux + Docker Compose + Nginx + Spring Boot + PostgreSQL/PostGIS + Redis + MinIO +
motor de routing open source.

## IA
Opcional y desacoplada. El producto central funciona sin LLM.
