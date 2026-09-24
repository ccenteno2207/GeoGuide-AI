# ADR-019 – Librería de mapas

**Estado:** Aceptado
**Ámbito:** P6 — Mobile Bootstrap

## Candidatos
- flutter_map
- MapLibre Flutter

## Decisión MVP
Adoptar **flutter_map 8.3.2** como biblioteca de mapas para el baseline inicial de
P6 — Mobile Bootstrap.

La decisión se basa en P6.0-C1, ejecutado sobre un mismo dispositivo físico Android
API 36. Ambos candidatos resolvieron dependencias, construyeron APK Android e
implementaron renderizado, interacción, markers / POIs, ubicación, comportamiento de
red y degradación sin red. `flutter_map` fue seleccionado porque presentó menor
complejidad y riesgo de integración observados, una API por capas adecuada para el
Mobile Bootstrap y menor configuración adicional para el alcance actual.

## Alternativa evaluada
**MapLibre Flutter / maplibre_gl 0.27.1** es una alternativa técnicamente viable.

- `maplibre_gl 0.27.0`: `BUILD FAIL / KNOWN_UPSTREAM_ISSUE`.
- `maplibre_gl 0.27.1`: `OFFICIAL FIX / BUILD PASS`.
- El fallo inicial de `https://demotiles.maplibre.org/style.json` correspondió a una
  dependencia externa / DNS del estilo demo, no a una incapacidad del motor MapLibre.
- Con estilo local controlado y tiles OSM, se validaron `STYLE_LOAD = PASS`,
  `BASE_MAP_RENDERING = PASS`, `INTERACTION = PASS`, `POIS = PASS`,
  `LOCATION = PASS` y `APPLICATION_STABILITY = PASS`.

## Licenciamiento
- `flutter_map 8.3.2`: BSD 3-Clause.
- `maplibre_gl 0.27.1`: BSD 3-Clause.

## Límites y gobierno posterior
`MAP_LIBRARY_DECISION` está separada de `TILE_PROVIDER_DECISION`.

```text
TILE_PROVIDER_GOVERNANCE = PENDING
```

La aceptación de `flutter_map` no autoriza usar `tile.openstreetmap.org` como
proveedor productivo ilimitado. OpenStreetMap permanece como foundation de datos/mapa,
pero proveedor, infraestructura de tiles, atribución, límites operativos y política
productiva requieren gobierno independiente.

P6.0-C1 no validó iOS, offline avanzado, benchmarks cuantitativos, producción a escala
ni un proveedor productivo definitivo de tiles. Tampoco valida clustering, polyline,
routing ni turn-by-turn navigation.

```text
POLYLINE = OUT_OF_SCOPE_FOR_C1_DECISION
```

`RoutingProvider`, geometría de ruta, validación Lima → Obrajillo y cualquier
abstracción de motores permanecen como hipótesis hasta que su inclusión esté confirmada
por el contrato de fase correspondiente.

No mezclar ambas librerías en la aplicación productiva sin una razón arquitectónica.
