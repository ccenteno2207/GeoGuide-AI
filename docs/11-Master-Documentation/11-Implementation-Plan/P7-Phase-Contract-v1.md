# P7 PHASE CONTRACT v1 — First Vertical Slice

## Estado del contrato

```text
PHASE CONTRACT: PROPOSED_PENDING_APPROVAL
PHASE APPROVAL: PENDING
AUTONOMOUS EXECUTION: NOT AUTHORIZED
```

**Clasificación:** P7 GOVERNANCE PROPOSAL
**Baseline de propuesta:** `1663794f819497cebc9e37f670b03c456057d238`
**Fecha:** 2026-09-26

Este documento delimita una propuesta de contrato. No congela P7, no inicia sus
checkpoints ni autoriza implementación funcional hasta aprobación humana explícita.

## 1. Propósito y escenario verificable

Demostrar, en un teléfono Android físico y usando infraestructura existente del piloto,
el siguiente flujo factual extremo a extremo:

1. La aplicación muestra el mapa base y obtiene ubicación puntual con los límites de
   privacidad heredados de P6.
2. La persona selecciona origen y destino mediante el mecanismo mínimo definido en la
   sección 5.
3. Mobile solicita una ruta al backend.
4. Mobile recibe una ruta válida y dibuja su geometría.
5. Mobile solicita Route Discovery para la misma pareja origen/destino.
6. El escenario de validación devuelve entre 5 y 20 POIs utilizables.
7. Mobile muestra la ruta y los marcadores POI; una persona selecciona un marcador y
   abre una ficha básica.

No se construye el producto móvil completo ni se introducen capacidades de P8 o fases
posteriores.

## 2. Baseline e inputs confirmados

- P0–P6 están cerradas.
- P6 functional baseline: `d434a82b57774deddd55713f7006d6783403c8c0`.
- P6 administrative baseline: `1663794f819497cebc9e37f670b03c456057d238`.
- Flutter `3.47.2`, Dart `3.13.2`, `flutter_map 8.3.2`, `geolocator 14.0.3` y
  `latlong2 0.10.1` están presentes en el bootstrap mobile.
- ADR-016 acepta Flutter; ADR-019 acepta `flutter_map 8.3.2`.
- P4 proporciona `POST /api/v1/routes/plan` y geometría GeoJSON `LineString`.
- P5 proporciona `POST /api/v1/routes/discover` y resultados `DISCOVERY_V1`.
- R3 — dataset piloto y P3, P4 y P5 están cerrados.

P7 consume esos contratos; no los modifica ni reimplementa.

## 3. Alcance autorizado al aprobar P7

- Integración mobile con `POST /api/v1/routes/plan` y
  `POST /api/v1/routes/discover` conforme al OpenAPI vigente.
- Selección manual mínima de origen y destino sobre el mapa.
- Mapeo de DTOs, repositorios y casos de uso mínimos para planificación y discovery.
- Transformación de GeoJSON `LineString` para dibujar la ruta con `flutter_map`.
- Marcadores POI seleccionables y ficha básica limitada a datos ya expuestos.
- Mapeo seguro de errores HTTP/red a estados de aplicación.
- Pruebas automatizadas proporcionales, build Android y validación E2E física.
- Documentación de evidencia, auditoría de alcance, PR y validación post-merge.

## 4. Fronteras de arquitectura

- Presentation no depende directamente de HTTP, DTOs, JSON ni detalles de Dio.
- Route planning, route discovery, recuperación de POI y error mapping quedan detrás
  de repositorios/casos de uso mínimos en Application/Domain/Data-Infrastructure.
- No se crea una abstracción adicional salvo responsabilidad demostrable por el flujo.
- Mobile consume los contratos backend; no duplica routing ni el ranking de discovery.
- `RoutingProvider`, GraphHopper y Route Discovery Engine continúan exclusivamente en
  backend y quedan protegidos.

## 5. Selección de origen y destino

Para P7 se usarán dos toques explícitos sobre el mapa en modo de selección visible:

1. El primer toque selecciona `origin`.
2. El segundo toque selecciona `destination`.
3. La UI muestra cuál punto se está solicitando y representa ambos puntos antes de
   permitir la solicitud.

La ubicación puntual puede centrar la cámara, pero no selecciona automáticamente origen
ni destino. No se incorporan búsqueda textual, geocoding, autocomplete, favoritos,
planificador de viaje ni persistencia de puntos.

## 6. Contrato HTTP y manejo mínimo de errores

### Endpoints congelados para consumo

- `POST /api/v1/routes/plan`
- `POST /api/v1/routes/discover`

Se consumen exclusivamente según el OpenAPI/backend vigente. Si ese contrato no permite
el flujo, P7 se detiene y reporta; no cambia backend, OpenAPI, base de datos ni P3–P5.

### Estados mínimos verificables

