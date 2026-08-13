# Alcance del MVP

## Objetivo
Construir un piloto funcional Open Source que permita descubrir puntos de interés
confiables alrededor de la ubicación actual y a lo largo de una ruta. GeoGuide AI no
reemplaza a Google Maps/Waze ni es un chatbot genérico.

## Incluye
- Origen y destino
- Trazado de ruta
- Descubrimiento de POIs por proximidad y corredor de ruta
- Filtros
- Ficha de detalle con hechos, fuente y frescura cuando estén disponibles
- Ranking y recomendaciones básicas, explicables y funcionales sin LLM
- Driving/Travel Mode con interacción reducida

## Evolución habilitada, no dependencia del núcleo

- Voz manos libres mediante STT → interpretación contextual → servicios GeoGuide → TTS.
- IA contextual para resumir o enriquecer sin sustituir fuentes factuales.
- Los canales visual y de voz reutilizan los mismos casos de uso de aplicación.

## Fuera de alcance
- Reservas
- Red social
- Publicidad
- Monetización
- Tráfico en tiempo real y navegación turn-by-turn avanzada propia
- IA avanzada, personalización compleja e itinerarios generados
- Integraciones CarPlay y Android Auto
