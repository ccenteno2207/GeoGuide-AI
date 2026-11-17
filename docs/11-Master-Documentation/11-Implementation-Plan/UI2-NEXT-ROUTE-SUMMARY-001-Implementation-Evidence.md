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

## Actualización — UI2-H04-FIX-AND-FLOATING-CONTROLS-001 (2026-11-16)

### H-04 — hallazgo y corrección

El fallo físico reportado se reprodujo en un test widget. En la ruta de `OfflineDiscovery`, el resumen completo solo se mostraba cuando el snapshot de presentación contenía todas las categorías. Al filtrar, ese snapshot pasaba a representar la consulta filtrada y la condición ocultaba también distancia y duración. Además, el flujo offline no mantenía por separado un resultado completo vigente para presentar el total.

`OfflineDiscovery` conserva ahora, solo durante la sesión, el snapshot completo vigente. Las consultas filtradas de los mismos extremos conservan su conteo total; una nueva consulta completa, la invalidación/cambio de ruta y la expiración eliminan el conteo anterior. Respuestas invalidadas no pueden restaurarlo. El resumen de distancia y duración permanece cuando hay una ruta/snapshot elegible para los mismos extremos, aunque las categorías estén filtradas. Si solo existe un snapshot filtrado, no se atribuye su cantidad como total de la ruta. El manejo de copia offline elegible, resultados vacíos y fallos recuperables se mantiene.

### Controles flotantes

`Ver lista` y `Conducción` usan ahora `FilledButton` con superficie `GeoGuideTheme.exploration.surface`, primer plano `primary`, borde del tema, radio y área mínima de 48 dp. Se conservaron el orden, ubicación, etiquetas y callbacks existentes. No se alteró el comportamiento de Driving.

### Validación automatizada

- La prueba de regresión falló antes del arreglo: después de aplicar el filtro, no encontraba el resumen visible. Tras el cambio verifica 5 resultados completos → filtro sin resultados → restauración, conservando `5 lugares` y la ruta.
- Pruebas offline/UI y de estado tras el cambio final: 50 PASS, 0 FAIL (`offline_ui_test.dart` y `offline_cache_test.dart`). Incluyen total filtrado/restaurado, snapshot filtrado sin total inventado, fallback offline elegible, expiración, invalidación por nueva ruta, respuesta tardía y descarte del conteo durante una nueva consulta completa.
- Suite focalizada relacionada anterior: 130 PASS, 0 FAIL en offline/cache, controlador Route Discovery, experiencia UI2, etiquetas/accesibilidad automatizada, shell/layout y `widget_test.dart`. No incluye las pruebas físicas ni una certificación TalkBack.
- `dart format --output=none --set-exit-if-changed` sobre los cuatro archivos Dart afectados: PASS, sin cambios.
- `flutter analyze --no-pub`: PASS, sin problemas.
- `git diff --check`: PASS.
- No hubo cambios en backend, API, DB, permisos, dependencias, GPS, Driving o contratos. No se generó APK ni se realizó instalación o validación física.

### Commits locales

- `d62170cf2c4fe52543b443bf9d070a16cf1c278e` — corrección de persistencia del resumen H-04.
- `10db4b58825473c5d8ff7d209acdba8b3bce82c6` — superficies opacas de controles flotantes.
- `284653d19f612062402063ff93fcec1a7dec2748` — formato final de aserciones del control visual.

### Estado

```ini
UI2_H04_FIX = PASS
UI2_H04_REGRESSION_TESTS = PASS
UI2_FLOATING_CONTROLS_VISUAL = PASS
UI2_FLUTTER_ANALYZE = PASS
UI2_SCOPE = PASS
UI2_H04_PHYSICAL_REVALIDATION = NOT_EXECUTED
TALKBACK = NOT_TESTED
TALKBACK_REMEDIATION = DEFERRED_TECH_DEBT
UI2_PR = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

La corrección cuenta con evidencia automatizada. H-04 todavía requiere revalidación física en HONOR; no se interpretan estos resultados como aprobación física.
