# ADMIN-POI-04 — Evidencia del editor visual de fichas turísticas

## Alcance

Trabajo local sobre la base `origin/main` `097063f3e4c4391864fbd6e4779c2ed1f62bb1e5`. El incremento añade contenido turístico versionado y auditado, galería editorial privada con texto alternativo/orden, vista previa en el portal y lectura en línea desde Detail y Route Discovery. Reutiliza la gestión operativa V012. No altera identidad, coordenadas, categoría, aprobación estructural, activación, Driving ni el contrato offline P9. No se incorporaron fotografías originales o sin derechos verificados.

## Cambios

- V013 es aditiva: revisiones, borrador vigente, proyección pública y auditoría append-only; agrega texto alternativo y orden de galería a los activos existentes.
- API editorial protegida por OIDC/RBAC; lectura pública limitada a POIs activos y contenido/fotos publicados. Guardado usa versión esperada; publicación exige revisión explícita; revertir crea borrador nuevo.
- Portal: editor turístico separado de datos estructurales, vista previa móvil, historial/reversión y acceso al administrador de media existente. Las fotos de vista previa se consultan con sesión autenticada.
- Flutter: Detail y tarjetas consumen texto turístico en línea; fotos publicadas se cargan desde el backend. El snapshot offline excluye resumen y referencias de media.

## Validación local

| Comprobación | Resultado |
| --- | --- |
| `mvn verify` | PASS: 134 pruebas, 0 fallos; 30 omitidas porque Docker no está disponible localmente. |
| `PostgisIntegrationTests` en PostGIS aislado de VM | PASS: 26 pruebas, 0 fallos, 2 omitidas; Flyway aplicó V001–V013 desde base vacía. |
| Portal `npm test -- --run` | PASS: 6 archivos, 21 pruebas. |
| Portal `npm run build` | PASS. |
| Flutter `dart format` en archivos afectados | PASS. |
| Flutter `flutter analyze` | PASS, sin issues. |
| Flutter `flutter test --reporter compact` | PASS: 318 pruebas; 3 omitidas por condiciones existentes del entorno. |
| APK debug con `--dart-define=BACKEND_BASE_URL=https://geoguide.getcom.pe:5443` | PASS: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, 194,381,771 bytes; SHA-256 `9e264275675fdd4142f900cec4c100d88ed32718600d883ae58b83c01ac3ba6b`. No instalar en HONOR. |

## Validación aislada de VM

El precheck observó PostGIS V012, seis POIs activos (incluido Cantamarca 1851) y PostGIS habilitado; los servicios existentes estaban saludables. Se creó el backup `/home/manager/backups/admin-poi-04-20261121/pre-v013.dump` (889,975 bytes, SHA-256 `3bddc61ad8a686f8783c8afae58bd57bb0e1a69ceef089ffde75645eb70cf55a`), con copia externa en `D:\Codex\backups\admin-poi-04-20261121\pre-v013.dump`. Se restauró en PostGIS temporal aislado desde `template0`: TOC de 157 entradas, Flyway V012, seis POIs, Cantamarca 1851 activo y consulta PostGIS satisfactoria. Se ejecutaron 26 pruebas PostGIS sobre una segunda base temporal vacía; V001–V013 se aplicaron, 0 fallaron y 2 fueron omitidas. El contenedor, la red y el túnel de prueba se retiraron. Después, la base persistente siguió en V012, con seis POIs y Cantamarca activo; todos los servicios preexistentes permanecieron saludables. No se aplicó V013 a la base persistente ni se desplegó el código integrado. Las pruebas usaron POIs sintéticos, no contenido editorial de registros reales.

## Riesgos y límites

- Los POIs actuales conservan su texto público; sin revisión y publicación de una revisión no aparecerá contenido nuevo.
- No se publicaron fotografías. Licencia/atribución se valida por el flujo de media existente.
- En la primera puesta en marcha del código integrado, la API pública de contenido respondió 200, pero la galería multimedia devolvió 404 porque el backend no tenía `GEOGUIDE_MEDIA_STORAGE_ENABLED` configurado. El defecto de despliegue fue aislado: MinIO estaba disponible, pero el backend no exponía la integración.
- El contrato P9 no cachea contenido ni imágenes turísticos; Detail enriquecido requiere conexión.
- La validación física Android no está autorizada y permanece pendiente.
- V013 ya se aplicó en la base de integración; el despliegue de media queda pendiente de la configuración opcional con credenciales restringidas y bucket privado.

```ini
ADMIN_POI_VISUAL_EDITOR = IMPLEMENTED_LOCAL
ADMIN_POI_MEDIA_MANAGEMENT = IMPLEMENTED_LOCAL
ADMIN_POI_MOBILE_PREVIEW = AUTOMATED_TESTS_PASS
ADMIN_POI_CONTENT_PUBLICATION = AUTOMATED_TESTS_AND_POSTGIS_PASS
RUTEA_DETAIL_ENRICHMENT = AUTOMATED_TESTS_PASS
ADMIN_POI_VM_DEPLOYMENT = PARTIAL_V013_APPLIED_MEDIA_CONFIGURATION_PENDING
```

