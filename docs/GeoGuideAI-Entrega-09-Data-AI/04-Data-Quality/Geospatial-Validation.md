# Validación Geoespacial

Controles:
- latitude [-90,90];
- longitude [-180,180];
- geometry válida;
- SRID;
- coordenadas no nulas;
- detección de puntos sospechosos;
- distancia razonable respecto a localidad/región declarada;
- duplicados por proximidad + similitud de nombre.

## Duplicados
La proximidad sola no basta. Dos POIs diferentes pueden estar juntos.
Combinar ubicación, nombre, categoría y fuente.
