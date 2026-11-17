# UI2-POI-LOCAL-IMAGES-PILOT-001 — evidencia de implementación

Fecha de ejecución: 2026-11-17

Baseline: `12afd686c3ba1efd23facc925c2c96c4396a0579`

Rama: `codex/ui2-poi-local-images-pilot`

Contrato complementario: aprobado expresamente por el propietario el 2026-11-17.

## Alcance implementado

El catálogo cerrado usa los cinco UUID del contrato en `mobile/lib/features/discovery/presentation/poi_thumbnail.dart`. `PoiResultCard`, `PoiPreviewSheet` y `PoiDetailSheet` proporcionan el mismo objeto `DiscoveryPoi` al componente visual común. No se añadieron imágenes a marcadores, modelos, DTO, backend, API, base de datos ni snapshots. El placeholder existente se mantiene para builds estándar, IDs desconocidos y fallos de carga. No se usa red para obtener fotografías.

Los originales permanecen fuera del repositorio en `D:\Proyectos\Desarrollo\Ruteo\Imagenes`. El script `mobile/tool/build_poi_local_images_demo.ps1` verifica nombres, SHA-256 fijados y decodificación PNG; copia el proyecto Flutter y las cinco imágenes a un directorio temporal único; añade assets solo al `pubspec.yaml` temporal; y construye la APK de demostración fuera del worktree. No versiona ni modifica los originales.

El código solo resuelve assets cuando se compila con `--dart-define=UI2_POI_LOCAL_IMAGES_DEMO=true`. El valor por defecto es `false`. El mismo script construye APK estándar debug y release sin imágenes, revisa sus entradas ZIP descomprimidas, y valida que la APK interna contenga exactamente cinco entradas demo con sus SHA-256 originales. Si una comprobación falla, el script termina con error.

## Inventario

| UUID | POI | Original | SHA-256 |
|---|---|---|---|
| `02000000-0000-0000-0000-000000000001` | Santuario de Santa Rosa de Quives | `Santa rosa de quives.png` | `0EE69A45559A9E4A715F7B4193930EAFB79145D277A9A18D8543D57E4DC592C5` |
| `02000000-0000-0000-0000-000000000002` | Petroglifos de Checta | `petroglifos de checta.png` | `3B2940F2AD8EC60F0CF877F74F82DC3E307E8843250AF4E55140ED6DCDAB74BE` |
| `02000000-0000-0000-0000-000000000003` | Plaza de Armas de Canta | `Plaza de armas de canta.png` | `B09D081FDA65691A1D4BA0EA528B6EB875DFB2145F28846C3ADF7AC31D955858` |
| `02000000-0000-0000-0000-000000000004` | Plaza de Armas de Obrajillo | `Plaza de Armas de obrajillo.png` | `D8BA0829948F38CB0DCDAD5520F2059387614D94C0D07311B424DB20DB01FF16` |
| `02000000-0000-0000-0000-000000000005` | Iglesia San Juan Bautista de Obrajillo | `Iglesia San juan Bautista de obrajillo.png` | `14742670885D8F782CA2013908ABEDFA365FB29F249B5F83886C9CCA58E4F875` |

## Validación y estado

