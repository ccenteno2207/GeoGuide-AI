# UI-2.3 — Evidencia de renderizado

**Tipo:** `FLUTTER_RENDERER_TEST_UI23`. Las imágenes se capturaron con Flutter Widget Test, `RepaintBoundary.toImage`, DPR 1 y fixtures sintéticos; no son capturas del APK ni del HONOR. La cartografía HTTP queda bloqueada por Flutter Test (respuestas 400), por lo que el fondo gris no demuestra disponibilidad o fallo del servidor de mapas.

Comando de generación:

```powershell
flutter test --no-pub --reporter expanded --dart-define=UI23_CAPTURE=true
```

| Archivo | Escenario |
| --- | --- |
| [Mapa y ruta](FLUTTER_RENDERER_TEST_UI23-map-route-360x800.png) | Explorer, controles flotantes, ruta sintética y atribución. |
| [Lista 360×640, escala 1](FLUTTER_RENDERER_TEST_UI23-list-360x640-text1.0.png) | Lista vertical compacta. |
| [Lista 360×640, escala 2](FLUTTER_RENDERER_TEST_UI23-list-360x640-text2.0.png) | Lista y texto ampliado. |
| [Lista 360×800, escala 1](FLUTTER_RENDERER_TEST_UI23-list-360x800-text1.0.png) | Lista vertical. |
| [Lista 360×800, escala 2](FLUTTER_RENDERER_TEST_UI23-list-360x800-text2.0.png) | Lista vertical y texto ampliado. |
| [Lista 640×360, escala 1](FLUTTER_RENDERER_TEST_UI23-list-640x360-text1.0.png) | Disposición horizontal. |
| [Lista 640×360, escala 2](FLUTTER_RENDERER_TEST_UI23-list-640x360-text2.0.png) | Disposición horizontal con texto ampliado. |
| [Lista 800×360, escala 1](FLUTTER_RENDERER_TEST_UI23-list-800x360-text1.0.png) | Disposición horizontal amplia. |
| [Lista 800×360, escala 2](FLUTTER_RENDERER_TEST_UI23-list-800x360-text2.0.png) | Disposición horizontal amplia con texto ampliado. |
| [Filtro con coincidencia](FLUTTER_RENDERER_TEST_UI23-local-filter-match-360x800.png) | Filtro del conjunto ya cargado; fixture sintético. |
| [Filtro sin coincidencia](FLUTTER_RENDERER_TEST_UI23-local-filter-empty-360x800.png) | Estado vacío del filtro local. |
| [Preview](FLUTTER_RENDERER_TEST_UI23-preview-360x800.png) | Vista previa con placeholder. |
| [Detail](FLUTTER_RENDERER_TEST_UI23-detail-360x800.png) | Detalle con placeholder compacto. |
| [Offline](FLUTTER_RENDERER_TEST_UI23-offline-360x800.png) | Estado offline sintético. |
| [Error](FLUTTER_RENDERER_TEST_UI23-error-360x800.png) | Estado de error sintético. |
| [Comparación mapa 360×640](FLUTTER_RENDERER_TEST_UI23-comparison-after-map-360x640.png) | Estado actualizado; comparar con [UI-2 baseline](../UI-2-Visual-Evidence/FLUTTER_RENDERER_TEST-comparison-before-map-360x640.png). |
| [Comparación lista 360×640](FLUTTER_RENDERER_TEST_UI23-comparison-after-list-360x640.png) | Estado actualizado; comparar con [UI-2 baseline](../UI-2-Visual-Evidence/FLUTTER_RENDERER_TEST-comparison-before-list-360x640.png). |
| [Comparación mapa 360×800](FLUTTER_RENDERER_TEST_UI23-comparison-after-map-360x800.png) | Estado actualizado; comparar con [UI-2 baseline](../UI-2-Visual-Evidence/FLUTTER_RENDERER_TEST-comparison-before-map-360x800.png). |
| [Comparación lista 360×800](FLUTTER_RENDERER_TEST_UI23-comparison-after-list-360x800.png) | Estado actualizado; comparar con [UI-2 baseline](../UI-2-Visual-Evidence/FLUTTER_RENDERER_TEST-comparison-before-list-360x800.png). |

Los PNG UI-2 originales de `comparison-before-*` se mantienen intactos. Las comparaciones muestran composición del renderer: no verifican tráfico HTTP, APK, servicios desplegados ni dispositivo físico. Ver [matriz de cambios, validación e inventario fotográfico](../UI-2.3-Execution-and-Photo-Inventory-Evidence.md).
