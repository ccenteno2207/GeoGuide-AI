# ADMIN-POI-04.1 — Evidencia de corrección del editor turístico

## Baseline y alcance

- Baseline verificado: `origin/main=dab015fa21d5d38e54ea9758e040d9e996762cdd`.
- Rama: `codex/admin-poi-04-1-tourism-editor-fix`.
- Alcance: precarga curada/editorial, presentación de ficha, galería privada visible, lecturas online sin caché y recuperación acotada de lecturas OIDC tras 401.
- No se modifican los contratos congelados P8/P9, datos operativos, Driving, identidad, ubicación ni activación de POIs. No se agrega migración.
- Cantamarca 1851 y el POI Iglesia San Juan Bautista de Obrajillo no se editan ni republican durante esta remediación. No se incorporan fotos originales ni contenido sintético al catálogo real.

## Matriz de evidencia visual recibida

| Captura | Defecto observado | Causa identificada | Corrección | Prueba / resultado |
| --- | --- | --- | --- | --- |
| 1 — editor vacío | La ficha seleccionada abría con campos vacíos aunque el POI curado tenía descripción. | GET administrativo devolvía solo borrador/publicación, sin el resumen de la ficha curada. | El DTO administrativo incorpora datos curados de solo lectura; el editor los muestra y ofrece inicializar un borrador de forma explícita, sin persistir ni publicar automáticamente. | Test `shows curated existing data without persisting it and offers an explicit draft initialization` — PASS. |
| 2 — Detail móvil | Provenance extensa ocupaba espacio principal de la ficha. | La fuente completa se renderizaba expandida en línea. | Se conserva una atribución breve y se agrupan referencias completas bajo «Fuentes y referencias». | Flutter Detail tests — PASS. |
| 3 — edición de descripción | La vista previa reflejaba el texto, pero no aclaraba si era borrador o versión vigente ni preservaba la identidad oficial. | Título y contenido editorial no tenían una jerarquía suficientemente explícita. | La vista separa nombre oficial, categoría, resumen y contenido; indica borrador/cambios sin guardar y conserva el contenido público publicado. | Portal editor tests — PASS. |
| 4 — resumen como título | El resumen reemplazaba visualmente el nombre del POI. | La previsualización usaba el resumen como encabezado. | El nombre oficial es siempre el título; el resumen aparece como texto destacado independiente. | Test `keeps the official name as preview title and blocks provisional copy from review` — PASS. |
| 5 — versión publicada | El portal mostraba contenido publicado, pero la ficha instalada no demostraba recibir la versión actual. | La respuesta pública dependía solo de contenido editorial y no tenía fallback curado explícito; faltaba distinguir origen y frescura. | API pública responde `contentSource=PUBLISHED|CURATED`, solo lectura online y `no-store` para galerías; Flutter consume el contenido y evita duplicar la descripción curada. | Backend/Flutter automatizado — PASS; API/VM y HONOR pendientes de smoke posterior al despliegue. |
| 6 — lista de POIs | El acceso a gestión de imágenes estaba separado de la ficha y no mostraba activos, derechos ni historial. | El listado daba acceso a la administración privada, pero no ofrecía un resumen visible de galería dentro del editor. | Se añade resumen de miniaturas, principal/orden, estado, derechos, autor/fuente/atribución, historial y CTA a la gestión privada ya existente. No se suben imágenes. | `PoiMediaGallery.test.tsx` — PASS; carga real y acciones de medios quedan para smoke autenticado en VM. |
| 7 — preview publicada | La previsualización publicada no garantizaba que el móvil obtuviera la misma versión. | Se necesitaba distinguir claramente modo borrador/vigente y leer la versión pública en cada consulta en línea. | Selector Borrador/Contenido vigente, título oficial, jerarquía de secciones y lectura pública online sin persistir contenido editorial en snapshots P9. | Tests portal/Flutter — PASS; comparación visual en navegador/HONOR pendiente. |

