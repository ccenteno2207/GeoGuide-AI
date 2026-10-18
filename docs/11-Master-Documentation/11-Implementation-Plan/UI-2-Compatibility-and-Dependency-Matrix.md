# UI-2 — Matriz de compatibilidad y dependencias

**Estado:** `APPROVED_FROZEN` como anexo de compatibilidad UI-2. U2-D01–D06 están aprobadas; baseline técnico `726cb989a902110aeeab314e5747ce684e201748`. Las restricciones de esta matriz forman parte del contrato congelado, sin modificar P8/P9 ni autorizar backend.

| Área | Estado actual / autoridad | Propuesta UI-2 | Riesgo principal | Gate/decisión |
|---|---|---|---|---|
| UI-1 | Aprobada, integrada y cerrada documentalmente; validación física/TalkBack pendiente. Tema aplicado al shell de exploración, rama Driving separada. | Reutilizar tema, jerarquía, cabecera y shell; evidenciar visualmente. | Regresión por mover controles o cambiar límites de mapa. | Compatible si UI2-AC-01/12/13 pasan; no reabrir UI-1. |
| P8 | `APPROVED_FROZEN`; búsqueda, geocodificación y media fuera de P8. | UI2 separada agrega filtro textual local aprobado sobre snapshot; no cambia P8. | Confundir filtro de resultados existentes con búsqueda global. | D01 fija etiquetas/vacío y límites; expansión/API requiere gate nuevo. |
| P9 | Cerrada; snapshot coherente, TTL 24 h, 5 MiB, consentimiento/borrado y límites Driving. API nueva y Search/proveedor externo son gates. | Leer snapshot actual y estado de disponibilidad; no cambiar schema/codec/cache. | Desacoplar resultados de query, revivir expirado o añadir referencias temporales multimedia. | P9 inmutable; diff futuro requiere auditoría de no regresión y gate si altera contrato. |
| Backend Route Discovery | `POST /api/v1/routes/discover`, route-first, categorías/corredor/límite; backend decide ranking y datos. | Reusar API actual sin cambios. El filtro local aprobado deriva resultados visibles después de recibir respuesta. | Etiquetar parcial como cobertura global, cambiar query del snapshot o alterar ranking. | API/OpenAPI/backend fuera de UI2. Endpoint nuevo requiere contrato independiente. |
| DTO POI | Incluye id, nombre, categoría, ubicación, distancia al trazado, progreso, score/razones, descripción y source fields; no media. | Mostrar solo campos aptos actuales. | Mostrar score/código/routeProgress; inventar destino textual o URL de foto. | Prohibido UI2-AC-04/05; cualquier DTO nuevo requiere backend gate. |
| Categorías P3 | 15 en taxonomía; Discovery móvil admite 10. Servicios FUEL/HEALTH/FOOD/LODGING y OTHER no son filtros actuales de exploración. | Reutilizar los 10 códigos Discovery exactos. | Mezclar POIs turísticos con servicios de viaje o agregar categoría sin datos. | Sin ampliación de taxonomía ni progreso. |
| I01 | Selección explícita en `SelectedPoiDraft`, ligada a identidad del snapshot; freeze de `chosenIds` al iniciar B1. | Conservar interacción explícita y estado. Tarjeta/detalle solo navegan. | Selección implícita, ID huérfano, cambio de snapshot conservando selección vieja. | No cambiar lógica; cobertura obligatoria selección/sustitución/freeze. |
| GPS / B1 / R01 | Ownership de ubicación y session worker, ciclo de vida y cancelación definidos en evidencia/contratos. | Ningún cambio, petición o acceso nuevo desde UI2. | Reentrancia/callback fuera de fecha, pedir permiso o mover cámara. | Cambio funcional requiere paquete/contrato separado. |
| Driving | Vista reducida P9 estática, raíz/guards y salida explícita. | Nada de búsqueda, lista, filtros o gesto; query no se conserva al entrar ni se encola al salir. | Acción diferida inesperada, superficie de exploración accesible por overlay/back. | No tocar árbol ni rutas; tests de entradas existentes. |
| CEFI / C1/C2 | Avisos TTS con consentimiento/reglas existentes; no STT/chat. | Mantener avisos actuales; UI3 lleva integración visual acordada. | Activar audio/consentimiento por foco o cambio UI. | No modificar TTS, controles ni callbacks. |
| POI media | Sin campo DTO/modelo; MinIO descrito como destino privado arquitectónico, sin integración POI-media demostrada. | Tarjeta/detalle reserva miniatura; placeholder neutral por defecto. Fixture sintético solo test; foto real de prueba solo con derechos verificados para ese uso controlado. | Licencias, hotlinking, URL firmada efímera, offline leak; TEST_ONLY en release. | Ninguna foto real de producto, endpoint, SDK o almacenamiento en UI2; excluir TEST_ONLY de release. |
| ADMIN-0 | Discovery/propuesta no aprobada. | No es prerequisito para snapshot/placeholders ni fixtures test. Puede gobernar pipeline futuro de contenido. | Bloquear UI por dependencia hipotética o mezclar portal/admin API. | ADMIN no autorizado; gate y contrato independientes. |
| Búsqueda de localidad | No existe API/servicio en las fuentes revisadas. Route input usa mapa. | Excluida; posibilidad futura solo después de decisión de producto y provider/data review. | Geocoding asumido, transferencia de ubicación/query, cobertura/licencia incierta. | Fuera U2-D01; gate humano/arquitectura/API/privacidad. |
| Accesibilidad | UI1 lector pendiente; objetivo UX WCAG AA donde aplique. | Lista alternativa, semantics, targets ≥48×48 dp, estados no solo color, escalas 1.0/2.0 y viewports 360×640/360×800/640×360/800×360. Contraste de superficies/texto independiente de tiles. | Widget/renderer confundido con TalkBack, dispositivo o tiles reales. | Automatización completa requerida y evidencia física/TalkBack/cartografía separada; no ejecutado queda pendiente. |
| OpenStreetMap/tiles | Flutter map y atribución existente; tiles/red son otra dependencia. | Mantener provider y atribución visibles según contrato vigente. | Tap/overlay oculta atribución o altera provider. | No cambio de proveedor ni política de tiles. |
| Dependencias/permisos | Flutter y flutter_map existentes; UI1 diff no alteró lock/permisos. | Ninguna dependencia, permiso o nativo nuevo. | Cargar imágenes/servicio externo introduce plugin/red/permisos y exposición. | Fuera de alcance; gate previo y actualización contratos si se considera. |

