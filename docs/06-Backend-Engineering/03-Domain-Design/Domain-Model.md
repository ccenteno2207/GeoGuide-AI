# Diseño de Dominio

## Aggregate principal: PointOfInterest

### Baseline P3

Atributos conceptuales:
- `PoiId`;
- `name`, obligatorio;
- `description`, factual y opcional;
- `Category`, obligatoria;
- `GeoPoint`;
- estado activo/inactivo;
- `createdAt` y `updatedAt`, que representan instantes.

Todo POI publicable requiere al menos una provenance. El aggregate no impone una
cardinalidad máxima ni exige múltiples fuentes. La forma Java del estado, el constructor
exacto y la firma del puerto de persistencia se definen durante la implementación.

### Evoluciones posteriores al baseline P3

No forman parte del baseline P3 los atributos o capacidades de multimedia, horarios,
precios, rating, reviews, favoritos, eventos, municipio, región, enriquecimiento, API,
búsqueda o discovery. Conceptos como `historicalDescription`, `openingHours`,
`priceInformation` y `contactInformation` podrán incorporarse en fases posteriores sin
convertirse ahora en invariantes del aggregate.

## Value Objects

### GeoPoint
- latitude
- longitude

Debe validar rangos geográficos.

### Money
Si se incorporan precios estructurados:
- amount
- currency

### SourceReference

Representa conceptualmente información de una provenance y no una fuente única
obligatoria. Puede incluir fuente, referencia verificable, fecha de recuperación,
licencia o condición de uso, atribución y origen de incorporación según corresponda.
La provenance persistida se modela separadamente y debe soportar identidad estable e ID
externo cuando la fuente lo proporcione. P3 no exige un grafo completo de lineage.

### RouteGeometry
Representación interna independiente del proveedor.

### Corridor
- radiusMeters

### Detour
- estimatedDistanceMeters
- estimatedDurationSeconds si está disponible

## Regla
Los DTO REST nunca son entidades de dominio.

El dominio P3 no depende de API HTTP, controllers, DTO HTTP, ORM ni una tecnología
concreta de persistencia.
