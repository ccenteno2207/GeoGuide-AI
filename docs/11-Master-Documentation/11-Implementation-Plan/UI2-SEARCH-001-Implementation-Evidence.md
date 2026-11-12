# UI2-SEARCH-001 — evidencia de implementación local

**Fecha:** 2026-11-11
**Rama de trabajo:** `codex/ui2-search-001`
**Baseline de origen:** `4003508f0e355de8fa003a7ce1898c5a8269fd4a`

## Alcance construido

- Backend: dominio/caso de uso, repositorio JDBC/PostGIS, endpoint `POST /api/v1/destinations/search`, migración `V005`, y loader opt-in `geoguide.destination-catalog.enabled=true`.
- Datos: catálogo versionado de nueve fichas MINCETUR; procedencia, licencia, atribución, alias sustentados, corte y limitaciones están en [registro de fuente](UI2-SEARCH-001-Catalog-Source.md).
- Flutter: adaptador HTTP, búsqueda enviada explícitamente y control visible solo con backend configurado. Seleccionar un resultado coloca el destino, conserva el origen y espera la acción explícita «Calcular ruta». Sin configuración no aparece una búsqueda aparente.
- OpenAPI: operación de búsqueda y esquemas request/response incorporados al documento versionado.

## Validación automatizada

- Backend `mvn verify`: BUILD SUCCESS; 67 pruebas sin fallos. Ocho pruebas de PostGIS/Testcontainers quedaron omitidas porque no había Docker disponible. Por tanto, esta ejecución no acredita la aplicación real de V005, carga del catálogo en PostgreSQL ni consulta API respaldada por PostGIS.
- Flutter `dart format lib test`: PASS.
- Flutter `flutter analyze`: PASS.
- Flutter suite completa: 261/261 PASS antes de agregar los dos últimos casos específicos.
- Flutter casos focalizados finales: 20/20 PASS, incluyendo adaptación HTTP, visibilidad condicional del control, estados de búsqueda y planificación.
- APK debug local: `mobile/build/app/outputs/flutter-apk/app-debug.apk`; SHA-256 `03E36DA4A0E02893C25DB9DF942E8ECC5A176F5F87024073284815244256D4BC` (194,267,822 bytes). Se compiló sin `BACKEND_BASE_URL`; por diseño no muestra el control de búsqueda. Es evidencia de compilación, no de búsqueda end-to-end.
- `git diff --check`: PASS. OpenAPI YAML parseado con SnakeYAML: PASS. JSON del catálogo, UTF-8 y enlaces Markdown locales: PASS.

## Límites y estados

No se inició una base compartida, migración remota, servidor de integración, instalación ni prueba física. No se afirmó que la APK consultara datos reales. Para completar verificación local end-to-end se requiere ejecutar V005 y cargar el JSON en PostgreSQL/PostGIS efímero/local aislado, habilitar el loader y compilar/configurar la app contra ese backend local. La cobertura permanece limitada a nueve recursos turísticos; no hay entradas independientes de localidades.

