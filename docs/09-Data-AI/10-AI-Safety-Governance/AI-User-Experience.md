# UX de IA

La aplicación debe distinguir:
- dato verificado;
- información proveniente de una fuente;
- resumen generado.

No presentar contenido AI como si fuese una autoridad oficial.

Para horarios, precios y cierres:
mostrar fuente y fecha de actualización cuando sea posible.

## Contexto y voz

CEFI es la identidad conversacional de GeoGuide AI y está sujeta a estos principios de
factualidad, seguridad, control del usuario y privacidad. CEFI no requiere un LLM y su
definición no autoriza una implementación ni un proveedor de AI o voz.

- Usar solo ubicación, ruta, POIs, preferencias y estado de viaje autorizados para la
  sesión; no inferir permisos por el mero uso de voz.
- No conservar audio, transcripciones ni historial GPS sin propósito, consentimiento y
  retención definidos.
- En Driving/Travel Mode, responder de forma breve, indicar incertidumbre y evitar
  diálogos que aumenten la distracción.
- La salida TTS debe derivarse de los mismos hechos y casos de uso que la UI; un LLM no
  puede convertir datos no verificados en hechos.
