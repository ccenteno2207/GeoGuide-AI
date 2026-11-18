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

## VALIDATION-4B — Integración aislada en VM (2026-11-18)

Esta sección actualiza los pendientes de infraestructura registrados arriba para la ejecución aprobada VALIDATION-4B. No modifica los contratos P8/P9 ni declara cierre de producto.

### Entorno y aislamiento

- Baseline local: rama `codex/master-implementation-v2`, HEAD inicial `f1ce88ec38fb24d8122f3759892b5fc22be6f761`; se conservaron intactos los commits locales previos.
- VM de desarrollo: `/home/manager/geoguide-ai`; checkout `main` en `0f114e320043da90d949b79ab0ab4fea5084c66b` sin cambios.
- Proyecto Compose exclusivo: `geoguide-v4b-20261118-0a11d241`, con red interna y volúmenes propios. Límites efectivos verificados con `docker inspect`: PostGIS 1.280 MiB / 0,75 CPU, MinIO 512 MiB / 0,25 CPU y Keycloak 1.536 MiB / 1 CPU; total 3.328 MiB y 2 CPU.
- Keycloak de prueba fijado a `quay.io/keycloak/keycloak:26.8.2`, digest `sha256:c68e286cacd87b942ac1939a0a1481461109d6acd3a57dc496969a319a76bbf0`. Los usuarios, realm, roles, claves y datos fueron sintéticos.
- Backend y portal se ejecutaron localmente en Windows. Los únicos túneles SSH fueron loopback local hacia servicios aislados de la VM; no se publicaron puertos externos.
- Los seis contenedores existentes del proyecto `geoguide-ai` se observaron antes y durante la validación: conservaron su estado `healthy`/`running`. No se accedió ni modificó su base, buckets, redes, volúmenes o credenciales.

### POI-DATA-1 / V006–V007

- V001–V007 se aplicaron sin error a una base PostgreSQL 16.4/PostGIS 3.4 vacía; Flyway reportó siete migraciones exitosas. Se comprobaron 86 constraints validadas y los índices/triggers de auditoría previstos.
- El CSV local de solo lectura mantuvo SHA-256 `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66`. El staging contiene 6.341 filas: 6.331 `NORMALIZED_PENDING_REVIEW` y 10 `COORDINATE_FORMAT_AMBIGUOUS` en cuarentena.
- Reiniciar el importador reutilizó el mismo batch; la base conserva un solo lote y el mismo total de 6.341 filas. El registro 237 conserva como raw `-7.576.291.501.522.060` y `-14.087.854.051.458.200`; continúa pendiente de revisión y no se normalizó ni publicó durante esta validación.
- Los cinco UUID P3 permanecen activos con las coordenadas originales del dataset. Se creó un borrador enlazado a una fila MINCETUR para probar el paso importación→edición; se dejó sin aprobar. El conteo de registros importados publicados es cero.
- V007 conserva latitud/longitud como `NUMERIC` sin escala fija; la inserción/publicación sintética con coordenadas decimales fue aceptada sin truncamiento. No se cambió la migración.

### ADMIN-1 / OIDC y publicación

- Se ejecutó Authorization Code + PKCE real contra Keycloak sintético para administrador, editor y revisor. Los tokens válidos incluyeron issuer, audience `geoguide-admin-api` y rol esperado; el backend aceptó el token válido y devolvió 401 para acceso anónimo, JWT de firma inválida y token vencido, y 403 para una operación prohibida al rol revisor.
- La suite backend cubre validador de audiencia incorrecta, conversión de roles y deny-by-default; la API en vivo confirmó los permisos aplicados.
- Lecturas paginadas con filtros opcionales omitidos para importaciones y catálogo pasaron tras corregir el tipado de parámetros nulos de PostgreSQL. La API permitió un borrador enlazado a un registro importado, rechazó un segundo borrador duplicado y preservó el candidato en `DRAFT`.
- El flujo sintético pasó edición optimista (actualización válida y 409 para versión obsoleta), revisión geográfica, comprobación de duplicados, revisión de identidad, submit y publicación explícita. Una aprobación sin revisiones fue rechazada con 409.
- Una falla inducida solo en la transacción temporal al insertar provenance devolvió error; la transacción dejó el registro en `PENDING_REVIEW`, sin `published_poi_id` y sin POI público. El trigger de prueba se eliminó después. Las auditorías no permitieron UPDATE ni DELETE y conservaron seis entradas.
- Route Discovery consultó PostGIS y devolvió el POI sintético publicado sobre una geometría de prueba. Para aislar este flujo se usó un stub local de GraphHopper; **no** se valida el GraphHopper real ni una ruta vial real.

### POI-MEDIA-1 / Flutter y P9

