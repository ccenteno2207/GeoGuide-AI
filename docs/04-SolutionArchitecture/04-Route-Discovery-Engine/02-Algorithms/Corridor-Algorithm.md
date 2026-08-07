# Algoritmo de Corredor

## Objetivo
Encontrar POIs cercanos a una ruta sin consultar toda la base geográfica.

## Estrategia MVP
La ruta se guarda temporalmente como `geometry(LineString,4326)`.
Para operaciones en metros se transforma a una proyección adecuada o se usa geography.

### Consulta conceptual
1. Convertir LineString a geography.
2. Seleccionar POIs donde `ST_DWithin(poi.location::geography, route::geography, radio)`.
3. Calcular distancia mínima a la línea.
4. Calcular posición relativa sobre la ruta.

## Radios sugeridos
El radio será configurable, no fijo. El MVP puede iniciar con:
- 1 km: descubrimiento muy cercano.
- 5 km: turismo de carretera.
- 10 km: exploración ampliada.

Los valores son parámetros funcionales, no constantes de código.
