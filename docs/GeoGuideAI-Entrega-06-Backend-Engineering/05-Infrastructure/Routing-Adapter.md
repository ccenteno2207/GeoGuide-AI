# Adaptador del Motor de Rutas

## Puerto
`RoutingProvider`

## Responsabilidades del adaptador
- construir request del proveedor;
- manejar timeout;
- interpretar status codes;
- transformar geometría;
- normalizar distancia/duración;
- traducir errores técnicos a errores de aplicación.

## Prohibido
El dominio no debe recibir clases específicas del SDK/JSON del proveedor.

## Configuración
Propiedades mediante variables de entorno:
- ROUTING_BASE_URL
- ROUTING_TIMEOUT
- ROUTING_PROFILE