- MinIO usó un bucket privado exclusivo. Una carga JPEG sintética con marcador EXIF de prueba se re-encodeó; el backend entregó bytes sin el marcador. La lista y acciones administrativas no exponen la clave de objeto; el acceso anónimo al bucket respondió 403.
- La secuencia de derechos→submit→aprobación revisora→imagen principal→lectura autenticada por API→retiro funcionó. Sin imagen publicada, el endpoint devolvió 404 para que Flutter use placeholder. SVG fue rechazado con 400. El límite de bytes está cubierto por una prueba unitaria nueva y el límite HTTP multipart produjo `MaxUploadSizeExceededException`; el cliente local recibió reset de conexión, por lo que no se verificó el código HTTP de esa respuesta.
- Se corrigió un defecto: respuestas administrativas serializaban `objectKey` pese a que la API debía conservarlo dentro del backend. Ahora devuelven `MediaAssetResponse`, que omite la clave; una prueba de serialización y la llamada en vivo lo confirman.
- Portal: `npm test -- --reporter=verbose` pasó 2/2 y `npm run build` pasó TypeScript/Vite; el servidor local respondió HTTP 200. No se hizo recorrido de interfaz en navegador.
- Flutter: `flutter test` pasó 314 pruebas con 3 omitidas; `flutter analyze` no encontró issues; `dart format --output=none --set-exit-if-changed lib test` no detectó cambios de formato. `offline_cache_test.dart` pasó 34 pruebas, incluida la exclusión de URI multimedia del snapshot. No se instaló ni validó una APK físicamente.
- Backend: `mvn verify` pasó con 97 pruebas, 0 fallos, 0 errores y 14 omitidas. Doce `PostgisIntegrationTests` usan Testcontainers y se omitieron al no haber Docker local; dos pruebas opcionales dependen del fixture CSV. La migración y los flujos centrales sí se validaron contra el PostGIS temporal en la VM.

### Defectos, limitaciones y limpieza

- Defectos corregidos localmente: consultas administrativas con filtros nulos no tipados en PostgreSQL y exposición de claves privadas de MinIO en DTO administrativos.
- Correcciones, pruebas focalizadas y esta evidencia: commit local `04a9627421db515ca672c1c3efc25ac23282b58d` en `codex/master-implementation-v2`.
- No se utilizaron fotografías reales del piloto, no se instalaron APK, no se hicieron cambios en servicios compartidos ni se desplegó nada.
- Resultado: `VALIDATION_4B = PARTIAL`. Persisten la falta de validación contra GraphHopper real, la inspección de portal en navegador y la imposibilidad de observar el código HTTP del rechazo por tamaño; no hay evidencia de regresión de servicios existentes.
- Limpieza completada: duración del token sintético restaurada a 300 segundos; procesos locales y túnel loopback detenidos; contenedores, red, volúmenes y directorios temporales exclusivos eliminados. Se verificó que no quedan listeners de VALIDATION-4B en los puertos locales usados. Los seis servicios preexistentes siguen `running` y con la misma salud observada al inicio; la memoria disponible de la VM pasó de aproximadamente 4,8 GiB durante la prueba a 5,6 GiB después.

## VALIDATION-4C — Cierre de pendientes (2026-11-18)

Se ejecutaron las comprobaciones que quedaron pendientes en VALIDATION-4B, usando el mismo entorno de desarrollo y límites aprobados. No se utilizaron servicios ni recursos del stack compartido `geoguide-ai`; no se transfirió el CSV MINCETUR ni se usaron fotografías reales.

### GraphHopper y Route Discovery reales

- Se creó un grafo temporal de GraphHopper 11.0 desde un recorte OSM descargado para esta prueba, separado de los datos GraphHopper de la VM. El XML temporal tenía SHA-256 `F0741208B8EC7AA817DDEB3B4BF4334296FFA2EB616220CF1564B00A4D84DA22` (14.993.716 bytes). La fuente OSM conserva su atribución/licencia ODbL; el recorte no se versionó.
- La API real `POST /api/v1/routes/discover` planificó una ruta vial de `1.868,209 m`, con 28 puntos de geometría. El primer intento se rechazó correctamente porque el corredor de 500 m estaba por debajo del mínimo de 1.000 m; se repitió con el mínimo contractual.
- Se creó exclusivamente en la base temporal un POI sintético, publicado mediante el flujo administrativo del portal en navegador, en un vértice de esa geometría (`-12.037216, -77.052620`). Route Discovery devolvió el POI en la ruta, con distancia al trazado de 0 m. Esto valida GraphHopper real, consulta PostGIS y publicación administrativa en conjunto; no representa un lugar real ni se publicó fuera del entorno temporal.

### ADMIN-1 — Portal en navegador

