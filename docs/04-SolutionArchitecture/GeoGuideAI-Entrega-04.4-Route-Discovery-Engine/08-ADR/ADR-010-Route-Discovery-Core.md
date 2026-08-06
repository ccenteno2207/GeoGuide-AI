# ADR-010 – Route Discovery como dominio independiente

**Estado:** Aceptado

## Decisión
Implementar el descubrimiento de POIs como un módulo de dominio independiente del
proveedor de mapas y del proveedor de routing.

## Razón
Es la capacidad diferenciadora de GeoGuide AI y debe poder evolucionar sin acoplarse
a un único proveedor.

## Consecuencia
Se definen puertos/adaptadores para routing, repositorios y ranking.