```ini
UI2_SEARCH_001_CONTRACT = APPROVED
UI2_SEARCH_001_DATA_SOURCE = FIRST_PARTY_CURATED_CATALOG
UI2_SEARCH_001_BACKEND_IMPLEMENTATION = LOCAL
UI2_SEARCH_001_POSTGIS_VALIDATION = PENDING_ENVIRONMENT
UI2_SEARCH_001_FLUTTER_IMPLEMENTATION = LOCAL
UI2_SEARCH_001_PHYSICAL_VALIDATION = NOT_AUTHORIZED
UI2_SEARCH_001_DEPLOYMENT = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

## UI2-SEARCH-004 — validación física de búsqueda en HONOR (2026-11-12)

**Resultado:** `PARTIALLY_VALIDATED`. La búsqueda consultó el API temporal real desde el HONOR, presentó fichas del catálogo, permitió seleccionar destinos y revisar POIs. El caso PlanRoute alcanzó GraphHopper desde la app, pero la última observación de pantalla no mostró un resumen de ruta persistente; Driving no pudo ejecutarse por ausencia del controlador/snapshot offline en esta configuración HTTP temporal. No se declara PASS global.

### Dispositivo, APK y conectividad

- ADB identificó un único HONOR LLY-NX3 autorizado, Android 16 / API 36, serial `AM4L6R5617005821`. Paquete instalado `com.geoguideai.geoguide_ai`, versión `1.0.0` (versionCode 1); se conservó la instalación/datos existentes mediante `adb install -r`.
- APK debug de `codex/ui2-search-001` (`e16d1258d6d586321a22f26f5fcbed3783270e5d`), compilada con `BACKEND_BASE_URL=http://127.0.0.1:18082`; SHA-256 `D5ED87D5196521B2495E4EFC0690C0AFAD781062AC80621FB4C26B8D279D3006`. La firma de depuración coincidió con la aplicación instalada antes de actualizar. No se afirma identidad binaria con un APK histórico.
- El API/PostGIS/GraphHopper se ejecutaron en el proyecto Compose temporal `geoguide-ui2-search-004`, en red Docker interna aislada, con volúmenes exclusivos y sin puertos públicos. El HONOR alcanzó el API por ADB reverse sobre loopback. No se cambiaron permisos, TLS global, firewall, DNS ni servicios compartidos.
- Tras la limpieza autorizada, la APK permanece instalada para revisión, pero su URL loopback apunta al API temporal ya retirado; la búsqueda no estará disponible hasta configurar un backend de prueba activo.
- Flyway aplicó V001–V005 en la base temporal; el catálogo MINCETUR cargó nueve destinos y un alias, con geometrías válidas. API `UP`. Una búsqueda de ruta del teléfono llegó a GraphHopper y recibió respuesta exitosa; una consulta Lima–Canta observada en logs produjo 101.255 km, 6.217 s (104 min) y 1.912 puntos. Una comprobación posterior desde un origen manual próximo a Canta produjo 1.269 m, 2 min y 28 puntos.
- La primera consulta de descubrimiento posterior a la ruta devolvió HTTP 400 porque el stack temporal no tenía cargada la taxonomía P3. Se habilitó el cargador P3 únicamente en la base/servicio temporal; al reintentar, el API devolvió 3 POIs y los filtros operaron. Esto fue configuración incompleta del fixture, no una corrección de código del producto.

### Casos físicos

| Caso | Estado | Evidencia observada |
| --- | --- | --- |
| SEARCH-PHYS-01 Inicio | `PASS` | Rutea abrió sin crash; mapa, CEFI, controles y atribución OSM visibles; sin panel técnico persistente. |
| SEARCH-PHYS-02 Buscador | `PASS` | Campo, teclado y envío explícito. Se ejercitaron loading, error contextual y reintento tras recuperar el API. |
| SEARCH-PHYS-03 Canta | `PASS` | Resultado real «Plaza De Armas De Canta», contexto Lima/Canta; selección centró el mapa y conservó el origen; no calculó ruta automáticamente. |
| SEARCH-PHYS-04 Huacachina | `PASS` | «Laguna De Huacachina» real, contexto Ica; selección utilizable en el mapa. |
| SEARCH-PHYS-05 Desambiguación | `PASS` | «Plaza de Armas» mostró cinco fichas diferenciadas por contexto (Arequipa, Canta, Ica, Obrajillo y Lima); selección explícita. |
| SEARCH-PHYS-06 Sin resultados | `PASS` | «Líneas de Nazca» mostró estado vacío correcto, sin resultados inventados y permitió continuar. |
| SEARCH-PHYS-07 PlanRoute | `PARTIAL` | La sesión Lima–Canta llegó a GraphHopper y se informó una ruta de 97,7 km / 104 min. En una comprobación posterior apareció «Los puntos seleccionados no son válidos»; luego GraphHopper registró una respuesta válida para el origen manual próximo a Canta (1,269 km / 2 min / 28 puntos), pero la última pantalla no mostró resumen/estado de ruta y mantuvo «Calcular ruta». La secuencia documenta una inconsistencia UI reproducida en esa sesión; la evidencia no permite certificar render/persistencia completa ni atribuir causa raíz. |
| SEARCH-PHYS-08 Selección manual | `PASS` | La interacción manual del mapa estableció el origen; la selección de destino desde búsqueda conservó ese origen. |
| SEARCH-PHYS-09 POIs | `PASS` | Tras cargar P3 en el entorno temporal: 3 POIs reales en mapa/lista; filtros redujeron a 2 y «Restablecer» restauró 3. Preview y Detail mostraron ficha, categoría, distancia, fuente/URL y atribución; navegación de retorno operativa. No se exigieron POIs fuera de la cobertura del catálogo. |
| SEARCH-PHYS-10 Driving | `NOT_EXECUTED_PRECONDITION_UNMET` | El árbol de accesibilidad no expuso «Gestionar copia offline» ni «Conducción». El contrato de `SnapshotCodec.backendContext` rechaza backends que no sean HTTPS, y la conectividad autorizada de esta sesión fue HTTP por ADB reverse; `GeoGuideApp._createOffline` captura esa incompatibilidad y deja el controlador nulo. No se cambió TLS ni se otorgó confianza a certificados, ni se creó una copia offline con datos de viaje. |

