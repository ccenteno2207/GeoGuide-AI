# Features del MVP

## map
Mapa principal, cámara, marcadores y polylines.

## location
Permisos y ubicación del dispositivo.

## route_planning
Origen, destino y cálculo de ruta.

## discovery
POIs encontrados a lo largo del trayecto.

## places
Preview y detalle del POI.

## favorites
Persistencia y sincronización futura de favoritos.

## driving
Modo de interacción reducida.

## interaction
Orquestación independiente del canal para intención, contexto autorizado y respuestas
adaptadas. Los adaptadores STT/TTS no duplican lógica de `discovery`, `places`,
`route_planning` ni `driving`.

## settings
Preferencias de categorías y configuración.

## auth
Autenticación cuando sea necesaria.

## offline
Caché local y estado de conectividad.
