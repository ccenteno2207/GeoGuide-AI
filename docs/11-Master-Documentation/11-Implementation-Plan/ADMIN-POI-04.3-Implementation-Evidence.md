# ADMIN-POI-04.3 — Evidencia local de fotografías propias

## Alcance y baseline

- Baseline verificado de `origin/main`: `13ab45cb8642aa1ba384a39d87ac4325ea00e9ba`.
- Rama aislada: `codex/admin-poi-04-3-own-photo-upload`.
- Se habilita `OWN_PHOTOGRAPH` para adjuntar un JPEG/PNG local sin URL externa. `EXTERNAL_SOURCE` conserva su URL HTTPS obligatoria.
- No se publicaron fotografías, no se cambió el contenido de POIs reales, no se desplegó ni se instaló APK.

## Cambios

- V014 es aditiva: permite `source_url` nula solo para fotografías propias; añade tipo de origen, fecha/lugar opcionales y recibo de declaración versionado con actor, fecha y versión del asset. Los registros previos reciben `EXTERNAL_SOURCE` por defecto y mantienen su URL.
- El endpoint multipart conserva autenticación/RBAC, validación por contenido JPEG/PNG, límites de bytes/dimensiones, re-encoding y almacenamiento MinIO privado. Para modo propio exige autor, declaración explícita, licencia/autorización y atribución; no acepta URL externa en ese modo.
- La aceptación registra una declaración del usuario, no acredita por sí sola titularidad. Cada asset continúa como `DRAFT` con `rightsStatus=UNVERIFIED`. Documentar derechos, revisión y publicación siguen siendo pasos separados; la publicación mantiene las validaciones existentes.
- El portal muestra selector de origen, campos condicionales, vista previa local y fecha/lugar opcionales. La galería administrativa identifica procedencia sin exponer la URL interna de almacenamiento.
- OpenAPI refleja multipart condicional y los campos del recibo. El contrato público de fotografías y los snapshots P9 no cambian.

## Causa y compatibilidad de fotografías anteriores

La evidencia ADMIN-POI-04.2 registró `photos=[]` en la API pública y que los cinco PNG del piloto permanecían fuera del repositorio, usados por una compilación de demostración aislada. No demostró eliminación física de los originales ni una asociación publicada en MinIO. ADMIN-POI-04.3 resuelve la falta de URL para una nueva carga propia; no restaura ni publica automáticamente imágenes anteriores. La API pública sigue mostrando únicamente assets publicados y autorizados.

## Validaciones

| Comprobación | Resultado |
|---|---|
| `PoiMediaServiceTests,PoiMediaControllerTests,FlywayMigrationTests` | PASS: 13 tests; carga propia sin URL, declaración/actor, DRAFT/UNVERIFIED, fecha, rechazos antes del almacenamiento, respuesta privada y guardia estática de V014. |
| Portal: suite completa | PASS: 44 tests en 10 archivos; incluye upload propio y external, sin URL propia y declaración en el multipart. |
| Portal: `npm run build` | PASS: TypeScript + Vite production build. |
| `mvn verify` | PASS: 140 tests, 0 fallos; 30 omitidos, incluidos los 26 tests PostGIS porque Docker no está disponible. |
| `git diff --check` | PASS. Escaneo focalizado de patrones de credenciales en archivos modificados: PASS. |
| Aplicación Flyway V014/PostGIS | NOT_RUN: Docker no está instalado/disponible localmente; no se accedió a la VM ni a bases compartidas. La prueba V014 revisa contenido aditivo, no sustituye ejecutar PostgreSQL/Flyway. |
| Smoke autenticado en navegador | NOT_RUN. |
| MinIO/API end-to-end | NOT_RUN; no se cargó una fotografía a una instancia. |
| Fotos reales/publicación | NOT_EXECUTED; no se copiaron originales ni se modificó contenido real. |

## Validación aislada previa al PR — 2026-11-21