## Cambios y límites de datos

- El endpoint administrativo compone la ficha curada junto con borrador, publicación e historial. La inicialización desde datos curados es una acción local explícita y no sobrescribe la ficha fuente.
- La lectura pública obtiene la descripción curada como fallback solo cuando no hay versión turística publicada. Borradores no se exponen; POIs inactivos continúan excluidos.
- La galería consulta activos privados y su auditoría mediante endpoints autenticados; el catálogo público solo incluye medios publicados. Se añade `Cache-Control: no-store` a lecturas de contenido multimedia para no servir una respuesta obsoleta.
- La renovación OIDC se coordina para lecturas: ante 401 intenta renovación silenciosa y como máximo repite una vez GET/blob con token actualizado. No repite POST/PUT/PATCH ni cargas. Si la renovación falla, presenta un error accionable sin registrar tokens.
- «Horario no informado» se presenta cuando no hay periodos. No se infiere «Cerrado» por ausencia de datos.
- Se bloquea enviar/publicar descripción vacía o frases provisionales conocidas. La regla no bloquea la frase legítima «abierto todo el año».
- No hay migraciones ni cambios a esquema, snapshots offline o modo Driving.

## Validaciones locales

| Comando | Resultado |
| --- | --- |
| `mvnw verify` | PASS: 136 tests, 0 fallos, 30 omitidos. Los tests PostGIS omitidos localmente se ejecutaron en VM aislada (26, 0 fallos, 2 omitidos). |
| `npm test -- --run` | PASS: 7 archivos, 29 tests. |
| `npm run build` | PASS (Vite/TypeScript). |
| `dart format` en los 7 Dart afectados | PASS: 0 cambios adicionales. |
| `flutter analyze` | PASS, sin issues (evidencia de esta ejecución local). |
| `flutter test --reporter compact` | PASS: 319 passed, 3 skipped por condiciones preexistentes del entorno. |
| `git diff --check` | PASS, sin errores; Git emite una advertencia de conversión CRLF/LF para `admin-portal/src/style.css`. |

APK de integración preparada desde este árbol, con `BACKEND_BASE_URL=https://geoguide.getcom.pe:5443`: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, 168,213,184 bytes, SHA-256 `75E0E6C830BA06AE49F568819262DE05D7B3E7602E0170F5473F9A91B2552AF7`. El certificado Android Debug coincide con la aplicación instalada en el HONOR (SHA-256 `894975b5bc6751da09b3d69923d4ae399192470d86c107106f65f6cb8d7eab7e`). En este checkpoint previo al despliegue, la actualización no destructiva aún estaba pendiente; su resultado se registra abajo.

### PostGIS aislado en VM

Se clonó el HEAD del PR en un directorio temporal único, se creó un proyecto Compose efímero con PostGIS 16.4 (`postgis/postgis:16-3.4`, image ID `sha256:44126d872ac91993766c341e369c539e8196614321765d36a6f1bab0419a5fa5`) limitado a 1 GiB y 1 CPU, y se ejecutaron los 26 tests `PostgisIntegrationTests` con Flyway V001–V013 desde esquema vacío: 26 ejecutadas, 0 fallidas, 2 omitidas. Los nueve servicios previos permanecieron levantados y saludables; al finalizar se retiraron el contenedor, red, volumen y directorio temporal. La primera tentativa, que intentó usar el caché Maven compartido de manager, fue denegada por permisos antes de ejecutar pruebas; se repitió correctamente con repositorio Maven efímero dentro del directorio temporal, sin cambiar permisos ni el caché compartido.

## Pendientes antes del despliegue (checkpoint histórico)

