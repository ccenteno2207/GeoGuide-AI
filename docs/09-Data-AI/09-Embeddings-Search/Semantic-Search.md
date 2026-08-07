# Búsqueda Semántica

## Casos
- “lugares incas”
- “cataratas para visitar”
- “sitios históricos coloniales”

## Arquitectura
PostgreSQL/PostGIS + pgvector.

Geospatial filter + semantic similarity.

## Estrategia
Filtrar geográficamente primero cuando la consulta depende de ruta/ubicación y aplicar
similitud semántica sobre un conjunto acotado.

Esto evita búsquedas vectoriales globales innecesarias.
