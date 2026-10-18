# UI-2.3.1 — Evidencia de Flutter renderer

Capturas de Widget Test con fuentes Roboto/MaterialIcons del SDK, snapshot
`TEST_ONLY`, dos POI sintéticos y tiles HTTP bloqueados por el binding. No son
capturas del HONOR, cartografía real ni validación de TalkBack.

La franja inferior reservada se simula mediante `viewPadding` y `padding` del
test; el renderer no dibuja botones o gestos Android.

| Escenario | Antes | Después |
| --- | --- | --- |
| 360×800, texto 1.0, inset inferior 48 dp | [Baseline](FLUTTER_RENDERER_TEST_UI231-before-360x800-bottom48.png) | [Corrección](FLUTTER_RENDERER_TEST_UI231-after-360x800-bottom48.png) |
| 800×360, texto 1.0, inset inferior 24 dp e insets laterales 24 dp | No capturado | [Corrección](FLUTTER_RENDERER_TEST_UI231-after-800x360-bottom24.png) |

La comparación equivalente 360×800 muestra que la atribución pasa de la región
reservada al área útil. El panel conserva las cuatro acciones y su resumen, por
encima de la atribución. La imagen horizontal comprueba una composición adicional;
las aserciones de layout cubren la matriz completa.

Generación desde `mobile/`:

```powershell
flutter test --no-pub test/features/map/ui231_system_insets_test.dart --dart-define=UI231_CAPTURE_LABEL=after
```

`before` se generó con el código de producción del baseline antes de corregirlo;
esa ejecución falla deliberadamente por la atribución fuera del área segura.
No regenerar la imagen `before` con el código corregido.
