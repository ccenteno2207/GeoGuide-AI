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
