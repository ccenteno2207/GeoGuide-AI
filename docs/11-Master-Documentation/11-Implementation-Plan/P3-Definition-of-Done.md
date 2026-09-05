# P3 — Definition of Done y Release Gate R3

## 1. Propósito, autoridad y estado

Este documento es la fuente normativa canónica e integral para determinar el cierre de
P3 — POI Data & Domain y la satisfacción de R3 — Data: POIs piloto validados. Los
documentos especializados desarrollan cada área; ante discrepancias sobre criterios de
cierre P3/R3 prevalece este contrato dentro de su ámbito, sin sustituir ADR aceptados.

El runbook externo conserva aprobaciones, comandos y evidencia operativa, pero no es la
fuente normativa del repositorio. Este contrato está aprobado documentalmente; la
implementación P3 fue completada y validada técnicamente en
`feature/p3-poi-data-domain`; el cierre definitivo permanece condicionado a la revisión e
integración del Pull Request.

## 2. Alcance

P3 = Domain + Persistence + Data. Su objetivo es un baseline POI canónico, versionado,
geoespacial, trazable, reproducible, idempotente y probado para Lima → Obrajillo.

Quedan fuera de P3: API HTTP, controllers, DTO HTTP, OpenAPI Places, search, `nearby`,
routing, `RoutingProvider`, Route Discovery, ranking, Flutter, UX móvil, voz e IA.

## 3. Baseline aprobado

### Dominio

`PointOfInterest` es el aggregate principal. El baseline incluye `PoiId`, `GeoPoint`,
`Category`, nombre obligatorio, descripción factual opcional, estado conceptual
activo/inactivo, provenance obligatoria para un POI publicable y timestamps como
instantes. Existe un puerto de persistencia; su firma se decide durante P3.

### Persistencia

El schema es `geo`, con Category, PointOfInterest y Provenance separadas. La identidad
interna usa UUID. Las FK son `PointOfInterest.category_id → Category.id` y
`Provenance.poi_id → PointOfInterest.id`. La ubicación es
`geometry(Point,4326) NOT NULL`, con GiST y sin columnas escalares duplicadas de
latitud/longitud. El estado físico es `active BOOLEAN`, los tiempos son `TIMESTAMPTZ` y
la identidad externa es condicional a la fuente.

### Flyway y datos

El estado heredado es baseline `0`, descripción `P1 pre-Flyway PostGIS state`, V001
inmutable y checksum `-1627021776`. Las migraciones P3 continúan después de V001 y
`baseline-on-migrate` no queda habilitado permanentemente. El DDL estructural se
gestiona mediante Flyway. Taxonomía y dataset permanecen separados del DDL y utilizan
mecanismos versionados, reproducibles e idempotentes definidos durante P3.

La taxonomía se aprueba y versiona antes del seed. El dataset usa Lima → Obrajillo,
incluye POIs durante el trayecto, conserva provenance y licencias, no fija cantidades
arbitrarias y no contiene hechos inventados.

## 4. Relación entre P3 y R3

P3 reúne el cierre técnico y de datos. La DoD técnica/backend es prerrequisito técnico
de R3. R3 acepta el dataset resultante; su satisfacción completa la aceptación de datos
y forma parte del cierre total de P3. No existe dependencia circular ni milestone M04
asociado a P3.

## 5. Definition of Done integral de P3

Cada criterio aplicable termina en `CUMPLE` o `NO CUMPLE`.

