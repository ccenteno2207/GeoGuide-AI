# UI-2.1 — Evidencia visual local

**Tipo de las 23 capturas:** `FLUTTER_RENDERER_TEST`.

Producidas por `mobile/test/features/discovery/ui2_experience_test.dart` mediante
Flutter Widget Test, `RepaintBoundary.toImage`, viewport lógico indicado en el nombre
y DPR 1. La fuente Roboto y Material Icons se cargan del caché de fuentes del SDK
exclusivamente en la suite UI-2 y la captura. Las medidas de geometría utilizan
esas fuentes reales, también cuando no se guardan PNG. No se añaden fuentes ni
fixtures al bundle de producto.

```powershell
flutter test --no-pub test/features/discovery/ui2_experience_test.dart --dart-define=UI2_CAPTURE=true --reporter expanded
```

Los nombres, descripciones, atribuciones y coordenadas del fixture son sintéticos
para probar presentación y geometría; no son una respuesta de backend desplegado,
una fotografía de POI ni muestras GPS. La cartografía HTTP queda bloqueada por el
binding de pruebas (400): la superficie gris no demuestra disponibilidad de tiles.
El diagnóstico de voz visible en debug es el control preexistente, no una activación
de voz. No hay micrófono ni interacción física.

## Inventario

| Captura | Escenario |
| --- | --- |
| [map-route-360x800](FLUTTER_RENDERER_TEST-map-route-360x800.png) | Mapa, trazado y controles existentes; snapshot sintético cached. |
| [local-filter-match-360x800](FLUTTER_RENDERER_TEST-local-filter-match-360x800.png) | Coincidencia por nombre normalizado; subconjunto de resultados, no búsqueda global. |
| [local-filter-empty-360x800](FLUTTER_RENDERER_TEST-local-filter-empty-360x800.png) | Texto exacto de cero coincidencias. Los extremos de ruta permanecen. |
| [preview-360x800](FLUTTER_RENDERER_TEST-preview-360x800.png) | Vista previa y elección explícita existente; placeholder. |
| [detail-360x800](FLUTTER_RENDERER_TEST-detail-360x800.png) | Descripción y procedencia sintéticas; placeholder y retorno. |
| [offline-360x800](FLUTTER_RENDERER_TEST-offline-360x800.png) | Estado cached existente, desplazado hasta disponibilidad y acciones. |
| [error-360x800](FLUTTER_RENDERER_TEST-error-360x800.png) | Fixture explícito de presentación de error; no incidente real de servidor. |
| [list-360x640-text1.0](FLUTTER_RENDERER_TEST-list-360x640-text1.0.png) | Lista, nombre largo, escala 1.0. |
| [list-360x640-text2.0](FLUTTER_RENDERER_TEST-list-360x640-text2.0.png) | Lista, nombre largo, escala 2.0. |
| [list-360x800-text1.0](FLUTTER_RENDERER_TEST-list-360x800-text1.0.png) | Lista, nombre largo, escala 1.0. |
| [list-360x800-text2.0](FLUTTER_RENDERER_TEST-list-360x800-text2.0.png) | Lista, nombre largo, escala 2.0. |
| [list-640x360-text1.0](FLUTTER_RENDERER_TEST-list-640x360-text1.0.png) | Lista horizontal y mapa con espacio reservado. |
| [list-640x360-text2.0](FLUTTER_RENDERER_TEST-list-640x360-text2.0.png) | Lista horizontal, escala 2.0. |
| [list-800x360-text1.0](FLUTTER_RENDERER_TEST-list-800x360-text1.0.png) | Lista horizontal y mapa con espacio reservado. |
| [list-800x360-text2.0](FLUTTER_RENDERER_TEST-list-800x360-text2.0.png) | Lista horizontal, escala 2.0. |

