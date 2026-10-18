# UI-2.2 — Plantilla de resultados de validación física

**PLANTILLA VACÍA. NINGUNA SESIÓN EJECUTADA.** Preparada: 2026-10-18.
[Protocolo](UI-2.2-Physical-Validation-Protocol-Proposal.md) · [Matriz](UI-2.2-Physical-Validation-Traceability-Matrix.md) · [Checklist](UI-2.2-Physical-Validation-Session-Checklist.md).

El llenado futuro exige autorización independiente. No copiar PASS_AUTOMATED a resultados físicos.
Los espacios — representan información aún no observada, no valores inferidos del HONOR histórico.

## Identidad de sesión futura

| Campo | Valor por completar |
| --- | --- |
| Alias sesión / operador / responsable | — |
| Inicio/fin y zona horaria reales | — |
| Protocolo/revisión aprobada / referencia G1 | — |
| G2 conexión / G3 APK / G4 operaciones y medios / G5 revisión | — |
| Casos y subcasos autorizados | — |
| Baseline objetivo de preparación | 083239649c86dd9efd9e0050dd3c955ae574b12a |
| Baseline real verificado antes de sesión | — |
| APK elegido, perfil y procedencia | — |
| SHA-256, bytes y firma del APK instalado | — |
| Versión/package/minSdk/targetSdk/ABI del APK | — |
| Alias dispositivo (sin serial completo) | — |
| Modelo / Android / API observados en sesión | — |
| ABI / resolución / densidad física y override observados | — |
| Toolchain que produjo APK / endpoint compilado | — |
| Endpoint/tiles realmente disponibles y ventana | — |
| Alias ruta pública / categorías / snapshot hora original | — |
| Variantes de POI disponibles y subcasos ausentes | — |
| Carpeta privada de evidencia y responsable de acceso | — |
| Regresión preexistente conocida / limitación de entorno | — |

El objetivo HONOR LLY-NX3/API36 se acredita históricamente en P9.3; no rellenar aquí sin reconfirmar.
Gates vacíos no equivalen a permisos concedidos.

## Bitácora inicial/restauración

| Elemento | Inicial observado | Cambio autorizado y referencia | Final observado | Restaurado / pendiente y responsable |
| --- | --- | --- | --- | --- |
| Depuración/USB | — | — | — | — |
| Instalación previa/firma/datos que conservar | — | — | — | — |
| GPS/B1/voz/sesiones existentes | — | — | — | — |
| Permisos Android | — | — | — | — |
| Ubicación | — | — | — | — |
| TalkBack/servicio accesible | — | — | — | — |
| Escala/tamaño de fuente | — | — | — | — |
| Orientación/bloqueo rotación | — | — | — | — |
| Wi-Fi/datos/conectividad | — | — | — | — |
| Copia offline y captura consentida | — | — | — | — |
| Capturas/logs y destino privado | — | — | — | — |

No existe undo garantizado para borrado. Un cambio no restaurado necesita explicación y propietario,
no una marca general de restauración completa.

## Registro de casos

Todos los estados iniciales son NOT_EXECUTED. En ejecución, PASS exige evidencia del subcaso y comparación
con el resultado esperado. FAIL/BLOCKED_BY_PRECONDITION no se convierten en PASS por tests previos.
NOT_APPLICABLE necesita justificación aprobada. Un caso mixto conserva subcasos y no se resume como PASS físico completo.

