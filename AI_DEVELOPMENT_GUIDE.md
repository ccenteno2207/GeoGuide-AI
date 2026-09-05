# AI Development Guide

Esta guía explica **cómo** debe trabajar un agente AI/Codex. `AGENTS.md` conserva las
reglas y restricciones globales del proyecto.

## Lectura y autoridad

Antes de actuar, leer `AGENTS.md`, `PROJECT_CONTEXT.md`, `DOCUMENTATION_INDEX.md`,
`ROADMAP.md`, los ADR aplicables, Entrega 04.6 y la documentación especializada. Leer
`docs/00-Executive/LICENSING-STATUS.md` para cualquier asunto de licencia. El archivo
histórico no dirige implementaciones actuales.

La autoridad depende del ámbito: los ADR aceptados gobiernan arquitectura; el contrato
de fase aprobado gobierna el alcance actual; `PROJECT_CONTEXT.md` describe el estado y
`ROADMAP.md` la progresión. La posición en el roadmap, una capacidad futura descrita en
arquitectura o una propuesta no equivalen a autorización.

## Detección de fase y scope gate

Confirmar en fuentes vigentes qué fases están cerradas, cuál es la siguiente y si existe
un contrato de alcance congelado y aprobado. Antes de una fase mayor:

1. auditar documentación y código;
2. identificar y resolver contradicciones;
3. definir y congelar alcance;
4. obtener aprobación y autorización de ejecución;
5. implementar y validar;
6. integrar mediante PR;
7. validar post-merge;
8. cerrar formalmente.

`PR MERGED` no implica `PHASE CLOSED`.

## Modos de gobierno

### CONTROLLED GOVERNANCE MODE

Se aplica cuando el alcance no está congelado, la aprobación está pendiente o existen
decisiones de arquitectura/alcance sin resolver. Se permite inspeccionar, auditar,
comparar, proponer y registrar evidencia. No se permite implementar, crear la rama de
fase ni resolver autónomamente decisiones de alcance.

### AUTONOMOUS EXECUTION MODE

Solo se activa cuando el contrato de fase está `FROZEN`, la fase está `APPROVED` y la
ejecución autónoma está `AUTHORIZED`. Permite inspeccionar, implementar, probar,
corregir, validar, documentar, hacer commits, push y preparar el PR dentro del alcance.
No permite ampliarlo.

## Flujo de implementación y validación

Partir de `main` limpio y sincronizado, crear la rama autorizada, trabajar mediante
checkpoints pequeños, ejecutar las validaciones relevantes de `AGENTS.md`, mantener
contratos y documentación alineados y producir commits cohesivos.

Distinguir validación local/unitaria, validación de integración y evidencia VM. Cuando
el contrato exija integración real, los mocks no son evidencia suficiente. No ejecutar
operaciones destructivas en VM, modificar datos protegidos ni asumir infraestructura
productiva sin autorización.

Flujo Git esperado: `main` limpio → rama autorizada → checkpoints → pruebas → commits
cohesivos → push → PR → auditoría maestra → remediación → merge → validación post-merge
→ cierre formal → limpieza de rama.

## Escalamiento

Pausar ante ampliación de alcance, nueva decisión arquitectónica, violación de frontera
de fase, operación destructiva, modificación de migración protegida, cambio protegido de
PBF/bounding box, riesgo de pérdida de datos, problema material de seguridad,
contradicción contractual, dependencia inesperada de una fase futura, regresión no
resoluble o imposibilidad de cumplir el DoD.

```text
AUTONOMOUS EXECUTION:
PAUSED

CHECKPOINT:
<id>

REQUIRES MASTER DECISION:
<issue>

EVIDENCE:
<evidence>
```

## Frontera del producto

GeoGuide AI es una plataforma de descubrimiento geográfico, no un clon de Google
Maps/Waze ni un chatbot genérico. Ruta y proximidad funcionan desde hechos confiables
sin depender de un LLM. La voz es un canal sobre servicios compartidos: STT → intención
contextual → casos de uso GeoGuide → TTS. No duplicar lógica en Flutter, voz, prompts o
adaptadores ni introducir capacidades futuras sin aprobación de alcance.

Estado al cierre de P4: no existe un skill personalizado GeoGuide AI. Evaluar su creación
en una iniciativa futura, después de fusionar y validar esta alineación documental.
