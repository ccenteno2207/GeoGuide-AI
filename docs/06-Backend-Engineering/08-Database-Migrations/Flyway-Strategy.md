# Estrategia Flyway

## Convención
`V<numero>__<descripcion>.sql`

Ejemplos:
- V001__enable_postgis.sql
- V002__create_categories.sql
- V003__create_point_of_interest.sql
- V004__create_spatial_indexes.sql

## Reglas
- Nunca modificar una migración ya aplicada en ambientes compartidos.
- Crear una migración nueva.
- Migraciones versionadas en Git.
- Datos demo separados de datos estructurales.
- Backups antes de cambios destructivos.
