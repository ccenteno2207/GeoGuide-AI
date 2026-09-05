# Estrategia Flyway

## Convención
`V<numero>__<descripcion>.sql`

## Estado heredado

- baseline version `0`;
- descripción `P1 pre-Flyway PostGIS state`;
- `V001__enable_postgis.sql` aplicada e inmutable;
- checksum heredado de V001: `-1627021776`;
- `baseline-on-migrate` ausente o deshabilitado permanentemente.

## Continuidad P3

Las migraciones estructurales de P3 son posteriores a V001, incrementales y de
granularidad lógica pequeña. La cantidad, numeración y nombres definitivos se deciden
durante la implementación; no existe una secuencia V002/V003/V004 aprobada de antemano.

El DDL estructural se administra mediante Flyway. La taxonomía y el dataset permanecen
separados del DDL y utilizan mecanismos versionados, reproducibles e idempotentes, que
no tienen que ser migraciones Flyway. La elección concreta de esos mecanismos pertenece
a la implementación.

## Reglas
- Nunca modificar una migración ya aplicada en ambientes compartidos.
- Crear una migración nueva.
- Migraciones versionadas en Git.
- Mantener separados DDL, taxonomía y dataset.
- Backups antes de cambios destructivos.
- No habilitar permanentemente `baseline-on-migrate`.
- No reconstruir innecesariamente la base persistente heredada.

## Validación

Se requieren dos rutas distintas y no equivalentes:

1. base limpia con PostgreSQL/PostGIS real mediante Testcontainers, migraciones desde
   cero y `flyway validate`;
2. baseline heredado en la VM, con baseline `0`, V001, base persistente y preservación
   de los datos y objetos P1/P2.

Ambas rutas deben comprobar el historial Flyway y el schema final. La validación sobre
la VM no reemplaza la reproducibilidad desde una base limpia, ni Testcontainers reemplaza
la compatibilidad con el baseline heredado.