| ID | Área | Criterio binario | Validación futura | Evidencia | Entorno/momento |
|---|---|---|---|---|---|
| P3-DOD-01 | Dominio | Se construye un POI con datos obligatorios válidos. | Prueba unitaria. | Aggregate con valores esperados. | Maven / implementación |
| P3-DOD-02 | Dominio | Nombre ausente, vacío o en blanco se rechaza. | Casos parametrizados. | Todos rechazados. | Maven / implementación |
| P3-DOD-03 | Dominio | Latitud admite `[-90,90]` y rechaza valores externos. | Fronteras. | Límites correctos. | Maven / implementación |
| P3-DOD-04 | Dominio | Longitud admite `[-180,180]` y rechaza valores externos. | Fronteras. | Límites correctos. | Maven / implementación |
| P3-DOD-05 | Dominio | Todo POI tiene categoría válida. | Unidad y FK. | Ausencia/inexistencia rechazada. | Maven/Testcontainers |
| P3-DOD-06 | Dominio | Activo e inactivo se representan y persisten. | Unidad y round-trip. | Ambos estados conservados. | Maven/Testcontainers |
| P3-DOD-07 | Dominio | Un POI publicable no queda sin provenance. | Regla de aplicación. | Intento inválido rechazado. | Maven / implementación |
| P3-DOD-08 | Dominio | Timestamps conservan semántica de instante. | Unidad y round-trip. | Valores equivalentes. | Maven/Testcontainers |
| P3-DOD-09 | Arquitectura | Dominio no depende de HTTP. | Dependencias y pruebas. | Sin imports web. | Maven / antes de PR |
| P3-DOD-10 | Arquitectura | Existe puerto de persistencia suficiente para P3. | Revisión de arquitectura. | Puerto y adaptador compatibles. | Revisión / implementación |
| P3-DOD-11 | Persistencia | Existe schema `geo`. | Catálogo PostgreSQL. | Schema presente. | Testcontainers/VM |
| P3-DOD-12 | Persistencia | Category, PointOfInterest y Provenance son estructuras separadas. | Catálogo y migraciones. | Tres estructuras presentes. | Testcontainers/VM |
| P3-DOD-13 | Persistencia | Category y POI usan UUID y PK válidas. | Catálogo/constraints. | Tipos y PK correctos. | Testcontainers |
| P3-DOD-14 | Persistencia | Las FK son POI→Category y Provenance→POI. | Inserts y catálogo. | `PointOfInterest.category_id → Category.id`; `Provenance.poi_id → PointOfInterest.id`. | Testcontainers |
| P3-DOD-15 | Persistencia | `category.code` es obligatorio y único. | Constraint y duplicado. | Duplicado rechazado. | Testcontainers |
| P3-DOD-16 | Persistencia | Ubicación es `geometry(Point,4326) NOT NULL`. | Catálogo e inserts. | Tipo, SRID y nulabilidad correctos. | Testcontainers/VM |
| P3-DOD-17 | Persistencia | SRID incorrecto no se almacena silenciosamente como válido. | Caso inválido. | Rechazo o transformación explícita aprobada. | Testcontainers |
| P3-DOD-18 | Persistencia | Existe GiST sobre ubicación. | Catálogo de índices. | Índice presente. | Testcontainers/VM |
| P3-DOD-19 | Persistencia | Estado físico usa `active BOOLEAN`. | Catálogo/round-trip. | Boolean y estados conservados. | Testcontainers |
| P3-DOD-20 | Persistencia | Timestamps físicos usan `TIMESTAMPTZ`. | Catálogo. | Tipos correctos. | Testcontainers/VM |
| P3-DOD-21 | Persistencia | No hay latitud/longitud escalares duplicadas. | Catálogo. | Geometría única. | Testcontainers/VM |
| P3-DOD-22 | Identidad | Se conserva identidad externa cuando existe. | Carga y consulta. | Fuente e ID recuperables. | Testcontainers |
| P3-DOD-23 | Identidad | Registro manual tiene identidad estable y origen auditable. | Carga repetida. | Mismo POI lógico, sin duplicado. | Testcontainers |
| P3-DOD-24 | Flyway | V001 no cambia y conserva checksum `-1627021776`. | Diff, validate e historial. | Controles coinciden. | Git/Testcontainers/VM |
| P3-DOD-25 | Flyway | Migraciones P3 son posteriores a V001 y ordenadas. | Nombres e historial. | Sin conflicto/versiones repetidas. | Git/Testcontainers |
| P3-DOD-26 | Flyway/datos | DDL usa Flyway; taxonomía y dataset están separados y son versionados, reproducibles e idempotentes. | Revisión de artefactos. | Mecanismos separados; forma concreta documentada. | Git / antes de PR |
| P3-DOD-27 | Flyway | `baseline-on-migrate` no queda activo. | Configuración efectiva. | Ausente o `false`. | Git/VM |
| P3-DOD-28 | Flyway | `flyway validate` finaliza correctamente. | Ejecución autorizada. | Exit code 0. | Testcontainers/VM |
| P3-DOD-29 | Flyway | Base limpia se construye con PostgreSQL/PostGIS real. | Testcontainers. | Schema final sin preparación manual. | Antes de PR |
| P3-DOD-30 | Flyway | Baseline heredado migra sin reconstrucción ni pérdida. | Validación VM. | Migraciones aplicadas y datos preservados. | VM / cierre |
| P3-DOD-31 | Taxonomía | Existe artefacto explícito, aprobado y versionado antes del seed. | Revisión documental/Git. | Aprobación y versión exacta. | Antes del seed |
| P3-DOD-32 | Taxonomía | Cada categoría tiene código único/estable, nombre y estado. | Consulta y constraint. | Cero incumplimientos. | Testcontainers |
| P3-DOD-33 | Taxonomía | Segunda carga no duplica ni cambia identidades sin cambio de entrada. | Carga doble. | IDs y conteos estables. | Testcontainers |
| P3-DOD-34 | Provenance | Cada POI publicable tiene provenance separada y consultable. | Anti-join. | Cero POIs sin provenance. | Testcontainers/VM |
| P3-DOD-35 | Provenance | Cada provenance identifica fuente y condición de uso. | Validación de datos. | Sin casos indeterminados. | Revisión/VM |
| P3-DOD-36 | Provenance | Recuperación y atribución se registran cuando aplican. | Revisión por fuente. | Valor o `no aplica` justificado. | Antes de R3 |
| P3-DOD-37 | Provenance | Segunda carga no duplica provenance. | Comparación por clave lógica. | Conteos y claves estables. | Testcontainers/VM |
| P3-DOD-38 | Dataset | Dataset versionado carga sin edición manual improvisada. | Checkout limpio/carga. | Proceso reproducible. | Testcontainers/VM |
| P3-DOD-39 | Dataset | Entrada sin cambios produce el mismo estado lógico. | Carga doble. | IDs, relaciones y valores estables. | Testcontainers/VM |
| P3-DOD-40 | Dataset | Cambio de fuente se maneja determinista y auditablemente. | Caso automatizado. | Insertado/actualizado/omitido/rechazado explicable. | Testcontainers |
| P3-DOD-41 | Pruebas | Pruebas aplicables pasan con Maven Wrapper. | `mvnw verify`. | Build exitoso. | Antes de PR/cierre |
| P3-DOD-42 | Pruebas | Integración espacial usa PostgreSQL/PostGIS real. | Dependencias/logs. | H2 no sustituye PostGIS. | Testcontainers |
| P3-DOD-43 | Operación | Backend y servicios heredados permanecen healthy. | Compose/Actuator. | Servicios esperados saludables. | VM / cierre |
| P3-DOD-44 | Operación | Se preservan objeto y datos históricos de `p1_persistence_test`. | Inventario before/after. | Sin pérdida o modificación indebida; se permiten objetos, migraciones, historial, taxonomía y dataset P3. | VM / cierre |
| P3-DOD-45 | Operación | Se preservan red interna y ausencia de bindings sensibles. | Runtime/Compose. | `internal=true`; sin 8080/5432 publicados. | VM / cierre |
| P3-DOD-46 | Documentación | Documentación oficial no tiene contradicciones bloqueantes. | Auditoría. | Alcance y contratos coherentes. | Antes de PR |
| P3-DOD-47 | Git | Diff contiene solo P3 y no incluye secretos/artefactos. | Revisión Git. | Sin excepciones. | Antes de PR |
| P3-DOD-48 | Git | Cierre final usa revisión, commits controlados y Pull Request. | Revisión del flujo. | PR aprobada/integrada y árbol limpio. | Cierre |

