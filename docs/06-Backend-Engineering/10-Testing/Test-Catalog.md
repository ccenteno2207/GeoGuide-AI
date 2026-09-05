# Catálogo Inicial de Pruebas

## P3 – POI Data & Domain

| ID | Propósito | Tipo | Entorno | Resultado esperado | Fase |
|---|---|---|---|---|---|
| POI-DOM-01 | Construir un POI válido | Unitaria | Maven | Aggregate creado con valores esperados | P3 |
| POI-DOM-02 | Rechazar nombre ausente, vacío o en blanco | Unitaria | Maven | Todos los casos son rechazados | P3 |
| POI-DOM-03 | Validar latitud `[-90,90]` | Unitaria | Maven | Límites aceptados y valores externos rechazados | P3 |
| POI-DOM-04 | Validar longitud `[-180,180]` | Unitaria | Maven | Límites aceptados y valores externos rechazados | P3 |
| POI-DOM-05 | Exigir categoría | Unitaria | Maven | Ausencia de categoría rechazada | P3 |
| POI-DOM-06 | Representar activo e inactivo | Unitaria | Maven | Ambos estados son representables | P3 |
| POI-DOM-07 | Exigir provenance para publicación | Unitaria | Maven | Publicación sin provenance rechazada | P3 |
| POI-DOM-08 | Preservar timestamps como instantes | Unitaria | Maven | Instantes conservados sin ambigüedad | P3 |
| POI-DOM-09 | Mantener el dominio sin dependencia HTTP | Arquitectura | Maven | Sin imports ni dependencias web | P3 |
| POI-DB-01 | Construir schema y estructuras P3 | Integración | Testcontainers | `geo`, Category, PointOfInterest y Provenance presentes | P3 |
| POI-DB-02 | Validar UUID, PK, FK y código único | Integración | Testcontainers | Constraints presentes y casos inválidos rechazados | P3 |
| POI-DB-03 | Validar `geometry(Point,4326) NOT NULL` | Integración | Testcontainers | Tipo, SRID y nulabilidad coinciden | P3 |
| POI-DB-04 | Rechazar o transformar explícitamente SRID incorrecto | Integración | Testcontainers | No se almacena silenciosamente como válido | P3 |
| POI-DB-05 | Verificar GiST, `active BOOLEAN` y `TIMESTAMPTZ` | Integración | Testcontainers | Catálogo coincide con el modelo aprobado | P3 |
| POI-DB-06 | Round-trip del puerto/adaptador | Integración | Testcontainers | POI recuperado conserva su estado lógico | P3 |
| POI-FLY-01 | Migrar desde base limpia | Integración | Testcontainers | Migraciones completas sin preparación manual | P3 |
| POI-FLY-02 | Ejecutar `flyway validate` | Integración | Testcontainers/VM | Validación exitosa en ambas rutas | P3 |
| POI-FLY-03 | Preservar V001 | Git/Integración | Git/VM | Sin diff y checksum `-1627021776` | P3 |
| POI-FLY-04 | Migrar baseline heredado | Operativa | VM | Baseline 0, V001 y migraciones P3 exitosas | P3 |
| POI-DATA-01 | Cargar taxonomía aprobada | Integración | Testcontainers | Códigos únicos e identidades estables | P3 |
| POI-DATA-02 | Exigir provenance por POI | Integración | Testcontainers/VM | Anti-join sin resultados | P3/R3 |
| POI-DATA-03 | Preservar identidad externa o manual | Integración | Testcontainers | Identidad reproducible en ambos casos | P3/R3 |
| POI-DATA-04 | Validar corredor, fuentes y licencias | Datos | Revisión/VM | Sin casos abiertos conforme a reglas aprobadas | P3/R3 |
| POI-IDEM-01 | Repetir carga sin cambios | Integración | Testcontainers/VM | IDs, relaciones y conteos estables | P3/R3 |
| POI-IDEM-02 | Evitar duplicados en segunda carga | Integración | Testcontainers/VM | Cero categorías, POIs o provenance duplicados | P3/R3 |
| POI-IDEM-03 | Procesar una fuente modificada | Integración | Testcontainers | Resultado determinista y auditable | P3 |
| POI-OPS-01 | Preservar P1/P2 y health | Operativa | VM | `p1_persistence_test`, datos y servicios intactos | P3 |
| POI-OPS-02 | Preservar aislamiento | Operativa | VM | Red interna y sin bindings sensibles | P3 |

H2 no sustituye PostgreSQL/PostGIS real en los casos de integración espacial.
`p1_persistence_test` se comprueba exclusivamente como protección operativa heredada;
no es una prueba funcional de P3.

## P4 – Routing

| ID | Propósito | Tipo | Entorno | Estado |
|---|---|---|---|---|
| RTE-APP-01 | Validar aplicación y contrato de `RoutingProvider` | Unitaria | Maven | Implementada |
| RTE-GH-01 | Normalizar respuesta GraphHopper | Adaptador HTTP controlado | Maven | Implementada |
| RTE-GH-02 | Normalizar timeout, indisponibilidad, ausencia de ruta y respuesta inválida | Adaptador HTTP controlado | Maven | Implementada |
| RTE-HTTP-01 | Validar `POST /api/v1/routes/plan` y GeoJSON `LineString` | Contrato HTTP | Maven | Implementada |
| RTE-HTTP-02 | Validar solicitud inválida y Problem Details | Contrato HTTP | Maven | Implementada |
| RTE-OPS-01 | Smoke backend → GraphHopper real | Operativa | VM | PASS post-merge |

El cierre P4 registró `mvn verify`: 39 pruebas, 0 fallos, 0 errores y 4 omitidas. Las
pruebas omitidas no se presentan como ejecutadas; la integración real requerida se
validó separadamente en VM.

## Casos de fases posteriores

### Places API
- consultar POI mediante API;
- `nearby` devuelve POIs dentro del radio;
- POI inactivo no aparece en resultados públicos.

### Discovery
- sin candidatos;
- candidatos en el borde;
- orden por progreso;
- filtros;
- ranking determinista;
- ruta larga.

### Security
- 401;
- 403;
- roles;
- JWT.

Estos casos permanecen en el catálogo para fases posteriores; Places, `nearby`, Route
Discovery, ranking y seguridad HTTP no están implementados por el cierre P4.
