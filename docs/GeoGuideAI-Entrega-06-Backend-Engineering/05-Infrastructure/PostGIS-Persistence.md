# Persistencia PostgreSQL/PostGIS

## Librerías
- Spring Data JPA.
- Hibernate Spatial.
- PostgreSQL JDBC.

## Datos espaciales
POI:
`geometry(Point,4326)`

Route temporal/persistida:
`geometry(LineString,4326)` cuando corresponda.

## Consultas espaciales
Las consultas complejas pueden implementarse mediante:
- repository custom;
- native SQL controlado;
- JdbcTemplate cuando resulte más claro que JPA.

## Principio
No forzar JPQL para operaciones GIS que PostGIS expresa mejor de forma nativa.

## Índices
GiST sobre columnas espaciales.

## Seguridad SQL
Todas las consultas parametrizadas.