### Validación automatizada y evidencia

- Backend sobre la fuente derivada del commit de trabajo: `mvn verify` PASS, 67 pruebas; las 8 pruebas PostGIS/Testcontainers pasaron contra PostGIS real.
- Flutter: `flutter pub get` PASS; `dart format .` PASS (97 archivos, 0 cambios); `flutter analyze` PASS; `flutter test` PASS (263 aprobadas, 1 omitida opt-in sin URL live). El APK debug configurado se compiló correctamente. No se volvió a ejecutar la suite después de la sesión física porque no hubo cambios de código.
- Capturas UI limitadas a Rutea: [selección de Canta](UI2-SEARCH-004-Physical-Evidence/search-canta.png), [desambiguación de Plaza de Armas](UI2-SEARCH-004-Physical-Evidence/search-plaza-disambiguation.png), [estado vacío de Nazca](UI2-SEARCH-004-Physical-Evidence/search-empty-nazca.png), [Detail de POI](UI2-SEARCH-004-Physical-Evidence/poi-detail.png), [error intermedio de selección de ruta](UI2-SEARCH-004-Physical-Evidence/planroute-intermediate-validation-error.png) y [estado final del mapa](UI2-SEARCH-004-Physical-Evidence/final-map-state.png). La última captura documenta que no quedó un resumen de ruta visible. No se capturaron coordenadas deliberadamente ni datos personales.
- No se modificó código de producción durante la sesión. No se usaron ubicación actual, seguimiento continuo, Driving, voz CEFI, TalkBack ni cambios de permisos.
- El stack remoto, sus volúmenes/red y el ADB reverse quedaron retirados; el checkout VM `main` sigue limpio en `d50fb8e2d807dc97a16c81f4ffaa6fcfa89fbaca` y los seis servicios principales permanecen healthy. La carpeta local `%TEMP%\geoguide-ui2-search-004` sigue retenida: la operación de borrado recursivo fue bloqueada por la política de herramientas. Contiene artefactos temporales (incluido el `.env` de la prueba); requiere eliminación manual desde el equipo antes de considerar completa toda la limpieza local.

