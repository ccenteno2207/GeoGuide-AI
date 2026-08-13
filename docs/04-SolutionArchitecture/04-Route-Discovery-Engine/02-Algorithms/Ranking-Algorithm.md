# Ranking de POIs

## Objetivo
Ordenar candidatos de manera comprensible y ajustable.

## Score inicial
El núcleo MVP utiliza una puntuación ponderada y explicable:

`score = relevance + proximity + quality`

Evolución posterior, cuando las señales estén disponibles:

`score = relevance + proximity + quality + preference - detourPenalty`

### Factores
- Relevancia de categoría.
- Distancia perpendicular a la ruta.
- Desvío y tiempo adicional estimados (señales posteriores y opcionales).
- Calidad/completitud del POI.
- Preferencias del usuario.
- Estado operativo cuando exista información confiable.

## Reglas
- Un POI con datos insuficientes puede aparecer, pero con menor calidad.
- Nunca ocultar sistemáticamente un POI solo por no tener rating.
- Mantener `reasonCodes` para explicar por qué fue recomendado.
- Versionar el algoritmo.
- La ausencia de estimaciones de desvío no invalida ni bloquea el ranking del MVP.
