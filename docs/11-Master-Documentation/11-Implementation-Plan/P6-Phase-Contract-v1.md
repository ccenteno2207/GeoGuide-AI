# P6 PHASE CONTRACT v1 — Mobile Bootstrap

## Estado del contrato

```text
PHASE CONTRACT: FROZEN
PHASE APPROVAL: APPROVED
AUTONOMOUS EXECUTION: NOT AUTHORIZED
```

**Clasificación:** P6 GOVERNANCE DECISION

**Baseline de freeze:** `11a8b002ca0f6b52fd561c63166623ba739bea5e`

**Fecha:** 2026-09-25

Este contrato autoriza el inicio posterior de P6, pero no inicia P6.1 ni la
implementación funcional. P6 permanece con progreso 0 % hasta una autorización de
ejecución autónoma posterior.

## 1. Propósito

Crear el bootstrap Flutter de GeoGuide AI que permita visualizar un mapa, manejar
ubicación puntual y permisos de ubicación, respetando la arquitectura móvil y la
privacidad, sin implementar routing, discovery ni el producto móvil completo.

## 2. Baseline y evidencia preparatoria

- P0–P5: cerradas.
- P6 funcional: no iniciada.
- ADR-016: Flutter aceptado como framework móvil inicial.
- ADR-019: `flutter_map 8.3.2` aceptado como biblioteca de mapas para el baseline
  inicial de P6.
- P6.0-C1: evidencia preparatoria histórica cerrada; no es un checkpoint funcional de
  P6 ni se reutiliza como P6.1–P6.4.
- `maplibre_gl 0.27.1`: alternativa técnicamente viable evaluada; no se incorpora a
  la implementación P6.

## 3. Alcance autorizado

- Bootstrap Flutter.
- Mapa base con `flutter_map 8.3.2`.
- Cámara, pan y zoom.
- Ubicación puntual y permisos de ubicación.
- Estados de ubicación y mensajes de privacidad apropiados.
- Validación Android proporcional al alcance.
- Pruebas, documentación de evidencia y cierre de P6.

## 4. Exclusiones congeladas

- `RoutingProvider`, geometría de ruta / polyline, Lima → Obrajillo y abstracciones de
  motores de routing.
- Navegación turn-by-turn, offline avanzado, GPS en segundo plano y tracking continuo
  de alta precisión.
- CEFI, STT, TTS, LLM, autenticación, analytics y distribución productiva.
- Infraestructura de tiles productiva y capacidades M04–M10 del piloto.

Ninguna capacidad excluida se incorpora por inferencia desde fases anteriores o desde
la arquitectura futura.

## 5. Arquitectura P6

P6 empleará Presentation, Application, Domain y Data / Infrastructure sólo cuando una
responsabilidad del alcance lo justifique. El acceso al GPS y al plugin de ubicación se
encapsulará fuera de Presentation; los widgets no dependerán directamente del plugin.

No se crea un `MapAdapter` artificial sólo para satisfacer Clean Architecture.
`flutter_map` puede permanecer asociado a Presentation cuando corresponda.

## 6. Fuente de tiles para desarrollo y validación

```text
DEVELOPMENT_VALIDATION_TILE_SOURCE = https://tile.openstreetmap.org/{z}/{x}/{y}.png
PURPOSE = DEVELOPMENT_AND_VALIDATION_ONLY
PRODUCTION_AUTHORIZATION = NO
TILE_PROVIDER_GOVERNANCE = PENDING
```

La atribución aplicable debe mantenerse. Esta autorización no selecciona un proveedor
productivo, no autoriza uso ilimitado de `tile.openstreetmap.org` y no sustituye el
gobierno posterior de proveedor, infraestructura, límites operativos y atribución.

## 7. Criterios de aceptación

| ID | Requisito | Método de validación | Evidencia esperada | Condición PASS |
| --- | --- | --- | --- | --- |
| P6-AC-01 | Existe bootstrap Flutter reproducible. | `flutter analyze`, `flutter test` y build Android. | CODE, TEST, GIT. | Proyecto compila, analiza y prueba sin fallos atribuibles a P6. |
| P6-AC-02 | La arquitectura mínima separa responsabilidades P6. | Revisión de paquetes y pruebas de límites. | CODE, TEST, DOC. | Presentation no depende directamente del plugin GPS y no existe abstracción artificial de mapa. |
| P6-AC-03 | Se visualiza un mapa base. | Ejecución Android con fuente autorizada. | SCREENSHOT, LOG, TEST. | Mapa renderiza con atribución aplicable. |
| P6-AC-04 | Cámara, pan y zoom operan. | Prueba runtime Android. | SCREENSHOT, LOG. | Interacción básica estable sobre áreas nuevas. |
| P6-AC-05 | Se solicitan y representan permisos de ubicación. | Pruebas y ejecución Android. | TEST, SCREENSHOT, LOG. | Estados concedido, denegado y no disponible son manejados. |
| P6-AC-06 | Se representa ubicación puntual sin historial. | Prueba runtime con permiso concedido. | TEST, SCREENSHOT, LOG. | Posición puntual visible sin persistencia ni tracking continuo. |
| P6-AC-07 | Se respetan privacidad y mínimo privilegio. | Revisión de permisos, código y manifiesto. | CODE, TEST, DOC. | Sólo permisos de ubicación necesarios; sin almacenamiento de historial GPS. |
| P6-AC-08 | El uso de tiles está limitado al entorno autorizado. | Revisión de configuración y atribución. | CODE, DOC, SCREENSHOT. | Fuente de desarrollo validada; no hay declaración de proveedor productivo. |
| P6-AC-09 | No existe regresión ni ampliación de alcance. | `git diff --check`, pruebas aplicables y auditoría de scope. | GIT, TEST, DOC. | Sin cambios en backend/P4/P5, secretos ni capacidades excluidas. |

## 8. Checkpoints de ejecución congelados

### P6.1 — Flutter Bootstrap

- **Objetivo:** crear el proyecto Flutter y la estructura mínima autorizada.
- **Salida:** bootstrap compilable, analizable y probado.

### P6.2 — Base Map

- **Objetivo:** integrar `flutter_map 8.3.2`, cámara e interacción base.
- **Salida:** mapa visible con fuente de desarrollo autorizada y atribución aplicable.

### P6.3 — GPS / Location

- **Objetivo:** encapsular permisos y ubicación puntual.
- **Salida:** estados de ubicación demostrables, sin tracking ni historial.

### P6.4 — Validation & Closure

- **Objetivo:** validar criterios P6-AC-01 a P6-AC-09 y preparar propuesta de cierre.
- **Salida:** evidencia objetiva, sin regresión ni ampliación de scope.

## 9. Gobernanza de ejecución

Antes de iniciar P6.1 se requiere una autorización separada de ejecución autónoma.
Durante P6, detener y solicitar decisión de gobierno ante cambio de ADR, expansión de
alcance, proveedor productivo de tiles, modificación de contratos P4/P5, necesidad de
routing, operación destructiva, riesgo de privacidad o regresión no resoluble.

P6 sólo podrá cerrarse después de implementación autorizada, validación de todos los
criterios, PR, validación post-merge y decisión formal de cierre. Un PR integrado no
equivale al cierre de fase.