- Se produjo el build de portal para navegador y se recorrió en Microsoft Edge contra Keycloak 26.8.2, backend y PostGIS/MinIO aislados. Las identidades fueron sintéticas. Los tres roles autenticaron mediante Authorization Code + PKCE (`S256`); el backend aceptó el issuer/audience configurados y aplicó RBAC. El editor no pudo aprobar geografía (403); el revisor aprobó geografía e identidad, no pudo enviar el registro (403) y sí pudo aprobar su publicación; el administrador pudo gestionar la carga multimedia sintética.
- Se verificaron catálogo/lote, importación sintética, borrador, revisión de coordenadas, consulta de duplicados, publicación, carga privada, registro de licencia/atribución, envío y publicación de imagen principal. La lectura pública de la imagen sintética respondió 200 `image/png`, `no-store`, 68 bytes. No se mostraron claves MinIO, credenciales ni claves de objeto en el DOM.
- Los estados de error 403, el bloqueo de botones mientras una solicitud estaba en curso y el estado vacío de búsqueda/catálogo se observaron. Se corrigieron dos defectos de presentación/operación hallados en navegador: razón de auditoría multimedia independiente de la selección editorial y cálculo de paginación cuando la API no serializa `totalPages`. Se corrigió además el contraste de la tarjeta de lote al pasar el puntero. El build visual final mostró ambos paginadores como `1 / 1` / `Página 1 de 1` y texto legible en hover.
- Durante la primera pasada se observó que un JWT válido del issuer, pero sin claim de audiencia, hacía que la API lanzara `NullPointerException`. Se corrigió el validador para rechazarlo de manera controlada cuando `aud` falta; se añadió prueba unitaria. El realm sintético se completó con el cliente audiencia `geoguide-admin-api`, requerido para que los tokens de las pruebas autorizadas incluyeran el audience esperado.
- Limitación: el portal no presenta un indicador de carga textual; durante carga deshabilita los botones. No bloqueó la validación funcional, pero conviene considerar un indicador accesible en trabajo de UX posterior.

### POI-MEDIA-1 — Límite HTTP multipart

- Se envió al endpoint administrativo real una carga sintética de 11 MiB contra un límite configurado de 10 MiB. La respuesta fue HTTP `413`, `application/problem+json`, con detalle genérico `El archivo supera el tamaño máximo permitido.` y sin nombres de excepción, rutas ni detalles internos. El listado multimedia permaneció en 1 registro antes y después.
- La prueba HTTP de Tomcat embebido confirma además que una carga superior al límite no invoca el controlador/probe de almacenamiento (0 invocaciones). Se configuró resolución multipart diferida y un manejador explícito para `MaxUploadSizeExceededException`; la respuesta queda controlada en lugar de resetear la conexión.

### Correcciones, validaciones y limpieza

- Correcciones locales cubiertas por pruebas: respuesta HTTP 413 multipart; rechazo null-safe de JWT sin `aud`; campo de razón de auditoría independiente para operaciones multimedia; cálculo de páginas faltante en portal; contraste de tarjetas de lote.
- Pruebas backend focalizadas: 11 PASS, 0 FAIL (validador de audiencia, manejador de errores, servicio multimedia y prueba HTTP multipart real de Tomcat). Pruebas portal: 3 PASS en 2 archivos. `npm run build` pasó TypeScript y Vite. No se repitieron pruebas Flyway/MINCETUR/OIDC/RBAC/MinIO/Flutter anteriores que no fueron afectadas.
- Recursos exclusivos: proyecto Compose `geoguide-v4c-20261118`, red, volúmenes, túnel SSH, backend local, Vite preview, recorte OSM, imágenes sintéticas y credenciales sintéticas; el resultado de limpieza se registra en los puntos siguientes.
- Limpieza de VM completada: Compose removió exclusivamente los cuatro contenedores, la red y los tres volúmenes etiquetados `geoguide-v4c-20261118`; se eliminaron el proyecto temporal y los SQL/OSM temporales. Se verificó cero contenedores, redes, volúmenes y archivos remotos de VALIDATION-4C. Los seis servicios preexistentes continúan con los mismos estados `running`/`healthy` que al inicio.
- Limpieza local incompleta: la herramienta de ejecución rechazó explícitamente la operación `Remove-Item -Recurse -Force` bajo su política. Permanecen fuera del repositorio `D:\Codex\validation4c-browser`, `D:\Codex\validation4c-stack`, el recorte OSM, los SQL/log temporales bajo `D:\Codex` y el directorio de build ignorado `admin-portal\dist`. No quedan procesos ni listeners locales de VALIDATION-4C. No se intentó otro método de eliminación.
- Resultado: las tres comprobaciones técnicas pendientes de VALIDATION-4B quedaron cubiertas, pero `VALIDATION_4C = PARTIAL` hasta completar la limpieza local autorizada; por la misma limitación, `MASTER_V2_READY_FOR_PR_REVIEW = NO` en este cierre.

