# Arquitectura AI

Mobile
→ Backend
→ Channel-independent GeoGuide Application Service
→ Retrieval/Search
→ Trusted POI Knowledge
→ Optional AI Application Service / Local or Open Model
→ Guardrails
→ Response.

La voz sigue `STT → interpretación contextual → servicios GeoGuide → TTS`. STT y TTS
son adaptadores; el contexto autorizado de sesión se minimiza y las reglas de negocio
permanecen en los servicios compartidos. Las intenciones acotadas deben poder resolverse
sin LLM.

## Desacoplamiento
Definir puerto `LanguageModelProvider`.

Implementaciones futuras:
- modelo local;
- servidor compatible con APIs abiertas;
- proveedor externo opcional.

El dominio no debe depender de un fabricante de LLM.
