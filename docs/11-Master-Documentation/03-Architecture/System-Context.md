# Contexto del Sistema

## Actores
- viajero;
- conductor mediante interacción manos libres;
- administrador/editor;
- institución futura;
- partner futuro.

## Sistemas externos
- OpenStreetMap/data extracts;
- motor de routing;
- fuentes oficiales;
- almacenamiento/servicios operativos.
- proveedores STT/TTS sustituibles cuando se habilite voz.

## Trust boundary
El móvil se considera cliente no confiable.
Toda autorización y regla crítica se valida en backend.
La ubicación, ruta activa, POIs, preferencias, estado del viaje, audio y transcripción
solo cruzan límites externos con propósito y autorización explícitos. UI y voz invocan
los mismos servicios de aplicación; los proveedores externos no contienen reglas de
dominio.
