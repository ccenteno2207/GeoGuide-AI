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

## Límites

La declaración no es evidencia jurídica independiente. Antes de publicar debe documentarse y revisarse la autorización/licencia aplicable. La migración se debe ejecutar y verificar en un entorno aislado antes de proponer integración. No se autoriza aquí push, PR, merge, despliegue, publicación real ni instalación móvil.

```ini
ADMIN_POI_04_3_OWN_PHOTO_UPLOAD = IMPLEMENTED_LOCAL
ADMIN_POI_04_3_EXTERNAL_SOURCE = PRESERVED
ADMIN_POI_04_3_RIGHTS_REVIEW = REQUIRED_BEFORE_PUBLICATION
ADMIN_POI_04_3_MEDIA_COMPATIBILITY = AUTOMATED_TESTS_PASS_POSTGIS_PENDING
ADMIN_POI_04_3_TESTS = PASS_WITH_POSTGIS_SKIPPED
ADMIN_POI_04_3_READY_FOR_INTEGRATION = NO
```