## VALIDATION-4C — Revalidación de limpieza y PR readiness (2026-11-18)

Esta actualización conserva el resultado e historial PARTIAL anteriores y registra una nueva comprobación de solo lectura después de la limpieza manual informada. No repite pruebas de GraphHopper, navegador, multipart, Flyway, MINCETUR, OIDC/RBAC, MinIO ni Flutter.

### Limpieza local verificada

- No existen `D:\Codex\validation4c-stack` ni `D:\Codex\validation4c-browser`.
- Aún existen fuera del repositorio: `D:\Codex\validation4c-lima-roads.osm`, `D:\Codex\validation4c-synthetic.sql`, `D:\Codex\validation4c-update.sql` y `D:\Codex\validation4c-multipart.log`. La comprobación de solo lectura no encontró en estos SQL/log las cadenas conocidas de credenciales sintéticas (`KC_BOOTSTRAP_ADMIN_PASSWORD`, `MINIO_ROOT_PASSWORD` ni contraseñas de prueba buscadas); esto no constituye una afirmación forense general sobre todo el disco.
- `admin-portal\dist` aún existe como salida de build ignorada localmente; no aparece en el diff ni en el estado Git.
- No se encontraron listeners en los puertos locales 5173, 8080, 55432, 58080, 58989 o 59000. La consulta de procesos, excluyendo la sesión PowerShell que ejecutó la propia inspección, no encontró procesos con los identificadores de VALIDATION-4C.
- La limpieza remota del proyecto temporal V4C y la conservación de los seis servicios preexistentes quedaron verificadas en la sección anterior. En esta actualización no se modificaron servicios ni worktrees.
- No se borraron archivos ni directorios: los artefactos que siguen presentes requieren limpieza manual posterior.

### Estado de integración revisado

- Rama `codex/master-implementation-v2`; HEAD `6896213b6b17c52d609dc891a953a0fcc50ad109`.
- `origin/main` actualizado mediante `git fetch`: `0d76dcf740e3558c4b7308dbb19139a6e9a1071e`. La rama contiene 7 commits por delante y ninguno por detrás. El worktree está limpio antes de esta actualización documental.
- El rango de integración contiene 72 archivos: migraciones aditivas V006/V007, backend MINCETUR/admin/media, pruebas, OpenAPI, portal y ajustes Flutter de media/snapshot. No hay PNG originales del piloto ni APK en el diff; `.env.example` contiene solo referencias a variables, no valores de secretos. Los contratos congelados P8/P9 no están modificados. El snapshot offline no persiste URL ni bytes multimedia y el cambio Flutter conserva placeholder/fallback.
- La evidencia existente registra V001–V007 y staging en PostGIS aislado, conteos 6.341/6.331/10, idempotencia, cero publicaciones automáticas y preservación de P3; OIDC/RBAC, MinIO, portal en navegador y Route Discovery real con GraphHopper quedaron probados en entorno aislado. HTTP multipart 413, manejo de JWT sin `aud`, pruebas de portal y `npm run build` se acreditan en el commit `6896213`. No se repitieron esas pruebas porque esta revalidación solo cambió documentación.
- La revisión del diff no encontró cambios de backend/infraestructura compartida, derechos de imágenes reales ni contratos P8/P9 fuera del alcance descrito. Las 6.331 ubicaciones continúan pendientes de revisión y las 10 filas permanecen en cuarentena; no hay publicación automática. Derechos de las cinco fotografías reales siguen sin acreditarse y no se utilizaron.
- `git diff --check origin/main...HEAD` pasó antes de esta actualización. La revalidación no ejecutó nuevas pruebas funcionales. Después de editar documentación se vuelve a ejecutar `git diff --check`.

### Veredicto

- `GRAPHOPPER_REAL = PASS`
- `ADMIN_PORTAL_BROWSER = PASS`
- `MULTIPART_HTTP_413 = PASS`
- `VM_CLEANUP = PASS`
- `WINDOWS_CLEANUP = INCOMPLETE`
- `PREEXISTING_SERVICES = UNCHANGED`
- `VALIDATION_4C = PARTIAL`
- `MASTER_V2_READY_FOR_PR_REVIEW = NO`

La única causa del estado PARTIAL de VALIDATION-4C es que persisten los cuatro archivos OSM/SQL/log enumerados arriba y la salida ignorada `admin-portal\dist`. La revisión de código/diff no encontró un bloqueo funcional adicional para revisión de PR; sin embargo, el gate solicitado de limpieza no está satisfecho. Próximo paso: completar manualmente la limpieza de esos temporales, volver a verificar existencia, procesos/listeners y estado de Git, y reevaluar readiness sin repetir pruebas técnicas.
