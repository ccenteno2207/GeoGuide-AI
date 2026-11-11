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
