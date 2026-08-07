# ADR-011 – Abstracción del motor de rutas

**Estado:** Aceptado

## Decisión
Definir una interfaz `RoutingProvider`.

## Implementación inicial recomendada
GraphHopper puede utilizarse en el piloto autohospedado, manteniendo la posibilidad
de sustituirlo por Valhalla u OSRM.

## Criterios de cambio
- cobertura;
- rendimiento;
- consumo de memoria;
- facilidad operacional;
- perfiles de vehículo;
- calidad de rutas en el territorio objetivo.
