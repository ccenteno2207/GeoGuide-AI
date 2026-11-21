# ADMIN-POI — Información operativa y recuperación de sesión

**Estado:** implementación local candidata; pendiente de revisión e integración.
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
