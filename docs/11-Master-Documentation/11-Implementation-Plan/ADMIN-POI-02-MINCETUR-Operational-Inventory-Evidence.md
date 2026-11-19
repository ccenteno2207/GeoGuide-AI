# ADMIN-POI-02 — Habilitación operativa del inventario MINCETUR

**Fecha:** 2026-11-19
**Baseline de código desplegado:** `a531c5065c78df14fad01faea6304c7726b5d4e8`
**Baseline documental al iniciar:** `b2056aa3e17e442fb6c7cb95997c3bde2b52310b`
**Portal:** <https://geoguide.getcom.pe:5443/admin/>

## Identidad y lectura de la fuente

Se localizó el snapshot original en `D:\Proyectos\Desarrollo\Ruteo\Imagenes\Inventario_recursos_turisticos.csv`. El archivo conservó el SHA-256 aprobado `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66`, tamaño 1.565.274 bytes, corte `2026-11-10`, codificación Windows-1252, delimitador `;`, 12 encabezados y 6.341 registros.

La evidencia de ADMIN-POI-01 atribuía el intento de lectura anterior a un bloqueo mientras el CSV estaba abierto en Excel. En esta ejecución la lectura de hash funcionó con los permisos existentes; no se eludió un bloqueo ni se cambió el original. La causa histórica exacta no puede reconstruirse sin una traza de handles de aquel momento. Se transfirió una copia temporal con hash comprobado por SSH a un directorio privado de la VM, montado solo lectura para el runner. La copia temporal se retiró al acabar; el original no se modificó ni se añadió al repositorio.

## Estado previo, respaldo y recuperación

- La base de integración `geoguide` estaba en Flyway V010 (`success=true`), sin lotes MINCETUR; tenía 5 POIs y 9 destinos.
- Antes de importar se generó el dump `/home/manager/backups/admin-poi-02-20261119/geoguide-before-mincetur-import.dump`, permisos `600`, SHA-256 `15ed9c83db928e475f3cd552ab2653c7c5381326d039fb3469d9b4a9e262456c`.
- La recuperación se ensayó antes de escribir: el dump se restauró con `pg_restore --exit-on-error --no-owner --no-acl` en una base PostGIS temporal creada desde `template0`, en un contenedor sin red y limitado a 512 MiB/1 CPU. Se verificaron 5 POIs, 9 destinos y Flyway 010; el contenedor temporal se eliminó.
- Huellas deterministas de todas las filas de `geo.point_of_interest` y `geo.destination` antes/después del staging coincidieron: `550b1d6b3da331256a6f72f5ae4eee02` y `dae41fcbb381cfc4d5113c1202d64d44`.

## Importación e idempotencia

Se utilizó el `MinceturSnapshotImportRunner` existente desde un contenedor de ejecución único. El runner recibió el archivo como volumen de solo lectura; se desactivaron explícitamente los loaders de destinos y P3. No se reinició ni se reconstruyó el backend desplegado y Flyway indicó que V010 ya estaba al día.

| Resultado | Conteo |
| --- | ---: |
| Registros del lote `4210164f-6b16-4e9f-8fbe-986910bbdd0f` | 6.341 |
| `NORMALIZED_PENDING_REVIEW` | 6.331 |
| `COORDINATE_FORMAT_AMBIGUOUS` / cuarentena geográfica | 10 |
| `ELIGIBLE_FOR_REVIEW` temático | 4.573 |
| `EXCLUDED_FROM_NAVIGATION` temático | 1.768 |
| `CLASSIFICATION_REVIEW_REQUIRED` | 0 |

Las dimensiones temática y geográfica permanecen separadas: las diez filas en cuarentena se conservan, ocho con elegibilidad temática y dos excluidas de navegación. El registro 237 conserva sus valores raw (`LATITUD=-7.576.291.501.522.060`, `LONGITUD=-14.087.854.051.458.200`); su candidato normalizado queda pendiente y no se presenta como ubicación aprobada. `batch_status=STAGED_REQUIRES_REVIEW`.

La segunda ejecución del mismo snapshot devolvió el mismo UUID de lote y dejó los conteos sin cambio (`1` lote, `6.341` filas, `5` POIs, `9` destinos). No hubo publicación automática, borradores editoriales ni cambios de datos curados.

## Portal, filtros, permisos y piloto Canta

