# GeoGuide AI – Entrega 09 – Data & AI

## Objetivo
Definir cómo GeoGuide AI obtiene, gobierna, valida, enriquece y utiliza datos para
convertir una ruta geográfica en una experiencia de descubrimiento confiable.

La IA es una capa de enriquecimiento y recomendación; no reemplaza las fuentes
factuales ni el motor geoespacial.

La IA también puede apoyar la interpretación contextual y la redacción de respuestas,
pero voz no equivale a LLM: el flujo STT → intención/contexto → servicios GeoGuide →
TTS reutiliza casos de uso independientes del canal y debe admitir intenciones
acotadas sin modelo generativo.

## Principio fundamental
**Facts first, AI second.**

Horarios, precios, coordenadas, restricciones de acceso y otros datos operativos deben
provenir de fuentes identificables. Un modelo generativo no debe inventarlos.

## Alcance
- fuentes de POIs;
- ingestión y normalización;
- calidad;
- provenance/lineage;
- enriquecimiento;
- búsqueda semántica;
- RAG futuro;
- recomendaciones;
- ranking híbrido;
- evaluación;
- gobernanza AI;
- MLOps/LLMOps;
- analytics.

## Open Source First
La arquitectura debe permitir modelos y herramientas open source/autohospedables.