| Caso | Estado mobile requerido |
| --- | --- |
| Backend inaccesible | Mensaje seguro de servicio no disponible; sin URL interna ni detalle de infraestructura. |
| Timeout | Mensaje seguro de espera agotada; sin reintento infinito. |
| Respuesta inválida | Error controlado de datos no utilizables; sin excepción visible. |
| `NO_ROUTE_FOUND` | Estado de ruta no disponible; no se intenta discovery. |
| `results: []` o POIs no utilizables | Estado vacío controlado; no falla la aplicación. |

Los errores se convierten a fallas de aplicación y mensajes orientados a la persona. No
se registran secretos, stack traces, URLs internas ni coordenadas personales precisas.

## 7. Geometría de ruta

- **Entrada:** `RoutePlanResponse.geometry`, GeoJSON `LineString` con pares
  `[longitude, latitude]` WGS84 y al menos dos puntos.
- **Validación:** tipo `LineString`, colección no vacía, pares numéricos finitos y
  coordenadas geográficas válidas. Una geometría no utilizable activa el estado de
  respuesta inválida.
- **Transformación:** el mapper Data/Infrastructure convierte cada par a
  `LatLng(latitude, longitude)`; no altera el formato backend.
- **Renderizado:** Presentation dibuja una sola ruta mediante las capacidades existentes
  de `flutter_map`; la cámara deja visibles origen, destino y la geometría cuando sea
  posible.
- **Criterio visual:** en el escenario E2E válido se observa una línea continua entre
  el origen y el destino seleccionados, sin sustituirla por una ruta calculada localmente.

## 8. Discovery, POIs y ficha mínima

- Discovery usa la misma pareja origen/destino que la ruta ya validada.
- La validación E2E utiliza un escenario del dataset piloto que devuelve de 5 a 20
  resultados utilizables dentro de los límites del contrato vigente.
- Cada resultado válido se representa como marcador seleccionable.
- La ficha básica muestra exclusivamente `name`, `category`,
  `distanceToRouteMeters`, `routeProgress` y `reasonCodes` cuando estén presentes en el
  contrato backend. No incorpora imágenes, media, filtros, favoritos, provenance
  completa, recomendaciones adicionales ni capacidades P8.

## 9. Dependencias y decisiones

### Confirmadas

- Flutter/Dart, `flutter_map 8.3.2`, `geolocator 14.0.3` y `latlong2 0.10.1`.
- OpenAPI/backend P4/P5 existentes.

### HTTP_CLIENT = CONTRACT_DECISION_PENDING_APPROVAL

Se propone `Dio 5.11.1`, versión estable publicada con restricción Dart
`>=2.18.0 <4.0.0`, compatible con Dart `3.13.2`. La documentación mobile ya contempla
`Dio o equivalente` y sus responsabilidades de URL base, timeout, JSON y error mapping;
esta propuesta no instala la dependencia ni autoriza overrides o upgrades de Flutter/Dart.

### Gestión de estado

```text
NEW_STATE_MANAGEMENT_DEPENDENCY = NOT_REQUIRED
```

Los estados mínimos del flujo pueden resolverse con Flutter nativo y la estructura
existente. Riverpod no se adopta ni instala en P7; cualquier necesidad posterior exige
decisión explícita.

## 10. Tiles, privacidad y seguridad

```text
DEVELOPMENT_VALIDATION_TILE_SOURCE = reuse P6 configuration
TILE_PROVIDER_GOVERNANCE = PENDING
PRODUCTION_AUTHORIZATION = NO
```

La atribución visible se mantiene. La ubicación conserva permisos mínimos, adquisición
puntual y ausencia de historial, tracking continuo, geofencing o precisión superior no
justificada. La URL backend se configura fuera del código fuente y sin secretos.

## 11. Conectividad backend para E2E

```text
P7_RUNTIME_BACKEND_CONNECTIVITY = REQUIRED_BEFORE_E2E_VALIDATION
```

La topología, hostname, IP, tunnel, reverse proxy y mecanismo de exposición no se
definen aquí. Esta decisión no bloquea la autoría contractual, pero bloquea el gate E2E
hasta disponer de una conectividad segura y verificable hacia la infraestructura del
piloto.

## 12. Exclusiones congeladas

- CEFI, STT, TTS, LLM y UI conversacional.
- Autenticación, analytics, favoritos y perfiles.
- Offline avanzado, paquetes de mapas offline y Driving Mode.
- GPS en segundo plano, tracking continuo y geofencing.
- Address search, geocoding, autocomplete y trip planner.
- Cambios backend, OpenAPI, base de datos, PostGIS, P3, P4, P5, RoutingProvider,
  GraphHopper o Route Discovery Engine.
- Selección de proveedor productivo de tiles.

## 13. Criterios de aceptación

