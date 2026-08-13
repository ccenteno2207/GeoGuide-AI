# Validación

## API
Bean Validation:
- @NotNull
- @NotBlank
- @Size
- @Min/@Max
- validaciones personalizadas cuando corresponda.

## Coordenadas
Latitude: -90 a 90.
Longitude: -180 a 180.

## Parámetros espaciales
Definir límites máximos para:
- radiusMeters;
- corridorMeters;
- page size.

Cuando se implemente la evolución de cálculo de desvío:
- `maxDetourMeters` será opcional y tendrá límites configurados;
- su ausencia no impedirá descubrimiento por corredor ni ranking básico;
- distancia de desvío y tiempo adicional se identificarán como estimaciones.

Los límites exactos serán configuración/documentación, no valores duplicados.
