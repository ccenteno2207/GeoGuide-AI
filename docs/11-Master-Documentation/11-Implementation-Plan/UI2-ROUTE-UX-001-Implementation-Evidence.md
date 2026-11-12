# UI2-ROUTE-UX-001 — Evidencia de implementación local

Fecha: 2026-11-12

## Estado

Implementación y validación automatizada local completadas. Validación física HONOR: PARTIAL; publicación, PR y merge no autorizados.

## Flujo

- «Seleccionar» fija el destino sin iniciar el cálculo.
- Un origen manual seleccionado prevalece. Si falta, el cliente consulta ubicación puntual con `requestPermission: false`; solo acepta coordenadas válidas, precisión ≤100 m y timestamp dentro de 2 minutos.
- Si no hay ubicación utilizable, la interfaz pide seleccionar el origen en el mapa.
- «Ver ruta» inicia PlanRoute; solo ante éxito se invoca Route Discovery. El modo Conducción no se inicia automáticamente.

## Validación H2

- `dart format --output=none --set-exit-if-changed` sobre los 15 archivos Dart afectados: PASS.
- `flutter analyze`: PASS, sin issues.
- `flutter test`: 271 PASS, 1 SKIP.
- `git diff --check`: PASS.
- Sin cambios al AndroidManifest, permisos o backend. No se añadieron streams de ubicación; centrado automático al abrir queda fuera del alcance.

## APK H3

- Build: `flutter build apk --debug --no-pub --dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` — PASS.
- Ruta: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.
- Tamaño: 194,273,791 bytes.
- SHA-256: `092DC53006797728BEC0B17C1604D4259229048146117F13CE8D9388E57950D1`.
- `aapt dump badging`: paquete `com.geoguideai.geoguide_ai`, versión `1.0.0`, etiqueta `Rutea`.
- Configuración de build usa el endpoint HTTPS indicado; búsqueda estática de localhost, 127.0.0.1, 10.0.2.2 y HTTP en código móvil no encontró endpoints locales ni fallback. Al cerrar H3 todavía no se había instalado ni probado físicamente; la sesión posterior está documentada abajo.

Limitaciones previas: el full suite informa un test omitido. La sesión física de 2026-11-12 se registra a continuación; los escenarios que requieren cambiar permisos o provocar errores no se ejecutaron.

## Validación física HONOR — 2026-11-12

### Instalación y dispositivo

- Dispositivo ADB verificado como HONOR LLY-NX3, estado `device`; se omite el serial en este registro.
- Worktree en `codex/ui2-route-ux-001`, HEAD `a0c712bb061cdbe034bed1012cd450b0a755d581`; árbol limpio antes de la sesión.
- APK autorizada usada en `adb install -r`: `mobile/build/app/outputs/flutter-apk/app-debug.apk`; SHA-256 local verificado `092DC53006797728BEC0B17C1604D4259229048146117F13CE8D9388E57950D1`. El hash identifica el artefacto de origen; no se afirma igualdad binaria de los APK extraídos tras instalar.
- `adb install -r`: `Success`. Paquete `com.geoguideai.geoguide_ai`, versión `1.0.0`; actualización no destructiva. Certificado de firma del artefacto y de la instalación existente coincidieron antes de actualizar. No se desinstaló la app ni se borraron datos.
- Rutea abrió sin crash. No hubo solicitud nueva de permiso al abrir o al preparar la ruta; los permisos de ubicación ya estaban concedidos.
- La build usa `https://geoguide.getcom.pe:5443`. Route Plan y Discovery finalizaron en el teléfono y `adb reverse --list` no devolvió reglas; no se configuró túnel.

### Matriz de escenarios

