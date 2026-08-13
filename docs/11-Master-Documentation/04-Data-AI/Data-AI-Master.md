# Data & AI Master

## Golden Record
PostgreSQL/PostGIS.

## Pipeline
Source → staging → normalize → validate → deduplicate → quality → publish.

## Provenance
Cada dato relevante debe poder rastrearse a su fuente.

## AI
Usos válidos:
- resumen;
- traducción;
- clasificación;
- tags;
- búsqueda semántica;
- RAG.
- interpretación contextual y redacción breve para voz, siempre opcionales.

## Prohibido
Usar el LLM como autoridad para:
- coordenadas;
- horarios;
- precios;
- cierres;
- hechos históricos sin respaldo.

UI y TTS deben presentar la misma separación entre hechos, fuente y contenido
generado. Audio, transcripciones, ubicación y contexto de viaje aplican minimización,
consentimiento y retención explícita; no se conserva historial GPS por defecto.

## Vector Search
pgvector antes de introducir una base adicional.
