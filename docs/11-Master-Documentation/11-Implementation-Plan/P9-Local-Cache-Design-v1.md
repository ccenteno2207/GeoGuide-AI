# P9 — Local Cache Design v1

**Estado:** diseño documental completo para revisión humana final; no aprobado para implementación. Anexo normativo candidato de [P9 Phase Contract v1](P9-Phase-Contract-v1.md). Baseline: `11d5f0bf3e92762bf9871a1df83415e9e54f4f3a`. D02 = RESOLVED_DOCUMENTALLY; D03 incorpora decisiones humanas. No se ha creado schema, migración, adapter ni dependencia.

## 1. Límite arquitectónico

Android es la plataforma de persistencia P9; no se promete implementación iOS/web. Presentation invoca casos de uso de application; estos dependen de un puerto `RouteDiscoverySnapshotStore` con operaciones tipadas readEligible, replaceValidated y delete. Adapter SQLite/Drift aislado en infrastructure/offline. Un DTO local versionado mapea a los tipos neutrales existentes; widgets no conocen SQLite, JSON, TTL o paths. No Riverpod, provider externo, nueva API ni lógica geoespacial/ranking en cliente.

La fuente del snapshot es **una respuesta válida de POST /api/v1/routes/discover** y sus criterios efectivos. Esa respuesta ya contiene route, results, algorithmVersion y generatedAt. El mapper actual descarta el envelope: su futura extensión interna conservará esos campos. La geometría de POST plan puede mostrarse provisionalmente, pero nunca se combina con POIs de otra respuesta ni se persiste como snapshot completo antes de Discovery. Sin resultado Discovery válido, la última copia anterior no se reemplaza. Resultado vacío válido sí es cacheable.

## 2. Evaluación documental de dependencias

Propuesta concreta sujeta al gate final: **Drift 2.35.1 + sqlite3 3.7.0**, con generación tipada. Estos números fijan la propuesta; no son instrucciones de instalación en P9.0. Consulta de metadata oficial realizada el 6-oct-2026 UTC. SDK local observado por lectura de `flutter.version.json`: Flutter **3.47.2**, Dart **3.13.2**, revision `d3b14c876900e553bc736ca19295fc09e3853e8e`; coincide con mobile/.metadata. pubspec exige Dart ^3.13.2 y lockfile declara Flutter >=3.38.4.

