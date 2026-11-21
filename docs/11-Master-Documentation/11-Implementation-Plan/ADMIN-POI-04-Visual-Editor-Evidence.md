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
- El contrato P9 no cachea contenido ni imágenes turísticos; Detail enriquecido requiere conexión.
- La validación física Android no está autorizada y permanece pendiente.
- V013 y el despliegue integrado siguen pendientes después del merge.

```ini
ADMIN_POI_VISUAL_EDITOR = IMPLEMENTED_LOCAL
ADMIN_POI_MEDIA_MANAGEMENT = IMPLEMENTED_LOCAL
ADMIN_POI_MOBILE_PREVIEW = AUTOMATED_TESTS_PASS
ADMIN_POI_CONTENT_PUBLICATION = AUTOMATED_TESTS_AND_POSTGIS_PASS
RUTEA_DETAIL_ENRICHMENT = AUTOMATED_TESTS_PASS
ADMIN_POI_VM_DEPLOYMENT = PENDING_MERGE_AND_V013
```
