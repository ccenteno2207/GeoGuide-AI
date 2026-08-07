# Route Discovery en Mobile

## Flujo
1. usuario calcula ruta;
2. mobile solicita `/routes/discover`;
3. recibe POIs clasificados;
4. los dibuja sobre el mapa;
5. muestra próximos lugares;
6. usuario filtra categorías;
7. filtros pueden volver a consultar backend o filtrar localmente según contrato.

## Datos mostrados
- nombre;
- categoría;
- distancia a ruta;
- desvío estimado;
- progreso;
- resumen;
- imagen si existe.

## Regla
El ranking principal pertenece al backend.
El móvil no debe duplicar la lógica central del Route Discovery Engine.