| ID | Título | Estado | Fecha/hora real | Observado/evidencia privada | Bloqueo/incidencia |
| --- | --- | --- | --- | --- | --- |
| [UI2-PHY-01](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-01) | Identidad del APK | NOT_EXECUTED | — | — | — |
| [UI2-PHY-02](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-02) | Conexión e identidad futura | NOT_EXECUTED | — | — | — |
| [UI2-PHY-03](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-03) | Actualización sin pérdida de datos | NOT_EXECUTED | — | — | — |
| [UI2-PHY-04](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-04) | Arranque estacionario | NOT_EXECUTED | — | — | — |
| [UI2-PHY-05](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-05) | Tiles reales y atribución | NOT_EXECUTED | — | — | — |
| [UI2-PHY-06](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-06) | Ruta y lista sin oclusión | NOT_EXECUTED | — | — | — |
| [UI2-PHY-07](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-07) | Cámara y alternancia | NOT_EXECUTED | — | — | — |
| [UI2-PHY-08](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-08) | Categorías y estados de consulta | NOT_EXECUTED | — | — | — |
| [UI2-PHY-09](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-09) | Identidad mapa/lista | NOT_EXECUTED | — | — | — |
| [UI2-PHY-10](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-10) | Tarjeta factual y placeholder | NOT_EXECUTED | — | — | — |
| [UI2-PHY-11](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-11) | Preview y Detail con contexto | NOT_EXECUTED | — | — | — |
| [UI2-PHY-12](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-12) | Opcionales y nombres largos | NOT_EXECUTED | — | — | — |
| [UI2-PHY-13](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-13) | Normalización del filtro local | NOT_EXECUTED | — | — | — |
| [UI2-PHY-14](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-14) | Subconjunto, orden y vacío local | NOT_EXECUTED | — | — | — |
| [UI2-PHY-15](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-15) | Retención y reemplazo del snapshot | NOT_EXECUTED | — | — | — |
| [UI2-PHY-16](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-16) | Expiración de consulta local | NOT_EXECUTED | — | — | — |
| [UI2-PHY-17](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-17) | Salida y recreación de Exploración | NOT_EXECUTED | — | — | — |
| [UI2-PHY-18](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-18) | Observación de red al escribir | NOT_EXECUTED | — | — | — |
| [UI2-PHY-19](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-19) | Selección explícita I01 | NOT_EXECUTED | — | — | — |
| [UI2-PHY-20](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-20) | Elegibilidad e invalidación I01 | NOT_EXECUTED | — | — | — |
| [UI2-PHY-21](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-21) | Freeze y restricciones B1 | NOT_EXECUTED | — | — | — |
| [UI2-PHY-22](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-22) | Consentimiento y reapertura offline | NOT_EXECUTED | — | — | — |
| [UI2-PHY-23](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-23) | Desconexión y recuperación cached | NOT_EXECUTED | — | — | — |
| [UI2-PHY-24](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-24) | Vacío, no disponible y error/retry | NOT_EXECUTED | — | — | — |
| [UI2-PHY-25](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-25) | Vigencia, límites y privacidad offline | NOT_EXECUTED | — | — | — |
| [UI2-PHY-26](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-26) | Borrado consentido de copia de prueba | NOT_EXECUTED | — | — | — |
| [UI2-PHY-27](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-27) | TalkBack y orden de foco | NOT_EXECUTED | — | — | — |
| [UI2-PHY-28](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-28) | Lectura de tarjetas y fichas | NOT_EXECUTED | — | — | — |
| [UI2-PHY-29](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-29) | Filtro, teclado y estados anunciados | NOT_EXECUTED | — | — | — |
| [UI2-PHY-30](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-30) | Texto grande y orientación | NOT_EXECUTED | — | — | — |
| [UI2-PHY-31](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-31) | Contraste y targets | NOT_EXECUTED | — | — | — |
| [UI2-PHY-32](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-32) | Accesibilidad de estados y recuperación | NOT_EXECUTED | — | — | — |
| [UI2-PHY-33](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-33) | Navegación y estabilidad | NOT_EXECUTED | — | — | — |
| [UI2-PHY-34](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-34) | Permisos, GPS y CEFI sin activación nueva | NOT_EXECUTED | — | — | — |
| [UI2-PHY-35](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-35) | Driving reducido estacionario opcional | NOT_EXECUTED | — | — | — |
| [UI2-PHY-36](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-36) | Restauración y cierre de sesión | NOT_EXECUTED | — | — | — |

## Ficha detallada para duplicar por caso/subcaso ejecutado

