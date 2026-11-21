# ADMIN-POI — Información operativa y recuperación de sesión

**Estado actualizado:** integrada en `main` y desplegada en la VM de integración; ver evidencia posterior al merge al final de este documento.
**Baseline:** `origin/main` `b6a6dfbf5b26289a456081c9ad4bb9dfe568145e`.
**Rama:** `codex/admin-poi-operational-info`.

## Alcance

Esta extensión permite mantener horarios semanales, funciones/actividades y
promociones asociadas a un POI ya existente. Es información operativa mutable,
distinta de la identidad, ubicación y decisión editorial que se revisan durante
el alta. El editor o administrador puede guardarla en línea sin desactivar el
POI, reiniciar revisiones ni solicitar otra aprobación. Cada cambio conserva
actor, hora, versión y valores anterior/nuevo en una auditoría append-only.

La API administrativa usa `GET/PUT /api/v1/admin/pois/{poiId}/operational-info`;
el `PUT` permite `ADMINISTRATOR` y `EDITOR`, y el `GET` también permite
`REVIEWER`. Se usa control optimista `expectedVersion`. La API pública
`GET /api/v1/pois/{poiId}/operational-info` responde solo para POIs activos y
omite funciones/promociones retiradas. El perfil vacío no inventa horarios ni
actividades. El snapshot offline P9, Route Discovery, Driving, DTOs existentes,
geometrías y estado de activación no cambian; la pantalla Detail consulta estos
datos por separado en línea y muestra una indicación de no disponibilidad sin
red.

Horarios usan zona IANA y siete días, cada uno con cero o más intervalos locales
`HH:mm`. No se permiten intervalos superpuestos ni cruces de medianoche en un
solo intervalo. Funciones y promociones admiten descripción, texto de fechas/
programación, vigencia, condiciones y estado activo. El portal no crea contenido
ni datos de acceso por defecto. Corresponde al administrador/editor ingresar
datos confirmados por el operador del POI.

## Diagnóstico acotado del HTTP 401

La inspección del cliente portal encontró renovación silenciosa OIDC desactivada
y solicitudes que reutilizaban el access token guardado sin comprobar su
expiración. Eso explica el patrón observado de recuperación temporal al cerrar
y abrir sesión, pero no demuestra por sí solo la causa servidor de cada 401:
no se consultaron logs ni claims del token de la VM.

La implementación candidata renueva silenciosamente bajo demanda antes de la
expiración, comparte una renovación concurrente para evitar carreras y, ante
401, renueva y repite una vez solo lecturas GET. No repite automáticamente POST/PUT/PATCH para evitar
duplicar transiciones; informa que se renovó la sesión y permite reintentar sin
cerrar sesión. La URI de retorno silencioso debe estar permitida en el cliente
OIDC desplegado: `/admin/auth/silent-callback`. Ese ajuste de Keycloak/VM queda
pendiente para un despliegue autorizado. Si el 401 persiste tras instalar esta
corrección, se requiere correlacionar el endpoint y `WWW-Authenticate`/logs
sanitizados con issuer, audience, expiración y reloj del backend.

## Implementación y verificación local

- Migración aditiva V012 para horarios/actividades y auditoría; no aplicada a
  una base compartida.
- Backend con validación, RBAC, control de versión y lectura pública filtrada
  por activación.
- Portal con edición desde cada POI del inventario existente.
- Rutea Detail consulta la ficha operativa online; los snapshots P9 permanecen
  intactos.
- Backend `mvnw verify`: BUILD SUCCESS; 133 pruebas, 0 fallos, 29 omitidas.
  Las 25 pruebas `PostgisIntegrationTests` se omitieron porque Docker no está
  disponible en este entorno; V012 y la persistencia/auditoría aún requieren
  ejecución en una base aislada.
- Portal: 19/19 pruebas Vitest PASS y `npm run build` PASS.
- Flutter: suite completa 315 PASS / 3 omitidas; tras añadir el botón de
  reintento, el test focalizado de Detail pasó 5/5 y `flutter analyze` PASS.
- `dart format` aplicado a los archivos Flutter afectados; `git diff --check`
  PASS. No se añadieron dependencias.
- El primer recorrido de la suite móvil tuvo una falla transitoria en una prueba
  de caché no relacionada; esa prueba aislada pasó y el siguiente recorrido
  completo terminó PASS.
- No se desplegó ni se validó en el portal remoto o en HONOR. La configuración
  de callback OIDC, V012 desplegada y contenido real de horarios/funciones/
  promociones no están verificados en integración. El access token y el 401 real
  del servidor tampoco se correlacionaron con logs; la corrección local elimina
  el defecto de renovación del cliente, pero no acredita issuer/audience/reloj
  del proveedor en el entorno integrado.

```ini
ADMIN_POI_OPERATIONAL_INFO_IMPLEMENTATION = LOCAL_VALIDATION_PASS_DB_PENDING
ADMIN_POI_401_CLIENT_REMEDIATION = LOCAL_VALIDATION_PASS_DEPLOYMENT_PENDING
ADMIN_POI_OPERATIONAL_INFO_DEPLOYMENT = NOT_AUTHORIZED
P9_OFFLINE_SNAPSHOT_CHANGE = NONE
```