## 6. Definition of Done de datos

Los criterios P3-DOD-31–40 gobiernan taxonomía, provenance, dataset e idempotencia. Su
aplicación especializada está en la [DoD Data & AI](../../09-Data-AI/16-Codex-Handoff/Definition-of-Done.md).
No constituyen una segunda lista independiente.

## 7. Contrato de calidad

R3 exige completitud, validez geográfica, consistencia referencial, unicidad,
provenance, licencia, reproducibilidad, idempotencia, pertenencia/distribución del
corredor y calidad factual. El detalle reside en el
[Framework de Calidad](../../09-Data-AI/04-Data-Quality/Data-Quality-Framework.md); no se
usa un score agregado ni umbrales numéricos no aprobados.

## 8. Criterios integrales R3

| ID | Dimensión | Criterio binario | Evidencia/método |
|---|---|---|---|
| R3-01 | Integridad | Todos los POIs tienen identidad, nombre, categoría, ubicación y estado. | Cero registros incumplidores. |
| R3-02 | Integridad | Categorías referenciadas existen y sus códigos son únicos. | Cero huérfanos/duplicados. |
| R3-03 | Geografía | Ubicaciones son Point/SRID 4326 no nulas. | Consulta PostGIS sin inválidos. |
| R3-04 | Geografía | Cada POI pertenece justificadamente a Lima → Obrajillo. | Reporte por POI conforme a regla aprobada. |
| R3-05 | Geografía | Existen POIs durante el trayecto, no solo en Obrajillo. | Distribución aprobada y documentada. |
| R3-06 | Provenance | Cada POI tiene al menos una provenance auditable. | Anti-join con resultado cero. |
| R3-07 | Provenance | Fuente, recuperación aplicable, licencia/condición y atribución están resueltas. | Sin valores indeterminados. |
| R3-08 | Identidad | Se conserva ID externo o clave manual estable y auditable. | Reporte reproducible de identidad. |
| R3-09 | Calidad | Ningún hecho obligatorio carece de evidencia verificable. | Matriz POI→fuente sin abiertos. |
| R3-10 | Unicidad | No existen duplicados indebidos sin resolver. | Reporte de duplicados limpio. |
| R3-11 | Idempotencia | Recarga sin cambios conserva IDs, conteos y estado lógico. | Comparación before/after. |
| R3-12 | Idempotencia | Segunda carga no duplica Category, POI ni Provenance. | Deltas iguales a cero. |
| R3-13 | Reproducibilidad | Dataset se reconstruye desde artefactos versionados. | Ejecución controlada sin edición improvisada. |
| R3-14 | Aprobación | Taxonomía y versión exacta del dataset tienen aprobación humana. | Registro de aprobación. |
| R3-15 | Aprobación | No queda regla indispensable de producto sin definir. | Revisión documental sin pendientes bloqueantes. |

