# P7 — Evidencia de validación P7.5 HTTPS

## Línea base y límites

- Baseline funcional móvil: `ecd068c0506ba445b5180126a1fdb61e8be98a91`.
- Contrato: [P7 Phase Contract v1](P7-Phase-Contract-v1.md),
  **APPROVED_FROZEN**.
- La validación física P7.5 usa exclusivamente
  `https://geoguide.getcom.pe:5443`, entregado desde `--dart-define`.
- HTTP `:1980` responde `308` hacia HTTPS; no se usó como fallback móvil y no
  satisface por sí mismo el gate seguro.

## Corrección de integración móvil

Durante la preparación de la validación se detectó que `GeoGuideApp` no componía los
casos de uso `PlanRoute` y `DiscoverRoute`, ni resolvía `BACKEND_BASE_URL`. Se corrigió
solamente el cableado en la capa de aplicación:

- `BACKEND_BASE_URL` se recibe exclusivamente mediante `String.fromEnvironment`.
- La URL se valida como HTTP o HTTPS antes de construir el cliente.
- `GeoGuideHttpClient`, repositorios Dio y casos de uso se inyectan sin exponer HTTP,
  DTOs o JSON a Presentation.
- No se alteraron Android, backend, OpenAPI, base de datos, infraestructura ni
  dependencias.

## Validación automática

- `flutter analyze`: PASS.
- `flutter test`: PASS; 16 pruebas.
- `flutter build apk --debug` con el `dart-define` temporal: PASS.
- `git diff --check`: PASS.

## Infraestructura TLS y renovación

- HTTPS público, hostname, cadena confiable y `GET /actuator/health`: PASS; health
  responde HTTP `200` con `{"status":"UP"}`.
- ACME DNS-01 de producción: certificado emitido y persistido; no hubo reemisión ni
  repetición ACME durante los gates posteriores. El TXT residual fue limpiado y la
  replicación DNS de la zona delegada fue validada para la emisión.
- El runtime de renovación está instalado, desacoplado de secretos de aplicación y del
  `.env` histórico. Conserva el volumen persistente de Let's Encrypt y el marcador de
  recarga; el timer está habilitado y activo con calendario `03:17` y `15:17`.
- Nginx sigue como único ingress publicado; backend y servicios de datos permanecen
  sin bindings de host. No se ejecutó renovación manual para esta evidencia.

## Validación física P7.5 exclusivamente HTTPS

En Android físico API 36 se verificó, sin registrar coordenadas precisas ni
identificadores personales:

- Inicio de aplicación y mapa base: PASS.
- Permiso de ubicación concedido, servicio disponible y adquisición puntual: PASS.
- `BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` fue suministrada externamente;
  no se utilizó fallback HTTP ni bypass TLS.
- Selección visible de origen y destino con dos toques: PASS.
- `POST /api/v1/routes/plan` mediante HTTPS, respuesta válida y renderizado de
  `LineString`: PASS.
  La transformación conserva `[longitude, latitude]` a `LatLng(latitude, longitude)`.
- `POST /api/v1/routes/discover` mediante HTTPS: PASS; el escenario devolvió entre 5
  y 20 POIs utilizables.
- Marcadores POI y ficha básica contractual: PASS.

Las fichas mostraron únicamente `name`, `category`, `distanceToRouteMeters`,
`routeProgress` y `reasonCodes`.

## Criterios de aceptación P7

| ID | Resultado | Evidencia |
| --- | --- | --- |
| P7-AC-01 | PASS | Composición de cliente/repositorios, pruebas y solicitudes reales. |
| P7-AC-02 | PASS | Dos toques físicos para origen y destino. |
| P7-AC-03 | PASS | Ruta HTTPS recibida y mostrada en Android. |
| P7-AC-04 | PASS | `LineString` validado, transformado y dibujado. |
| P7-AC-05 | PASS | Discovery HTTPS real para la misma pareja de puntos. |
| P7-AC-06 | PASS | Entre 5 y 20 POIs utilizables y marcadores visibles. |
| P7-AC-07 | PASS | Ficha básica física con los campos congelados. |
| P7-AC-08 | PASS | Pruebas de mapeo cubren indisponibilidad, timeout y `NO_ROUTE_FOUND`; mappers validan respuesta no utilizable y la UI presenta el estado vacío controlado. Los mensajes permanecen seguros y no exponen detalles internos. |
| P7-AC-09 | PASS | Configuración externa, permiso mínimo y sin coordenadas en evidencia. |
| P7-AC-10 | PASS | Android físico API 36, HTTPS confiable, sin bypass/fallback, route plan y discovery reales. |
| P7-AC-11 | PASS | No se incorporaron cambios excluidos ni se modificó backend/P3–P5. |

## Estado y riesgo residual

```text
P7_5_TECHNICAL_STATUS = COMPLETE
P7_5_GOVERNANCE_STATUS = COMPLETE
P7_5_STATUS = CLOSED
P7_STATUS = IN_PROGRESS
P7_6_STATUS = NOT STARTED
TILE_PROVIDER_GOVERNANCE = PENDING
PARENT_DELEGATION_INCIDENT = OPEN
```

El éxito de DNS-01, ACME, TLS y Android HTTPS no cierra el incidente histórico de
delegación del parent. No se registran token de deSEC, claves privadas, contraseñas,
contenido de secretos, serial completo del teléfono ni coordenadas precisas.