Los estados anteriores y los pendientes descritos en esta sección corresponden
al corte inicial de la implementación. El resultado posterior al merge y el
despliegue autorizado se registra a continuación; las pruebas históricas no se
reclasifican retroactivamente.

## Evidencia posterior al merge y despliegue de integración

**Fecha:** 2026-11-20

**Portal:** <https://geoguide.getcom.pe:5443/admin/>

**Baseline final:** `origin/main` y checkout desplegado en
`1ac1f771c3bcf6341619f9ae8386dda5cdde8629`.

### Integración

- PR #126 integrado mediante merge normal: `130cbfac72e5ac6949f817e8af586e98b26088e2`.
- PR #127 integró la corrección del conteo de migraciones en pruebas PostGIS:
  `2b258ee6d3a93d82cde10e246454b1ad2ac40ac9`.
- PR #128 integró el callback silencioso exacto de OIDC:
  `1ac1f771c3bcf6341619f9ae8386dda5cdde8629`.
- GitHub no reportó checks configurados para estos PR; se registra
  `NO_CHECKS_REPORTED`, no CI PASS.

### V012, respaldo e integridad

- Antes de V012 se creó el respaldo
  `/home/manager/backups/admin-poi-operational-info-20261120/geoguide-pre-v012-20261120.dump`
  (904.541 bytes, SHA-256
  `58ae0b30b1e2c5686734e9a694f2ccb76827d22bc5954edfc62434e01f9e3980`).
- La restaurabilidad se comprobó en un contenedor PostGIS aislado, sin red ni
  volúmenes compartidos: restauración completada en versión V011 con los seis
  POIs y la identidad/activación de Cantamarca preservadas.
- Flyway aplicó V012 correctamente en la base persistente de integración.
- Después de la migración se conservaron seis POIs y Cantamarca
  (`fdfeb867-576f-4fb5-bcbf-8784e54c2f3a`) permaneció `active=true`.
- Las tablas de información operativa y auditoría quedaron vacías; no se
  introdujeron horarios, eventos o promociones ficticias.
- La API pública de Cantamarca respondió HTTP 200 con siete días sin intervalos,
  cero elementos y versión 0. Los datos se exponen en línea y el snapshot offline
  permanece sin cambios.

### Validación de sesión y HTTP 401

- Keycloak y el portal permiten el callback normal y
  `/admin/auth/silent-callback`, con URI exactas y sin comodines.
- Authorization Code + PKCE real con cuenta sintética de administrador validó
  issuer, audience `geoguide-admin-api` y rol `ADMINISTRATOR`.
- El filtro administrativo devolvió HTTP 200 y encontró Cantamarca activo.
- La renovación silenciosa `prompt=none` funcionó con la misma sesión y el
  filtro continuó en HTTP 200.
- Al esperar la expiración más la tolerancia JWT de 60 segundos, el access token
  anterior fue rechazado con HTTP 401. Sin cerrar sesión, un nuevo flujo
  silencioso obtuvo token y el filtro volvió a HTTP 200.
- Después del logout, el intento silencioso devolvió `login_required`.
- Esto demuestra que expiración de access token produce 401 y que el callback
  silencioso desplegado recupera lecturas. No permite atribuir cada 401 histórico
  a una sola causa ni sustituye una prueba de interacción visual del navegador.
- Las pruebas del portal (19/19 Vitest) y el build pasaron; la renovación previa,
  el reintento único de lecturas GET tras 401 y la protección contra reintento de
  escrituras están cubiertos localmente.

### Validación técnica y estado operativo

- Backend: `mvnw verify` local, 133 pruebas, 0 fallos y 29 omitidas; las pruebas
  PostGIS focalizadas en VM pasaron (25 ejecutadas, 0 fallos, 2 omitidas).
- El build del contenedor backend pasó con 133 pruebas, 0 fallos y 29 omitidas;
  los tests que requieren Docker se omitieron en ese contexto de build.
- Flutter: analyze PASS; suite 315 PASS / 3 omitidas; pruebas focalizadas de
  Detail 5/5 PASS.
- Portal y backend quedaron saludables. El checkout desplegado está limpio y en
  el baseline final indicado.
- No se instaló APK en HONOR. No se ejecutaron cambios en producción ni se
  modificaron contratos P8/P9.

```ini
ADMIN_POI_OPERATIONAL_INFO_MAIN = PASS
ADMIN_POI_OPERATIONAL_INFO_V012 = PASS
ADMIN_POI_OPERATIONAL_INFO_VM = PASS
ADMIN_POI_SESSION_RENEWAL = PASS
ADMIN_POI_OPERATIONAL_EDIT_E2E = PASS_SYNTHETIC_TESTS; NO_REAL_DATA_WRITTEN
ADMIN_POI_RUTEA_ONLINE_QUERY = PASS_EMPTY_PROFILE
P9_OFFLINE_SNAPSHOT_CHANGE = NONE
PHYSICAL_HONOR_INSTALLATION = NOT_AUTHORIZED
```
