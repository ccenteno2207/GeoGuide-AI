# Resumen Ejecutivo

GeoGuide AI es una plataforma orientada al descubrimiento durante viajes por carretera que aplica una estrategia tecnologica Open Source First. La licencia del producto esta en revision; consulte `docs/00-Executive/LICENSING-STATUS.md`.

El usuario define origen y destino. El sistema calcula la ruta y encuentra lugares de interes dentro de un corredor geografico razonable, indicando relevancia y desvio necesario.

## Diferenciacion

Su nucleo es **Route Discovery**.

## MVP

- Flutter, GPS, OpenStreetMap, routing abierto, Route Discovery Engine, POIs PostGIS y fichas de lugares.
- Linux, Docker Compose, Nginx, Spring Boot, PostgreSQL/PostGIS, Redis y MinIO.
- IA opcional y desacoplada; el producto central funciona sin LLM.
