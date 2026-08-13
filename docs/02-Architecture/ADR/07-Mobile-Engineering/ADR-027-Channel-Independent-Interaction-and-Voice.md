# ADR-027 – Interacción independiente del canal y voz contextual

**Estado:** Aceptado

## Contexto

GeoGuide AI ofrece descubrimiento geográfico alrededor de la ubicación actual y a lo
largo de una ruta. La interfaz visual, la voz manos libres y clientes futuros necesitan
consultar los mismos datos confiables y ejecutar los mismos casos de uso sin duplicar
reglas de negocio.

La conducción exige respuestas breves y baja distracción. A la vez, ADR-023 y ADR-026
requieren que los hechos y el núcleo geoespacial funcionen sin un LLM.

## Decisión

- Los casos de uso y servicios de aplicación de GeoGuide son independientes del canal.
- Flutter UI, voz y clientes futuros consumen esos mismos servicios; no implementan
  reglas de dominio en pantallas, adaptadores STT/TTS ni prompts.
- El flujo de voz es `STT -> interpretación de intención y contexto -> casos de uso
  GeoGuide -> TTS`.
- El contexto autorizado de sesión puede incluir ubicación actual, ruta activa, POIs
  cercanos, preferencias y estado del viaje. Se aplica minimización de datos y no se
  conserva historial GPS permanente por defecto.
- La interpretación determinista se prefiere para intenciones acotadas. Un LLM puede
  enriquecer la interpretación o redacción mediante `LanguageModelProvider`, pero no
  es requisito para Route Discovery, proximidad, ranking ni fichas factuales.
- Driving/Travel Mode entrega audio breve, reduce la carga visual y no requiere
  manipular el teléfono durante la conducción.
- STT y TTS son puertos/adaptadores sustituibles. La selección de proveedores y sus
  contratos se decidirá antes de implementarlos.

## Alcance incremental

La arquitectura habilita voz como canal estratégico. El núcleo del MVP conserva como
obligatorios el descubrimiento geográfico y las fichas confiables; voz avanzada,
personalización compleja, itinerarios generados, CarPlay y Android Auto son evolución
posterior salvo decisión explícita de alcance.

## Consecuencias

- Se evita divergencia funcional entre UI y voz.
- La seguridad, autorización, trazabilidad y calidad factual se aplican en servicios
  compartidos.
- Los adaptadores de voz deben probarse por separado y también contra los mismos casos
  de uso de aplicación.
- La ubicación y el audio requieren consentimiento, permisos mínimos y políticas de
  retención explícitas antes de habilitar proveedores externos.