| Control | Resultado | Evidencia |
|---|---|---|
| LI-AC-01 catálogo exacto por UUID | PASS | Prueba del catálogo: exactamente cinco IDs estables, mapeo uno a uno, ID desconocido sin asociación. |
| LI-AC-02 asociación en tarjeta, Preview y Detail | PASS | Test demo carga cada uno de los cinco recursos por ID en las tres superficies y compara ruta exacta. |
| LI-AC-03 placeholder | PASS | ID desconocido y fallo simulado del `AssetBundle` conservan placeholder accesible, sin excepción. |
| LI-AC-04 recorte/layout | PASS | Test demo comprueba `BoxFit.cover`, sin excepción en 320×480, 360×640 y 640×360 para las tres superficies. |
| LI-AC-05 accesibilidad | PASS | `Image.semanticLabel` identifica fotografía de referencia y POI; fallback mantiene “Imagen no disponible”. |
| LI-AC-06 navegación y selección | PASS | Regresión Flutter completa mantiene Preview/Detail, selección, filtros y ruta; cambios de UI solo suministran el ID al thumbnail. |
| LI-AC-07 offline/sin red | PASS | Implementación usa solo `Image.asset`, sin cliente HTTP ni `Image.network`; no se alteraron DTO ni snapshots; regresión offline pasa. |
| LI-AC-08 aislamiento de artefactos | PASS | La APK demo contiene exactamente cinco entradas, cada una con hash idéntico al original. Debug y release estándar no contienen esas entradas, nombres de origen ni hashes. |
| LI-AC-09 fail-closed | PASS | Prueba negativa con una copia temporal de imagen alterada terminó con exit 1 y mensaje de SHA-256 incorrecto antes de construir; las fuentes reales pasaron inventario/decodificación. |
| LI-AC-10 alcance | PASS | Diff limitado a Flutter visual, prueba, script y documentación; sin cambios de backend/API/DB/DTO/snapshots/permisos/dependencias/Driving. |
| LI-AC-11 licencia/distribución | LIMITED — interno autorizado | No hay licencia pública/comercial confirmada. Aprobación cubre demostración interna; APK no se instala, publica ni distribuye a terceros. |
| LI-AC-12 validación física | NOT_AUTHORIZED | No instalar ni probar físicamente en esta tarea. |

Validaciones ejecutadas en `mobile`: `dart format --output=none --set-exit-if-changed lib test` PASS; `flutter analyze` PASS; `flutter test` completa: 311 PASS, 3 omitidas (guards existentes, incluidos tests condicionados al define interno); regresión visual focalizada PASS; test de demo en staging: 4 PASS, 1 omitida. `git diff --check`, UTF-8, enlaces locales, diff de alcance y escaneo de secretos se registran al cierre del commit.

El script `mobile/tool/build_poi_local_images_demo.ps1` ejecutó builds estándar debug/release y el debug interno desde copias temporales. Artefactos inspeccionados:

| Artefacto | Bytes | SHA-256 | Resultado de contenido |
|---|---:|---|---|
| Estándar debug | 168188968 | `F7540EFE9054CE1A60A9F677B7CCAB4664D90D62801623F0BFCF59DA5ECEF459` | Sin las cinco imágenes. |
| Estándar release | 61142397 | `753333C463D075D45F03F70B7B0FF129EF8A97C13957951B1CAEBC8C516541DE` | Sin las cinco imágenes. |
| Demo interno debug | 175212651 | `6018DB89D03FFA384C7ED1DE8B457BE8DD5B1A2379D54CE854E93D93135AEB9A` | Exactamente cinco recursos demo; bytes verificados contra el SHA de cada original. |

Ruta local temporal de la APK interna: `C:\Users\CC_Laptop\AppData\Local\Temp\rutea-poi-local-demo-754d2f199be24da9a399e00828d6be0f\internal-demo-mobile\build\app\outputs\flutter-apk\app-debug.apk`. Se informa para trazabilidad; no se instaló ni distribuyó.

```ini
UI2_POI_LOCAL_IMAGES_PILOT_IMPLEMENTATION = IMPLEMENTED_PENDING_REVIEW
UI2_POI_LOCAL_IMAGES_PILOT_INTERNAL_BUILD_ISOLATION = PASS
UI2_POI_LOCAL_IMAGES_PILOT_PHYSICAL_VALIDATION = NOT_AUTHORIZED
UI2_POI_CARDS_HONOR_VALIDATION = PASS
UI2_CATEGORY_ICONS_HONOR_VALIDATION = PARTIAL
TALKBACK_REMEDIATION = DEFERRED_TECH_DEBT
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
