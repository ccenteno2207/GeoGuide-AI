# Estrategia de Índices

## Índices mínimos
- GiST sobre `point_of_interest.location`.
- B-tree sobre `category_id`.
- B-tree sobre `status`.
- Índice parcial para POIs activos si el volumen lo justifica.

## Principios
- Medir con EXPLAIN ANALYZE.
- No agregar índices por intuición.
- Evitar transformar la columna indexada de manera innecesaria en filtros.
- Mantener estadísticas de PostgreSQL actualizadas.