## 9. Rutas obligatorias de validación

La ruta limpia usa Testcontainers con PostgreSQL/PostGIS real, aplica las migraciones
desde cero, ejecuta `flyway validate`, carga taxonomía/dataset y repite la carga. La ruta
heredada usa la VM con baseline 0 y V001, aplica P3, repite la carga, valida health y
preserva P1/P2. Ambas son obligatorias y no intercambiables.

## 10. Contrato de idempotencia

Una entrada sin cambios conserva IDs, conteos, relaciones y estado lógico, sin
duplicados. Una entrada modificada produce comportamiento determinista y un reporte
auditable. La política concreta de insert/update/reject se define durante P3.

## 11. Evidencia mínima

- estado Git, revisión de V001 y ausencia de secretos;
- Maven Wrapper y pruebas unitarias/integración;
- Testcontainers, Flyway y catálogo PostgreSQL/PostGIS;
- taxonomía, conteos, geometrías, provenance y duplicados;
- comparación de primera y segunda carga;
- health e inventario P1/P2 before/after en VM;
- aprobación humana de taxonomía, dataset, R3 y cierre P3.

Los comandos y logs completos permanecen en el runbook externo.

## 12. Condiciones de bloqueo

Bloquean P3: pruebas o migraciones fallidas, V001 alterada, modelo distinto, falta de
provenance, carga no reproducible/idempotente, regresión P1/P2, secretos, contradicción
documental, cambios fuera de alcance o ausencia del flujo PR final.

