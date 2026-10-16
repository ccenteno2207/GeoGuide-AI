# UI-0 — Compatibilidad de propuestas Rutea

Fecha: 2026-10-15. Baseline: `7edc494ba9bf578da07deec25ace1d625ecd5a5b`. Estado: MASTER_DECISIONS_APPROVED / DOCUMENTATION_INTEGRATION_AUTHORIZED. Ninguna clasificación aprueba una modificación funcional.

Procedencia y hashes: [inventario y gobierno](UI-0-Governance-and-Rutea-Inventory.md). Los tres originales se revisaron completos en copias verificadas. No se incorporan automáticamente ni sustituyen contratos congelados.

## Resolución maestra A/B/C

Fuente: instrucción humana «UI-0 — MASTER DECISION RESOLUTION, DOCUMENTATION REMEDIATION & CONTROLLED AUTONOMOUS COMPLETION», recibida el 2026-10-15. Registro y límites en el [inventario](UI-0-Governance-and-Rutea-Inventory.md).

| Decisión | Estado | Disposición definitiva para UI-0 |
|---|---|---|
| DECISION A | APPROVED | APPROVED_FOR_VISUAL_CONTRACT: dirección Rutea Explorer + CEFI Smart, CEFI permanente y «Avisos de CEFI» operativo. DEFERRED_FUNCTIONAL_CAPABILITY: búsqueda/geocodificación y «Habla con CEFI» conversacional; sin controles simulados, STT, micrófono ni nuevos consentimientos |
| DECISION B | APPROVED | CONTRACT_CONFLICT_RECORDED: P9 §7/GPS Follow queda como asunto independiente pendiente de disposición contractual. No se elige precedencia ni se concede excepción; comportamiento implementado no equivale a conformidad funcional |
| DECISION C | APPROVED | FUNCTIONAL_DRIVING_NOT_AUTHORIZED: DR separado, no forma parte del contrato visual ni es requisito de UI-1/2/3. UI-4 requiere revisión específica de DR y P9/GPS antes de ejecución |

Estas decisiones sustituyen el gate humano de separación pendiente en la revisión anterior. Autorizan completar e integrar documentación tras validación, no implementar UI-1 a UI-5 ni DR.

## UI_0_CONTRACT_COMPATIBILITY_MATRIX

| Original / sección | Clasificación | Fundamento y disposición propuesta |
|---|---|---|
| Rutea-UI-UX-Contract-v1-Proposal.md, tema/POIs/estados | COMPATIBLE_WITH_ADJUSTMENTS | Material 3, mapa protagonista, datos factuales y accesibilidad son compatibles. Añadir selección explícita I01, cambio de baseline y nueva distribución UI-1–5 |
| Mismo original, búsqueda diferida y «Habla con CEFI» futuro | APPROVED_FOR_VISUAL_CONTRACT / DEFERRED_FUNCTIONAL_CAPABILITY | DECISION A confirma «Avisos de CEFI» operativo y búsqueda/conversación futuras; no hay decisión pendiente sobre esta separación |
| Mismo original, DR como requisito automático anterior a UI-4 | FUNCTIONAL_DRIVING_NOT_AUTHORIZED | DECISION C separa DR. UI-1/2/3 no dependen de implementarlo; UI-4 exige revisión específica, sin aprobación automática de guards, frescura, retorno, cámara ni excepciones |
| Rutea-UI-0-Contract-Reconciliation-Proposal.md, inventario de estados | COMPATIBLE_WITH_ADJUSTMENTS | Trazabilidad histórica válida; actualizar alcance I01 y no elevar la evidencia previa a validación actual |
| Mismo original, excepciones P9/GPS/B1/C2 | CONTRACT_CONFLICT_RECORDED | DECISION B aprueba registrar y diferir la disposición contractual independiente. DRIVING-01–06 no se congelan ni se ratifican funcionalmente con UI-0 |
| Rutea-Driving-Corrective-Package-Proposal.md, guards/callbacks | FUNCTIONAL_DRIVING_NOT_AUTHORIZED | DECISION C mantiene la corrección fuera del alcance; una futura revisión debe incorporar selector I01 y callbacks de elección retenidos |
| Mismo original, marcador/frescura/encuadre/retorno/TTS | CONTRACT_CONFLICT_RECORDED / FUNCTIONAL_DRIVING_NOT_AUTHORIZED | DECISION B/C: originales intactos, conflicto abierto y prohibición de cambios; no promover políticas propuestas a conformidad o contrato funcional aprobado |
| Mismo original, atribución estática y accesibilidad | COMPATIBLE | P9 ya exige atribución, targets y texto escalable. Puede proponerse estilo no interactivo sin conceder el resto de DR |

