# Estrategia de Pruebas

## Pirámide

### Unitarias
Dominio y Application. Para P3 cubren construcción válida de `PointOfInterest`, nombre
y categoría obligatorios, límites de latitud y longitud, estado activo/inactivo,
timestamps como instantes, provenance obligatoria para publicación e invariantes sin
dependencia HTTP. Deben ser rápidas y sin Spring cuando sea posible.

### Slice tests
- @WebMvcTest
- @DataJpaTest cuando tenga sentido.

### Integración
P3 utiliza Testcontainers con PostgreSQL/PostGIS real para comprobar desde una base
limpia:

- migraciones y `flyway validate`;
- schema, tablas, UUID, PK, FK y unicidad;
- Point/SRID 4326, ubicación obligatoria, GiST, `active BOOLEAN` y `TIMESTAMPTZ`;
- round-trip del repositorio e identidad externa;
- taxonomía, provenance, carga, duplicados e idempotencia.

H2 no sustituye PostgreSQL/PostGIS para estas pruebas.

### Datos

Validar taxonomía, provenance, fuentes/licencias, calidad geográfica, duplicados,
reproducibilidad e idempotencia mediante pruebas automatizadas y revisión documental.

### Operación

La validación separada en la VM parte del baseline `0` y V001, aplica las migraciones y
cargas P3 y comprueba `flyway validate`, health y preservación de P1/P2, la base, los
volúmenes, la red interna y la ausencia de bindings sensibles. Testcontainers no
reemplaza esta ruta y la VM no reemplaza la prueba limpia.

### API
Verificar contratos OpenAPI y status codes.

Estas pruebas, incluidas las de `nearby`, pertenecen a fases posteriores y no son
necesarias para cerrar P3.

### End-to-End
Solo flujos críticos del MVP.

## Cobertura
No establecer un porcentaje como objetivo aislado.
Priorizar reglas de negocio, seguridad y Route Discovery.

Durante P3 se priorizan las invariantes POI, persistencia y calidad de datos. Route
Discovery conserva su prioridad de producto, pero no pertenece al alcance P3. P3.0 es
documental y no ejecuta estas pruebas.