| ID | Requisito | Condición PASS | Método y evidencia requerida |
| --- | --- | --- | --- |
| P7-AC-01 | Integración mobile/backend | Presentation no depende de HTTP y ambos endpoints se consumen según OpenAPI vigente. | CODE, TEST, HTTP, DOC. |
| P7-AC-02 | Selección de puntos | Origen y destino se seleccionan mediante los dos toques visibles definidos en este contrato. | TEST, SCREENSHOT, DEVICE. |
| P7-AC-03 | Solicitud de ruta | Una solicitud válida recibe distancia, duración y geometría válida. | TEST, HTTP, DEVICE. |
| P7-AC-04 | Geometría | `LineString` se valida, transforma y dibuja sin cálculo local de ruta. | TEST, SCREENSHOT, DEVICE. |
| P7-AC-05 | Route Discovery | La misma pareja de puntos produce una solicitud discovery conforme al contrato. | TEST, HTTP, DEVICE. |
| P7-AC-06 | POIs y marcadores | El escenario E2E presenta entre 5 y 20 POIs utilizables como marcadores seleccionables. | HTTP, SCREENSHOT, DEVICE. |
| P7-AC-07 | Ficha básica | Seleccionar un marcador abre la ficha mínima sin capacidades P8. | TEST, SCREENSHOT, DEVICE. |
| P7-AC-08 | Errores | Indisponibilidad, timeout, respuesta inválida, ausencia de ruta y vacío se manejan sin información interna. | TEST, HTTP, LOG. |
| P7-AC-09 | Privacidad y seguridad | Sin secretos, URLs productivas hardcodeadas, logs sensibles ni tracking continuo. | CODE, TEST, DOC, GIT. |
| P7-AC-10 | Gates R4/R5 | El flujo factual completo funciona contra infraestructura piloto en teléfono Android físico. | HTTP, SCREENSHOT, LOG, DEVICE. |
| P7-AC-11 | Alcance | No cambia backend/P3–P5 ni incorpora exclusiones; tiles siguen sólo para desarrollo/validación. | GIT, DOC, TEST. |

## 14. Definition of Done P7

P7 se considera terminada únicamente cuando:

1. P7-AC-01 a P7-AC-11 tienen evidencia PASS.
2. `dart format .`, `flutter analyze`, `flutter test` y `flutter build apk --debug`
   pasan para el contenido P7.
3. Los dos endpoints se consumen sin modificar sus contratos.
4. Ruta, geometría, POIs, marcadores y ficha básica funcionan en E2E.
5. R4 confirma que el vertical slice funciona con infraestructura del piloto.
6. R5 confirma la ejecución en un teléfono Android físico.
7. Se revisan permisos, privacidad, secretos y registros.
8. Se completa auditoría de alcance, PR, post-merge y evidencia de cierre.

## 15. Checkpoints propuestos

### P7.0 — Contract / Entry Gate

- Resolver aprobación contractual, `HTTP_CLIENT`, conectividad backend y rama autorizada.
- No escribir código hasta que el contrato esté FROZEN / APPROVED y la ejecución esté autorizada.

### P7.1 — Mobile API Integration

- Añadir el cliente HTTP aprobado, configuración no secreta, DTOs, mappers, repositorios,
  casos de uso y error mapping mínimos.
- Prohibido modificar backend/OpenAPI.

### P7.2 — Route Planning & Geometry

- Implementar selección por dos toques, solicitud de ruta, validación/mapeo de
  `LineString` y renderizado `flutter_map`.

### P7.3 — Route Discovery & POIs

- Solicitar discovery, validar resultados, representar 5–20 POIs del escenario y
  marcadores seleccionables.

### P7.4 — Basic POI Detail

- Implementar la ficha mínima contractual exclusivamente con campos existentes.

### P7.5 — Physical Device E2E Validation

- Confirmar conectividad backend segura y ejecutar R4/R5 en Android físico, sin exponer
  datos sensibles ni coordenadas precisas en evidencia.

### P7.6 — Phase Audit & Closure

- Ejecutar gates, auditoría de alcance, PR, validación post-merge y propuesta de cierre.

## 16. Evidence y governance stops

- **CODE/TEST:** arquitectura, mappers, repositorios, casos de uso y pruebas.
- **HTTP:** solicitudes, respuestas y errores sanitizados de ambos endpoints.
- **SCREENSHOT/DEVICE:** selección, ruta, POIs y ficha en Android físico.
- **GIT/DOC/PR:** diff, exclusiones, commits, PR y evidencia de cierre.

Detener y solicitar decisión antes de implementar si se requiere cambiar contratos P4/P5,
backend, OpenAPI, proveedores, tiles productivos, dependencias no aprobadas, arquitectura
material, topología no segura o alcance excluido.

## 17. Evaluación de readiness

La propuesta es ejecutable sólo después de:

1. aprobar y congelar este contrato;
2. aceptar o rechazar la propuesta de `Dio 5.11.1`;
3. definir conectividad backend segura para el gate E2E;
4. autorizar explícitamente la ejecución autónoma P7.

```text
P7_CONTRACT_STATUS = PROPOSED_PENDING_APPROVAL
P7_IMPLEMENTATION_STATUS = NOT_STARTED
AUTONOMOUS_EXECUTION = NOT AUTHORIZED
```
