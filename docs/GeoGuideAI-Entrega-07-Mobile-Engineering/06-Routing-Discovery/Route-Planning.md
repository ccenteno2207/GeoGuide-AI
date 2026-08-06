# Planificación de Ruta

## Flujo
Origen/destino → backend `/routes/plan` → Route DTO → Domain Route → polyline.

## Origen
Opciones:
- ubicación actual;
- punto elegido manualmente;
- búsqueda de lugar en una fase posterior.

## Destino
- punto elegido;
- POI;
- búsqueda futura.

## Cliente
La app no calcula rutas complejas localmente en el MVP.
El backend y RoutingProvider son la fuente de verdad.