| Criterio | Estado | Evidencia |
|---|---|---|
| `ADMIN_POI_04_3_FLYWAY_V014` | BLOCKED | En Windows no están disponibles Docker, PostgreSQL ni MinIO. La VM de integración se comprobó solo en lectura; tenía Docker y recursos disponibles, pero no se creó ningún contenedor porque la instrucción prohíbe alterarla. V014 no se ejecutó. |
| `ADMIN_POI_04_3_POSTGIS` | BLOCKED | `mvn verify` omitió 26 pruebas PostGIS al no encontrar Docker en Windows. La VM no se usó para ejecutar pruebas. |
| `ADMIN_POI_04_3_MINIO_E2E` | BLOCKED | No hay MinIO local y no se levantó ni modificó infraestructura. Ningún objeto temporal fue creado. |
| `ADMIN_POI_04_3_API_UPLOAD` | NOT_RUN | Pasan las pruebas unitarias del servicio y controlador; no se envió una carga multipart autenticada contra backend + PostgreSQL + MinIO reales. |
| `ADMIN_POI_04_3_EXTERNAL_COMPATIBILITY` | NOT_RUN | El wrapper y la validación HTTPS externa tienen cobertura unitaria; no se probó la migración sobre filas externas históricas en PostgreSQL. |
| `ADMIN_POI_04_3_OPENAPI_VALIDATION` | BLOCKED | Redocly CLI 1.34.5 parseó el documento, pero el lint integral no pasa: rama actual 109 errores / 81 advertencias; `origin/main` sin cambios 112 errores / 81 advertencias. Los hallazgos restantes pertenecen a esquemas preexistentes fuera de las líneas modificadas; las nuevas líneas multipart y `AdminMediaAsset` no aparecen en el reporte tras corregir su sintaxis OAS 3.1. Esto no es un PASS integral. |
| `ADMIN_POI_04_3_AUTHENTICATED_PORTAL_SMOKE` | NOT_RUN | Sin backend/MinIO aislados ni sesión de prueba disponible; no se probó el portal desplegado ni se alteró la VM. |
| `ADMIN_POI_04_3_READY_FOR_PR` | BLOCKED | Continúan pendientes Flyway/PostGIS, compatibilidad de filas reales previas, API + MinIO E2E y smoke autenticado; no corresponde publicar la rama. |

La comprobación de solo lectura de la VM confirmó Docker disponible y capacidad de recursos, pero no habilitó su uso: crear el stack temporal cambiaría esa VM y queda fuera de las restricciones de esta validación.

## Límites

La declaración no es evidencia jurídica independiente. Antes de publicar debe documentarse y revisarse la autorización/licencia aplicable. La migración se debe ejecutar y verificar en un entorno aislado antes de proponer integración. No se autoriza aquí push, PR, merge, despliegue, publicación real ni instalación móvil.

```ini
ADMIN_POI_04_3_OWN_PHOTO_UPLOAD = IMPLEMENTED_LOCAL
ADMIN_POI_04_3_EXTERNAL_SOURCE = PRESERVED
ADMIN_POI_04_3_RIGHTS_REVIEW = REQUIRED_BEFORE_PUBLICATION
ADMIN_POI_04_3_MEDIA_COMPATIBILITY = AUTOMATED_TESTS_PASS_POSTGIS_PENDING
ADMIN_POI_04_3_TESTS = PASS_WITH_POSTGIS_SKIPPED
ADMIN_POI_04_3_READY_FOR_PR = BLOCKED
```

## Validación aislada de integración — 2026-11-21

Esta ejecución posterior usó recursos efímeros propios en la VM de desarrollo, no el stack persistente ni su base de datos, bucket, red o credenciales. Se mantuvo el resultado anterior como registro histórico; los resultados siguientes lo complementan y lo sustituyen únicamente para las comprobaciones repetidas aquí.

