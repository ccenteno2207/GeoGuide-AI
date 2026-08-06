# Progreso sobre la Ruta

Cada POI debe ubicarse en una posición aproximada del recorrido.

PostGIS permite proyectar un punto sobre un LineString mediante `ST_LineLocatePoint`.
El valor resultante está normalizado entre 0 y 1.

Usos:
- ordenar POIs desde origen a destino;
- indicar qué aparece primero;
- construir la línea de tiempo del viaje;
- activar avisos por proximidad;
- evitar recomendar puntos ya superados.
