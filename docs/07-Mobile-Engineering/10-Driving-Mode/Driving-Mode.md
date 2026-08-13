# Modo Conducción

## Objetivo
Reducir interacción manual durante desplazamiento.

## UI
- mapa dominante;
- próximo POI;
- distancia;
- categoría;
- proximidad y, posteriormente, desvío/tiempo adicional cuando estén disponibles;
- botones grandes y mínimos;
- audio breve y priorizado cuando el canal de voz esté habilitado.

## Comportamiento
No mostrar contenido histórico extenso mientras el usuario está conduciendo.

Flujo de voz: STT → intención contextual → caso de uso GeoGuide → TTS. Las respuestas
deben ser cortas, accionables y basadas en la ruta, ubicación y POIs autorizados. Las
acciones complejas se difieren hasta que el usuario esté detenido. El modo debe seguir
siendo útil sin LLM y no debe exigir CarPlay o Android Auto.

## Notificaciones
Evitar exceso de alertas. Aplicar:
- distancia mínima entre avisos;
- categorías seleccionadas;
- cooldown;
- no repetir POI avisado.

## Seguridad
La app no debe animar al usuario a manipular el teléfono mientras conduce.
El audio, la ubicación y cualquier proveedor externo requieren permisos claros,
minimización y retención explícita; no se almacena historial GPS permanente por defecto.