```ini
UI2_SEARCH_004_DEVICE = HONOR_LLY_NX3_ANDROID_16_API_36
UI2_SEARCH_004_BACKEND = TEMPORARY_ISOLATED
UI2_SEARCH_004_ANDROID_UI = PASS
UI2_SEARCH_004_SEARCH = PASS_REAL_API
UI2_SEARCH_004_DESTINATION_SELECTION = PASS
UI2_SEARCH_004_PLAN_ROUTE = PARTIAL_UI_RESULT_NOT_PERSISTENT_AT_FINAL_OBSERVATION
UI2_SEARCH_004_REGRESSION = PASS_AUTOMATED_WITH_PHYS_07_PARTIAL_PHYS_10_NOT_EXECUTED
UI2_SEARCH_004_PHYSICAL_VALIDATION = PARTIALLY_VALIDATED
UI2_SEARCH_004_TEMPORARY_STACK = REMOVED_AFTER_VALIDATION
UI2_SEARCH_004_LOCAL_TEMP_ARTIFACTS = RETAINED_CLEANUP_BLOCKED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

## UI2-SEARCH-003 — PostGIS, API y flujo Flutter real (2026-11-11/12)

**Resultado global:** `PARTIALLY_VALIDATED`. Se acreditaron Flyway/PostGIS, el catálogo, búsquedas por HTTP y el flujo del cliente/controlador Flutter hasta `PlanRoute`. No se acreditó una sesión de la UI Android en emulador ni en dispositivo.

### Entorno y aislamiento

- Se mantuvo intacto el checkout principal de la VM (`main`, `d50fb8e2d807dc97a16c81f4ffaa6fcfa89fbaca`) y sus servicios activos. La fuente se validó desde una copia temporal de backend derivada de `daae3fe3dcb547cc0b6cecf674ccd16bd9a4c84c`; no se cambió el checkout VM.
- Compose usó el proyecto exclusivo `geoguide-ui2-search-test`, red Docker `internal`, PostgreSQL/PostGIS y volúmenes propios. API y PostGIS solo se comunicaron dentro de esa red; el PBF de GraphHopper se montó en solo lectura y su caché fue un volumen separado. La API se consultó desde Windows mediante SSH loopback hacia la IP privada de su contenedor, sin publicar el servicio en Internet ni tocar firewall/DNS.
- La primera ejecución real de los ocho tests PostGIS reveló una consulta inválida (`SELECT DISTINCT` con expresiones `ORDER BY` no seleccionadas) y una aserción que mezclaba índices GIST de dos tablas. Se corrigió la consulta con `EXISTS` y se separó la verificación de índices por tabla. Una segunda pasada confirmó ambas correcciones y mostró que el test directo del puerto de repositorio debía pasar su `normalizedQuery` según el contrato; el caso se ajustó con el normalizador de dominio. La corrida final pasó los 67 tests.

### Flyway, PostGIS y catálogo

- PostgreSQL 16.4 con PostGIS 3.4.3. Flyway validó y aplicó las cinco migraciones, `V001`–`V005`, en la base temporal vacía; el API arrancó en estado `UP` y cargó el catálogo opt-in. Tras reiniciar el contenedor API, el catálogo persistió con nueve filas y un alias, sin duplicados.
- El JAR usado por el API temporal se generó desde la corrida final verificada y tuvo SHA-256 `2ec40f4fea47409a2a40b11a807155784f091aa6dbc649f363e2ce3abc5b260c`.
- `PostgisIntegrationTests`: **8/8 PASS**, 0 fallos, 0 omitidos. `mvn verify`: **67/67 PASS**, 0 fallos, 0 omitidos.
- PostGIS verificó nueve geometrías válidas en SRID 4326; 0 geometrías inválidas. La carga idempotente y las búsquedas de integración se ejecutaron contra PostGIS real, no mocks.

### Consultas HTTP al API temporal

Todas las consultas respondieron HTTP 200 desde `POST /api/v1/destinations/search`. Los resultados con coincidencia incluyeron nombre, contexto, coordenadas, procedencia MINCETUR, URL de ficha, licencia y atribución:

| Consulta | Resultado real |
| --- | --- |
| `Canta` | 1: Plaza De Armas De Canta — Lima, Canta, CANTA |
| `Obrajillo` | 1: Plaza De Armas De Obrajillo — Lima, Canta, CANTA |
| `Santa Rosa de Quives` | 1: Santuario De Santa Rosa De Quives — Lima, Canta, SANTA ROSA DE QUIVES |
| `Huacachina` | 1: Laguna De Huacachina — Ica, Ica, ICA |
| `Plaza de Armas` | 5 coincidencias diferenciadas por nombre/contexto: Arequipa, Canta, Ica, Obrajillo y Lima |
| `Plaza de Armas de Lima` | 1: Plaza Mayor De Lima, usando el único alias respaldado por la ficha MINCETUR |
| `Plaza de Armas de Ica` | 1: Plaza De Armas De Ica |
| `Plaza de Armas de Arequipa` | 1: Plaza De Armas De Arequipa |
| `Líneas de Nazca` | 0: respuesta vacía correcta para la cobertura actual; existe una ficha cuyo nombre canónico usa “Nasca”, pero no se inventó un alias “Nazca” |

`POST /api/v1/routes/plan` también respondió HTTP 200 para Lima → Plaza De Armas De Canta mediante el GraphHopper temporal: 102.326,648 m, 6.372,52 s, geometría con extremos válidos. Esto comprueba el servicio real de planificación para esas coordenadas; no constituye validación de POIs descubiertos a lo largo de la ruta.

### Integración Flutter y regresiones

- Se añadió `mobile/test/integration/ui2_search_003_live_backend_test.dart`, prueba opt-in que usa el `GeoGuideHttpClient`, repositorio de búsqueda, `RoutePlanningController` y `DioRoutePlanningRepository` reales. Contra el API temporal obtuvo la ficha Canta, preservó el origen Lima, esperó la acción explícita de cálculo y recibió una ruta real con geometría. Resultado focalizado: **1/1 PASS**.
- `dart format .`: PASS, 97 archivos, 0 cambios de formato. `flutter analyze`: PASS. `flutter test`: **263 PASS, 1 SKIP**; el skip es la prueba opt-in de API real cuando no se define `UI2_SEARCH_LIVE_BACKEND_URL`. Ejecutada separadamente con la URL del túnel SSH, esa prueba pasó. Las pruebas widget ordinarias siguen usando dobles y no se presentan como tráfico HTTP real.
- Se intentó iniciar el AVD `P6_MapSpike_API36` en modo headless. El host no tiene Android Emulator Hypervisor Driver; el emulador x86_64 terminó con `x86_64 emulation currently requires hardware acceleration`. No se instaló APK ni se interactuó con el HONOR. Por ello queda pendiente comprobar la pantalla mapa completa conectada al API y el gesto visual de selección.
- `flutter build apk --debug`: PASS. Artefacto `mobile/build/app/outputs/flutter-apk/app-debug.apk`, SHA-256 `03E36DA4A0E02893C25DB9DF942E8ECC5A176F5F87024073284815244256D4BC`, 194.267.822 bytes. Se compiló sin `BACKEND_BASE_URL`; es evidencia de compilación, no de conectividad Android.

### Estados UI2-SEARCH-003

```ini
UI2_SEARCH_003_POSTGIS = PASS
UI2_SEARCH_003_FLYWAY = PASS
UI2_SEARCH_003_CATALOG = VERIFIED_9_RECORDS_1_SUPPORTED_ALIAS
UI2_SEARCH_003_API = PASS_REAL_SEARCH_AND_PLAN_ROUTE
UI2_SEARCH_003_FLUTTER_CLIENT_CONTROLLER = PASS_REAL_API
UI2_SEARCH_003_ANDROID_UI_RUNTIME = PENDING_EMULATOR_ACCELERATION
UI2_SEARCH_003_REGRESSION = PASS_BACKEND_67_FLUTTER_263_PLUS_1_OPT_IN_SKIP
UI2_SEARCH_003_OVERALL = PARTIALLY_VALIDATED
UI2_SEARCH_003_PUSH = NOT_AUTHORIZED
UI2_SEARCH_003_PR = NOT_AUTHORIZED
UI2_SEARCH_003_MERGE = NOT_AUTHORIZED
UI2_SEARCH_003_PHYSICAL_VALIDATION = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

