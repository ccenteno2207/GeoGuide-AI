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
- El parser y normalizador se ejecutaron contra el CSV original de solo lectura en `D:\Proyectos\Desarrollo\Ruteo\Imagenes\Inventario_recursos_turisticos.csv`, SHA-256 `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66`: **9/9 pruebas PASS**, 6.341 filas, 6.331 candidatos y 10 en cuarentena. El caso 237 conserva los dos tokens raw y genera candidato únicamente según el manifiesto de ese hash. Esta validación no insertó datos en una base.
- El importador mantiene separado el snapshot raw, las coordenadas candidatas, la regla de normalización, la evidencia y la cuarentena. No existe publicación automática en `geo.destination` o `geo.point_of_interest`.
- El resultado vigente de `mvn verify` es **94 pruebas, 0 fallos, 0 errores y 13 omitidas**. Las 11 pruebas `PostgisIntegrationTests` requieren Testcontainers/Docker y fueron omitidas por falta de runtime. Las 2 restantes son escenarios dependientes del fixture/snapshot externo opt-in; no equivalen a una validación de importación real. Este resultado completo sustituye como evidencia final los recuentos parciales anteriores de 74, 90 y 93; no acredita migración PostGIS ejecutada.
- Se añadió una comprobación unitaria de recursos para la presencia de V007 y sus guardas de aprobación/auditoría. No sustituye la aplicación real de Flyway.

## ADMIN-1

- V007 define una tabla editorial separada del catálogo público, referencias a la fila importada, raw/candidato/regla/evidencia, estados de revisión geográfica e identidad, versión optimista y auditoría append-only.
- La API local implementa lectura paginada de lotes y registros, borradores, edición con reinicio de revisiones, revisión geográfica con evidencia, revisión de duplicados, estados editoriales, consulta de coincidencias y publicación explícita.
- La publicación requiere aprobación geográfica, confirmación de identidad sin duplicado, licencia y atribución, y una categoría P3 activa. Inserta un nuevo POI y provenance; no actualiza ni reemplaza POIs/destinos existentes.
- La seguridad administrativa permanece **denegada por defecto**. Spring Security valida issuer, audiencia y roles configurables al habilitarla; el frontend usa Authorization Code con PKCE y no fija issuer, client ID, credenciales ni usuarios. No hay proveedor OIDC configurado, por lo que autenticación real y llamadas autenticadas no se validaron.
- El portal React/TypeScript/Vite presenta lotes, cuarentena, coordenadas raw/candidatas, revisión, coincidencias, publicación y medios. Se compila localmente, pero no se ejecutó contra una base de datos con identidad real.

### Revisión de precisión V007

- La revisión detectó que `NUMERIC(10,7)` redondeaba el candidato de Huacachina al copiarlo a un borrador: `-14.087854051458200` pasaría a `-14.0878541`. Aunque los valores raw y el staging permanecían intactos, el borrador ya no conservaba el candidato exacto.
- Se corrigió V007 antes de su aplicación en un entorno persistente: `admin.poi_editorial_record.latitude/longitude` ahora usan `NUMERIC` sin escala fija. Se añadió una prueba PostGIS que exige preservar los dos candidatos de alta precisión y los tokens raw al crear el borrador. La prueba compila pero no pudo ejecutarse por falta de Docker; la guarda estática de la migración sí pasó. No se atribuye exactitud geodésica adicional a los dígitos conservados.

## POI-MEDIA-1

- V007 persiste metadata de imagen, hash, dimensiones, autor, origen, licencia, atribución, evidencia de derechos, estado editorial y selección principal; la bitácora multimedia es append-only e incluye detalles auditables.
- El adaptador MinIO utiliza bucket privado y claves opacas. El upload acepta JPEG/PNG por contenido, aplica límites configurables (10 MiB y 40 Mpx por defecto), decodifica antes de procesar, re-encodea para eliminar metadatos EXIF/GPS y registra el hash. La publicación requiere derechos documentados y rol revisor; el backend entrega bytes de assets publicados, nunca una URL pública del bucket.
- Route Discovery expone `primaryMediaPath` solo para media principal publicada. Flutter resuelve rutas únicamente contra el backend configurado y conserva placeholder/error fallback. No se modificaron DTO de POI, API pública de búsqueda, backend remoto ni datos.
- Una nueva prueba encontró y corrigió un defecto: el decoder de snapshot aceptaba `primaryMediaUrl` de la respuesta online en memoria aunque no serializaba el campo. `SnapshotCodec` ahora elimina `primaryMediaUrl` y `primaryMediaPath` al decodificar para uso offline. El contrato P9 no cambió.
- No se copiaron fotografías originales del piloto ni otros archivos reales. Las pruebas usan un PNG sintético en memoria. MinIO real y publicación/lectura contra almacenamiento no se probaron porque el servicio no está disponible ni configurado.

## Validaciones ejecutadas