| Paquete propuesto | Tipo / necesidad | Restricción SDK publicada | Licencia publicada | Efecto |
|---|---|---|---|---|
| [drift 2.35.1](https://pub.dev/packages/drift/versions/2.35.1) | Runtime: tablas/consultas tipadas y transacciones | Dart >=3.10.0 <4.0.0 | MIT | Adapter local, sin lógica en widgets |
| [sqlite3 3.7.0](https://pub.dev/packages/sqlite3/versions/3.7.0) | Runtime directo: backend nativo FFI, setup y pragmas | Dart >=3.10.0 <4.0.0 | MIT | Biblioteca SQLite nativa empaquetada; no DB servidor |
| [crypto 3.0.7](https://pub.dev/packages/crypto/versions/3.0.7) | Runtime directo: SHA-256 de envelope/clave técnica | Dart ^3.4.0 | BSD-3-Clause | Integridad accidental, no cifrado/autenticación |
| [drift_dev 2.35.1](https://pub.dev/packages/drift_dev/versions/2.35.1) | Dev: generación del acceso tipado | Dart >=3.10.0 <4.0.0 | MIT | Código generado versionado; no runtime nuevo |
| [build_runner 2.16.1](https://pub.dev/packages/build_runner/versions/2.16.1) | Dev: ejecutar generador | Dart ^3.11.0 | BSD-3-Clause | Herramienta de build local; sin cambiar CI/CD |

Compatibilidad documental: Dart 3.13.2 satisface los rangos anteriores; drift requiere sqlite3 ^3.4.0, compatible con 3.7.0. drift_dev acepta drift >=2.30.0 <2.36.0 y build >=3 <5; build_runner requiere build ^4.0.9. Los rangos analyzer >=13 <15 y >=13.3 <15 se intersectan. Estas restricciones se verificaron en las APIs versionadas de pub.dev enlazadas al final. **No se ejecutó solver, codegen ni build; no se declara compatibilidad runtime probada.** Las dependencias transitivas se resolverán y auditarán bajo P9.1 autorizado, sin overrides ni upgrades del SDK. Conflicto no resoluble dentro de estos pins = STOP_AND_REPORT; no cambiar versiones materiales por inferencia.

Alternativas evaluadas: sqflite con capa tipada propia mantiene SQLite, pero requiere más mapping manual y un plugin Flutter adicional; sqlite3 directo con DTO propio reduce codegen pero hace manual la protección tipada; JSON/SharedPreferences no satisface la dirección SQLite. Se propone Drift por correspondencia directa con [ADR-018](../../02-Architecture/ADR/07-Mobile-Engineering/ADR-018-Local-Storage.md), no por una selección nueva de proveedor. No hace falta drift_flutter/path_provider: un adapter Android mínimo obtiene el directorio no-backup mediante API de plataforma. No se propone sqlite3_flutter_libs: sqlite3 3.x dispone de empaquetado nativo según [plataformas Drift](https://drift.simonbinder.eu/platforms/). Sin cifrado SQLCipher ni nuevas claves; el modelo de amenaza no cubre dispositivo comprometido/root o extracción forense.

## 3. Modelo persistente conceptual

Una única tabla ordinaria `route_discovery_snapshot`; máximo una fila con clave constante 1. No tablas de rutas, usuarios, favoritos, visitas, preferencias o historial. El esquema siguiente es especificación, **no DDL ni migración ejecutable**.

| Campo | Tipo conceptual | Regla |
|---|---|---|
| slot | integer PK | Exactamente 1; 0 o 1 filas |
| format_version | integer | Exactamente 1 para este contrato |
| payload | blob | JSON UTF-8 compacto validado de la sección 4; no comprimido |
| payload_bytes | integer | Longitud real del blob; 1..5,242,880 inclusive |
| payload_sha256 | blob | 32 bytes; digest del blob para corrupción accidental |
| captured_at_utc_ms | integer | Instante de recepción completa/validación de respuesta; nunca se renueva por lectura |
| expires_at_utc_ms | integer | captured_at + 86,400,000; duplicado contrastado con payload |
| last_observed_utc_ms | integer | Máximo reloj UTC observado para esta copia; sin secuencia histórica |

La clave canónica de consulta y el contexto de backend están dentro del payload; no índices geoespaciales, búsqueda o tablas POI locales separadas. `slot` es técnico y constante, no identidad persistente de sesión/persona/dispositivo. SQLite user_version = 1 y formato de payload = 1 son distintos de schema_version interno SQLite; no manipular este último.

## 4. Payload y mapping exacto

Objeto JSON con estas claves permitidas, en este orden de serialización:

1. `formatVersion`: 1.
2. `capturedAtUtcMs`, `expiresAtUtcMs`: enteros; valores iguales a las columnas espejo.
3. `backendContext`: origen HTTPS normalizado (scheme, host, puerto efectivo y base path) + endpoint `/api/v1/routes/discover`. Sin userinfo, query, fragment, tokens ni credenciales. Configuración con credenciales no es cacheable.
4. `criteria`: origin y destination de la petición, categories normalizadas por trim/deduplicación/orden ordinal, corridorMeters efectivo y limit efectivo. Valores omitidos usan los defaults contractuales backend actuales 5000 y 20; rango 1000..10000 y 1..50. Conservar semántica de conjunto vacío sin inventar filtro local; no ampliar Discovery a servicios. Coordenadas finitas en rango, sin redondeo geográfico para construir identidad; normalizar -0 a 0.
5. `queryKeySha256`: digest de JSON canónico UTF-8 de backendContext + criteria con ese orden y números finitos. Igualdad final también compara los campos tipados; un hash no reemplaza validación. No persistir/localizar rutas por nombre o geohash aproximado.
6. `route`: origin, destination, distanceMeters, durationSeconds y geometry LineString exactamente de la respuesta Discovery, validados contra los puntos de la petición. Sin ruta de POST plan mezclada.
7. `pois`: orden exacto de results backend; id UUID, name, category, location, distanceToRouteMeters, routeProgress, reasonCodes y opcionales description/sourceLabel/sourceUrl/attribution. No persistir score, datos crudos extras o campos no usados. No reordenar ni recalcular ranking; los datos opcionales ausentes siguen ausentes.
8. `algorithmVersion`: texto no vacío de la respuesta, sin usarlo como progreso del conductor; `generatedAt`: timestamp de respuesta válido. Ninguno prueba frescura editorial.

Canonicalización local v1: claves en el orden definido, sin espacios/indentación; arrays POI/geometría preservan orden; categorías ordenadas; opcionales ausentes se omiten; sin NaN/Infinity. El decoder valida tipos, campos, digest, size, timestamps, UUID, geometría y coherencia; no confía en un archivo por estar en app-private. Un resultado con datos obligatorios inválidos no genera copia nueva (no truncar POIs/geometría para hacerlo caber). Se conserva la presentación online heredada en lo no afectado; no se usa mapper permisivo como única validación de persistencia.

No persistir selección actual, viewport o modal: son estado temporal de UI en memoria. Tras reinicio, abrir copia en resumen de ruta con criterios guardados, sin POI seleccionado/modal abierto; Map/List usa el valor inicial del cliente. Continuidad durante la misma sesión conserva vista, viewport, selección y filtros sin añadir historial.

## 5. Tamaño y almacenamiento acotado

`CACHE_MAX_SIZE = 5_MIB = 5,242,880 bytes` se mide sobre el **payload completo codificado** (incluye ruta, criterios, POIs, provenance y metadata indicada), no cantidad de caracteres, tamaño comprimido ni solo geometría. Aceptable <=5,242,880; >5,242,880 no reemplaza la copia previa y produce aviso breve de que no se conservó offline. No truncar ni dividir en varios snapshots.

SQLite tiene overhead de páginas/índices y journal de transacción. Esta especificación distingue el límite del snapshot de la ocupación física: página 4096 bytes, archivo DB limitado a **6 MiB** mediante max_page_count 1536; sin WAL ni export/staging de payload. Alcanzar el límite físico produce rollback y aviso, aunque el payload esté dentro de 5 MiB. Journal rollback transitorio vive junto al DB y se elimina al commit; puede coexistir temporalmente con la copia anterior, pero no constituye segundo snapshot consultable. No se promete que DB + journal sumen 5 MiB. Este detalle de diseño queda visible en el gate final; no altera el límite humano de datos del snapshot. No ejecutar VACUUM de copia completa ni mantener archivos históricos.

Conexión única/worker único, `journal_mode=DELETE`, `synchronous=EXTRA`, `secure_delete=ON`, `temp_store=MEMORY`, busy_timeout=2000 ms. Si un pragma requerido no se aplica, no habilitar caché y reportar fallo; no degradar atomicidad/privacidad. SQLite documenta overwrite de tablas ordinarias con secure_delete y sincronización adicional con EXTRA en [PRAGMA](https://www.sqlite.org/pragma.html). No FTS/tablas virtuales.

## 6. App-private, backup y transferencia

Path: subdirectorio `geoguide_p9_cache` de `Context.getNoBackupFilesDir()`; DB `snapshot.sqlite`. Resolver path mediante un adapter Android/MethodChannel estrecho sin permisos nuevos, no un path absoluto hardcoded. DB, journal y cualquier marcador de borrado residen allí. Nunca Documents, external storage, shared preferences, export, provider de archivos, telemetry, logs o copias temporales externas.

No depender solo de `allowBackup=false`: Android documenta diferencias OEM para D2D. Directorios no-backup se excluyen de Auto Backup y de reglas normales de transferencia; véase [Auto Backup](https://developer.android.com/identity/data/autobackup). No se habilita BackupAgent ni ruta de transferencia/exportación. Si path no-backup no puede garantizarse, cache unavailable; no fallback a otro directorio. La comprobación Android futura debe inspeccionar path y exclusión; no ejecutar herramienta de backup/dispositivo ahora. La propuesta no requiere cambiar uses-permission ni TLS/infraestructura.

## 7. Consentimiento y retención

Captura durable desactivada inicialmente en cada proceso. En exploración normal, acción explícita «Permitir copia offline durante esta sesión» explica: una consulta reemplazable, 24 horas, hasta 5 MiB, posible intención sensible de viaje, sin backup/transferencia y borrable. Consentir habilita captura de la consulta vigente válida y sus siguientes reemplazos en esa sesión; no habilita tracking ni guarda preferencia global. La copia creada puede leerse tras reinicio hasta caducar; la captura de nuevas consultas vuelve a requerir consentimiento en el nuevo proceso. Esta regla concreta minimización y consentimiento contextual, sin tabla de preferencias.

Se usa el instante de recepción válida original, no el instante de guardar/tocar/reabrir. Consentimiento tardío no reinicia su edad. Sin consentimiento, resultado sigue disponible en memoria sin escritura. Borrado desactiva captura de sesión, invalida operaciones pendientes y requiere nuevo gesto explícito para volver a guardar.

TTL: 86,400,000 ms de reloj UTC del dispositivo. Elegible si `capturedAt <= now < expiresAt` y `now >= lastObserved`; exactamente en expiresAt ya no es elegible. Actualizar lastObserved antes de entregar copia. Si el reloj retrocede respecto al último valor observado o fecha capturada, invalidar/purgar; no desplazar expiresAt. Dentro del proceso, reloj monotónico evita extender la elegibilidad por ajustes del reloj: aplicar también edad transcurrida >= TTL como vencimiento. Adelanto de reloj puede expirar anticipadamente; se prefiere no extender retención.

Comprobar al abrir, leer, volver a foreground, entrar Driving y en timer de expiración mientras copia esté presentada. Al expirar, retirar datos cacheados, conservar solo estado UI no sensible necesario para salida y mostrar «Copia vencida». No mantener en pantalla una copia caducada bajo otra etiqueta. Sin tareas background: si la app está detenida, la eliminación física se realiza en la siguiente apertura; no se puede usar la copia entre tanto. No se promete defensa contra manipulación indetectable del reloj/SO durante apagado; el TTL se define sobre el reloj del dispositivo, no como tiempo confiable de servidor.

## 8. Atomic replacement y concurrencia

1. Validar/coherenciar nueva respuesta completa en memoria, consentimiento activo, consulta vigente y token de generación de sesión. Rechazar tamaño, formato, timestamps o campos inválidos antes de escritura.
2. Serializar operaciones de store en un único worker. Revalidar generación/consentimiento inmediatamente antes del commit; borrar/salir/cambiar consulta invalida trabajo tardío.
3. Transacción única sobre slot 1: reemplazar payload y todos sus metadatos de forma conjunta. Emitir estado cache saved solo después de commit. No ejecutar DELETE aislado previo al insert.
4. Error de escritura/disco lleno/lock/timeout => rollback y conservar última copia válida sin cambiar TTL ni criterios. No retry automático ilimitado; intento siguiente solo por acción explícita/consulta posterior autorizada.
5. Tras crash, permitir recuperación SQLite del journal antes de validar la fila, salvo que exista intención de borrado pendiente. Resultado observable: copia anterior o nueva completa, nunca mezcla. Atomicidad sigue [transacciones Drift](https://drift.simonbinder.eu/dart_api/transactions/) y [atomic commit SQLite](https://www.sqlite.org/atomiccommit.html).

Reemplazar no altera el contexto online si guardar falla. Una copia anterior se identifica por su propia consulta; no se entrega como resultado de criterios nuevos. Conserva máximo una fila; el valor vacío válido reemplaza igual que uno no vacío.

## 9. Corrupción, versión y eliminación segura

`schema user_version=1` y `formatVersion=1`; v1 no migra formatos desconocidos. Al detectar otra versión, corrupción SQLite, quick_check no OK, digest inválido, campos incompatibles, expiración o tamaño excesivo: marcar no elegible antes de presentar datos, purgar únicamente el almacenamiento dedicado y recrear vacío cuando una nueva captura autorizada lo necesite. No reexportar contenido inválido ni intentar rescate parcial. Payloads externos con campos nuevos se mapean a whitelist v1; si falta un campo necesario, no se guarda copia. Cambiar modelo/versión posteriormente requiere revisión documental, nunca reinterpretación silenciosa.

Operación user delete, accessible fuera de Driving:

1. Cancelar captura/lecturas y trabajos pendientes, invalidar generación; la UI no presenta éxito hasta terminar. No borrar datos backend ni la ruta online actual. Si la UI depende de la copia, pasa a no disponible.
2. Escribir/sincronizar marcador local de intención de borrado, sin payload ni identificador: `delete_pending`. Si falla, no afirmar éxito; bloquear lectura de store durante la sesión y mostrar error con reintento. No habilitar nuevas escrituras.
3. Con acceso exclusivo, borrar fila con secure_delete=ON cuando DB sea legible; cerrar conexión y quitar DB y archivos auxiliares del directorio dedicado, incluido journal. No conservar copia de respaldo. Ante DB corrupta/incompatible se omite lectura y se eliminan los archivos tras cerrar handles.
4. Retirar marcador solo cuando no existen DB/auxiliares. Si la app se interrumpe, la siguiente apertura revisa primero el marcador y completa eliminación **antes** de abrir/recuperar DB; no resucitar snapshot desde journal.
5. Cualquier fallo deja marcador, store bloqueado y estado de borrado pendiente con reintento explícito. Nunca eliminar rutas calculadas ni directorios fuera del subdirectorio dedicado. El marcador es control técnico sin datos de viaje, no segundo snapshot o identidad.

La garantía es eliminación lógica comprobable y mitigación de residuos SQLite, sin copia accesible a la aplicación ni backup autorizado. No se promete sobreescritura forense de flash, borrado criptográfico ni borrado en dispositivo comprometido. Esas garantías exigirían un gate adicional; no se simulan con secure_delete. Después del borrado y reinicio, readEligible debe devolver empty; no auto-reguardar respuesta tardía.

## 10. Pruebas requeridas posteriormente, no ejecutadas aquí

Boundary TTL: 86,399,999 / 86,400,000 / 86,400,001 ms; lectura/reinicio no extienden edad; reloj atrás invalida. Payload UTF-8 de 5,242,879 / 5,242,880 / 5,242,881 bytes, incluyendo caracteres multibyte; simular límite físico DB/disco lleno sin perder copia válida. Validar uno/cero slots, criterios diferentes, respuesta tardía, vacío válido, digest alterado, user_version/formato distintos, crash durante reemplazo y borrado, marcador pendiente al arranque, revocación y no-recaptura. Examinar exclusión de backup/transferencia y ausencia de coordenadas/secretos en logs. Flutter/backend tests no se ejecutan durante P9.0 documental.

## Fuentes externas versionadas de D02

Metadata oficial: [drift 2.35.1](https://pub.dev/api/packages/drift/versions/2.35.1), [drift_dev 2.35.1](https://pub.dev/api/packages/drift_dev/versions/2.35.1), [sqlite3 3.7.0](https://pub.dev/api/packages/sqlite3/versions/3.7.0), [build_runner 2.16.1](https://pub.dev/api/packages/build_runner/versions/2.16.1), [crypto 3.0.7](https://pub.dev/api/packages/crypto/versions/3.0.7). Se consultaron metadata/documentación, no se descargaron/instalaron archives ni se modificó lockfile. Las licencias citadas son las declaradas por los paquetes; no cambian LICENSE del producto.
