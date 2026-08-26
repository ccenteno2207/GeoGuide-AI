# P1 — Routing spike

## Estado y objetivo

**Estado:** completado. GraphHopper 11.0 fue seleccionado por ADR-028, incorporado al
Compose interno y validado con ruta, error HTTP estructurado y reutilización del grafo.

El spike compara implementaciones sustituibles de `RoutingProvider` con evidencia del
corredor piloto. No cambia la abstracción aprobada ni acopla el dominio a un motor.

## Entorno y metodología

- VM: 4 vCPU, 16 GiB RAM fija, Ubuntu 26.04; CPU expuesta como QEMU Virtual CPU.
- PostgreSQL/PostGIS, Redis y MinIO permanecieron activos durante las pruebas.
- Dataset congelado: `peru-geoguide-pilot.osm.pbf`, recorte
  `-77.40,-13.50,-75.85,-11.40` con `complete_ways`, ~31 MB y referencias completas.
- El SHA-256 se conservó en la VM y se verificó antes de cada motor.
- Perfil automóvil; un solo motor activo; listener limitado a `127.0.0.1`.
- Latencia: 30 solicitudes por caso, 180 por motor, sin geometría ni instrucciones;
  p50 como mediana y p95 por *nearest rank*.
- PBF, grafos, logs, JSON y muestras fuera de Git en `/srv/geoguide/routing-spike/`.

Las cifras permiten una comparación relativa en esta VM y dataset; no son una prueba
universal ni de carga concurrente.

## Casos congelados

| Caso | Ruta | Origen | Destino |
| --- | --- | --- | --- |
| 1 | Lima Centro → Miraflores | `-12.0478931,-77.0459961` | `-12.1255265,-77.0344948` |
| 2 | Miraflores → Pachacámac | `-12.1255265,-77.0344948` | `-12.2598322,-76.9020593` |
| 3 | Pachacámac → San Vicente | `-12.2598322,-76.9020593` | `-13.07775,-76.38744` |
| 4 | San Vicente → Lunahuaná | `-13.07775,-76.38744` | `-13.0026086,-76.1623609` |
| 5 | Lima Centro → Lunahuaná | `-12.0478931,-77.0459961` | `-13.0026086,-76.1623609` |
| 6 | Lima → Obrajillo | `-12.002644,-77.094678` | `-11.6954053,-76.8352259` |

El endpoint inicial de San Vicente no era enrutable y hacía fallar los casos 3 y 4.
Se corrigió y congeló el punto de la tabla; GraphHopper lo ajustó a una vía a ~34 m.
Los tres motores recibieron después la misma coordenada y realizaron su propio *snapping*.

## Preparación y operación

| Métrica | GraphHopper 11.0 / CH | OSRM 26.8.0 / MLD | Valhalla 3.8.2 |
| --- | ---: | ---: | ---: |
| Preparación principal | 12.36 s | 17.27 s | 14.74 s + 0.21 s extract |
| Etapas | import + CH | extract 10.82 s; partition 4.19 s; customize 2.27 s | build tiles + tile extract |
| RAM pico | ~1.50 GiB | ~0.94 GiB | ~0.99 GiB |
| Artefactos | ~42 MB | ~326 MB | ~104 MB tiles; ~239 MB workspace |
| RAM idle | ~304 MiB | ~209 MiB | ~104 MiB |
| Casos funcionales | 6/6 | 6/6 | 6/6 |
| p50 medio | ~3.49 ms | **~0.92 ms** | ~23.85 ms |
| p95 medio | ~4.98 ms | **~1.36 ms** | ~26.92 ms |

El pico de OSRM correspondió a `extract` (~937.5 MiB); `partition` y `customize`
alcanzaron ~253.7 MiB y ~360.7 MiB. Valhalla produjo 62 tiles empaquetados.

## Resultados funcionales

| Caso | GraphHopper distancia / tiempo | OSRM distancia / tiempo | Valhalla distancia / tiempo |
| --- | ---: | ---: | ---: |
| 1 | 10.616 km / 11m 59s | 10.749 km / 15m 27s | 10.743 km / 12m 25s |
| 2 | 28.11 km / 28m 59s | 28.06 km / 34m 21s | 27.677 km / 29m 41s |
| 3 | 118.54 km / 1h 35m 34s | 117.92 km / 1h 48m 05s | 121.016 km / 1h 25m 43s |
| 4 | 33.02 km / 40m 16s | 33.09 km / 45m 35s | 33.231 km / 41m 03s |
| 5 | 180.42 km / 2h 34m 47s | 181.53 km / 2h 55m 14s | 188.716 km / 2h 30m 07s |
| 6 | 54.51 km / 53m 25s | 55.07 km / 1h 00m 55s | 55.677 km / 49m 02s |

Los tres motores encontraron ruta. La inspección cartográfica posterior de las 18
geometrías no reveló discontinuidades ni desvíos bloqueantes y confirmó el mismo
corredor general en los seis casos. Las diferencias de ETA —en especial casos 3, 5 y
6— siguen requiriendo contraste en campo; no deben interpretarse aisladamente como
calidad de ruta porque cada motor utiliza supuestos de velocidad distintos.

## Latencia

