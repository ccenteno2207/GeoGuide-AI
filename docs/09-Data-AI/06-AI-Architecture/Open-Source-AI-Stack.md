# Stack AI Open Source – Candidatos

## Serving
- Ollama para piloto/desarrollo;
- llama.cpp para ejecución eficiente;
- vLLM para serving de mayor escala.

## Modelos
Seleccionar modelos con licencia compatible y tamaño adecuado al servidor disponible.

## Embeddings
Usar modelos de embeddings open source multilingües cuando se habilite búsqueda semántica.

## Vector store
Primera opción: PostgreSQL + pgvector, evitando otra base hasta justificarla.

## Regla
La selección concreta del modelo se realizará mediante benchmark sobre hardware real,
no por popularidad.
