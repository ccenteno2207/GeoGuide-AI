# Framework de Calidad

Dimensiones:
- completeness;
- validity;
- accuracy;
- consistency;
- uniqueness;
- freshness;
- provenance.

## Quality Score
Debe ser explicable y basado en reglas.

Ejemplo conceptual:
- coordenadas válidas;
- nombre;
- categoría;
- fuente;
- descripción;
- freshness;
- verificación.

No usar un único score para ocultar qué dimensión falló.

## Reglas binarias P3/R3

| Dimensión | Regla binaria | Evidencia esperada | Revisión | Decisión pendiente |
|---|---|---|---|---|
| Completitud | Cada POI tiene identidad, nombre, categoría, ubicación, estado y al menos una provenance. | Cero registros incumplidores. | Automatizada y de datos | Ninguna para estos campos. |
| Validez geográfica | Cada ubicación es Point no nulo con SRID 4326 y coordenadas válidas. | Cero geometrías incumplidoras. | PostgreSQL/PostGIS real | Ninguna. |
| Consistencia | No existen referencias huérfanas y los códigos de categoría son únicos. | Cero huérfanos y cero códigos duplicados. | Automatizada | Ninguna. |
| Unicidad | No quedan duplicados abiertos según identidad externa o la regla aprobada para registros sin ID externo. | Reporte de duplicados sin casos abiertos. | Automatizada y humana | Identidad estable y manejo de casos dudosos durante P3. |
| Provenance | Cada POI puede vincularse con fuente y evidencia auditable. | Cobertura de provenance completa. | Automatizada y documental | Clave lógica exacta durante P3. |
| Licencia | Cada fuente registra licencia o condición de uso y atribución cuando aplica. | Cero fuentes con condición indeterminada. | Revisión humana | Fuentes definitivas antes del seed. |
| Reproducibilidad | Taxonomía y dataset pueden cargarse desde artefactos versionados. | Ejecución sin edición manual improvisada. | Automatizada | Mecanismo técnico durante P3. |
| Idempotencia | Una segunda carga sin cambios conserva IDs, relaciones, conteos y estado lógico. | Comparación sin diferencias indebidas ni duplicados. | Automatizada | Política de cambios durante P3. |
| Corredor | Todos los POIs pertenecen justificadamente a Lima → Obrajillo y existe distribución durante el trayecto, no solo en Obrajillo. | Reporte espacial y aprobación humana sin casos abiertos. | Espacial y humana | Reglas binarias de pertenencia y distribución antes de R3. |
| Calidad factual | Ningún dato factual obligatorio carece de evidencia verificable. | Matriz POI→fuente sin hechos abiertos. | Revisión humana | Interpretación de calidad suficiente antes de R3. |

Todas las reglas aplicables deben cumplir para R3. No se utiliza un score agregado,
cantidad de POIs, distancia, diversidad porcentual ni porcentaje de revisión como
condición del gate mientras esos umbrales no hayan sido aprobados. Los scores pueden
servir en evoluciones futuras, pero no sustituyen las reglas binarias.
