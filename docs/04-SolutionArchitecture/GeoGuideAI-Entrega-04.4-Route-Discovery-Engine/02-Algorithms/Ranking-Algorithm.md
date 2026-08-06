# Ranking de POIs

## Objetivo
Ordenar candidatos de manera comprensible y ajustable.

## Score inicial
El MVP utilizará una puntuación ponderada y explicable:

`score = relevance + proximity + quality + preference - detourPenalty`

### Factores
- Relevancia de categoría.
- Distancia perpendicular a la ruta.
- Desvío estimado.
- Calidad/completitud del POI.
- Preferencias del usuario.
- Estado operativo cuando exista información confiable.

## Reglas
- Un POI con datos insuficientes puede aparecer, pero con menor calidad.
- Nunca ocultar sistemáticamente un POI solo por no tener rating.
- Mantener `reasonCodes` para explicar por qué fue recomendado.
- Versionar el algoritmo.
