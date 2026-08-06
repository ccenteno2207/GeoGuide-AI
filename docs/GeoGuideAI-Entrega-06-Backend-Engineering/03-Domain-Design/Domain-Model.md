# Diseño de Dominio

## Aggregate principal: PointOfInterest

Atributos conceptuales:
- PoiId
- name
- category
- GeoPoint
- description
- historicalDescription
- openingHours
- priceInformation
- contactInformation
- sourceInformation
- status
- createdAt
- updatedAt

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
- sourceName
- sourceUrl opcional
- retrievedAt
- license opcional

### RouteGeometry
Representación interna independiente del proveedor.

### Corridor
- radiusMeters

### Detour
- estimatedDistanceMeters
- estimatedDurationSeconds si está disponible

## Regla
Los DTO REST nunca son entidades de dominio.
