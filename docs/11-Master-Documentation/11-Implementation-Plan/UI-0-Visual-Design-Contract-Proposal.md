# UI-0 — Contrato visual propuesto: Rutea Explorer + CEFI Smart

Fecha: 2026-10-15. Baseline: `7edc494ba9bf578da07deec25ace1d625ecd5a5b`.

```ini
UI_0_VISUAL_DESIGN_CONTRACT = PROPOSED
PRODUCT_SCOPE_CONFIRMATION = APPROVED_A_B_C
VISUAL_SCOPE = APPROVED_FOR_VISUAL_CONTRACT
IMPLEMENTATION_CONTRACT_FREEZE = NOT_GRANTED
UI_1_TO_UI_5_IMPLEMENTATION = NOT_AUTHORIZED
FUNCTIONAL_DRIVING_PACKAGE = SEPARATE_NOT_AUTHORIZED
```

## Autoridad y dirección

Propuesta reconciliada con decisiones A/B/C aprobadas en la [matriz de compatibilidad](UI-0-Rutea-Compatibility-Matrix.md), con procedencia en el [inventario](UI-0-Governance-and-Rutea-Inventory.md). No copia ni adopta automáticamente los originales. No modifica arquitectura ni contratos funcionales congelados.

Rutea es candidato comercial público; GeoGuide AI conserva el nombre vigente y sus identificadores, sin renombrado de paquetes, applicationId, endpoints o infraestructura. CEFI conserva su nombre e identidad permanente. Mapa protagonista, lectura clara, tarjetas de viaje, navegación visual consistente y esfera violeta con ondas originales. No copiar interfaces o assets propietarios.

Búsqueda de destinos accesible y «Habla con CEFI» se conservan como dirección conceptual futura. El candidato operativo mantiene selección por mapa y «Avisos de CEFI», conforme a DECISION A aprobada por el responsable del proyecto. No agregar un buscador simulado, micrófono, STT o conversación falsa. La separación conceptual/operativa está confirmada; el freeze y la autorización de implementación siguen siendo gates posteriores independientes.

## Invariantes obligatorios de la propuesta

- Material 3, flutter_map y dependencias instaladas; extraer presentación sin migrar estado, router ni servicios. Sin lógica GIS/GPS/voz en componentes visuales.
- Preservar ruta/discovery, orden/backend, categorías, razón factual, fuentes opcionales y distancia al trazado. No confundirla con desvío, ETA ni distancia al viajero.
- Mantener caché P9, errores de seguridad, TTL, captura consentida, borrado y reintento manual. No inferir conectividad a partir de tiles ni añadir polling.
- Preservar I01: abrir/listar no elige; elegir/quitar explícitos; selección ligada al snapshot actual; respuesta nueva invalida el borrador; freeze de chosenIds al iniciar B1; edición/caché/discovery bloqueados durante B1. UI recreada no inventa IDs elegidos. Stop/caducidad no restauran selección antigua.
- Preservar permisos, servicios nativos, ownership, lifecycle R01, validadores y codecs. No alterar políticas C1/C2, consentimiento, foco, cancelación o tiempos.
- Driving conserva su árbol de interacción y salida; sin nuevos controles, gestos, rutas indirectas, navegación secundaria, selección I01 ni CEFI táctil. Cambiar entrada, frescura, callbacks, cámara o retorno es paquete funcional separado; no se cuela en UI-4.
- C2.1 sigue debug y fuera de Driving. Las ondas decorativas no simulan escucha ni reproducción; consentimiento no es reproducción. Animación discreta opcional y reduced motion.
- No persistir nuevos estados/GPS ni introducir telemetría, backend, dependencia, permiso, fuente descargada, proveedor de tiles, fotografía o valoración ficticia.

## Tokens y accesibilidad propuestos

| Token | Valor inicial | Uso |
|---|---|---|
| Primary | #006D63 | Acción principal con texto blanco |
| CEFI | #7138D8 | Esfera/identidad CEFI, sin significado de escucha |
| Accent | #FFAE49 | Texto oscuro, no blanco |
| Surface | #F6F9F8 | Superficies opacas legibles sobre mapa |
| Text Primary | #203632 | Texto principal |
| Route | #1677E8 | Trazado con contraste/halo verificado |
| Spacing / radios | 8 dp, ajustes 4 dp; 16–24 dp | Composición consistente |
| Targets | >=48×48 dp | Controles compactos 48–56 dp |