La validación no incluye ejecución visual de la UI completa en Android. El test opt-in demuestra el cliente y controlador Flutter con datos y ruta reales; el mapa renderizado, permisos/red en Android y selección desde el launcher/runtime quedan sin verificar. El catálogo sigue limitado a nueve fichas; “Líneas de Nazca” no tiene coincidencia bajo el criterio vigente.

## UI2-SEARCH-002 — validación local de integración (2026-11-11)

**Resultado global:** `PARTIALLY_VALIDATED`. Esta ejecución no contó con una base PostGIS local aislada: Docker, Podman y psql/postgres no están instalados/disponibles, WSL no tiene distribuciones y no había listener local en el puerto 5432. No se usaron VM, base compartida, despliegue ni dispositivo físico.

### Fuente y catálogo

- Se descargó en memoria el CSV del recurso oficial MINCETUR; 6.341 filas. SHA-256 `F66AE874FAD26E899ABD023A47B96E980D194A563D7F0E7CB202A95D221D263E`, igual al corte versionado. Los nueve IDs `CODIGO DEL RECURSO` tuvieron una única fila y coincidieron exactamente nombre, contexto y coordenadas del JSON usando `latitude = LONGITUD` y `longitude = LATITUD` del CSV.
- Se conserva el alcance de nueve registros en Lima, Ica y Arequipa. Se comprobó la licencia ODC-BY declarada en la Plataforma Nacional de Datos Abiertos. La ficha MINCETUR 3348 respalda explícitamente el único alias conservado, «Plaza de Armas de Lima» para «Plaza Mayor De Lima»; dos aliases no sustentados por las fichas MINCETUR del catálogo se retiraron. La cobertura sigue siendo limitada, no nacional ni de localidades independientes.

