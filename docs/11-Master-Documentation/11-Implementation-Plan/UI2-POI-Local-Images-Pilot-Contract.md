# UI2-POI-LOCAL-IMAGES-PILOT-001 — contrato complementario aprobado

## Estado y autoridad

| Campo | Estado |
|---|---|
| Baseline de referencia | `12afd686c3ba1efd23facc925c2c96c4396a0579` (PR #110 integrado) |
| Relación con UI2-POI-UX-IMPLEMENTATION-001 | Ampliación posterior, específica y limitada; no modifica el snapshot congelado |
| Decisión del propietario | Aprobado expresamente el 2026-11-17 para implementación local del piloto interno |
| Contrato complementario | `APPROVED` |
| Implementación Flutter | Autorizada únicamente dentro del alcance de este complemento |
| Distribución de fotografías | Solo APK de demostración interna aprobada; no publicación comercial ni pública |
| Validación física HONOR | Pendiente de autorización posterior y de APK interna aprobada |
| UI-2 master closure | `NOT_AUTHORIZED` |
| P12.5 | `NOT_AUTHORIZED` |
| Production Readiness | `NOT_DECLARED` |

Este complemento fue aprobado por el propietario el 2026-11-17 para implementar el piloto local dentro de los límites descritos aquí. No autoriza publicar o distribuir la APK, instalarla en HONOR, ni realizar push, PR o merge.

## 1. Objetivo y alcance

Proponer la incorporación de las cinco fotografías facilitadas por el propietario para una demostración interna de Rutea con los POIs del dataset P3 Lima–Obrajillo.

La ampliación se limita a una asociación visual local por ID estable y a mostrar la fotografía en las superficies existentes de tarjeta de POI, Preview y Detail. No constituye un sistema general de medios, un catálogo remoto ni una nueva capacidad de contenido.

## 2. Precedencia limitada y reconciliación

El contrato congelado [UI2-POI-UX-IMPLEMENTATION-001](UI2-POI-UX-Implementation-Contract-Proposal.md) mantiene íntegros D04, B-AC-10, los demás criterios y el historial de aceptación de los incrementos A y B. Su alcance original sigue describiendo correctamente aquellos incrementos: conservar placeholder y no agregar fotografías.

La decisión aprobatoria del propietario prevalece exclusivamente para el piloto interno aquí definido y solo respecto a incorporar estas cinco fotografías locales. Esa precedencia limitada:

- no reescribe ni invalida D04, B-AC-10, las evidencias ni las validaciones históricas de A o B;
- no permite otras fotografías, POIs, fuentes, usos o destinos de distribución;
- no cambia el placeholder como fallback, ni las reglas de tarjetas, navegación, selección u offline;
- no modifica UI-2 congelado fuera de esta excepción de demostración.

Si la aprobación del complemento se revoca, se conserva el comportamiento sin imágenes y con placeholder.

## 3. Inventario y mapeo cerrado

Los IDs y nombres se contrastaron con `backend/src/main/resources/data/p3/lima-obrajillo-v1.json`. El nombre de archivo de origen no será una clave de runtime.

| ID estable del POI | Nombre en P3 | Archivo entregado | SHA-256 del original | Recurso interno |
|---|---|---|---|---|
| `02000000-0000-0000-0000-000000000001` | Santuario de Santa Rosa de Quives | `Santa rosa de quives.png` | `0EE69A45559A9E4A715F7B4193930EAFB79145D277A9A18D8543D57E4DC592C5` | `assets/demo/poi_images/02000000-0000-0000-0000-000000000001.png` |
| `02000000-0000-0000-0000-000000000002` | Petroglifos de Checta | `petroglifos de checta.png` | `3B2940F2AD8EC60F0CF877F74F82DC3E307E8843250AF4E55140ED6DCDAB74BE` | `assets/demo/poi_images/02000000-0000-0000-0000-000000000002.png` |
| `02000000-0000-0000-0000-000000000003` | Plaza de Armas de Canta | `Plaza de armas de canta.png` | `B09D081FDA65691A1D4BA0EA528B6EB875DFB2145F28846C3ADF7AC31D955858` | `assets/demo/poi_images/02000000-0000-0000-0000-000000000003.png` |
| `02000000-0000-0000-0000-000000000004` | Plaza de Armas de Obrajillo | `Plaza de Armas de obrajillo.png` | `D8BA0829948F38CB0DCDAD5520F2059387614D94C0D07311B424DB20DB01FF16` | `assets/demo/poi_images/02000000-0000-0000-0000-000000000004.png` |
| `02000000-0000-0000-0000-000000000005` | Iglesia San Juan Bautista de Obrajillo | `Iglesia San juan Bautista de obrajillo.png` | `14742670885D8F782CA2013908ABEDFA365FB29F249B5F83886C9CCA58E4F875` | `assets/demo/poi_images/02000000-0000-0000-0000-000000000005.png` |

Los cinco archivos se encontraron en `D:\Proyectos\Desarrollo\Ruteo\Imagenes`, se decodificaron como PNG y se calcularon sus hashes durante la preparación. El staging deberá comparar los originales con estos SHA-256 antes de renombrarlos por ID. La tabla es la lista cerrada del piloto.

## 4. Propuesta técnica

### Asociación y presentación

- Un catálogo Flutter de presentación mapearía cada ID P3 exacto a un recurso interno. No usaría índices de lista, nombre parcial, categoría ni coordenadas como claves.
- Los componentes de tarjeta, Preview y Detail reutilizarían el mismo proveedor de miniatura, suministrándole el ID estable del POI. El marcador del mapa no recibiría una fotografía.
- Una imagen ausente, un ID desconocido o un error de carga mostraría el `poi_thumbnail.dart` placeholder existente. Ningún error de asset bloquearía la ficha.
- La imagen quedaría recortada dentro del contenedor existente, con clipping y `BoxFit.cover`; no se deformaría la relación de aspecto ni se alteraría el layout de otros campos.
- La semántica accesible anunciaría la identidad del POI y una etiqueta de imagen de recurso turístico solo cuando aporte información. No inventaría autor, lugar de captura ni descripción fotográfica.
- No se cargarían `Image.network`, URL de imagen, servicio remoto ni nuevas dependencias.

### Aislamiento de build interno — hallazgo y condición

En el baseline verificado, `mobile/pubspec.yaml` no declara assets de imágenes; `mobile/android/app/build.gradle.kts` define `debug` y `release`, sin `productFlavors`. La sección `flutter.assets` de `pubspec.yaml` es común a los builds: declarar ahí las fotografías haría que Flutter pudiera empaquetarlas también en builds de release. `--dart-define`, ocultar el widget en runtime o usar una condición `kDebugMode` no elimina bytes del APK.

Por ello, no se añaden las fotografías a los assets normales rastreados ni a la lista global de `pubspec.yaml`. La separación verificable es:

1. Mantener originales fuera del repositorio en la carpeta local facilitada; no versionar ni copiar originales a la raíz normal de `mobile`.
2. Preparar, únicamente para la compilación de demo, una copia temporal aislada del proyecto Flutter fuera del worktree. Un script interno validaría los cinco nombres/IDs, decodificación y hashes; copiaría los archivos a rutas con ID; y añadiría la entrada de assets solo al `pubspec.yaml` temporal.
3. Compilar un artefacto debug identificado como `internal-demo`, separado de salidas públicas/estándar; no reutilizar `build/` de la raíz normal ni permitir que el paso de staging altere archivos rastreados.
4. Verificar automáticamente que el APK demo contiene exactamente los cinco assets esperados y que una compilación estándar (incluidos los tipos de build que el repositorio soporte) no contiene sus nombres ni hashes. Si esa comprobación no puede hacerse en la etapa de build, el demo no se distribuye.
5. Registrar el APK de demo como uso interno restringido. Ningún APK, asset o fuente se publica, se adjunta a PR público ni se distribuye comercialmente bajo esta autorización.

El mecanismo requiere un script de staging/build aislado, aún no implementado. No se declarará garantizada la exclusión de builds públicos hasta que las pruebas de empaquetado demuestren ambas condiciones: inclusión exacta en demo y ausencia en artefactos estándar.

## 5. Límites

No se propone cambiar backend, API, base de datos, `DiscoveryPoi`, DTO, snapshot offline, taxonomía, `chosenIds`, routing, filtros, navegación, Driving, GPS, CEFI, permisos, arquitectura ni dependencias.

El piloto no agrega campos de imagen al POI ni persistencia. Las imágenes solo se resuelven localmente por el ID existente. La ruta, Preview/Detail directo, filtros, selección explícita y navegación permanecen según contratos actuales.

## 6. Criterios de aceptación

| ID | Criterio verificable |
|---|---|
| LI-AC-01 | El catálogo contiene exactamente los cinco IDs P3 aprobados y una sola asociación por ID; no usa índices ni nombres parciales. |
| LI-AC-02 | Cada ID muestra su imagen correcta en tarjeta, Preview y Detail; pruebas de identidad prueban que no hay cruce entre POIs. |
| LI-AC-03 | Para POIs fuera de la lista, asset ausente, corrupto o con error de decode, el placeholder actual se muestra sin crash ni desbordamiento. |
| LI-AC-04 | Las imágenes respetan `BoxFit.cover`, clipping y dimensiones de superficie; no deforman contenido ni causan overflow en tamaños/escalas UI-2 cubiertos. |
| LI-AC-05 | La semántica mantiene nombre/identidad del POI y no anuncia metadatos fotográficos no verificados. |
| LI-AC-06 | CTA «Ver detalles» abre Detail del mismo POI; tap restante conserva Preview. Consultar superficies no cambia `chosenIds`, ruta, filtros ni estado de GPS. |
| LI-AC-07 | Imágenes accesibles funcionan sin red y no generan requests HTTP; los campos DTO/snapshot continúan sin imágenes y pasan sus validadores existentes. |
| LI-AC-08 | La compilación interna incluye exactamente los cinco recursos verificados; builds estándar y de distribución comprobados no contienen ninguno de los cinco por nombre ni hash. |
| LI-AC-09 | El staging/build interno falla cerrado si falta un archivo, no decodifica, cambia el mapeo o no puede verificar la exclusión de build público. |
| LI-AC-10 | No hay cambios de backend, API, DB, DTO, snapshots, permisos, dependencias ni Driving; se conservan pruebas existentes de selección, filtros, ruta y navegación. |
| LI-AC-11 | La licencia/procedencia permite el uso interno previsto o existe aprobación documentada del titular. Sin evidencia, el APK no se distribuye a testers externos ni se publica. |
| LI-AC-12 | Una validación física posterior se registra separada de la validación de A/B; no se infiere PASS físico por pruebas automatizadas. |

## 7. Pruebas automatizadas

- Prueba unitaria exacta de catálogo ID → asset y ausencia de resolución para IDs desconocidos.
- Pruebas widget de tarjeta, Preview y Detail por cada uno de los cinco IDs, con `AssetBundle` determinista que permita comprobar bytes/recurso esperado y detectar cruces.
- Pruebas de asset faltante/decodificación fallida → placeholder, sin excepción visible.
- Pruebas de overflow en los viewports y escalas del contrato UI-2, cubriendo nombre largo y todas las superficies con imagen.
- Regresión de Detail directo, Preview, `chosenIds`, filtros, ruta y regreso al mapa.
- Prueba offline o de cliente HTTP falso que asegure cero solicitudes de imagen y que el snapshot no cambió.
- Prueba del script de staging: inventario cerrado, falta/corrupción/hashes incorrectos fallan; APK demo tiene cinco assets; APK estándar no contiene nombres ni SHA-256 de ninguna fotografía.
- `dart format`, `flutter analyze`, pruebas focalizadas y regresión Flutter pertinente; revisión del APK y `git diff --check` antes de aceptar la implementación.

## 8. Validación física posterior

Solo después de aprobación del complemento y autorización de la sesión física:

- instalar o actualizar únicamente el APK de demo interno aprobado, con hash registrado;
- comprobar los cinco mapeos en lista, Preview y Detail, placeholders de otros POIs, navegación y accesibilidad visual;
- verificar que no se activan GPS, Driving o CEFI por abrir o consultar imágenes;
- comprobar conexión y modo sin conexión sin borrar datos ni cambiar permisos;
- capturar evidencia sin datos personales y mantener `UI2_POI_CARDS_HONOR_VALIDATION = PASS` como resultado histórico de B. La validación nueva se reporta bajo el identificador de este piloto.

La instalación física y la prueba de distribución no están autorizadas por este documento.

## 9. Licencia, privacidad y distribución

La carpeta de origen fue indicada por el propietario, pero no se adjuntó evidencia de titularidad, licencia de fotografía o permiso de redistribución. La aprobación solo cubre el uso interno previsto y no se interpreta como una licencia pública, comercial, perpetua o sublicenciable.

Hasta aprobación expresa de uso y comprobación del aislamiento:

- no subir originales a Git, Git LFS, GitHub Actions, PR, tienda o documentación pública;
- no publicar ni redistribuir la APK demo; limitarla a equipos y testers internos identificados bajo autorización;
- conservar atribución solo si está confirmada; no fabricar crédito fotográfico;
- retirar los recursos y el script de staging si la autorización o el control de distribución se revoca.

Una eventual publicación requiere decisión separada de licencia y distribución.

## 10. Riesgos y rollback

| Riesgo | Control propuesto |
|---|---|
| Derechos/redistribución desconocidos | Uso interno limitado; no publicación; requerir autorización/licencia documentada para ampliar distribución. |
| Asset termina en APK público | Staging temporal fuera del repositorio, manifiesto por build interno y verificación negativa de artefactos estándar por hash/nombre; cerrar build si falla. |
| Imagen equivocada | Asociación solo por UUID P3, test exhaustivo del catálogo y comprobación del contenido esperado. |
| Archivo ausente/corrupto | Fallback al placeholder y validación de PNG antes de empaquetar. |
| Crop poco usable o layout overflow | Contenedor/clipping existente, `BoxFit.cover`, pruebas de viewports y revisión visual física posterior. |
| APK demo confundida con distribución | Identificación inequívoca `internal-demo`, hash/registro y canal restringido; sin push/tienda bajo esta autorización. |

Rollback: retirar el catálogo visual opcional y la invocación de imágenes, conservar el placeholder existente y deshabilitar/eliminar el flujo de staging. No migrar ni limpiar datos de usuario; originales permanecen en su ubicación externa y no se borran por automatización.

## 11. Gates de aprobación y estado

La aprobación del propietario está registrada arriba. Antes de preparar una APK de demostración, debe probarse el aislamiento descrito. La distribución física o a terceros requerirá autorización adicional, hash aprobado y evaluación de licencia aplicable.

```ini
UI2_POI_LOCAL_IMAGES_PILOT_CONTRACT = APPROVED
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

## 12. Evidencia de implementación local — 2026-11-17

La implementación usa un catálogo cerrado por UUID, un proveedor visual compartido para tarjeta, Preview y Detail, y un script que construye en una copia temporal fuera del worktree. Los originales continúan en la carpeta externa; el script verifica sus SHA-256 y decodificación antes de staging. La evidencia de pruebas y de inspección de APK se registra en [UI2-POI-Local-Images-Pilot-Implementation-Evidence.md](UI2-POI-Local-Images-Pilot-Implementation-Evidence.md).
