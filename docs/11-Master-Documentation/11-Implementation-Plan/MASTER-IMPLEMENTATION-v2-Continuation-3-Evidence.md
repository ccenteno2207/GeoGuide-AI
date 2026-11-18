# Master Implementation v2 — Continuación 3: evidencia local

Fecha de verificación: 2026-11-18
Rama: `codex/master-implementation-v2`
Baseline de trabajo conservado: `2f1627a8809cafce6225e6bb8d37ae6b439131a3`
Baseline de `origin/main` al inicio: `0d76dcf740e3558c4b7308dbb19139a6e9a1071e`

## Alcance y gobierno

Se conservaron sin reescritura los commits locales `40260f6158f0d2cded5e9c43ca76a845bdaed860` y `2f1627a8809cafce6225e6bb8d37ae6b439131a3`. La implementación de esta continuación es local. No se publicó rama, PR, merge, despliegue, migración compartida ni APK. El checkout principal y los cinco POIs P3 no fueron modificados.

Los 6.331 registros siguen en `NORMALIZED_PENDING_REVIEW`; los 10 registros ambiguos/rechazados permanecen en cuarentena. No se publicaron candidatos ni se aprobaron coordenadas por coincidencia numérica.

P8 y P9 no se reescribieron. La capacidad multimedia es una extensión posterior autorizada por el propietario; el snapshot offline continúa sin URI, bytes o descarga de imágenes.

## POI-DATA-1

- V006 y la importación completa no se ejecutaron contra PostgreSQL/PostGIS en esta sesión. No hay Docker/Podman ni servidor PostgreSQL local disponible. Los puertos de desarrollo comprobados no tenían servicios; no se accedió a una base o infraestructura remota.
- El importador mantiene separado el snapshot raw, las coordenadas candidatas, la regla de normalización, la evidencia y la cuarentena. No existe publicación automática en `geo.destination` o `geo.point_of_interest`.
- El resultado vigente de `mvn verify` es **93 pruebas, 0 fallos, 0 errores y 12 omitidas**. Las 10 pruebas `PostgisIntegrationTests` requieren Testcontainers/Docker y fueron omitidas por falta de runtime. Las 2 restantes son escenarios dependientes del fixture/snapshot externo opt-in; no equivalen a una validación de importación real. Este resultado completo sustituye como evidencia final el recuento parcial anterior de 74 y el recuento previo de 90; no acredita migración PostGIS ejecutada.
- Se añadió una comprobación unitaria de recursos para la presencia de V007 y sus guardas de aprobación/auditoría. No sustituye la aplicación real de Flyway.

## ADMIN-1

- V007 define una tabla editorial separada del catálogo público, referencias a la fila importada, raw/candidato/regla/evidencia, estados de revisión geográfica e identidad, versión optimista y auditoría append-only.
- La API local implementa lectura paginada de lotes y registros, borradores, edición con reinicio de revisiones, revisión geográfica con evidencia, revisión de duplicados, estados editoriales, consulta de coincidencias y publicación explícita.
- La publicación requiere aprobación geográfica, confirmación de identidad sin duplicado, licencia y atribución, y una categoría P3 activa. Inserta un nuevo POI y provenance; no actualiza ni reemplaza POIs/destinos existentes.
- La seguridad administrativa permanece **denegada por defecto**. Spring Security valida issuer, audiencia y roles configurables al habilitarla; el frontend usa Authorization Code con PKCE y no fija issuer, client ID, credenciales ni usuarios. No hay proveedor OIDC configurado, por lo que autenticación real y llamadas autenticadas no se validaron.
- El portal React/TypeScript/Vite presenta lotes, cuarentena, coordenadas raw/candidatas, revisión, coincidencias, publicación y medios. Se compila localmente, pero no se ejecutó contra una base de datos con identidad real.

## POI-MEDIA-1

