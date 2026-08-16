# P1 — Routing spike

## Objetivo

Elegir una implementación inicial de `RoutingProvider` mediante evidencia obtenida con
rutas reales del corredor piloto. La arquitectura mantiene GraphHopper, Valhalla y OSRM
como alternativas sustituibles.

## Decisión provisional

GraphHopper sigue siendo la opción recomendada por ADR-002 y ADR-011, pero la selección
operativa no se considera cerrada hasta ejecutar este spike. No se añade todavía un
contenedor de routing al Compose base para evitar descargar o procesar un extracto OSM
sin haber definido el corredor piloto.

## Prueba mínima

Para cada candidato se usará el mismo extracto `.osm.pbf` y, como mínimo, cinco pares
origen/destino representativos. Se registrará:

| Criterio | Medición |
| --- | --- |
| Calidad | inspección de geometría y maniobras sobre rutas conocidas |
| Perfiles | automóvil obligatorio; caminar y bicicleta deseables |
| Importación | duración, RAM máxima y espacio producido |
| Consulta | latencia p50/p95 en una muestra repetible |
| Operación | complejidad de imagen, configuración, health check y actualización OSM |
| Contrato | geometría, distancia, duración, instrucciones y errores normalizables |
| Licencia | licencia del motor, imagen y datos documentada |

## Criterio de salida

El spike finaliza con:

1. corredor y extracto OSM identificados;
2. resultados comparables guardados sin versionar datos pesados;
3. recomendación razonada del motor inicial;
4. ADR-011 confirmado o un nuevo ADR si cambia la decisión;
5. servicio interno incorporado a Compose con health check.

Los archivos `.pbf`, grafos y resultados voluminosos permanecen fuera de Git.