### Validaciones ejecutadas

- `mvn verify`: `BUILD SUCCESS`, 67 pruebas, 0 fallos, 8 omitidas en `PostgisIntegrationTests` porque no existe entorno Docker. Por ello no se ejecutaron contra PostGIS: migraciones Flyway reales, índices/restricciones/geometry, carga e idempotencia persistida, consulta JDBC ni endpoint con datos del catálogo.
- `dart format --output=none --set-exit-if-changed lib test`: PASS, 96 archivos sin cambios.
- `flutter analyze`: PASS.
- `flutter test`: PASS, 263/263. Incluye pruebas de adaptador/widget con dobles, no prueba tráfico real Flutter→API→PostGIS.
- La verificación HTTP del endpoint sigue limitada a pruebas MockMvc del controlador y su respuesta bajo mocks; no se ejecutó un servidor API con datos persistidos. Consultas reales de aceptación y flujo destino→`PlanRoute` contra esos resultados: no ejecutados.
- APK debug configurada: `mobile/build/app/outputs/flutter-apk/app-debug.apk`; `BACKEND_BASE_URL=https://10.0.2.2:8443` (dirección reservada para Android Emulator hacia el host; no es una configuración para HONOR ni una URL de despliegue). Build PASS, SHA-256 `F53964E4B8AA335CB163E8B99C052CBDEA06EB1F21B5C83241F1822DC2B05797`, 194.269.483 bytes. La compilación no demuestra conectividad: no había servidor backend local ni certificado local disponible.
- `git diff --check`: PASS. UTF-8/enlaces Markdown locales, JSON del catálogo y escaneo de secretos: PASS.

```ini
UI2_SEARCH_002_POSTGIS = NOT_EXECUTED_ENVIRONMENT_UNAVAILABLE
UI2_SEARCH_002_FLYWAY = NOT_EXECUTED_AGAINST_POSTGIS
UI2_SEARCH_002_CATALOG_SOURCE = VERIFIED_9_RECORDS
UI2_SEARCH_002_CATALOG_DATABASE_LOAD = NOT_EXECUTED
UI2_SEARCH_002_API = MOCKMVC_ONLY_NO_DATABASE
UI2_SEARCH_002_FLUTTER_INTEGRATION = AUTOMATED_WITH_TEST_DOUBLES
UI2_SEARCH_002_BACKEND_TESTS = PASS_67_WITH_8_POSTGIS_SKIPPED
UI2_SEARCH_002_FLUTTER_TESTS = PASS_263
UI2_SEARCH_002_END_TO_END = PARTIALLY_VALIDATED
UI2_SEARCH_002_PUSH = NOT_AUTHORIZED
UI2_SEARCH_002_PR = NOT_AUTHORIZED
UI2_SEARCH_002_MERGE = NOT_AUTHORIZED
UI2_SEARCH_002_PHYSICAL_VALIDATION = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
P12_5 = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
