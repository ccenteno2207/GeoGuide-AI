# ADMIN-POI-04.2 — Evidencia local de multimedia y errores del portal

## Baseline y límites

- `origin/main` verificado: `835d48e75f156376865a0c8529388b8e2fd24144`.
- Rama local aislada: `codex/admin-poi-04-2-media-errors`.
- `ADMIN-POI-04.1-Validation-Evidence.md` y el contrato de imágenes locales se revisaron antes de implementar.
- Solo se modificaron localmente portal, backend de validación multimedia, OpenAPI y esta evidencia. No se escribieron registros reales, no se subieron imágenes, no se desplegó ni instaló APK.

## Diagnóstico de fotografías

No hay evidencia de eliminación física causada por ADMIN-POI-04.1. La evidencia 04.1 registra que la API pública devolvía `photos=[]` para Iglesia San Juan Bautista de Obrajillo; la consulta de solo lectura en esta ejecución volvió a devolver HTTP 200 y cero fotos publicadas para Iglesia (`02000000-0000-0000-0000-000000000005`) y Santuario de Santa Rosa de Quives (`02000000-0000-0000-0000-000000000001`). La galería administrativa no tenía assets en el checkpoint 04.1.

Los cinco PNG originales siguen fuera del repositorio en `D:\Proyectos\Desarrollo\Ruteo\Imagenes`; sus SHA-256 coinciden con el inventario del piloto:

| UUID POI | Original disponible | SHA-256 |
|---|---|---|
| `02000000-0000-0000-0000-000000000001` | `Santa rosa de quives.png` | `0EE69A45559A9E4A715F7B4193930EAFB79145D277A9A18D8543D57E4DC592C5` |
| `02000000-0000-0000-0000-000000000002` | `petroglifos de checta.png` | `3B2940F2AD8EC60F0CF877F74F82DC3E307E8843250AF4E55140ED6DCDAB74BE` |
| `02000000-0000-0000-0000-000000000003` | `Plaza de armas de canta.png` | `B09D081FDA65691A1D4BA0EA528B6EB875DFB2145F28846C3ADF7AC31D955858` |
| `02000000-0000-0000-0000-000000000004` | `Plaza de Armas de obrajillo.png` | `D8BA0829948F38CB0DCDAD5520F2059387614D94C0D07311B424DB20DB01FF16` |
| `02000000-0000-0000-0000-000000000005` | `Iglesia San juan Bautista de obrajillo.png` | `14742670885D8F782CA2013908ABEDFA365FB29F249B5F83886C9CCA58E4F875` |

El catálogo local de demostración está aislado detrás de `UI2_POI_LOCAL_IMAGES_DEMO`, cuyo valor estándar predeterminado es `false`; los assets solo se copian al staging y APK interna de demostración. Los builds normales dependen de la API y conservan el placeholder cuando no hay fotografía publicada. Así se explica la diferencia entre la foto mostrada en una APK de demostración y el placeholder en la APK estándar; no se atribuye la ausencia a borrado.

Las capturas recientes incluidas con la solicitud muestran fotografías para Iglesia/Santuario y un placeholder para Cantamarca. Son compatibles con fuentes/builds distintos; sin metadatos del APK de cada captura no se puede atribuir cada imagen a MinIO, a assets internos o a una asociación concreta. No se cambió la galería pública ni se promovieron imágenes originales: sus derechos de publicación siguen sin acreditarse.

## Diagnóstico del HTTP 400

El payload histórico y la respuesta del intento real no quedaron capturados, por lo que no es posible atribuir con certeza el incidente anterior a un campo concreto. Sí se reprodujo localmente un HTTP 400 determinista cuando la carga multipart carece de `author` o cuando `sourceUrl` no es una URL HTTPS válida (el backend permite además referencias `fixture:` solo en pruebas). El formulario anterior no prevenía todos esos casos antes de enviar y los errores de servidor se presentaban de forma genérica. Este es un defecto reproducible y corregido, no una afirmación sobre el payload perdido.

La carga inicial exige POI seleccionado, archivo JPEG/PNG decodificable, autor/titular y referencia HTTPS. La referencia `fixture:` solo se usa en pruebas; el límite configurado por defecto es 10 MiB, el backend vuelve a validar bytes reales, dimensiones y MIME, re-encodea para quitar EXIF/GPS y guarda un objeto privado en estado `DRAFT`, con `rightsStatus=UNVERIFIED`. La carga no solicita ni modifica licencias, atribución o evidencia de derechos. Esos metadatos se registran después en la acción separada de documentación/revisión; publicar sigue siendo una transición distinta. No se relajaron controles.

## Correcciones locales

