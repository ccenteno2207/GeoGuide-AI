# Reglas de Negocio

Los POIs se muestran dentro de un corredor configurable alrededor de la ruta.

- El descubrimiento cercano usa una ubicación autorizada y un radio configurable.
- El ranking debe ser explicable y no depender de un LLM.
- Una ficha distingue datos factuales, fuente, fecha de actualización y contenido
  generado cuando estén disponibles.
- UI y voz aplican las mismas reglas mediante casos de uso independientes del canal.
- En Driving/Travel Mode las respuestas habladas son breves y las acciones complejas
  se posponen hasta que el usuario pueda interactuar con seguridad.
- La ubicación continua no se conserva permanentemente por defecto.
