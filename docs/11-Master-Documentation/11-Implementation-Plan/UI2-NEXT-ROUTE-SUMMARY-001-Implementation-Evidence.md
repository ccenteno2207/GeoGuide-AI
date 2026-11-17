# UI2-NEXT-ROUTE-SUMMARY-001 — Evidencia de implementación

## Alcance

El resumen de una ruta planificada muestra distancia, duración y cantidad de lugares cuando existe una respuesta exitosa y vigente de Route Discovery para el mismo origen/destino y con todas las categorías. La cantidad usa singular para un resultado y plural para cero o varios (`0 lugares`).

El controlador conserva el total de la última consulta completa de esa ruta mientras se actualizan resultados filtrados. Iniciar una consulta completa nueva o invalidar/cambiar la ruta invalida el total anterior. Durante carga o error no se presenta una cantidad como vigente.

Para `OfflineDiscovery`, solo se presenta el conteo de un snapshot vigente que coincide con los extremos seleccionados y contiene el conjunto completo de categorías. Snapshots expirados, de otra ruta o limitados a categorías no se presentan como total de la ruta.

No se modificaron API, backend, base de datos, permisos, GPS, Driving, contratos ni dependencias. No se generó APK ni se ejecutó una validación física.

## Validación local

- `dart format --output=none --set-exit-if-changed lib test`: PASS, 99 archivos inspeccionados sin cambios pendientes.
- `flutter test --no-pub test/features/discovery/presentation/route_discovery_controller_test.dart test/widget_test.dart test/features/discovery/offline_ui_test.dart`: 34 PASS, 0 FAIL.
- El test `searched destination plan renders route geometry and a persistent summary` verifica el conteo bajo todas las categorías, conservación durante filtro, restauración y resultado exitoso vacío.
- Pruebas de controlador: total preservado ante filtro, cero exitoso, error sin conteo válido, cambios de origen/destino e ignorado de respuestas tardías tras cambiar ruta.
- Pruebas offline: conteo de snapshot completo, resultado vacío, snapshot filtrado sin conteo de ruta y expiración que oculta el resumen.
- `flutter analyze --no-pub`: PASS, no issues found.
- `git diff --check`: PASS.

## Estado

```ini
UI2_PHYSICAL_EVIDENCE_CONSOLIDATION = PASS
UI2_PHYSICAL_VALIDATION = PARTIAL
UI2_ROUTE_SUMMARY_IMPLEMENTATION = PASS
UI2_ROUTE_SUMMARY_PHYSICAL = NOT_EXECUTED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

La validación física anterior de UI2 permanece PARTIAL; esta modificación solo aporta evidencia automatizada para el resumen de ruta.
