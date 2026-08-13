# Prompt Codex – Inicio de Implementación

Objetivo: preparar GeoGuide AI para el primer Vertical Slice.

No intentes construir toda la aplicación.

Antes de actuar, lee `AGENTS.md`, `PROJECT_CONTEXT.md`, `DOCUMENTATION_INDEX.md`, los
ADR aplicables y Entrega 04.6. La documentación archivada no es normativa.

## Paso 1
Audita el repositorio actual y muestra:
- árbol de carpetas;
- documentación disponible;
- inconsistencias;
- archivos faltantes para bootstrap.

No cambies nada todavía.

## Paso 2
Propón un plan de commits pequeños para:
1. infrastructure local;
2. backend bootstrap;
3. PostGIS migrations;
4. seed POIs;
5. routing spike;
6. discovery endpoint;
7. Flutter bootstrap;
8. map/GPS;
9. integración end-to-end.

El primer endpoint de discovery debe entregar POIs del corredor con ranking básico y
orden por progreso. No debe hacer obligatorios distancia de desvío ni tiempo adicional.

Conserva desde el inicio casos de uso independientes del canal para que Flutter, voz y
futuros clientes reutilicen la misma lógica. La voz STT → contexto → servicios GeoGuide
→ TTS es estratégica e incremental; no bloquea el Vertical Slice factual.

## Paso 3
Espera aprobación antes de ejecutar cambios estructurales importantes.

Cuando se apruebe cada commit:
- implementa solo ese alcance;
- ejecuta tests;
- reporta resultados;
- no avances automáticamente al siguiente commit.