## Contraste por fuente vigente

| Fuente | Regla preservada y ajuste requerido |
|---|---|
| [Entrega 04.6](../../04-SolutionArchitecture/06-Master-Architecture/01-Master/GeoGuideAI-Master-Architecture.md), [ADR-027](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-027-Channel-Independent-Interaction-and-Voice.md) | UI y voz reutilizan servicios; Facts First; no nueva arquitectura, proveedor o lógica de dominio en widgets |
| [Design System](../../05-UX-UI/04-Design-System/Design-System.md), [handoff](../../05-UX-UI/10-Implementation-Handoff/Flutter-Handoff.md) | Tema/tokens centralizados, estados, componentes y accesibilidad. SearchField del catálogo conceptual no demuestra capacidad instalada |
| [P8](P8-Phase-Contract-v1.md) | Taxonomía y filtrado backend, preview/detalle factuales, procedencia y distancia al trazado; sin inventar fotos, ratings o direcciones |
| [P9](P9-Phase-Contract-v1.md), [anexo caché](P9-Local-Cache-Design-v1.md) | Snapshot único, 24 h, payload 5 MiB, consentimiento/borrado/errores; Driving restringido, sin rutas indirectas de interacción |
| [GPS Follow](GPS-Follow-Mode-Contract-Proposal.md) | APPROVED_FROZEN; línea 21 conserva dos frases incompatibles sobre congelación y display pasivo. No corregirla ni elegir precedencia mediante un rediseño visual |
| [B1](B1-Active-Route-Session-Implementation-Evidence.md), [R01](R01-GPS-Lifecycle-Remediation-Evidence.md) | Ownership exclusivo, inicio/Stop explícitos, frescura, lifecycle y rechazo de respuestas tardías; no reconstruir servicios por cambiar widgets |
| [I01](I01-Selected-POI-Session-Integration-Evidence.md) | Elegir/quitar es explícito fuera de Driving; abrir ficha no elige. Borrador ligado a instancia de snapshot, freeze al iniciar y chosenIds inmutables en worker. Bloqueo de edición/discovery/caché durante B1; conservar contexto desconocido tras recreación y no restaurar selección tras Stop |
| I01 codec/puerto | `RouteSessionClient.start(snapshot, chosenIds: ...)`, `SelectedPoiSessionCodec` y su límite total 5 MiB no se rediseñan. El límite del frame de sesión y el del payload de caché son distintos; no reducirlos a una sola promesa |
| [C1](C1-CEFI-Alert-Delivery-Core-Evidence.md), [C2](C2-CEFI-Voice-Alerts-Implementation-Evidence.md), [C2.1](C2.1-Controlled-Voice-Diagnostic-Evidence.md) | Consentimiento revocable, voz local, cooldown/cola/acuses/foco/cancelación intactos. Diagnóstico solo debug y fuera de Driving. No STT ni micrófono; voiceEnabled no significa habla en curso |
| [P12](P12-Phase-Contract-v1.md), [preparación](P12.2-P12.4-Preparation-Evidence.md) | 45% administrativo, P12.5 NOT_AUTHORIZED; evidencia visual no valida conducción. I01 físico NOT_EXECUTED, V01 STATIONARY_PARTIAL y deuda backup abiertas según encargo |

## Riesgos residuales y disposición aprobada

El riesgo HIGH de ampliar alcance Driving queda contenido documentalmente mediante DECISION B/C: ningún cambio funcional ni excepción se autoriza. La contradicción P9/GPS continúa abierta como asunto independiente; UI-0 no declara PASS funcional. No bloquea esta integración documental porque la decisión humana dispone expresamente su separación. Si surge una contradicción material nueva, STOP_AND_REPORT.

I01 Selected POI Session es contrato obligatorio de no regresión para cualquier futuro paquete: no perder selección/freeze ni reactivar edición durante B1 al extraer widgets. Las pruebas previstas en el [contrato visual](UI-0-Visual-Design-Contract-Proposal.md) no están ejecutadas por UI-0.

Gate documental de producto: resuelto por A/B/C. Gate de integración: condicionado a alcance, integridad, auditoría y reglas normales del repositorio. Gate de ejecución UI-1 a UI-5: NOT_AUTHORIZED. Gate específico UI-4: revisión contractual DR/P9/GPS previa, sin nuevas acciones o controles Driving. La integración no elimina los riesgos funcionales ni valida dispositivos o conducción.