- `/admin/` respondió HTTP 200; la API de importaciones sin autenticación respondió 401.
- Las cuentas sintéticas existentes `poi-admin-demo`, `poi-editor-demo` y `poi-reviewer-demo` están habilitadas, con correo verificado, sin acciones de perfil pendientes y con los roles `ADMINISTRATOR`, `EDITOR` y `REVIEWER` respectivamente.
- Se completó un flujo OIDC Authorization Code + PKCE real con cada cuenta. Las tres leyeron `/api/v1/admin/imports` (HTTP 200). `EDITOR` y `REVIEWER` recibieron 403 al intentar la operación reservada de activación; la petición se denegó antes de modificar el POI.
- El lote presenta 6.341 filas, 6.331 con coordenadas candidatas, 10 en cuarentena y 6.331 sin asignación editorial. El filtro de estado encontró 10 cuarentenas y 6.331 filas pendientes; el filtro de localidad exacta parcial `Canta` devolvió 17 filas, todas con contexto Canta; la categoría raw `1. SITIOS NATURALES` devolvió 2.221 coincidencias exactas.
- La paginación de 25 filas fue comprobada en páginas consecutivas: 25 resultados por página, sin intersección, 6.331 elementos en total. El API no serializa `totalPages`; el portal aplica su fallback `ceil(totalElements / size)`, que resulta en 254 páginas.
- Los catorce códigos del piloto POI-DATA-3 fueron localizables individualmente por búsqueda administrativa: `1851`, `2725`, `5559`, `5560`, `6009`, `7173`, `13029`, `13016`, `11877`, `12185`, `12189`, `14041`, `14068` y `14060` (14/14).
- La matriz de calificación permanece 3 validados en entorno aislado, 4 coincidencias existentes y 7 pendientes por evidencia insuficiente. Los catorce continúan como filas de staging; no se crearon ni publicaron expedientes editoriales. Los estados de calificación POI-DATA-3 no se transformaron en transiciones editoriales.
- El catálogo persistente al cierre sigue en 5 POIs activos y 9 destinos, con cero filas editoriales. Los cuatro códigos ya coincidentes no crearon duplicados.

## Acceso de administración para el propietario

```ini
ADMIN_PORTAL_OWNER_ACCESS = READY
ADMIN_PORTAL_LOGIN_URL = https://geoguide.getcom.pe:5443/admin/
ADMIN_PORTAL_ADMIN_USERNAME = poi-admin-demo
ADMIN_PORTAL_PASSWORD_SETUP = SECURE_PROCEDURE_DOCUMENTED
```

La contraseña existente de `poi-admin-demo` completó el flujo PKCE y la consulta del inventario. No hizo falta restablecerla: la cuenta no tiene acciones de actualización pendientes. La contraseña permanece fuera de Git, en `/home/manager/.config/geoguide/admin-poi-01.env`, propiedad `manager`, modo `600`.

Procedimiento privado de recuperación para el propietario: desde una terminal confiable y con el acceso SSH ya autorizado, conectarse usando el destino SSH ya provisionado y leer únicamente el valor de `ADMIN_POI_DEMO_ADMIN_PASSWORD` en ese archivo protegido. No copiar el valor a chat, tickets, logs, documentos o repositorio. Para rotarlo, usar la consola administrativa de Keycloak en la realm `geoguide-admin`, usuario `poi-admin-demo`, Credentials → Reset password; marcar `Temporary` y entregar el nuevo valor solo por un canal privado controlado. Esta instrucción no incluye ni registra contraseñas ni publica la dirección de la VM.

La prueba acreditó que la cuenta y el secreto actual son válidos; el propietario debe realizar su primer acceso interactivo desde su equipo confiable. No se crearon usuarios reales.

## Integridad del entorno y alcance

- Se removieron el contenedor temporal y la copia CSV temporal; no quedan contenedores `admin-poi-02`.
- Backend, PostgreSQL, portal, Keycloak, Nginx, Redis, MinIO y GraphHopper continuaron activos; PostgreSQL/backend/portal/Keycloak-Postgres/GraphHopper/Redis/MinIO mostraron estado saludable donde hay healthcheck. No se modificaron DNS, TLS ni puertos públicos.
- No se activó ni publicó ningún candidato; no se modificaron P8/P9, Flutter, API pública o Route Discovery.
- El respaldo se conserva para recuperación. No se añadieron secretos, CSV, imágenes, APK ni artefactos temporales a Git.

```ini
ADMIN_POI_02_MINCETUR_IMPORT = PASS
ADMIN_POI_02_INVENTORY_VISIBLE = PASS
ADMIN_POI_02_CANTA_14_ACCESSIBLE = PASS
ADMIN_POI_02_PUBLIC_ACTIVATION = NOT_EXECUTED
ADMIN_POI_02_VM_VALIDATION = PASS
ADMIN_PORTAL_OWNER_ACCESS = READY
```