Bloquean R3: POIs inválidos, provenance/licencias sin resolver, hechos sin evidencia,
POIs fuera del corredor sin justificación, concentración solo en destino, duplicados,
carga no reproducible/idempotente o reglas/aprobaciones indispensables pendientes.

No bloquean P3/R3: ausencia de API, `nearby`, routing, Route Discovery, Flutter, voz,
IA, porcentaje genérico de cobertura o cantidad rígida de POIs.

## 13. Decisiones pendientes

Durante P3: forma Java del estado, firma del repositorio, tecnología de persistencia,
nombres/cantidad de migraciones, mecanismo de carga, identidad manual, clave lógica de
provenance y política de actualización.

Antes del seed: códigos definitivos, fuentes, licencias, campos y reglas de identidad.
Antes de R3: reglas binarias de pertenencia, distribución, calidad factual y revisión
humana. Fuera de P3 permanecen todas las capacidades excluidas en la sección 2.

## 14. Referencias especializadas

- [Pilot Implementation Plan](Pilot-Implementation-Plan.md)
- [Release Gates](Release-Gates.md)
- [Backend Definition of Done](../../06-Backend-Engineering/15-Codex-Handoff/Definition-of-Done.md)
- [Data & AI Definition of Done](../../09-Data-AI/16-Codex-Handoff/Definition-of-Done.md)
- [Domain Model](../../06-Backend-Engineering/03-Domain-Design/Domain-Model.md)
- [PostgreSQL Physical Model](../../04-SolutionArchitecture/02-Geospatial-Data-Model/03-Physical/PostgreSQL-PhysicalModel.md)
- [Data Dictionary](../../04-SolutionArchitecture/02-Geospatial-Data-Model/06-DataDictionary/DataDictionary.md)
- [Flyway Strategy](../../06-Backend-Engineering/08-Database-Migrations/Flyway-Strategy.md)
- [Testing Strategy](../../06-Backend-Engineering/10-Testing/Testing-Strategy.md)
- [Test Catalog](../../06-Backend-Engineering/10-Testing/Test-Catalog.md)
- [Data Quality Framework](../../09-Data-AI/04-Data-Quality/Data-Quality-Framework.md)
- [Data Lineage](../../09-Data-AI/11-Data-Lineage-Licensing/Data-Lineage.md)
- [Licensing](../../09-Data-AI/11-Data-Lineage-Licensing/Licensing.md)
- [ADR-014 Flyway](../../02-Architecture/ADR/06-Backend-Engineering/ADR-014-Flyway.md)
- [ADR-015 Testcontainers](../../02-Architecture/ADR/06-Backend-Engineering/ADR-015-Testcontainers.md)

## 15. Aprobación y cierre

Cada criterio aplicable se registra como `CUMPLE` o `NO CUMPLE`. La evidencia consolidada
está en [P3 Validation Evidence](P3-Validation-Evidence.md). R3 cumple técnicamente y P3
requiere revisión Git e integración del Pull Request final para su cierre definitivo.
