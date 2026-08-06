# RAG / Knowledge Architecture

RAG no es obligatorio para el primer incremento funcional.

## Flujo futuro
Question
→ intent/context
→ retrieve trusted documents/POI facts
→ build context
→ LLM
→ grounded answer
→ source references.

## Casos
- “¿Qué historia tiene este sitio?”
- “¿Qué puedo visitar cerca de esta ruta?”
- “Resume este museo para escucharlo durante el viaje.”

## Grounding
Si no existe evidencia suficiente, la respuesta debe indicarlo en lugar de completar
el vacío con una afirmación inventada.