- Ejecutar los tests PostGIS en la VM y el smoke autenticado del portal después de desplegar el merge.
- Confirmar en la API y en HONOR que la respuesta pública muestra la versión actual y que no hay regresión P8/P9.
- Capturar evidencia física del Detail y conectividad. No se declara todavía equivalencia visual completa ni cierre de ADMIN-POI-04.1.
- En el servicio de integración, la API pública ya se observó previamente en `publishedVersion=2`, con cero fotografías públicas. El resumen publicado contiene el texto provisional «Que Va AQUI». Se preserva sin alteración por ser contenido real ya publicado y requerir autorización editorial para corregirlo; la nueva validación evita futuras publicaciones similares.

```ini
ADMIN_POI_04_1_EXISTING_DATA = AUTOMATED_PASS
ADMIN_POI_04_1_MEDIA_MANAGEMENT = AUTOMATED_PASS_LIVE_SMOKE_PENDING
ADMIN_POI_04_1_PUBLICATION_SYNC = AUTOMATED_PASS_VM_HONOR_PENDING
ADMIN_POI_04_1_NAME_AND_SUMMARY = PASS
ADMIN_POI_04_1_MOBILE_PREVIEW = AUTOMATED_PASS_VISUAL_SMOKE_PENDING
ADMIN_POI_04_1_PROVENANCE_PRESENTATION = PASS
ADMIN_POI_04_1_UNKNOWN_HOURS = PASS
ADMIN_POI_04_1_CONTENT_VALIDATION = PASS
ADMIN_POI_04_1_BACKEND_TESTS = PASS
ADMIN_POI_04_1_POSTGIS_TESTS = 26_PASS_2_SKIPPED_ISOLATED_VM
ADMIN_POI_04_1_PORTAL_TESTS = PASS
ADMIN_POI_04_1_FLUTTER_TESTS = PASS
ADMIN_POI_04_1_VM_DEPLOYMENT = PENDING
ADMIN_POI_04_1_HONOR_INSTALL = PENDING
ADMIN_POI_04_1_HONOR_E2E = PENDING
ADMIN_POI_04_1_VISUAL_EVIDENCE = PARTIAL
ADMIN_POI_04_1_COMPLETE = NOT_CLOSED
```

## Despliegue integrado y validación física — 2026-11-21