## Integración y despliegue en VM — 2026-11-21

- PR #130 se integró mediante merge normal (`ec64e887016f511c92db0fbdc38233561f76dd1d`). PR #131 añadió la configuración opcional de MinIO y el rechazo seguro cuando el bucket no existe; merge normal `583cd5d6e8bee6f2def31c472d219326ccd7eae1`. No hubo checks de GitHub (`NO_CHECKS_REPORTED`). `origin/main` y el checkout aislado `/home/manager/deploy/admin-poi-01` terminaron en `583cd5d6e8bee6f2def31c472d219326ccd7eae1`, limpio. El checkout `/home/manager/geoguide-ai` no se modificó.
- Antes de aplicar V013 se verificó el backup restaurado `/home/manager/backups/admin-poi-04-20261121/pre-v013.dump`, 889,975 bytes, SHA-256 `3bddc61ad8a686f8783c8afae58bd57bb0e1a69ceef089ffde75645eb70cf55a`. La prueba de restauración aislada validó V012, seis POIs, PostGIS y Cantamarca activo.
- Flyway aplicó V013 en la base persistente de integración. Después permanecieron seis POIs, Cantamarca `fdfeb867-576f-4fb5-bcbf-8784e54c2f3a` siguió activo; revisiones de contenido y proyecciones publicadas: cero. No se añadieron textos, horarios, promociones, fotografías ni cambios editoriales a registros reales.
- Se habilitó el storage con el bucket privado `geoguide-poi-media-private` y una identidad de aplicación limitada a ese bucket. La configuración está fuera del repositorio en `/home/manager/.config/geoguide/admin-poi-04-media.env` (modo `0600`); no se registran sus valores. Una prueba sintética de almacenamiento verificó escritura/lectura/eliminación y denegación de acceso al bucket ajeno; el objeto temporal se eliminó. La política anónima del bucket es `private`.
- Build del backend desplegado: Maven `BUILD SUCCESS`, 135 pruebas, cero fallos y 30 omitidas; la prueba PostGIS aislada ejecutó 26, cero fallos y dos omitidas. Se ejecutó `docker compose config -q` con los archivos externos de entorno, sin mostrar valores. El contenedor backend y el portal quedaron saludables; no se reiniciaron PostgreSQL, Keycloak, MinIO, GraphHopper, Redis ni Nginx.
- Smoke HTTPS: `/admin/` HTTP 200; API administrativa anónima HTTP 401; contenido público de Cantamarca HTTP 200; galería pública HTTP 200 y vacía. Health backend `UP`. El bucket no se expuso públicamente.
- Se identificó y corrigió el motivo inicial del 404 de galería: el despliegue omitía `GEOGUIDE_MEDIA_STORAGE_ENABLED`. PR #131 la deja apagada por defecto y la habilita solo con configuración explícita. El adaptador ya no crea buckets con la credencial runtime.
- La validación OIDC previa está documentada en `ADMIN-POI-Operational-Information-and-401-Remediation.md` (renovación silenciosa real, RBAC y recuperación de GET 401); no se repitió una sesión interactiva para este editor. No se capturó una nueva pantalla autenticada del editor/preview porque la herramienta de navegador no pudo inicializarse en esta sesión. Por tanto, la evidencia visual del portal y la publicación autenticada desde un navegador quedan pendientes; no se infiere PASS de esas acciones.
- No se instaló APK en HONOR. El contenido turístico nuevo requiere conexión y no se incorporó a los snapshots offline. No se subió ninguna fotografía real o sin derechos acreditados.

```ini
ADMIN_POI_VISUAL_EDITOR = PARTIAL_AUTHENTICATED_BROWSER_SMOKE_PENDING
ADMIN_POI_MEDIA_MANAGEMENT = PARTIAL_NO_LIVE_PHOTO_UPLOAD
ADMIN_POI_MOBILE_PREVIEW = AUTOMATED_TESTS_PASS_SCREENSHOT_NOT_CAPTURED
ADMIN_POI_CONTENT_PUBLICATION = POSTGIS_INTEGRATION_PASS_NO_REAL_RECORD_WRITTEN
RUTEA_DETAIL_ENRICHMENT = AUTOMATED_TESTS_PASS_PHYSICAL_NOT_AUTHORIZED
ADMIN_POI_VM_DEPLOYMENT = PASS
V013_INTEGRATION = PASS
MINIO_BUCKET_PRIVACY = PASS
OIDC_EDITOR_INTERACTIVE_SMOKE = NOT_EXECUTED
ANDROID_PHYSICAL_VALIDATION = NOT_AUTHORIZED
```