| Criterio | Estado | Evidencia y límites |
|---|---|---|
| `ADMIN_POI_04_3_FLYWAY_V014` | PASS | PostgreSQL/PostGIS aislado partió vacío. Flyway V001–V013 se aplicaron; se insertó una fila multimedia sintética `EXTERNAL_SOURCE` con esquema V013 y el arranque normal aplicó V014. La fila y su auditoría se conservaron. Las cuatro restricciones negativas de V014 rechazaron combinaciones inválidas. |
| `ADMIN_POI_04_3_POSTGIS` | PASS | `PostgisIntegrationTests`: 26 ejecutadas, 0 fallos, 0 errores, 2 omitidas. La primera ejecución encontró una expectativa fija de 13 migraciones; se actualizó a 14 y la repetición pasó. |
| `ADMIN_POI_04_3_MINIO_E2E` | PASS | MinIO temporal privado; bucket aislado. Acceso anónimo al objeto rechazado. El backend autenticado leyó los bytes del archivo sintético. El bucket y volumen temporal fueron eliminados al cerrar la prueba. |
| `ADMIN_POI_04_3_API_UPLOAD` | PASS | Flujo OIDC Authorization Code + PKCE sintético y API autenticada. Carga propia JPEG/PNG quedó `DRAFT/UNVERIFIED`, sin URL externa, con declaración, actor y fecha. Solicitudes inválidas produjeron HTTP 400 estructurado sin crear assets. No se publicaron imágenes. |
| `ADMIN_POI_04_3_EXTERNAL_COMPATIBILITY` | PASS | Un asset externo previo con URL HTTPS sobrevivió V014 y una nueva carga `EXTERNAL_SOURCE` válida fue aceptada en estado borrador. Se rechazaron origen externo sin URL y origen propio con URL. |
| `ADMIN_POI_04_3_OPENAPI_VALIDATION` | PARTIAL | Redocly CLI 1.34.5 informó 109 errores y 81 advertencias en la rama, frente a 112 errores y 81 advertencias en `origin/main`; son hallazgos globales heredados de lint. La evidencia focalizada previa no identificó hallazgos en el multipart nuevo ni en `AdminMediaAsset`, pero el reporte JSON disponible está truncado por el límite de problemas y no permite certificar de nuevo la validación integral. |
| `ADMIN_POI_04_3_AUTHENTICATED_PORTAL_SMOKE` | BLOCKED | La prueba de login OIDC y llamadas protegidas se ejecutó por HTTP con identidad sintética; no equivale a interacción visual autenticada. El runtime de automatización de navegador falló al iniciar con `failed to write kernel assets: The system cannot find the path specified (os error 3)` en dos intentos. |
| Servicios persistentes | PASS | Los nueve contenedores preexistentes `geoguide-ai` permanecieron activos; los que tenían healthcheck siguieron healthy. No se modificó su configuración. Las métricas al finalizar fueron consistentes con el consumo observado durante el precheck. |
| Limpieza VM | PASS | Se detuvo el backend temporal tras verificar PID, directorio de trabajo y comando. Compose eliminó exclusivamente los tres contenedores, volúmenes y red con prefijo `adminpoi043_93003994`; no quedaron listeners en los puertos temporales. Se eliminó el directorio remoto temporal. |
| Limpieza Windows | BLOCKED | El túnel primario terminó y los otros procesos Vite/túnel asociados a sesiones terminaron. La política de ejecución rechazó `Remove-Item` para el staging local `D:\Codex\adminpoi043-validation-93003994`; no se intentó otra vía. Ese directorio conserva artefactos y credenciales sintéticas de esta prueba y requiere retirada manual por el propietario. También quedó un `admin-portal/tsconfig.tsbuildinfo` generado por build como archivo no rastreado; no está incluido en el commit. |
| Publicación o datos reales | NOT_RUN | Se usaron un POI y archivos sintéticos. No se modificaron POIs reales, no se publicaron imágenes y no se usaron las cinco fotografías del piloto. |

El primer arranque local del backend temporal enlazó brevemente a `0.0.0.0`; se detuvo inmediatamente al detectarlo, antes de enviar solicitudes. El backend se reinició enlazado a `127.0.0.1`, se validó así y se detuvo al terminar. No se modificó el servicio persistente.

```ini
ADMIN_POI_04_3_FLYWAY_V014 = PASS
ADMIN_POI_04_3_POSTGIS = PASS
ADMIN_POI_04_3_MINIO_E2E = PASS
ADMIN_POI_04_3_API_UPLOAD = PASS
ADMIN_POI_04_3_EXTERNAL_COMPATIBILITY = PASS
ADMIN_POI_04_3_OPENAPI_VALIDATION = PARTIAL
ADMIN_POI_04_3_AUTHENTICATED_PORTAL_SMOKE = BLOCKED
ADMIN_POI_04_3_READY_FOR_PR = NO
ADMIN_POI_04_3_VM_TEMP_CLEANUP = PASS
ADMIN_POI_04_3_WINDOWS_TEMP_CLEANUP = BLOCKED
```

La rama no queda lista para PR mientras permanezcan sin resolver la limpieza local del staging sintético y el smoke visual autenticado. No se ejecutaron push, PR, merge, despliegue ni instalación física.
