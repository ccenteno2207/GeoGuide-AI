# Resumen Ejecutivo

GeoGuide AI es una plataforma móvil Open Source de descubrimiento geográfico alrededor
de la ubicación y durante viajes por carretera. La licencia del producto está en
revisión; consulte `docs/00-Executive/LICENSING-STATUS.md`.

El usuario define origen y destino. El sistema calcula la ruta y encuentra lugares de
interés dentro de un corredor geográfico razonable, indicando relevancia y posición en
el recorrido. En una evolución posterior podrá informar distancia de desvío y tiempo
adicional estimados.
También puede descubrir POIs cercanos sin una ruta activa y consultar fichas que
distinguen hechos confiables, fuentes y contenido generado.

## Diferenciacion

Su nucleo es **Route Discovery**.

## MVP

- Flutter, GPS, OpenStreetMap, routing abierto, Route Discovery Engine, POIs PostGIS y fichas de lugares.
- Linux, Docker Compose, Nginx, Spring Boot, PostgreSQL/PostGIS, Redis y MinIO.
- IA opcional y desacoplada; el producto central funciona sin LLM.
- Voz manos libres como canal estratégico sobre servicios compartidos, con respuestas
  breves en Driving/Travel Mode; capacidades avanzadas se incorporan incrementalmente.