| Verificación | Resultado |
| --- | --- |
| Backend `mvn verify` | PASS: 94 tests, 0 failures/errors, 13 skipped: 11 PostGIS/Docker y 2 perfiles opt-in del CSV |
| Parser/normalizador contra CSV original | PASS: 9 tests, 0 failures/errors/skips; confirma 6.341/6.331/10 y el caso 237, sin persistir datos |
| Seguridad OIDC/JWT/RBAC | PASS en pruebas locales; 4 pruebas focalizadas cubren acceso cerrado, claims/roles, audience y configuración incompleta |
| Flutter suite completa | PASS: 314 passed, 3 skipped; incluye la prueba de que el snapshot offline descarta URI/path multimedia |
| Flutter `offline_cache_test.dart` después de la corrección | PASS: 34 tests; incluye descarte de URI/path multimedia en snapshot offline |
| Flutter `analyze` | PASS: sin issues, después de retirar el cast innecesario del codec |
| Flutter format | PASS: 9 archivos Dart afectados, sin cambios pendientes (`dart format --output=none --set-exit-if-changed`) |
| OpenAPI YAML | PASS: SnakeYAML analizó OpenAPI 3.1.0, 23 paths |
| Portal `npm test -- --reporter=verbose` | PASS: 2 tests OIDC startup gate |
| Portal `npm run build` | PASS: TypeScript y Vite |
| `git diff --check` | PASS al cierre local de la evidencia |
| V006/V007 contra PostgreSQL/PostGIS | NOT EXECUTED: no hay runtime de contenedores ni PostgreSQL local; 11 Testcontainers tests omitidos |
| MinIO/OIDC reales | NOT EXECUTED: no hay servicio/issuer/credenciales configurados |

## Pendientes de validación y decisiones

1. Aplicar y probar V006/V007, conteos de lote, idempotencia, flujo de revisión/publicación, preservación de P3 y consulta espacial en PostgreSQL/PostGIS aislado. No se autoriza resolverlo usando una base compartida o remota sin autorización específica.
2. Validar MinIO privado, permisos/bucket, upload y lectura controlada en instancia aislada.
3. Provisionar un issuer OIDC, client ID público de portal, audience y claims de roles; hasta entonces la API administrativa debe continuar deny-by-default.
4. Ejecutar la integración completa local de importación → revisión → publicación → Route Discovery → imagen/placeholder cuando existan DB, OIDC y MinIO locales.
5. Revisar derechos de medios antes de publicar cualquier imagen real. Las cinco fotografías del piloto local continúan excluidas.

## Plan reproducible para VALIDATION-4

El equipo actual no tiene Docker, Podman, `psql`, servicio PostgreSQL ni listener local en 5432. No se usó la VM ni el Compose de desarrollo, cuyo nombre de proyecto y volúmenes son compartidos. Cuando exista Docker Desktop autorizado localmente, ejecutar con un archivo temporal `compose.validation4.yaml` y un nombre de proyecto único, por ejemplo `geoguide-validation4-<fecha>`:

1. Crear solo servicios efímeros `postgis/postgis:16-3.4`, MinIO y Keycloak de prueba, con versiones/digests fijados al preparar el entorno. Definir red interna exclusiva y volúmenes nombrados exclusivos; no montar ni reutilizar los volúmenes de `infrastructure/compose.yaml`. Bindear puertos de host solo a `127.0.0.1` y generar credenciales sintéticas fuera de Git.
2. Aplicar V001–V007 a una base vacía, revisar `flyway_schema_history`, constraints, índices y triggers; ejecutar casos transaccionales de rollback. Si la migración no se ha aplicado, conservar V007 como corrección previa a la primera aplicación. Si aparece aplicada en cualquier base persistente, no editarla: preparar una migración aditiva posterior.
3. Ejecutar el perfil CSV con `-Dgeoguide.test.minceturCsv=<ruta local>` y staging contra la base aislada; comprobar lote, 6.341 filas, 6.331 candidatos, 10 cuarentenas, reimportación idempotente, cero publicados y las geometrías P3 intactas.
4. Levantar Keycloak únicamente para pruebas con realm/cliente sintéticos, Authorization Code + PKCE, issuer/audience/roles de prueba. Iniciar backend y portal con configuración local, probar JWT válido, inválido, vencido y cada rol, y recorrer importación → borrador → revisiones → aprobación → Route Discovery.
5. Levantar MinIO en el mismo proyecto aislado, crear bucket privado mediante configuración de prueba y usar un PNG/JPEG sintético. Probar rechazo de derechos incompletos, upload, EXIF, principal, bytes autorizados y retiro/fallback.
6. Ejecutar suite Flutter y pruebas de mapper/offline contra el backend local; verificar que el snapshot no persista URL ni bytes. Al concluir, detener y eliminar únicamente recursos creados con el mismo `-p <proyecto>` y revisar sus nombres antes de limpiar; nunca usar `docker compose down -v` sin confirmar el proyecto.

Este plan no se ejecutó: Docker y Podman no están instalados en el equipo y no hay una base local. La VM de integración sería el siguiente entorno disponible y requiere autorización específica antes de cualquier cambio allí.

Estado de esta continuación: `LOCAL_IMPLEMENTATION = PARTIAL_PENDING_INFRASTRUCTURE_VALIDATION`
`POI_DATA_COORDINATES = NORMALIZED_PENDING_REVIEW (6331)`
`MINCETUR_QUARANTINE = 10`
`P3_GEOMETRY_CHANGES = NONE`
`ADMIN_SECURITY_WITHOUT_OIDC = DENY_BY_DEFAULT`
`REAL_MINIO_VALIDATION = NOT_EXECUTED`
`P9_OFFLINE_MEDIA = EXCLUDED`