## Límites de origen/destino

El planificador por mapa y `POST /api/v1/routes/plan` siguen siendo fuente actual de ruta. Los ejemplos Canta/Ica de búsqueda de lugares no se resuelven desde texto con API existente. `distanceToRouteMeters` solo describe proximidad lateral a geometría de ruta. UI2 no puede convertir coordenadas a nombres ni construir un falso resultado de geocodificación.

## Reglas de integración sugeridas

Para una implementación futura, mantener cambios de presentación en el shell de exploración y sus pruebas. El filtro local es efímero y opera sobre snapshot vigente; al volver de Preview/Detail mantiene query en esa sesión y al reemplazar/vencer el snapshot o salir de Exploración la limpia. Los cambios que toquen DTO, API/OpenAPI, base de datos, snapshot/codec/TTL, permisos, GPS/Driving/CEFI, media pipeline o dependencia ADMIN salen de esta matriz y exigen scope/autorización propios. La regresión mínima incluye `exploration_shell_test`, POI preview/detail/filter/list, offline cache/UI, I01 selection/widget/worker, B1, R01 y CEFI delivery; suites completas se ejecutarán solo bajo contrato aprobado.

```ini
UI_2_COMPATIBILITY_MATRIX = APPROVED_FROZEN
UI_2_CONTRACT = APPROVED_FROZEN
UI_2_CONTRACT_FREEZE = RECORDED
UI_2_IMPLEMENTATION = NOT_AUTHORIZED
BACKEND_API_CHANGE_UI_2 = NOT_PROPOSED
SNAPSHOT_SCHEMA_CHANGE_UI_2 = NOT_PROPOSED
MEDIA_BACKEND_DEPENDENCY_UI_2 = NOT_REQUIRED_FOR_PLACEHOLDER_OR_TEST_FIXTURES
ADMIN_DEPENDENCY_UI_2 = NONE
DRIVING_GPS_CEFI_CHANGE_UI_2 = PROHIBITED
```