Tema centralizado en `GeoGuideTheme`; tipografía Material ya disponible, sin nueva fuente obligatoria. Contraste contractual heredado P9: 4.5:1 texto normal y 3:1 texto grande/elementos esenciales. Comprobar colores finales, incluidos gradientes y disabled; los tokens no bastan para demostrar contraste sobre cartografía.

TextScaler 1.0 y 2.0, 360×640 y 360×800 logical px, paisaje, nombres/descripciones largos, SafeArea y TalkBack. Sin recortes de acciones ni ocultar errores reduciendo fuente. Lista alternativa al mapa, foco determinista, estados anunciados sin depender solo del color. Capturas sintéticas sin coordenadas personales ni datos privados.

## UI_0_IMPLEMENTATION_PACKAGES

Todos PROPOSED / NOT_AUTHORIZED. Secuencia UI-1 → UI-2 → UI-3 → UI-4 → UI-5, con gates indicados. La clasificación visual no elimina la necesidad de validar efectos de refactorización.

### UI-1 — Design System & Exploration Shell

- Alcance/pantallas: tema, tokens, cabecera y shell de exploración, sin dependencia de nombre permanente; mapa dominante.
- Componentes: `GeoGuideTheme`, `GeoGuideApp`, `BaseMapPage`; componentes de presentación nuevos solo como extracción, no servicios nuevos.
- Dependencias: decisiones A/B/C ya aprobadas; freeze y autorización de implementación posteriores. DR no es requisito de UI-1 a UI-3.
- Exclusiones: rutas/estado de dominio, permisos, productores, comportamiento Driving. Aislar aplicación del tema de exploración para no modificar Driving antes de UI-4.
- Riesgos: tema global cambia otras pantallas; remontaje destruye estado o duplica callbacks.
- Aceptación UI-V01: mismos callbacks y controles disponibles, targets/contraste y texto 2.0 conformes; sin cambios de contratos.
- Pruebas: tema/layout, `widget_test.dart`, `offline_ui_test.dart`, regresión GPS/B1/R01.
- Evidencia visual: antes/después de exploración inicial, ubicación pendiente/denegada y panel con texto grande, misma dimensión y fixture.

### UI-2 — Map, Search & POI Experience

- Alcance/pantallas: presentación mapa/ruta/lista, preview/detalle/filtros y selección I01. Search conserva nombre conceptual del paquete; no incluye geocodificación ni control simulado en el candidato actual.
- Componentes: `BaseMapPage`, `PoiPreviewSheet.selectionControl`, `PoiDetailSheet`, `DiscoveryFilterSheet`, `OfflineCacheSheet`, `poi_presentation.dart`; reutilizar `SelectedPoiDraft` sin modificar su semántica.
- Dependencias: UI-1, P8/P9/I01; datos reales disponibles.
- Exclusiones: ranking local, filtros sobre top-N como resultado completo, favoritos, codec, API, fotos/ratings, nuevas categorías y búsqueda operativa.
- Riesgos: perder selected/frozen/unknown, selección implícita al abrir tarjeta, reactivar filtros/caché durante B1, perder invalidación por instancia de snapshot.
- Aceptación UI-V02: nombre/categoría/distancia legibles; cierre al mapa; seleccionar explícitamente y freeze inalterados; cancelar filtro no aplica; TTL/errores intactos.
- Pruebas: sheets/controllers/mappers/cache; `i01_selection_test.dart`, `i01_widget_test.dart`, `i01_worker_test.dart`, `poi_list_close_test.dart` y regresiones B1/R01. Comprobar efectos, no solo labels.
- Evidencia visual: mapa/lista, preview elegido/no elegido, selección bloqueada/desconocida durante B1, detalle largo/sin fuente, filtros y vacío/error/copia offline. Sin afirmar que elegir garantiza aviso.

### UI-3 — CEFI Visual Integration

- Alcance/pantallas: control compacto de avisos en exploración, esfera violeta/ondas y etiqueta operativa propuesta «Avisos de CEFI».
- Componentes: control que delega al consentimiento actual, `_toggleVoiceConsent`, `RouteSessionClient`; diagnóstico existente permanece separado.
- Dependencias: UI-1/2 y separación conceptual/operativa aprobada por DECISION A. «Habla con CEFI» exige capacidad futura contratada separadamente.
- Exclusiones: STT/micrófono, TTS nuevo, permisos, cambios de foco/cola/cooldown, estados de escucha ficticios, control en Driving.
- Riesgos: animación implica escucha o habla inexistente; nueva presentación duplica consentimiento.
- Aceptación UI-V03: un control, misma activación/revocación y condiciones de disponibilidad; reduced motion; no iniciación automática por mostrarlo.
- Pruebas: `b1_widget_test.dart`, `c2_voice_test.dart`, `cefi_delivery_test.dart`, `voice_diagnostic_test.dart`; labels y callbacks.
- Evidencia visual: avisos desactivados/activados/bloqueados, consentimiento cancelar/aceptar y vista Driving sin el control. Screenshots no acreditan audio real.

