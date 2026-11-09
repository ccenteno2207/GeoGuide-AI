# A01-B — preparación de integración funcional

Fecha 2026-11-08. Rama codex/integration-a01-flutter sobre
84b222960a588d224d7e630abd5872424cba67dc (Paquete A, PR #95).
Fuente seleccionada 7d1a96965cc4b6ff828e46627505ea7b610057b5.

## Alcance y dependencias

Se incorporan exclusivamente cinco archivos de producción Dart y tres de pruebas
con diferencias reales frente a main. Producción: poi_detail_sheet.dart,
poi_preview_sheet.dart, poi_result_card.dart, poi_ui_language.dart y base_map_page.dart.
Pruebas: a01_b_ui_language_test.dart, a01_preview_actions_test.dart y
ui231_poi_language_test.dart. Los paths completos figuran en el diff del commit.
La selección conserva exactamente el árbol mobile de f17bcf5d1f26c8f2c001c6ea5d766a8c3efec004.
Main ya contiene UI-2 y la documentación de decisión del PR #95.
El cambio declara idioma es_PE en acciones UI y prefijos españoles, preservando
campos factuales, callbacks y navegación existentes. No hay cambios de dependencias,
Android nativo, permisos o contratos. Las tres suites aportan cobertura de rangos
semánticos, acciones, navegación y datos factuales multilingües.

## Trazabilidad del artefacto

APK original localizado en el worktree fuente bajo
mobile/build/app/outputs/flutter-apk/app-debug.apk. SHA-256 comprobado directamente:
912E1DDB8936577F603FD8A3F4C00FBB742089A8F6B1F89F621ED95779B64FA5.
Los registros locales ui2-a01-b-candidate-2026-11-01/apk-candidate.json y
build-debug.txt contienen identidad, hashes de cuatro fuentes y build debug
assembleDebug satisfactorio en 235,2 s. Los cuatro hashes coinciden con las fuentes
seleccionadas. El registro documental de la candidata vincula la preparación a
f17bcf5, debug y BACKEND_BASE_URL=https://geoguide.getcom.pe:5443.

Demostrado: identidad actual del APK, coincidencia de hashes registrados de fuentes
y equivalencia del árbol mobile seleccionado con f17bcf5. Documentado: build y
configuración histórica. No demostrado: reproducción byte a byte del binario desde
el nuevo commit de integración o atestación independiente de procedencia del build.
La evidencia física histórica corresponde al APK identificado, permanece PARTIAL
y no se convierte en una nueva validación física del commit de integración.

## Validación actual

- Dependencias resueltas con flutter pub get; pubspec y lockfile sin cambios.
- dart format --output=none --set-exit-if-changed lib test: PASS, 88 archivos, cero cambios.
- flutter analyze: PASS, sin incidencias, 132,4 s.
- flutter test: PASS, 242 pruebas, 3 min 20 s.
- git diff --check: PASS.
- Compilación Android nueva: NOT_EXECUTED. Se conserva build histórico de la misma
  selección mobile; el alcance Dart no modifica configuración ni código Android.
- Pruebas físicas: NOT_EXECUTED en esta preparación.

La primera invocación de pub get desde la raíz indicó que faltaba la raíz Flutter.
Se corrigió el directorio a mobile y todas las validaciones anteriores finalizaron.
Riesgo residual: pronunciación dependiente del lector/voz y composición semántica.
Recomendación: PR funcional único con estos ocho archivos y este registro, sobre
main con PR #95 integrado, conservando la aceptación delimitada del propietario.

```ini
PACKAGE_B = READY_FOR_INTEGRATION_REVIEW
A01_B_PHYSICAL_VALIDATION = PARTIAL
UI2_AC_12 = AUTOMATED_PASS_PHYSICAL_PARTIAL
P12_5 = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
