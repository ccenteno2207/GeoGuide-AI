# ADR-011 – Abstracción del motor de rutas

**Estado:** Aceptado

**Refinada por:** [ADR-028 – GraphHopper como motor inicial de routing](../../../02-Architecture/ADR/04-Route-Discovery/ADR-028-GraphHopper-Initial-Routing-Engine.md)

## Decisión
Definir una interfaz `RoutingProvider`.

## Implementación inicial
GraphHopper 11.0 se adopta para el piloto autohospedado según ADR-028, manteniendo
la posibilidad de sustituirlo por Valhalla u OSRM.

## Criterios de cambio
- cobertura;
- rendimiento;
- consumo de memoria;
- facilidad operacional;
- perfiles de vehículo;
- calidad de rutas en el territorio objetivo.