### UI-4 — Driving Visual Refinement

- Alcance/pantallas: tipografía, contraste, espacio, superficie y atribución estática no interactiva de la vista Driving; salida explícita accesible.
- Componentes: `_buildDrivingView` o extracción equivalente; conservar árbol restringido y callbacks actuales.
- Dependencias: UI-1–3 y gate contractual específico: revisión humana de los hallazgos DR y de la contradicción P9/GPS antes de ejecutar UI-4. No se interpreta como aprobación del original correctivo.
- Exclusiones: entrada/guards, productores, frescura, cámara/fit, TTS, selección, retorno, nuevos controles. Esos cambios requieren paquete funcional separado y aceptación propia.
- Riesgos: HIGH si se cambia interacción al simplificar; contradicción P9/GPS conocida no resuelta por estilo. Si el objetivo requiere tocar esos límites, STOP.
- Aceptación UI-V04: ninguna acción/gesto/solicitud adicional; salida y Back conservados; atribución accesible sin enlace; texto 2.0 sin tapar salida. No declarar conformidad funcional global por un cambio cosmético.
- Pruebas: `offline_ui_test.dart`, árbol semántico, callbacks y regresiones B1/R01/I01/C2; casos nuevos de atribución/layout solo tras autorización.
- Evidencia visual: normal/copia/no disponible, escala 2.0 y paisaje, atribución y salida; revisión estacionaria autorizada, nunca conducción.

### UI-5 — Visual Regression & Validation

- Alcance: validar composición final, estados y accesibilidad; documentar versión/commit/APK y límites.
- Componentes/pantallas: todas las superficies afectadas, sin añadir funcionalidad para hacer pasar pruebas.
- Dependencias: paquetes anteriores aceptados en su alcance y ausencia de gates funcionales sin disposición.
- Exclusiones: backend/infra, P12.5, calibración GPS, certificación vial y Production Readiness.
- Riesgos: goldens ocultan defectos de interacción; extrapolar mocks o APK anterior a validación física nueva.
- Aceptación UI-V05: format/analyze/tests/diff PASS; revisión visual comparativa y TalkBack estacionario autorizado del APK exacto, resultados diferenciados. I01 físico previo continúa NOT_EXECUTED salvo un encargo independiente que lo valide.
- Pruebas: `dart format .`, `flutter analyze`, `flutter test`, build/validación de iconos pertinentes y `git diff --check`; no se ejecutan durante UI-0 documental.
- Evidencia visual: matriz antes/después por superficie, tamaño, escala y estado con fixtures reproducibles; inventario de incidencias, hash de artefacto y regresiones resueltas. Sin señal/candidato real, registrar limitación, nunca fabricar PASS.

## Gate y trazabilidad funcional

Los tests I01 se suman a los ya definidos en los originales, no los reemplazan. El codec efímero de sesión no se confunde con SnapshotCodec persistente. Los estados C1/C2 no equivalen a conversación. P9-AC-06/07/08 y la cláusula GPS ambigua requieren disposición para cualquier ampliación funcional Driving; este candidato no los sustituye.

Estado inalterado: P12 IN_PROGRESS/45%, P12.5 NOT_AUTHORIZED, P11-BACKUP-01 OPEN_DEFERRED, V01 STATIONARY_PARTIAL, I01 physical validation NOT_EXECUTED. Aprobación de documentación no es aprobación de implementación.

DECISION B/C dispone la contradicción histórica como asunto contractual independiente y DR como NOT_AUTHORIZED. UI-1 a UI-3 no modifican Driving ni requieren implementar DR. UI-4 no inicia sin su gate específico. UI-5 no transforma simulaciones en validación física. La integración documental está autorizada tras controles satisfactorios; no congela contratos funcionales ni autoriza la siguiente etapa. El cierre formal UI-0 requiere revisión maestra posterior al merge y a la evidencia post-merge.