| Motor | p50 observado | p95 observado | Promedio p50 | Promedio p95 |
| --- | ---: | ---: | ---: | ---: |
| GraphHopper | 2.84–4.81 ms | 3.76–7.22 ms | ~3.49 ms | ~4.98 ms |
| OSRM | **0.59–1.09 ms** | **0.75–1.57 ms** | **~0.92 ms** | **~1.36 ms** |
| Valhalla | 5.94–34.56 ms | 6.73–42.92 ms | ~23.85 ms | ~26.92 ms |

Valhalla por caso: p50 `21.403`, `34.556`, `19.134`, `5.938`, `34.440` y
`27.596` ms; p95 `23.550`, `42.917`, `22.949`, `6.733`, `36.738` y `28.612` ms.
Las muestras completas y resúmenes permanecen preservados fuera de Git.

## Incidencias y hallazgos

- **GraphHopper:** operación directa sobre Java 21. El endpoint inicial de San Vicente
  reveló un problema de coordenada, no del motor. El resumen inicial usó `case` como
  variable de `awk`; se corrigió a `label` sin perder las 180 muestras.
- **OSRM:** pipeline MLD de tres etapas, consulta muy rápida y mayor huella de disco.
  Las advertencias de *unreachable boundary nodes* no impidieron finalizar con estado 0.
- **Valhalla timezones:** la imagen oficial no tenía `pkg-config` y el helper llegó a
  devolver estado 0 con un SQLite vacío. Se creó la imagen derivada
  `geoguide-valhalla:3.8.2-p1` solo para diagnosticarlo, pero la base resultante no
  contenía `tz_world`; se preservó como evidencia y no se usó.
- **Valhalla admins:** el recorte tenía relaciones incompletas; Perú, Lima, Ica y Junín
  fueron descartados y solo se insertó un área. La base se preservó pero no se usó.
  Cambiar el PBF habría invalidado la comparación.
- **Valhalla final:** tiles sin `admin` ni `timezone`, válidos para este benchmark
  estático sin `date_time`; no validan routing temporal ni reglas dependientes de esas
  bases. La ausencia de `traffic.tar` tampoco fue bloqueante.

## Matriz técnica

| Criterio | GraphHopper 11.0 | OSRM 26.8.0 MLD | Valhalla 3.8.2 |
| --- | --- | --- | --- |
| Consulta | Muy buena | **Mejor observada** | Menor en esta prueba |
| RAM idle | Media | Baja | **Menor observada** |
| Preparación | Mayor RAM | Menor RAM | Menor RAM |
| Disco | **Menor** | Mayor | Intermedio |
| Operación | Baja/media | Media; tres etapas | Alta; auxiliares y configuración |
| Integración | Natural con stack Java | Adaptador HTTP sencillo | Adaptador HTTP; semántica más amplia |
| Automóvil MVP | Adecuado | **Muy adecuado** | Adecuado |
| Perfiles futuros | Flexible | Perfiles preprocesados | **Multimodalidad amplia** |
| `RoutingProvider` | Normalizable | Normalizable | Normalizable |
| Licencia motor | Apache-2.0 | BSD-2-Clause | MIT |
| Riesgo pendiente | Calidad/ETA | Calidad/ETA y disco | Auxiliares y operación |

Las licencias de imágenes y dependencias deben verificarse antes de producción; esta
tabla no reemplaza la revisión de licenciamiento.

## Decisión

Adoptar **GraphHopper 11.0 como implementación inicial** de `RoutingProvider`, según
ADR-028. No fue el más rápido, pero ofrece el mejor equilibrio observado entre latencia
suficiente, disco, operación, calidad visual y alineación con Java, consistente con
ADR-002 y ADR-011.

Conservar **OSRM 26.8.0 MLD como alternativa preferida de rendimiento**. Fue claramente
el más rápido y usó menos RAM. Debe reconsiderarse como primera opción si P4 confirma
un alcance principalmente automovilístico, el mayor disco es aceptable y la inspección
de geometría/ETA resulta igual o mejor.

No usar **Valhalla 3.8.2 como motor inicial**. Su menor RAM idle y capacidades futuras
no compensan todavía la latencia y complejidad observadas. Puede reevaluarse cuando
multimodalidad o routing temporal sean requisitos y se construyan auxiliares completos.

## Cierre técnico

Durante el cierre del benchmark comparativo, cada motor temporal fue detenido antes de
iniciar el siguiente. En ese punto quedaron únicamente PostgreSQL/PostGIS, Redis y
MinIO; ~14 GiB disponibles, swap sin uso y puertos 8989, 5000 y 8002 cerrados. Después
de la selección, GraphHopper se incorporó al Compose operativo como cuarto servicio.

La implementación operativa quedó validada el 26 de agosto de 2026:

1. ruta interna resuelta sin errores: 10 615.548 m, 719 133 ms, `LineString` con
   152 coordenadas;
2. solicitud con un punto rechazada con HTTP 400 y JSON estructurado;
3. reinicio con carga de `/data/graph-cache` en aproximadamente 2 s, sin reconstrucción,
   y segunda ruta con resultado idéntico;
4. grafo persistente de aproximadamente 42 MB, UID/GID 10001 y permisos 750;
5. cuatro servicios `healthy` y ningún puerto de datos o routing publicado.

El adaptador y la normalización de `RoutingProvider` corresponden a P4.

Pendiente posterior a P1: contrastar ETA con evidencia de campo cuando esté disponible.
