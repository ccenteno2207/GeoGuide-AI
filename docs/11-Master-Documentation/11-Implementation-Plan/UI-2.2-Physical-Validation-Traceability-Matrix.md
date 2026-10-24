# UI-2.2 — Matriz de trazabilidad de validación física propuesta

Fecha: 2026-10-18. Base efectiva: `083239649c86dd9efd9e0050dd3c955ae574b12a`.
[Protocolo y autoridad](UI-2.2-Physical-Validation-Protocol-Proposal.md). UI2-AC-01–14 y U2-D01–D06 permanecen congelados.

El catálogo y sus estados iniciales se conservan como preparación histórica.
El [seguimiento vigente del 2026-10-24](#seguimiento-vigente-2026-10-24)
registra los subcasos S01 ejecutados sin convertir los 36 casos completos en PASS.

## Leyenda

- COVERED_AUTOMATED: respaldo en UI-2.1; no prueba física.
- PLANNED_PHYSICAL: futura observación diseñada; requiere gates, no significa ejecutada.
- BLOCKED_BY_PRECONDITION: clasificación prospectiva de subcaso sin dato/permiso/observabilidad; no es resultado ejecutado.
- NOT_APPLICABLE: solo para dimensiones sin requisito o subcasos justificados/aprobados; no oculta bloqueos.
- Estado inicial de todos los casos: NOT_EXECUTED. Un resultado parcial no se agrega a PASS físico completo.
- Los 14 AC constan PASS_AUTOMATED en [UI-2.1](UI-2.1-Execution-and-Acceptance-Evidence.md); aquí no se repiten tests.

## Cobertura UI2-AC-01–14

| Criterio congelado | Casos | Cobertura | Límite |
| --- | --- | --- | --- |
| UI2-AC-01 Mapa/ruta | [04](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-04), [05](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-05), [06](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-06), [30](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-30) | Renderer/widget + PLANNED_PHYSICAL | Tiles reales requieren PHY-05 |
| UI2-AC-02 Mapa/lista | [06](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-06), [07](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-07), [09](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-09), [14](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-14) | IDs/widget + PLANNED_PHYSICAL | ID técnico privado; nunca UUID en UI |
| UI2-AC-03 Categorías | [08](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-08), [24](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-24) | Sheet/controller/mapper + PLANNED_PHYSICAL | Filtro local no es requery |
| UI2-AC-04 Datos actuales | [09](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-09), [10](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-10), [12](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-12), [28](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-28) | Campos presentes/ausentes + PLANNED_PHYSICAL | Sin variantes reales: subcaso bloqueado |
| UI2-AC-05 Distancia | [10](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-10), [28](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-28) | Strings + PLANNED_PHYSICAL/TalkBack | Sin ETA/desvío/distancia al usuario |
| UI2-AC-06 Continuidad | [07](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-07), [11](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-11), [15](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-15), [28](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-28), [33](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-33) | Retorno + PLANNED_PHYSICAL | Solo contexto válido y viewport factible |
| UI2-AC-07 I01 | [11](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-11), [19](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-19), [20](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-20), [21](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-21) | Selection/widget/worker + PLANNED_PHYSICAL parcial | B1 físico requiere gate separado |
| UI2-AC-08 Filtro local | [13](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-13), [14](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-14), [15](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-15), [16](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-16), [17](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-17), [18](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-18), [29](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-29), [35](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-35) | Unicode/spy/TTL/teardown + PLANNED_PHYSICAL parcial | Silencio de servidor no prueba cero intentos |
| UI2-AC-09 Estados/cache | [08](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-08), [16](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-16), [20](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-20), [22](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-22), [23](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-23), [24](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-24), [25](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-25), [26](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-26), [29](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-29), [32](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-32) | Offline/TTL + PLANNED_PHYSICAL parcial | No forzar milisegundos/bytes en teléfono |
| UI2-AC-10 Medios | [10](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-10), [12](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-12), [28](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-28) | Widget/asset/APK audit + PLANNED_PHYSICAL | Sin fotos nuevas ni TEST_ONLY en producto |
| UI2-AC-11 Driving/GPS/voz | [17](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-17), [21](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-21), [34](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-34), [35](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-35) | Guards/diff + PLANNED_PHYSICAL acotada | Sin sesiones GPS/voz; Driving opcional |
| UI2-AC-12 Accesibilidad | [05](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-05), [27](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-27), [28](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-28), [29](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-29), [30](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-30), [31](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-31), [32](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-32) | Semantics/guidelines/tokens + PLANNED_PHYSICAL/TalkBack | No certificación WCAG global por captura |
| UI2-AC-13 Viewports | [05](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-05), [06](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-06), [12](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-12), [30](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-30), [31](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-31) | Matriz 4×2 COVERED_AUTOMATED + teléfono PLANNED_PHYSICAL | Un teléfono no acredita cuatro tamaños exactos |
| UI2-AC-14 No regresión | [01](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-01), [02](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-02), [03](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-03), [04](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-04), [18](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-18), [21](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-21), [25](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-25), [33](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-33), [34](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-34), [36](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-36) | Format/analyze/202 tests/build/diff COVERED_AUTOMATED + observación acotada | Repetir tests por documentación: NOT_APPLICABLE |

## Relación por caso

| ID | Grupo/caso | UI2-AC | U2-D | Contrato complementario | Evidencia previa | Cobertura futura | Estado inicial |
| --- | --- | --- | --- | --- | --- | --- | --- |
| [UI2-PHY-01](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-01) | A — Identidad del APK | 14 | D05 | UI2-AC-14; U2-D05; P9-AC-11 | [Fuente](UI-2.1-Validation-Logs/artifact-sha256.json) | Estático; validación de instalación futura | NOT_EXECUTED |
| [UI2-PHY-02](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-02) | A — Conexión e identidad futura | 14 | D05 | UI2-AC-14; P9-AC-12; P9.3 | [Fuente](UI-2.1-Validation-Logs/artifact-sha256.json) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-03](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-03) | A — Actualización sin pérdida de datos | 14 | D05 | UI2-AC-14; P9-AC-10/12 | [Fuente](UI-2.1-Validation-Logs/artifact-sha256.json) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-04](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-04) | A — Arranque estacionario | 01, 14 | D05 | UI2-AC-01/14; UI-1 shell | [Fuente](UI-2.1-Validation-Logs/artifact-sha256.json) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-05](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-05) | B — Tiles reales y atribución | 01, 12, 13 | D05, D06 | UI2-AC-01/12/13; ADR-019; P8 §9 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-06](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-06) | B — Ruta y lista sin oclusión | 01, 02, 13 | D05, D06 | UI2-AC-01/02/13; P8-AC-04 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-07](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-07) | B — Cámara y alternancia | 02, 06 | D05 | UI2-AC-02/06; P8 §7/9 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-08](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-08) | B — Categorías y estados de consulta | 03, 09 | D05 | UI2-AC-03/09; P8 §7, AC03/05 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-09](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-09) | C — Identidad mapa/lista | 02, 04 | D05 | UI2-AC-02/04; P8-AC-01/04 | [Fuente](../../../mobile/test/features/discovery/presentation/poi_visual_contract_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-10](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-10) | C — Tarjeta factual y placeholder | 04, 05, 10 | D02, D03 | UI2-AC-04/05/10; U2-D02/D03; P8 §8 | [Fuente](../../../mobile/test/features/discovery/presentation/poi_visual_contract_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-11](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-11) | C — Preview y Detail con contexto | 06, 07 | D01, D05 | UI2-AC-06/07; P8-AC-01/02 | [Fuente](../../../mobile/test/features/discovery/presentation/poi_visual_contract_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-12](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-12) | C — Opcionales y nombres largos | 04, 10, 13 | D02, D03, D06 | UI2-AC-04/10/13; U2-D02/D06 | [Fuente](../../../mobile/test/features/discovery/presentation/poi_visual_contract_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-13](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-13) | D — Normalización del filtro local | 08 | D01 | UI2-AC-08; U2-D01 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-14](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-14) | D — Subconjunto, orden y vacío local | 02, 08 | D01, D04 | UI2-AC-02/08; U2-D01/D04 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-15](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-15) | D — Retención y reemplazo del snapshot | 06, 08 | D01 | UI2-AC-06/08; U2-D01; I01 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-16](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-16) | D — Expiración de consulta local | 08, 09 | D01 | UI2-AC-08/09; U2-D01; P9 §6 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL tras 24 h; frontera COVERED_AUTOMATED | NOT_EXECUTED |
| [UI2-PHY-17](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-17) | D — Salida y recreación de Exploración | 08, 11 | D01 | UI2-AC-08/11; U2-D01 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-18](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-18) | D — Observación de red al escribir | 08, 14 | D01, D05 | UI2-AC-08/14; U2-D01/D05 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL parcial; observabilidad requerida; spy automatizado | NOT_EXECUTED |
| [UI2-PHY-19](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-19) | E — Selección explícita I01 | 07 | — | UI2-AC-07; I01; P8 continuidad | [Fuente](../../../mobile/test/features/tracking/i01_widget_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-20](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-20) | E — Elegibilidad e invalidación I01 | 07, 09 | — | UI2-AC-07/09; I01 | [Fuente](../../../mobile/test/features/tracking/i01_widget_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-21](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-21) | E — Freeze y restricciones B1 | 07, 11, 14 | D05 | UI2-AC-07/11/14; I01/B1/R01 | [Fuente](../../../mobile/test/features/tracking/i01_widget_test.dart) | COVERED_AUTOMATED; físico BLOCKED_BY_PRECONDITION (B1 no autorizado) | NOT_EXECUTED |
| [UI2-PHY-22](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-22) | F — Consentimiento y reapertura offline | 09 | — | UI2-AC-09; P9 §6, AC01/05/08 | [Fuente](../../../mobile/test/features/discovery/offline_cache_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-23](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-23) | F — Desconexión y recuperación cached | 09 | D05 | UI2-AC-09; P9-AC-01/02/03/04 | [Fuente](../../../mobile/test/features/discovery/offline_cache_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-24](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-24) | F — Vacío, no disponible y error/retry | 03, 09 | D05 | UI2-AC-03/09; P8-AC-05; P9-AC-01/03/10 | [Fuente](../../../mobile/test/features/discovery/offline_cache_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-25](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-25) | F — Vigencia, límites y privacidad offline | 09, 14 | D05 | UI2-AC-09/14; P9-AC-05/10 | [Fuente](../../../mobile/test/features/discovery/offline_cache_test.dart) | PLANNED_PHYSICAL tras 24 h; frontera COVERED_AUTOMATED | NOT_EXECUTED |
| [UI2-PHY-26](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-26) | F — Borrado consentido de copia de prueba | 09 | — | UI2-AC-09; P9 §6, AC05/10 | [Fuente](../../../mobile/test/features/discovery/offline_cache_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-27](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-27) | G — TalkBack y orden de foco | 12 | D06 | UI2-AC-12; U2-D06; P8 §10; P9-AC-09 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-28](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-28) | G — Lectura de tarjetas y fichas | 04, 05, 06, 10, 12 | D02, D06 | UI2-AC-04/05/06/10/12; U2-D02/D06 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-29](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-29) | G — Filtro, teclado y estados anunciados | 08, 09, 12 | D01, D06 | UI2-AC-08/09/12; U2-D01/D06 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-30](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-30) | G — Texto grande y orientación | 01, 12, 13 | D06 | UI2-AC-01/12/13; U2-D06 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-31](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-31) | G — Contraste y targets | 12, 13 | D06 | UI2-AC-12/13; U2-D06; P9-AC-09 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-32](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-32) | G — Accesibilidad de estados y recuperación | 09, 12 | D06 | UI2-AC-09/12; P8-AC-08/10; P9-AC-09 | [Fuente](../../../mobile/test/features/discovery/ui2_experience_test.dart) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-33](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-33) | H — Navegación y estabilidad | 06, 14 | D05 | UI2-AC-06/14; P8 continuidad; UI-1 shell | [Fuente](UI-2.1-Validation-Logs/scope-audit.txt) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-34](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-34) | H — Permisos, GPS y CEFI sin activación nueva | 11, 14 | D05 | UI2-AC-11/14; ADR-027; B1/R01/C2 | [Fuente](UI-2.1-Validation-Logs/scope-audit.txt) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |
| [UI2-PHY-35](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-35) | H — Driving reducido estacionario opcional | 08, 11 | D01, D05 | UI2-AC-08/11; P9 §7; UI-0 compatibilidad | [Fuente](UI-2.1-Validation-Logs/scope-audit.txt) | PLANNED_PHYSICAL opcional con gate Driving | NOT_EXECUTED |
| [UI2-PHY-36](UI-2.2-Physical-Validation-Protocol-Proposal.md#ui2-phy-36) | H — Restauración y cierre de sesión | 14 | D05 | P9-AC-10/12; U2-D05; gates UI-2.2 | [Fuente](UI-2.1-Validation-Logs/scope-audit.txt) | PLANNED_PHYSICAL; gates y datos del caso | NOT_EXECUTED |

## Decisiones y contratos transversales

| Fuente | Casos | Invariante |
| --- | --- | --- |
| U2-D01 | 11, 13–18, 29, 35 | Nombre local, NFD/diacríticos/espacios/subcadena, orden, retención y limpieza |
| U2-D02 | 10, 12, 28 | Miniatura estable/placeholder; sin campos nuevos |
| U2-D03 | 01, 10, 12 | Derechos y TEST_ONLY fuera del producto |
| U2-D04 | 13, 14 | Sin localidades/geocoding; extremos por mapa |
| U2-D05 | 01–09, 16–18, 21, 23–26, 33–36 | Separación automatizado/renderer/APK/Android/TalkBack/tiles |
| U2-D06 | 05/06, 12, 27–32 | Accesibilidad y matriz 4×2; física solo en condiciones observadas |
| P8 §§7–10, AC01–10/14/15 | 05–15, 19/20, 27–33 | Datos, categorías, contexto, mapa/lista, accesibilidad; sin modificar API |
| P9 §6 y anexo, AC01–05/08/10 | 16, 22–26, 32 | Copia única, TTL 24 h, 5 MiB payload, consentimiento/borrado |
| P9 §7, AC06–09 | 17, 21, 34/35 | Guards, Driving estático/salida; sin nueva política funcional |
| I01 | 09/11, 19–21 | Consultar no elige, pertenencia/elegibilidad y freeze |
| B1/R01/C2, ADR-027 | 21, 34/35 | Ownership, lifecycle, voz, consentimiento intactos |
| UI-0/UI-1 | 04–07, 27–35 | Identidad/shell y separación Driving funcional; sin reabrir contratos |

## Complementos verificables y vacíos

- [Filtro unitario](../../../mobile/test/features/discovery/poi_result_filter_test.dart), [experiencia/spy/TTL/viewports](../../../mobile/test/features/discovery/ui2_experience_test.dart), [Preview](../../../mobile/test/features/discovery/presentation/poi_preview_sheet_test.dart), [Detail](../../../mobile/test/features/discovery/presentation/poi_detail_sheet_test.dart).
- [Offline UI](../../../mobile/test/features/discovery/offline_ui_test.dart), [cache](../../../mobile/test/features/discovery/offline_cache_test.dart), [P9 anexo](P9-Local-Cache-Design-v1.md): fronteras de tiempo/bytes/corrupción/borrado/backup no se recrean destruyendo datos del HONOR.
- [I01 selección](../../../mobile/test/features/tracking/i01_selection_test.dart), [widget](../../../mobile/test/features/tracking/i01_widget_test.dart), [worker](../../../mobile/test/features/tracking/i01_worker_test.dart), [B1 widget](../../../mobile/test/features/tracking/b1_widget_test.dart), [R01](../../../mobile/test/features/tracking/r01_investigation_test.dart), [C2](../../../mobile/test/features/tracking/c2_voice_test.dart), [CEFI](../../../mobile/test/features/tracking/cefi_delivery_test.dart).
- [Formato](UI-2.1-Validation-Logs/format.txt), [análisis](UI-2.1-Validation-Logs/analyze.txt), [202 pruebas](UI-2.1-Validation-Logs/flutter-tests.txt), [APK/assets](UI-2.1-Validation-Logs/apk-audit.txt), [renderer](UI-2-Visual-Evidence/README.md): evidencia histórica, sin repetir ahora.
- Datos reales ausentes, tiempo <24 h, observabilidad insuficiente o permiso no concedido bloquean el subcaso futuro; hoy NOT_EXECUTED.
- No se propone prueba física de GIS/ranking, inyección de payload, backup del usuario, proxy/certificados TLS, GPS continuo, voz de proximidad, STT o conducción.
- Protocolo APPROVED no equivale a entorno listo, ejecución física ni aceptación del producto.

[Checklist](UI-2.2-Physical-Validation-Session-Checklist.md) · [Resultados sin ejecutar](UI-2.2-Physical-Validation-Results-Template.md).

## Seguimiento vigente 2026-10-24

La tercera sesión UI-2.3.2 fue focalizada en la desaparición del teclado, bajo
autorización específica del propietario y el
[protocolo S01](UI-2.3.2-Focused-Physical-Validation-Protocol.md).
La [evidencia consolidada](UI-2.3.2-Local-Search-and-Accessibility-Corrective-Evidence.md#cierre-documental-2026-10-24)
contiene P01–P07, identidad del APK, escenario y clasificación. Se consultó la
bitácora privada solo en lectura; aquí se publican conclusiones sanitizadas,
sin identificadores únicos, registros completos, APK extraídos ni datos personales.

Dispositivo de prueba: HONOR LLY-NX3. APK debug `com.geoguideai.geoguide_ai`,
`1.0.0 / versionCode 1`, SHA-256
`32F2D62A4B7E6A007E92CB89F2DB6990F8D9E4E2AE6E0983BAEA045E1FDB70B5`.
Instalación y coincidencia binaria: CODEX_VERIFIED, PASS. Interacciones P01–P06,
regresión incidental y restauración: OWNER_OBSERVED, PASS en el alcance probado.

| Casos del catálogo relacionados | Evidencia S01 del 2026-10-24 | Alcance y pendientes conservados |
| --- | --- | --- |
| UI2-PHY-01–04 | Identidad, firma compatible, actualización con datos conservados y apertura verificadas; ruta Online calculada. | Evidencia de esta instalación/arranque; no se completa por asociación cada requisito de los cuatro casos originales. |
| UI2-PHY-13 | P01/P02 PASS: teclado estable, escritura/edición de «Cant»/«Canta», una coincidencia correcta. | Subcaso de interacción y subcadena PASS; variantes de diacríticos, espacios y Unicode no probadas en esta sesión siguen pendientes físicamente. |
| UI2-PHY-14 | P02/P03 PASS: Plaza de Armas de Canta; vacío exacto; borrar recupera 5 POIs. | Subconjunto/vacío observado PASS; no se acredita auditoría completa de IDs, orden y equivalencia mapa/lista. |
| UI2-PHY-07/11/15 | P04/P05 PASS: Back, reapertura/refoco, Preview/Detail y retorno conservan «Canta»/una coincidencia. | Retención en contexto válido PASS; no prueba todo el viewport, I01, reemplazo de identidad o expiración del snapshot. |
| UI2-PHY-08 | P06 PASS: Sitio arqueológico muestra 1 POI en mapa/lista; restablecer devuelve 5. | Subcaso de categorías PASS; error/retry, vacío backend y demás estados no se acreditan. |
| UI2-PHY-18 | P07 NOT_VERIFIED_PHYSICALLY; evidencia automatizada previa de cero llamadas al source al escribir, PASS. | No observación del tráfico real. Sin proxy, captura general ni instrumentación. No se declara PASS físico. |
| UI2-PHY-29 | P01–P05 prueban teclado ordinario y estados visuales del filtro. | TalkBack no se activó; el caso con lector y anuncios de estados no se considera ejecutado en esta tercera sesión. A01 sigue UNCONFIRMED / DEFERRED. |
| UI2-PHY-05/06/33/34 | Observación incidental sin nueva obstrucción; atribución OpenStreetMap visible; sin activar GPS continuo/voz ni cambiar permisos. | PASS incidental del alcance S01; no repite cartografía, layout completo, navegación ampliada, permisos ni sesiones. |
| UI2-PHY-36 | G6 PASS: búsqueda vacía, teclado/fichas cerrados y ruta conservada; TalkBack no activado. | Restauración de esta sesión confirmada por el propietario; no equivale al cierre de todo UI-2.2. |

El defecto de desaparición del teclado queda corregido y confirmado en la
interacción física probada. P01–P06 conservan PASS; la limitación de red no los
degrada. La sesión global y S01 global permanecen PARTIAL por P07. El toque
accidental en mapa y el recálculo de 97,7 a 97,6 km (104 min/5 POIs) no constituyen
una regresión demostrada. La etiqueta «A 131 m del trazado» expresa metros.

Los casos/subcasos UI-2.2 ajenos a esta cobertura conservan sus resultados previos
o pendientes; no se reasignan a PASS por asociación. Tampoco se reabren los
resultados previos de UI-2.3.1. A01, variantes no observadas, offline/TTL, B1,
Driving y otros casos pendientes no se cierran. La esfera luminosa/ondas de CEFI
continúa como deuda visual aceptada, sin cambio de diseño o comportamiento.

```ini
UI_2_3_2_S01_USER_INTERACTION_PHYSICAL = PASS
UI_2_3_2_S01_NETWORK_AUTOMATED = PASS
UI_2_3_2_S01_NETWORK_PHYSICAL = NOT_VERIFIED_PHYSICALLY
UI_2_3_2_THIRD_PHYSICAL_SESSION = PARTIAL
UI_2_3_2_S01_PHYSICAL = PARTIAL
UI_2_3_2_A01_ROOT_CAUSE = UNCONFIRMED
UI_2_3_2_A01_REMEDIATION = DEFERRED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
UI_2_PRODUCTION_READINESS = NOT_DECLARED
```
