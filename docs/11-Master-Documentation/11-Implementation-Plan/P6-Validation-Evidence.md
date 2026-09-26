# P6 — Evidencia de validación y cierre

## Línea base y alcance

- Baseline de inicio de P6.2: `f53fc67fd3f3a68fbd90d4577727e3323da581be`.
- Baseline integrado después de P6.3: `a40b6b85c87e81f99dc82cce8f54b0bd52fd93fb`.
- Contrato: [P6 Phase Contract v1](P6-Phase-Contract-v1.md), **FROZEN / APPROVED**.
- ADR-016: Flutter aceptado; ADR-019: `flutter_map 8.3.2` aceptado.
- `geolocator 14.0.3`: dependencia aprobada para P6.3 y resuelta por Flutter/Dart.

## Checkpoints

| Checkpoint | PR / commit | Evidencia | Resultado |
| --- | --- | --- | --- |
| P6.1 — Flutter Bootstrap | PR #18 / `04c576c` | Bootstrap, análisis, prueba y APK debug | PASS |
| P6.2 — Base Map | PR #19 / `fef7b50` | Mapa OSM de desarrollo, atribución, pan y zoom en Android | PASS |
| P6.3 — GPS / Location | PR #20 / `32d1be3` | Permiso aproximado, ubicación puntual y marcador en Android | PASS |
| P6.4 — Validation & Closure | Esta evidencia | Auditoría de P6-AC-01 a P6-AC-09 | PASS |

## Validación técnica

- Flutter `3.47.2`; Dart `3.13.2`.
- `flutter pub get`: PASS.
- `flutter analyze`: PASS.
- `flutter test`: PASS; cuatro pruebas de widget cubren estado inicial, permiso denegado,
  servicio no disponible y permiso bloqueado.
- `flutter build apk --debug`: PASS.
- La mitigación local `kotlin.incremental=false` se mantiene por un problema de caché
  incremental Kotlin entre el proyecto en `D:` y el Pub Cache en `C:`. No cambia
  dependencias ni comportamiento funcional.

## Validación Android en dispositivo físico

- Mapa base y atribución `OpenStreetMap contributors`: PASS.
- Cámara, pan y zoom: PASS.
- Permiso `ACCESS_COARSE_LOCATION`: concedido durante la prueba.
- Servicio de ubicación disponible, adquisición puntual y marcador visible: PASS.
- No se registraron coordenadas en evidencia, logs ni documentación.

## Privacidad, tiles y alcance

- Solo se declara `ACCESS_COARSE_LOCATION`; no se declara precisión fina, ubicación en
  segundo plano ni permiso de almacenamiento.
- `LocationAccuracy.low`; no existe tracking continuo, geofencing, historial ni
  persistencia de ubicación.
- `DEVELOPMENT_VALIDATION_TILE_SOURCE` permanece
  `https://tile.openstreetmap.org/{z}/{x}/{y}.png` con atribución visible.
- `TILE_PROVIDER_GOVERNANCE = PENDING`; no existe autorización de uso productivo del
  servicio público de tiles.
- No hay cambios en backend, P4/P5, contratos API, infraestructura, routing, polyline,
  CEFI, voz, autenticación, analytics u offline avanzado.

## Criterios de aceptación

| ID | Resultado | Evidencia |
| --- | --- | --- |
| P6-AC-01 | PASS | Bootstrap reproducible, análisis, pruebas y APK debug. |
| P6-AC-02 | PASS | `geolocator` queda en Infrastructure; Presentation usa Application/Domain. |
| P6-AC-03 | PASS | Mapa base y atribución visibles en Android. |
| P6-AC-04 | PASS | Pan y zoom validados en Android. |
| P6-AC-05 | PASS | Estados de permiso denegado, bloqueado y servicio no disponible cubiertos; permiso aproximado validado. |
| P6-AC-06 | PASS | Posición puntual visible sin historial ni tracking. |
| P6-AC-07 | PASS | Mínimo privilegio: `ACCESS_COARSE_LOCATION` solamente. |
| P6-AC-08 | PASS | Tiles limitados a desarrollo/validación y atribución visible. |
| P6-AC-09 | PASS | Auditoría de alcance, pruebas y `git diff --check` sin regresiones P4/P5. |

## Cierre maestro

- P6.1–P6.4: **CLOSED**.
- P6 — Mobile Bootstrap: **COMPLETED**.
- PR #21: **MERGED**.
- Baseline funcional final de P6:
  `d434a82b57774deddd55713f7006d6783403c8c0`.
- P6-AC-01–P6-AC-09: **PASS**.
- P7 — First Vertical Slice: **NOT STARTED**.
- Riesgo residual: la ubicación aproximada puede mostrar una desviación compatible con
  su nivel de precisión; la definición de un proveedor productivo de tiles permanece
  pendiente de gobierno independiente.