| Escenario | Estado | Evidencia observada |
| --- | --- | --- |
| PHYS-01 — Apertura | PASS | Inicio estable, mapa y atribución OSM visibles; sin cálculo ni Driving automático y sin centrado automático impuesto. |
| PHYS-02 — Búsqueda | PASS | Búsqueda `Canta` mostró Plaza de Armas de Canta. Seleccionar el resultado dejó el cálculo sin ejecutar y presentó el botón `Ver ruta`. |
| PHYS-03 — Origen GPS puntual | PASS | Con permisos ya concedidos se mostró `Origen: Tu ubicación actual` antes de calcular; no apareció un diálogo de permiso. `Ver ruta` produjo geometría y resumen. No se activó seguimiento continuo. |
| PHYS-04 — PlanRoute y Route Discovery | PASS | La ruta GPS mostró `98.4 km · 101 min`; la lista informó `5 de 5 lugares`. Preview y Detail de Plaza de Armas de Canta abrieron y regresaron. |
| PHYS-05 — Prioridad manual | PASS | Un toque en el mapa fijó origen manual; después de seleccionar Canta se mostró `Origen: Origen manual`. El cálculo resultó en `5.7 km · 12 min`, diferente de la ruta GPS, y cargó POIs. |
| PHYS-06 — Ubicación no disponible/permiso denegado | NOT_TESTED | No se alteraron permisos del HONOR. El escenario requiere que el propietario cambie el permiso manualmente para poder probarlo de forma segura. No se usaron coordenadas inventadas. |
| PHYS-07 — Regresión | PARTIAL | Se filtró la categoría Monumento y la lista cambió a `1 de 1` lugar; el resumen siguió visible. El destino se cambió a Plaza de Armas de Obrajillo y la nueva ruta mostró `28.9 km · 45 min` y 3 POIs. Driving no se inició automáticamente. No se provocó un error para probar recuperación. |
| Red/ADB reverse | PASS | Solicitudes de búsqueda, planificación y descubrimiento completaron en la app; `adb reverse --list` vacío. La sesión usó conectividad Wi-Fi disponible; no se cambió ni aisló la red móvil. |
| Estabilidad | PASS | Rutea permaneció en primer plano; no se encontraron entradas de crash/FATAL del proceso en el logcat consultado. |

### Evidencia visual

Las capturas se conservaron fuera del repositorio para evitar añadir imágenes de dispositivo al historial Git. No incluyen coordenadas textuales ni notificaciones con contenido personal.

Carpeta local: `D:\Codex\ui2-route-ux-001-physical-evidence\`

- `PHYS-01-home.png` — pantalla inicial.
- `PHYS-02-canta-search.png` y `PHYS-03-origin-precalc.png` — resultado seleccionado, sin cálculo automático y origen GPS mostrado antes de `Ver ruta`.
- `PHYS-04-route-result.png` y `PHYS-05-poi-list.png` — geometría, resumen y cinco POIs.
- `PHYS-06-poi-preview.png` y `PHYS-07-poi-detail.png` — Preview y Detail.
- `PHYS-08-map-after-detail.png` — retorno al mapa conservando ruta y resumen.
- `PHYS-10-filtered-list.png` y `PHYS-14-filter-excluded.png` — filtro aplicado y lista reducida.
- `PHYS-12-manual-origin-precalc.png` y `PHYS-13-manual-route.png` — prioridad manual y cálculo.
- `PHYS-15-changed-destination-route.png` y `PHYS-15-changed-destination-pois.png` — cambio de destino, nueva geometría y POIs.
- `PHYS-16-final-route-map.png` — mapa final con ruta, resumen, controles y atribución visibles.

### Resultado de la sesión

```ini
UI2_ROUTE_UX_001_PHYSICAL = PARTIAL
UI2_ROUTE_UX_001_H1 = PASS
UI2_ROUTE_UX_001_H2 = PASS
UI2_ROUTE_UX_001_H3 = PASS
UI2_ROUTE_UX_001_MERGE = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

Pendientes: PHYS-06 con cambio manual de permiso por el propietario y recorrido de error recuperable. Esta evidencia no constituye validación en carretera, autorización de P12.5, cierre maestro UI-2 ni Production Readiness.
