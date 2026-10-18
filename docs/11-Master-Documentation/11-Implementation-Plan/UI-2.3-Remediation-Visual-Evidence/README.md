# UI-2.3 — Capturas tras la remediación visual

**Tipo:** `FLUTTER_RENDERER_TEST_UI23R`. Generadas por Flutter Widget Test con `RepaintBoundary.toImage`, DPR 1, fuentes del SDK y fixtures sintéticos. El renderer bloquea las teselas HTTP; el fondo gris no representa el mapa cargado en un dispositivo. Estas capturas no prueban el APK ni el HONOR.

Comando: `flutter test --no-pub --dart-define=UI23_REMEDIATION_CAPTURE=true` desde `mobile`.

| Escenario | Antes UI-2.3 | Después de remediación |
| --- | --- | --- |
| Mapa, ruta y POI, 360×800 | [UI23](../UI-2.3-Visual-Evidence/FLUTTER_RENDERER_TEST_UI23-map-route-360x800.png) | [UI23R](FLUTTER_RENDERER_TEST_UI23R-map-route-360x800.png) |
| Mapa, 360×640 | [UI23](../UI-2.3-Visual-Evidence/FLUTTER_RENDERER_TEST_UI23-comparison-after-map-360x640.png) | [UI23R](FLUTTER_RENDERER_TEST_UI23R-comparison-after-map-360x640.png) |
| Lista, 360×800 | [UI23](../UI-2.3-Visual-Evidence/FLUTTER_RENDERER_TEST_UI23-comparison-after-list-360x800.png) | [UI23R](FLUTTER_RENDERER_TEST_UI23R-comparison-after-list-360x800.png) |
| Lista, 360×640 | [UI23](../UI-2.3-Visual-Evidence/FLUTTER_RENDERER_TEST_UI23-comparison-after-list-360x640.png) | [UI23R](FLUTTER_RENDERER_TEST_UI23R-comparison-after-list-360x640.png) |
| Filtro local con/sin coincidencia | [UI23](../UI-2.3-Visual-Evidence/FLUTTER_RENDERER_TEST_UI23-local-filter-match-360x800.png) | [Coincidencia](FLUTTER_RENDERER_TEST_UI23R-local-filter-match-360x800.png) · [Sin coincidencia](FLUTTER_RENDERER_TEST_UI23R-local-filter-empty-360x800.png) |
| Preview y Detail | [UI23 Preview](../UI-2.3-Visual-Evidence/FLUTTER_RENDERER_TEST_UI23-preview-360x800.png) | [Preview](FLUTTER_RENDERER_TEST_UI23R-preview-360x800.png) · [Detail](FLUTTER_RENDERER_TEST_UI23R-detail-360x800.png) |
| Offline y error | [UI23 offline](../UI-2.3-Visual-Evidence/FLUTTER_RENDERER_TEST_UI23-offline-360x800.png) | [Offline](FLUTTER_RENDERER_TEST_UI23R-offline-360x800.png) · [Error](FLUTTER_RENDERER_TEST_UI23R-error-360x800.png) |

Matriz de lista con nombre y descripción largos en [360×640](FLUTTER_RENDERER_TEST_UI23R-list-360x640-text1.0.png), [360×640 texto 2.0](FLUTTER_RENDERER_TEST_UI23R-list-360x640-text2.0.png), [360×800](FLUTTER_RENDERER_TEST_UI23R-list-360x800-text1.0.png), [360×800 texto 2.0](FLUTTER_RENDERER_TEST_UI23R-list-360x800-text2.0.png), [640×360](FLUTTER_RENDERER_TEST_UI23R-list-640x360-text1.0.png), [640×360 texto 2.0](FLUTTER_RENDERER_TEST_UI23R-list-640x360-text2.0.png), [800×360](FLUTTER_RENDERER_TEST_UI23R-list-800x360-text1.0.png) y [800×360 texto 2.0](FLUTTER_RENDERER_TEST_UI23R-list-800x360-text2.0.png).

Las 19 capturas UI23 originales permanecen sin cambios. Comparar composición, jerarquía y legibilidad; ninguna imagen certifica tiles de red, validación física, lector de pantalla ni respuesta del backend.
