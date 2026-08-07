# Estrategia de Pruebas Mobile

## Unit tests
- use cases;
- repositories;
- mappers;
- ranking visual/local si existe;
- permission logic.

## Widget tests
- RouteInput;
- POI cards;
- estados loading/error;
- permission screens.

## Integration tests
- abrir app;
- conceder ubicación simulada;
- calcular ruta con backend mock;
- mostrar POIs;
- abrir detalle.

## Golden tests
Opcionales para componentes críticos del Design System.

## No depender
Las pruebas unitarias no deben requerir GPS real ni Internet.