La lista está desplazada hasta el nombre largo para verificar su lectura; por eso
algunas capturas no incluyen el buscador o la miniatura situados más arriba. El cierre
permanece fijo y el resto del contenido es desplazable. El texto 2.0 ocupa todo el
ancho de tarjeta debajo del placeholder estable de 96×72 dp. Las fichas reservan un
área 16:9 de ancho máximo 320 dp (altura máxima 180 dp).

La revisión visual detectó una columna estrecha con texto 2.0, solapamiento del
trazado por el panel horizontal y la cinta roja "DEBUG" de Flutter en las capturas.
Se corrigieron: distribución vertical de tarjeta a escala grande, mapa/lista en espacios
separados, atribución fuera de la cartografía con texto escalable y ocultamiento del
banner de depuración en `MaterialApp`. Se regeneraron y revisaron las 15 capturas
posteriores; las 8 imágenes comparativas conservan el estado original del baseline.
Los tests comprueban no solapamiento y geometría del fixture dentro del mapa, sin
añadir movimientos de cámara.

## Comparación contractual AC-01

Baseline inmutable: `597950decddecef38dd4f6c44595b807a4087f14`.
`mobile/tool/capture_ui2_baseline.py` exporta únicamente `mobile/` desde Git a un
nuevo directorio ignorado de `mobile/build/`, sin cambiar un checkout. Copia
literalmente la función `syntheticSnapshot` de la suite actual y usa `long: true`,
el mismo reloj, escala 1.0, DPR 1, SDK y fuentes. Verifica que el lockfile exportado
permanezca idéntico después de `pub get`. Los hashes de función y archivos figuran
en los logs y en el inventario SHA-256 de validación.

```powershell
python tool/capture_ui2_baseline.py
```

| Viewport / estado inicial | Antes (baseline) | Después (UI-2) |
| --- | --- | --- |
| 360x640 / map | [Antes](FLUTTER_RENDERER_TEST-comparison-before-map-360x640.png) | [Después](FLUTTER_RENDERER_TEST-comparison-after-map-360x640.png) |
| 360x640 / list | [Antes](FLUTTER_RENDERER_TEST-comparison-before-list-360x640.png) | [Después](FLUTTER_RENDERER_TEST-comparison-after-list-360x640.png) |
| 360x800 / map | [Antes](FLUTTER_RENDERER_TEST-comparison-before-map-360x800.png) | [Después](FLUTTER_RENDERER_TEST-comparison-after-map-360x800.png) |
| 360x800 / list | [Antes](FLUTTER_RENDERER_TEST-comparison-before-list-360x800.png) | [Después](FLUTTER_RENDERER_TEST-comparison-after-list-360x800.png) |

Se revisaron las 23 imágenes. La comparación muestra el trazado antes oculto por
la lista y ahora visible en su área reservada, el filtro local real y las tarjetas
con datos/placeholder. La cámara conserva centro y zoom; cambia el área disponible
de dibujo. El escenario de mapa cerrado conserva las acciones existentes. Los 8 PNG
comparativos se suman a los 15 escenarios de la tabla anterior.

## Registro de medios

| Recurso | Origen/autor | Derechos/uso | Estado |
| --- | --- | --- | --- |
| Fixture Dart de UI-2 | Creado para esta ejecución, 2026-10-18; texto y coordenadas de prueba | Pruebas internas, sin imagen externa ni afirmación factual de producto | `TEST_ONLY`, excluido del APK |
| Placeholder | Widget Flutter con icono Material ya disponible | Presentación neutral; no fotografía ni recurso editorial | Sin pipeline de media |
| PNG de esta carpeta | Renderer Flutter a partir del fixture y fuentes del SDK | Evidencia técnica local; no asset de aplicación | `FLUTTER_RENDERER_TEST` |

Los hashes de PNG y del fixture se registran en la evidencia de validación. No se
incorporan fotos, URLs de imagen, assets `RIGHTS_NOT_VERIFIED`, API de media ni cambios
al snapshot. Android físico, TalkBack, tiles reales y GPS real: `NOT_EXECUTED`.