| Campo | Registro vacío |
| --- | --- |
| ID / subcaso y responsable | — |
| Estado inicial | NOT_EXECUTED |
| Precondiciones realmente comprobadas | — |
| Datos reales usados / referencia privada al mismo snapshot | — |
| Pasos realizados y hora de cada evento relevante | — |
| Resultado esperado (referenciar protocolo, no redefinirlo) | — |
| Resultado observado literal | — |
| Comparación observación/expectativa | — |
| Estado final y fundamento | — |
| Evidencia, tipo y hash; baseline/build/dispositivo asociado | — |
| Alcance de la observación; qué no pudo comprobarse | — |
| Complemento COVERED_AUTOMATED y enlace; sin atribuirlo a físico | — |
| Riesgo/impacto, posible preexistente vs UI-2 y reproducción | — |
| Restauración realizada, resultado y pendiente | — |
| Revisión del responsable / fecha | — |

Tipos válidos: UI2_PHYSICAL_ANDROID, UI2_TALKBACK_PHYSICAL, UI2_REAL_TILES,
UI2_PHYSICAL_REGRESSION. FLUTTER_RENDERER_TEST se registra solo como evidencia automatizada complementaria.

## Observación de red de PHY-18

| Campo | Registro |
| --- | --- |
| Método de lectura autorizado y responsable de logs | — |
| Control positivo de petición y hora correlacionada | — |
| Ventana control / ventana escritura y duración | — |
| Endpoint(s) y criterio de atribución sin IP personal | — |
| Conteos recibidos y solicitudes no atribuibles | — |
| Límite: intentos cliente no observables por access logs | — |
| Evidencia complementaria spy repository | — |
| Estado del componente físico y limitación | NOT_EXECUTED |

Ni silencio del servidor, ni logcat, ni tráfico HTTPS cifrado por sí solos demuestran cero llamadas cliente.

## Evidencia y privacidad

| Archivo privado/alias | Tipo | Caso/subcaso | Fecha/build/dispositivo asociado | SHA-256 | Redacción revisada/consentimiento |
| --- | --- | --- | --- | --- | --- |
| — | — | — | — | — | — |

No crear archivos ficticios para llenar la tabla. No almacenar tokens, serial completo, ubicaciones personales,
notificaciones ni audio sin consentimiento; no subir automáticamente al repositorio.

## Incidencias y decisión futura

| ID hallazgo | Caso/observación | Severidad y fundamento | Preexistente/UI-2/indeterminado | Evidencia | Responsable y gate |
| --- | --- | --- | --- | --- | --- |
| — | — | — | — | — | — |

Casos/subcasos pendientes: todos hasta que se ejecuten realmente.
La revisión final debe separar resultados físicos, TalkBack y tiles; no cerrar UI-2 por firmar esta plantilla.
No se asigna PASS agregado mientras una cobertura aprobada está pendiente sin disposición humana explícita.

## Estados al preparar la plantilla

```ini
UI_2_CONTRACT = APPROVED_FROZEN
UI_2_1_CODE_INTEGRATION = PASS
UI_2_2_PROTOCOL = READY_FOR_HUMAN_REVIEW
UI_2_2_PROTOCOL_APPROVAL = PENDING
UI_2_2_PHYSICAL_EXECUTION = NOT_AUTHORIZED
UI_2_PHYSICAL_VALIDATION = NOT_EXECUTED
UI_2_TALKBACK_VALIDATION = NOT_EXECUTED
UI_2_REAL_TILES_VALIDATION = NOT_EXECUTED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
UI_2_2_PUSH = NOT_AUTHORIZED
UI_2_2_PR = NOT_AUTHORIZED
UI_2_2_MERGE = NOT_AUTHORIZED
ADMIN_IMPLEMENTATION = NOT_AUTHORIZED
DRIVING_FUNCTIONAL_PACKAGE = NOT_AUTHORIZED
UI_3_IMPLEMENTATION = NOT_AUTHORIZED
```

Decisión humana siguiente: revisión/aprobación del protocolo. Ningún campo vacío concede ejecución.

STOP_AND_REPORT
