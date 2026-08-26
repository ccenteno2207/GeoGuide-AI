# ADR-028 – GraphHopper como motor inicial de routing

**Estado:** Aceptado  
**Fecha:** 2026-08-25  
**Ámbito:** P1 – Local Infrastructure / Route Discovery  
**Decisión relacionada:** ADR-011 – Abstracción del motor de rutas

## Contexto

GeoGuide AI necesita una implementación inicial autohospedada de `RoutingProvider`
para el piloto. ADR-011 aprobó desacoplar el dominio del motor concreto y señaló
GraphHopper como candidato, manteniendo la posibilidad de sustituirlo por OSRM o
Valhalla.

Durante P1 se compararon GraphHopper 11.0 con CH, OSRM 26.8.0 con MLD y Valhalla
3.8.2 sobre el mismo recorte OSM del corredor piloto, la misma VM y seis casos de
ruta congelados. Los tres motores resolvieron 6/6 casos.

La comparación cubrió preparación, latencia, memoria, disco, complejidad operativa,
distancia, ETA y geometría. Después se recuperaron las 18 geometrías y se revisaron
sobre cartografía OpenStreetMap.

## Decisión

Adoptar **GraphHopper 11.0 como implementación inicial de `RoutingProvider`** para
el piloto autohospedado de GeoGuide AI.

La integración debe cumplir estas condiciones:

- el dominio y los casos de uso dependen únicamente de `RoutingProvider`;
- GraphHopper se consume mediante un adaptador de infraestructura;
- las respuestas y errores del motor se normalizan al contrato de GeoGuide AI;
- el servicio se incorpora a la red interna de Docker Compose, sin publicar su
  puerto en el host;
- el Compose incluye un health check explícito;
- el perfil inicial es automóvil;
- la actualización del PBF y la reconstrucción del grafo se documentan como un
  procedimiento reproducible;
- el PBF y los artefactos pesados del grafo no se incorporan al repositorio Git.

La decisión selecciona la primera implementación; no elimina la capacidad de cambiar
de motor prevista por ADR-011.

## Evidencia

| Criterio | GraphHopper 11 / CH | OSRM 26.8 / MLD | Valhalla 3.8.2 |
| --- | ---: | ---: | ---: |
| Casos funcionales | 6/6 | 6/6 | 6/6 |
| p50 medio | ~3.49 ms | **~0.92 ms** | ~23.85 ms |
| p95 medio | ~4.98 ms | **~1.36 ms** | ~26.92 ms |
| RAM pico | ~1.50 GiB | ~0.94 GiB | ~0.99 GiB |
| RAM idle | ~304 MiB | ~209 MiB | ~104 MiB |
| Artefactos principales | **~42 MB** | ~326 MB | ~104 MB tiles; ~239 MB workspace |
| Preparación principal | 12.36 s | 17.27 s | 14.74 s + 0.21 s extract |

Las cifras describen el entorno y dataset del spike; no constituyen una prueba de
carga concurrente ni un resultado universal. Los tres motores produjeron rutas
válidas y la inspección de las 18 geometrías no reveló discontinuidades ni desvíos
geográficos bloqueantes. Las diferencias de ETA no se usaron aisladamente para
decidir porque los motores aplican perfiles de velocidad distintos.

La evidencia técnica reproducible se documenta en
[P1 — Routing spike](../../../../infrastructure/routing/ROUTING-SPIKE.md).

## Motivos

GraphHopper no obtuvo la menor latencia ni el menor consumo de RAM, pero sus tiempos
de consulta son suficientes para el piloto. Presenta la menor huella de artefactos,
operación directa sobre Java 21, rutas coherentes en los seis casos y alineación con
el stack Java previsto para el backend.

El balance entre integración, operación, disco, rendimiento y flexibilidad futura es
más favorable para la primera implementación que maximizar exclusivamente una sola
métrica.

## Alternativas

### OSRM 26.8.0 MLD

Se conserva como alternativa preferida de rendimiento. Obtuvo la mejor latencia y
menor RAM pico que GraphHopper, pero requiere un pipeline de preparación de tres
etapas y produjo una huella de disco considerablemente mayor.

Debe reconsiderarse si el alcance permanece principalmente automovilístico, la
latencia pasa a ser el factor dominante o las pruebas de carga muestran que
GraphHopper no cumple los objetivos operativos.

### Valhalla 3.8.2

Se conserva para una eventual reevaluación multimodal o temporal. En el spike tuvo
menor RAM idle, pero mayor latencia y complejidad operativa. El benchmark solo cubrió
routing estático sin `date_time`, porque las bases auxiliares de administración y
zonas horarias no se validaron con el recorte congelado.

### Postergar la selección

Rechazada. El benchmark y la revisión cartográfica proporcionan evidencia suficiente
para seleccionar una implementación inicial reversible mediante `RoutingProvider`.

## Consecuencias

### Positivas

- habilita el adaptador real de `RoutingProvider`;
- mantiene el dominio independiente del proveedor;
- reduce la huella inicial de artefactos frente a OSRM;
- aprovecha afinidad operativa con Java 21;
- conserva OSRM y Valhalla como alternativas verificadas.

### Negativas y riesgos

- GraphHopper consumió más RAM que las alternativas durante el spike;
- no fue el motor de menor latencia;
- la precisión real de ETA aún requiere contraste de campo;
- la construcción y actualización de grafos introduce una tarea operativa;
- el adaptador no debe filtrar tipos propios de GraphHopper hacia el dominio.

## Validación

### Completada

- benchmark reproducible sobre la VM P1;
- seis casos funcionales por motor;
- medición de latencia, memoria, preparación y disco;
- incorporación de GraphHopper al Compose interno sin publicar puertos;
- health check interno y arranque operativo con grafo persistente;
- recuperación y normalización de 18 geometrías;
- inspección cartográfica comparativa de los seis casos;
- detención de los motores temporales y liberación de sus puertos.

### Pendiente de implementación

- prueba contractual del adaptador contra `RoutingProvider`;
- normalización de errores, timeouts y ausencia de ruta;
- primera ruta operativa desde la red interna y verificación de dependencia desde el backend;
- validación de persistencia o reconstrucción controlada del grafo;
- procedimiento documentado de actualización del PBF;
- prueba posterior a reinicio de la VM;
- contraste de ETA con evidencia de campo cuando esté disponible.

## Criterios de reconsideración

Revisar esta decisión ante incumplimiento de objetivos de latencia o concurrencia,
consumo de memoria incompatible, calidad insuficiente de rutas o ETA, prioridad de
multimodalidad o routing temporal, reconstrucción del grafo inaceptable o una
incompatibilidad de licencia o despliegue.

## Impacto sobre P1

Este ADR cierra la **selección técnica del motor inicial**, pero no cierra P1. La
integración interna en Compose y el health check ya fueron verificados. El cierre
técnico todavía requiere la primera ruta operativa, la prueba contractual, la
reutilización del grafo tras reinicio y el procedimiento reproducible de actualización
del PBF.
