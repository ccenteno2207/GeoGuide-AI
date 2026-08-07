# Arquitectura AI

Mobile
→ Backend
→ AI Application Service
→ Retrieval/Search
→ Trusted POI Knowledge
→ Optional Local/Open Model
→ Guardrails
→ Response.

## Desacoplamiento
Definir puerto `LanguageModelProvider`.

Implementaciones futuras:
- modelo local;
- servidor compatible con APIs abiertas;
- proveedor externo opcional.

El dominio no debe depender de un fabricante de LLM.