- PR #133 se fusionó normalmente. Merge commit y baseline integrado: `8669bfdae4050e5b749627c715787d91fd5e8752`. El worktree de despliegue aislado de la VM quedó en ese SHA; el checkout principal de la VM no se modificó.
- Se reconstruyeron y recrearon únicamente `backend` y `admin-portal`, sin dependencias (`--no-deps`). Backend y portal quedaron `healthy`; los siete servicios restantes conservaron sus contenedores y permanecieron activos/saludables. No se ejecutó migración: este cambio no incluye migraciones.
- Smoke HTTPS: `/admin/` = 200, `/actuator/health` = 200 y `/api/v1/admin/pois` anónimo = 401. El último resultado confirma el control de acceso, no una falla. El navegador automatizado no pudo inicializarse (`cua.getState`: error del entorno «failed to write kernel assets», OS error 3); por ello no se acredita una sesión interactiva ni renovación OIDC real post-despliegue. Las pruebas automatizadas del portal y la compilación sí pasan.
- Consulta pública en línea para Iglesia San Juan Bautista de Obrajillo (`02000000-0000-0000-0000-000000000005`): HTTP 200, `contentSource=PUBLISHED`, versión 2, cero fotografías publicadas. La consulta curada de Cantamarca sigue HTTP 200 y la lectura directa de `geo.point_of_interest` confirma Iglesia y Cantamarca con `active=true`. No se modificaron registros.
- HONOR LLY-NX3, Android API 36: `adb install -r` exitoso, app abierta con PID activo, sin `FATAL EXCEPTION` en la ventana de log revisada. La firma Android Debug coincide con la instalada (SHA-256 del certificado `894975b5bc6751da09b3d69923d4ae399192470d86c107106f65f6cb8d7eab7e`). El APK extraído después de instalar coincide byte por byte con el generado.
- Prueba estacionaria: se buscó Plaza de Armas de Canta, se calculó la ruta y se mostraron geometría, resumen `Ruta: 99.6 km · 102 min · 6 lugares`, lista y POIs. Iglesia San Juan Bautista de Obrajillo se encontró a 1.554 m del trazado y abrió en Detail. El nombre oficial, categoría, descripción, historia e importancia se vieron en línea; la atribución y referencias aparecen en una sección secundaria. Sin datos operativos, la ficha indica que no hay horarios, funciones o promociones publicados; no declara que el lugar esté cerrado. No se inició Driving.
- La vista Detail presenta el placeholder porque la API devuelve `photos=[]`; esto es esperado, ya que no hay fotografía publicada y las imágenes del piloto no están autorizadas para uso público. Capturas físicas: [detalle superior](evidence/admin-poi-04-1-honor/poi-detail-top.png) y [contenido, estado de horarios y provenance](evidence/admin-poi-04-1-honor/poi-detail-content-and-source.png). No se guardó captura del mapa para evitar registrar la ubicación del dispositivo.
- Contenido preexistente sin modificar: resumen publicado «Que Va AQUI» y algunos textos de plantilla («Datos interesantes, uno por línea», «Recomendaciones, una por línea», «Información práctica»). Se conserva porque es contenido real ya publicado y su corrección requiere edición y aprobación editorial. Aunque la regla nueva bloquea futuros placeholders, esta ejecución no reescribió la versión v2.
- Comparación de las siete capturas originales: el editor precarga los datos curados y distingue borrador/publicado según las pruebas automatizadas; la nueva galería está cubierta por pruebas, pero la interacción autenticada en navegador quedó sin smoke visual. En HONOR sí se comprobó sincronización API → Detail, nombre oficial y jerarquía de contenido. La equivalencia visual total portal/móvil y la administración de una fotografía publicada no se validaron en vivo.
- APK: `mobile/build/app/outputs/flutter-apk/app-debug.apk`, 168.213.184 bytes, SHA-256 `75E0E6C830BA06AE49F568819262DE05D7B3E7602E0170F5473F9A91B2552AF7`; endpoint integrado `https://geoguide.getcom.pe:5443`. Hash SHA-256 del APK instalado: coincide exactamente.
- Checks de GitHub: `NO_CHECKS_REPORTED` (el repositorio no reportó checks; no se interpreta como CI PASS). No se cambiaron P8/P9, snapshots offline, Driving, esquema, permisos ni datos editoriales.

```ini
ADMIN_POI_04_1_EXISTING_DATA = PASS
ADMIN_POI_04_1_MEDIA_MANAGEMENT = PARTIAL
ADMIN_POI_04_1_PUBLICATION_SYNC = PASS
ADMIN_POI_04_1_NAME_AND_SUMMARY = PARTIAL
ADMIN_POI_04_1_MOBILE_PREVIEW = PASS
ADMIN_POI_04_1_PROVENANCE_PRESENTATION = PASS
ADMIN_POI_04_1_UNKNOWN_HOURS = PASS
ADMIN_POI_04_1_CONTENT_VALIDATION = PASS
ADMIN_POI_04_1_BACKEND_TESTS = PASS
ADMIN_POI_04_1_POSTGIS_TESTS = 26_PASS_2_SKIPPED_ISOLATED_VM
ADMIN_POI_04_1_PORTAL_TESTS = PASS
ADMIN_POI_04_1_FLUTTER_TESTS = PASS
ADMIN_POI_04_1_VM_DEPLOYMENT = PASS
ADMIN_POI_04_1_HONOR_INSTALL = PASS
ADMIN_POI_04_1_HONOR_E2E = PARTIAL
ADMIN_POI_04_1_VISUAL_EVIDENCE = PARTIAL
ADMIN_POI_04_1_SESSION_RENEWAL_LIVE = NOT_VERIFIED
ADMIN_POI_04_1_COMPLETE = PARTIAL
```
