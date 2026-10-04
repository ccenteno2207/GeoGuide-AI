# P7 — Evidencia de validación funcional temporal

## Línea base y límites

- Baseline de gobierno: `100da7a9cf724c430366093c55635d07a713eae3`.
- Contrato: [P7 Phase Contract v1](P7-Phase-Contract-v1.md),
  **APPROVED_FROZEN**.
- Esta evidencia registra exclusivamente P7.5 mediante el endpoint funcional temporal
  `http://geoguide.getcom.pe:1980`, entregado desde `--dart-define`.
- El objetivo seguro continúa siendo `https://geoguide.getcom.pe:5443`.
  `HTTP_SATISFIES_SECURE_GATE = NO`.

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

## Validación física P7.5

En Android físico se verificó, sin registrar coordenadas precisas ni identificadores
personales:

- Inicio de aplicación y mapa base: PASS.
- Permiso aproximado concedido, servicio disponible y adquisición puntual: PASS.
- Selección visible de origen y destino con dos toques: PASS.
- `POST /api/v1/routes/plan`, respuesta válida y renderizado de `LineString`: PASS.
  La transformación conserva `[longitude, latitude]` a `LatLng(latitude, longitude)`.
- `POST /api/v1/routes/discover`: PASS; el escenario devolvió 5 POIs utilizables.
- Marcadores POI y ficha básica contractual: PASS.

Las fichas mostraron únicamente `name`, `category`, `distanceToRouteMeters`,
`routeProgress` y `reasonCodes`.

## Criterios de aceptación P7

| ID | Resultado | Evidencia |
| --- | --- | --- |
| P7-AC-01 | PASS | Composición de cliente/repositorios, pruebas y solicitudes reales. |
| P7-AC-02 | PASS | Dos toques físicos para origen y destino. |
| P7-AC-03 | PASS | Ruta recibida y mostrada en Android. |
| P7-AC-04 | PASS | `LineString` validado, transformado y dibujado. |
| P7-AC-05 | PASS | Discovery real para la misma pareja de puntos. |
| P7-AC-06 | PASS | Cinco POIs utilizables y marcadores visibles. |
| P7-AC-07 | PASS | Ficha básica física con los campos congelados. |
| P7-AC-08 | PASS | Pruebas de mapeo cubren indisponibilidad, timeout y `NO_ROUTE_FOUND`; mappers validan respuesta no utilizable y la UI presenta el estado vacío controlado. Los mensajes permanecen seguros y no exponen detalles internos. |
| P7-AC-09 | PASS | Configuración externa, permiso mínimo y sin coordenadas en evidencia. |
| P7-AC-10 | BLOCKED | El flujo funcional temporal pasó, pero el gate seguro exige HTTPS confiable. |
| P7-AC-11 | PASS | No se incorporaron cambios excluidos ni se modificó backend/P3–P5. |

## Estado y riesgo residual

```text
P7_5_FUNCTIONAL_E2E = PASS
P7_5_SECURE_CONNECTIVITY = BLOCKED_BY_AUTHORITATIVE_DNS
P7_5_STATUS = FUNCTIONAL_E2E_PASS_TLS_PENDING
P7_STATUS = IN_PROGRESS
P7_6_STATUS = NOT STARTED
```

`TLS_STATUS = BLOCKED_BY_AUTHORITATIVE_DNS`. La incidencia externa requiere
sincronización de los nameservers autoritativos antes de una nueva validación ACME
expresamente autorizada. No se reintentó ACME ni se degradó la configuración de
seguridad Android.