- Error estable `AdminApiError` con HTTP, código, campos y `X-Request-Id` opcional; el modal presenta copy seguro y deja detalles técnicos colapsados.
- Modal reutilizable centrado, accesible como `alertdialog`, con gestión de foco, tabulación, Escape seguro, mensajes específicos para 400/401/403/404/409/413/5xx/conexión y CTA de autenticación cuando la renovación falla.
- Para un GET, OIDC renueva y repite una sola vez con token nuevo. Una escritura nunca se repite automáticamente: si la renovación tuvo éxito, el modal indica comprobar el estado; si falló, ofrece iniciar sesión. Los formularios conservan valores y el archivo ante errores.
- Errores de carga multimedia tienen códigos y campos estables. El servidor devuelve Problem Details sin detalles de MinIO, rutas privadas ni stack trace; 413 está separado de 400.
- El formulario muestra finalidad, obligatoriedad, formato y ejemplo para POI, autor, fuente, texto alternativo, archivo y documentación de derechos; valida en cliente, resalta errores y agrupa campos incorrectos en el modal. Tamaño efectivo por defecto del backend y formulario: 10 MiB. Archivo elegido se previsualiza localmente y su URL `blob:` se revoca al cambiar/desmontar.
- La licencia sigue siendo campo de texto porque el contrato/API actual no contiene un catálogo normativo de licencias permitidas. El portal exige valor, atribución, evidencia y razón antes de documentar derechos; no inventa una lista de permisos. La definición de un catálogo cerrado requiere una decisión de producto/legal.
- Éxitos muestran toast no bloqueante. No hay reintento automático de escrituras ni publicación de fotografías.
- OpenAPI documenta campos multipart, formato y errores estructurados 400/413.

## Validaciones

| Validación | Resultado |
|---|---|
| `admin-portal`: `npm test` | PASS — 10 archivos, 41 tests. Incluye renovación GET, no repetición de escrituras, modal/campos/foco/teclado, carga 400 conservando formulario/archivo y preview local. |
| `admin-portal`: `npm run build` | PASS — TypeScript + Vite. |
| Backend: `mvnw verify` | PASS — 135 tests, 0 fallos, 30 omitidos (26 PostGIS porque Docker no está disponible localmente; 4 omisiones existentes). |
| Backend focalizado `PoiMediaServiceTests,AdminApiExceptionHandlerTests,OversizedMultipartHttpIntegrationTests` | PASS — 8 tests, 0 fallos; confirma validación, almacenamiento privado DRAFT/UNVERIFIED, errores por campo y límite multipart 413. |
| `git diff --check` | PASS — sin errores de whitespace. |
| Escaneo focalizado de patrones de secretos | PASS — cero coincidencias en cambios y evidencia revisados. |
| Smoke visual autenticado | BLOCKED — el runtime CUA falló al inicializar (`failed to write kernel assets`, OS error 3); no se ingresaron credenciales ni se subió un archivo. `GET /admin/` devolvió HTTP 200 sin autenticación interactiva; galerías públicas comprobadas en modo lectura. |
| Validación MinIO integrada y API pública tras una publicación autorizada | NOT_RUN — sin upload real ni fotografía publicada. |
| Flutter / HONOR | NOT_RUN — no se modificó Flutter; no se compiló ni instaló APK. |
| Escaneo de derechos/licencia de fotos | NOT_AUTHORIZED — originales conservados sin publicación. |

## Estado

```ini
ADMIN_POI_MEDIA_ROOT_CAUSE = PASS_WITH_SOURCE_BUILD_DISTINCTION
ADMIN_POI_MEDIA_RECOVERY = PARTIAL_NO_PUBLICATION_AUTHORIZED
ADMIN_POI_UPLOAD_VALIDATION = PASS_LOCAL
ADMIN_POI_UPLOAD_ERROR_MESSAGES = PASS_AUTOMATED
ADMIN_POI_PRIVATE_UPLOAD = PASS_UNIT_TEST_ONLY
ADMIN_POI_PUBLICATION_SECURITY = PASS_UNIT_TEST_ONLY
ADMIN_POI_ERROR_MODAL = PASS_AUTOMATED
ADMIN_POI_FIELD_VALIDATION_UX = PASS_AUTOMATED
ADMIN_POI_ERROR_HANDLING_CENTRALIZED = PASS_AUTOMATED
ADMIN_POI_NOTIFICATION_ACCESSIBILITY = PASS_AUTOMATED
ADMIN_POI_ERROR_MODAL_LIVE_SMOKE = BLOCKED
ADMIN_POI_401_ROOT_CAUSE = NOT_VERIFIED_LIVE
ADMIN_POI_HONOR_MEDIA = NOT_RUN
ADMIN_POI_LICENSE_CATALOG = PENDING_PRODUCT_LEGAL_DECISION
ADMIN_POI_VM_DEPLOYMENT = NOT_AUTHORIZED_PENDING_OWNER_REVIEW
```

Antes de push, PR, merge o despliegue se requiere revisión del propietario de este diagnóstico y del alcance. No se declara que el HTTP 400 histórico se haya reproducido con el payload original, que la renovación OIDC se haya probado en el portal vivo, ni que la ruta Portal→MinIO→API pública→HONOR esté validada en esta rama.