- V007 persiste metadata de imagen, hash, dimensiones, autor, origen, licencia, atribución, evidencia de derechos, estado editorial y selección principal; la bitácora multimedia es append-only e incluye detalles auditables.
- El adaptador MinIO utiliza bucket privado y claves opacas. El upload acepta JPEG/PNG por contenido, aplica límites configurables (10 MiB y 40 Mpx por defecto), decodifica antes de procesar, re-encodea para eliminar metadatos EXIF/GPS y registra el hash. La publicación requiere derechos documentados y rol revisor; el backend entrega bytes de assets publicados, nunca una URL pública del bucket.
- Route Discovery expone `primaryMediaPath` solo para media principal publicada. Flutter resuelve rutas únicamente contra el backend configurado y conserva placeholder/error fallback. No se modificaron DTO de POI, API pública de búsqueda, backend remoto ni datos.
- Una nueva prueba encontró y corrigió un defecto: el decoder de snapshot aceptaba `primaryMediaUrl` de la respuesta online en memoria aunque no serializaba el campo. `SnapshotCodec` ahora elimina `primaryMediaUrl` y `primaryMediaPath` al decodificar para uso offline. El contrato P9 no cambió.
- No se copiaron fotografías originales del piloto ni otros archivos reales. Las pruebas usan un PNG sintético en memoria. MinIO real y publicación/lectura contra almacenamiento no se probaron porque el servicio no está disponible ni configurado.

## Validaciones ejecutadas

| Verificación | Resultado |
| --- | --- |
| Backend `mvn verify` | PASS: 93 tests, 0 failures/errors, 12 skipped por dependencias externas descritas arriba |
| Seguridad OIDC/JWT/RBAC | PASS en pruebas locales; 4 pruebas focalizadas cubren acceso cerrado, claims/roles, audience y configuración incompleta |
| Portal `npm test -- --reporter=verbose` | PASS: 2 tests |
| Portal `npm run build` | PASS: TypeScript y Vite |
| Flutter suite completa | PASS: 314 passed, 3 skipped; incluye la prueba de que el snapshot offline descarta URI/path multimedia |
| Flutter `offline_cache_test.dart` después de la corrección | PASS: 34 tests; incluye descarte de URI/path multimedia en snapshot offline |
| Flutter `analyze` | PASS: sin issues, después de retirar el cast innecesario del codec |
| Flutter format | PASS: 9 archivos Dart afectados, sin cambios pendientes (`dart format --output=none --set-exit-if-changed`) |
| OpenAPI YAML | PASS: SnakeYAML analizó OpenAPI 3.1.0, 23 paths |
| Portal `npm test -- --reporter=verbose` | PASS: 2 tests OIDC startup gate |
| Portal `npm run build` | PASS: TypeScript y Vite |
| `git diff --check` | PASS al cierre local de la evidencia |
| V006/V007 contra PostgreSQL/PostGIS | NOT EXECUTED: no hay entorno local aislado disponible; 10 Testcontainers tests omitidos |
| MinIO/OIDC reales | NOT EXECUTED: no hay servicio/issuer/credenciales configurados |

## Pendientes de validación y decisiones

1. Aplicar y probar V006/V007, conteos de lote, idempotencia, flujo de revisión/publicación, preservación de P3 y consulta espacial en PostgreSQL/PostGIS aislado. No se autoriza resolverlo usando una base compartida o remota sin autorización específica.
2. Validar MinIO privado, permisos/bucket, upload y lectura controlada en instancia aislada.
3. Provisionar un issuer OIDC, client ID público de portal, audience y claims de roles; hasta entonces la API administrativa debe continuar deny-by-default.
4. Ejecutar la integración completa local de importación → revisión → publicación → Route Discovery → imagen/placeholder cuando existan DB, OIDC y MinIO locales.
5. Revisar derechos de medios antes de publicar cualquier imagen real. Las cinco fotografías del piloto local continúan excluidas.

Estado de esta continuación: `LOCAL_IMPLEMENTATION = PARTIAL_PENDING_INFRASTRUCTURE_VALIDATION`
`POI_DATA_COORDINATES = NORMALIZED_PENDING_REVIEW (6331)`
`MINCETUR_QUARANTINE = 10`
`P3_GEOMETRY_CHANGES = NONE`
`ADMIN_SECURITY_WITHOUT_OIDC = DENY_BY_DEFAULT`
`REAL_MINIO_VALIDATION = NOT_EXECUTED`
`P9_OFFLINE_MEDIA = EXCLUDED`
