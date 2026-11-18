# POI-CATALOG-1 — Evidencia de implementación local

## Alcance y baseline

- Contrato congelado: [POI-CATALOG-1 Discovery and Implementation Contract](POI-CATALOG-1-Discovery-and-Implementation-Contract.md), decisiones D01–D06.
- Base inicial: `origin/main` `7b7fb9c9aec8efe4076a048fb224e4ec92681155` (PR #112).
- Worktree: `D:\Codex\worktrees\GeoGuide-AI\poi-catalog-1-discovery`.
- Rama: `codex/poi-catalog-1-discovery`.
- Base de staging local: CSV SHA-256 `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66`, corte `2026-11-10`, 6,341 filas.

Los commits documentales anteriores se preservan. Esta evidencia distingue implementación local de validación PostGIS aislada. No se publicaron registros reales ni se aplicaron migraciones a bases compartidas.

## Implementación

- `V008__poi_catalog_destination_review_and_links.sql` añade ledger editorial independiente para destinos, evidencia/decisiones de geografía, identidad y acceso, auditoría append-only y relaciones auditables destino↔POI `SAME_RESOURCE`/`RELATED_RESOURCE`.
- Los flujos de destino y POI no sincronizan coordenadas, publicación ni estado. La publicación de destino inserta una nueva fila en `geo.destination`; nunca actualiza una geometría existente. Route Discovery sigue leyendo POIs activos.
- El envío a revisión exige revisiones geográfica, de identidad y de acceso aprobadas y derechos/atribución; la publicación vuelve a aplicar esos requisitos. Una versión obsoleta se rechaza.
- La relación destino↔POI requiere entidades activas, razón y evidencia, y queda pendiente hasta revisión. Crear/aprobar el vínculo no altera geometrías.
- La clasificación de cola describe únicamente cuarentena, candidatos sin asignar y borradores existentes. No aprueba ni publica registros.
- El resumen de cada lote incorpora borradores POI, borradores destino y candidatos pendientes sin asignar.
- El portal React permite crear un borrador destino desde un candidato elegible, editarlo, revisar duplicados como indicios, capturar evidencia independiente y administrar relaciones pendientes. Las rutas administrativas mantienen OIDC/RBAC existente y acceso deny-by-default.
- Se actualizó OpenAPI 3.1 para los endpoints nuevos y los conteos de lotes.
- No se modificaron V001–V007, tablas públicas P3, nueve destinos curados, Flutter, contratos P8/P9, offline ni Driving. La implementación multimedia existente se reutiliza con activos sintéticos; las cinco fotos del piloto local siguen excluidas por derechos no acreditados.

## Muestra de revisión piloto Lima–Canta–Obrajillo

La fuente local contiene 17 filas con provincia Canta. Todas aparecen en el manifiesto exacto del snapshot como `NORMALIZED_PENDING_REVIEW`; los pares siguientes son candidatos reconstruidos por la regla individual aprobada en dicho manifiesto, no coordenadas verificadas. La fuente conserva el campo `LATITUD` como longitud candidata y `LONGITUD` como latitud candidata según la regla versionada de este snapshot. Se incluyen para priorizar fichas de revisión, no para publicar.

| Código | Recurso | Distrito | Categoría / subtipo | Raw LATITUD / LONGITUD | Candidato latitude, longitude | Estado |
|---|---|---|---|---|---|---|
| 1851 | Sitio Arqueológico Cantamarca | CANTA | Manifestaciones culturales / Sitios arqueológicos / Templos | -7.659.177.699.999.990 / -11.438.714 | -11.438714, -76.59177699999990 | NORMALIZED_PENDING_REVIEW |
| 2725 | Petroglifos de Checta | Santa Rosa de Quives | Manifestaciones culturales / Sitios arqueológicos / Petroglifos | -7.681.504 / -1.169.289 | -11.69289, -76.81504 | NORMALIZED_PENDING_REVIEW |
| 5559 | Laguna Chuchun | Huaros | Sitios naturales / cuerpo de agua / lagunas | -7.643.949.630.422.970 / -11.374.894.289.600.500 | -11.374894289600500, -76.43949630422970 | NORMALIZED_PENDING_REVIEW |
| 5560 | Cascada Pomora | Huaros | Sitios naturales / caídas de agua / cascadas | -7.653.394.019.510.650 / -11.408.466.910.142.300 | -11.408466910142300, -76.53394019510650 | NORMALIZED_PENDING_REVIEW |
| 6009 | Santuario de Santa Rosa de Quives | Santa Rosa de Quives | Manifestaciones culturales / arquitectura y espacios urbanos / santuario | -7.679.021.699.999.990 / -11.668.871 | -11.668871, -76.79021699999990 | NORMALIZED_PENDING_REVIEW |
| 7173 | Pueblo de San Buenaventura | San Buenaventura | Manifestaciones culturales / pueblos / tradicionales | -7.666.198 / -1.148.929 | -11.48929, -76.66198 | NORMALIZED_PENDING_REVIEW |
| 7174 | Danza Los Chunchitos de San Buenaventura | San Buenaventura | Folclore / músicas y danzas | -7.666.198 / -1.148.929 | -11.48929, -76.66198 | NORMALIZED_PENDING_REVIEW |
| 7186 | Danza Los Negritos de San José | San Buenaventura | Folclore / músicas y danzas | -7.666.198 / -1.148.929 | -11.48929, -76.66198 | NORMALIZED_PENDING_REVIEW |
| 7187 | Danza Los Viejitos de San José | San Buenaventura | Folclore / músicas y danzas | -7.666.198 / -1.148.929 | -11.48929, -76.66198 | NORMALIZED_PENDING_REVIEW |
| 13029 | Cordillera de la Viuda | Huaros | Sitios naturales / montañas / cordillera | -7.640.447 / -1.139.873 | -11.39873, -76.40447 | NORMALIZED_PENDING_REVIEW |
| 13016 | Laguna de Siete Colores | Huaros | Sitios naturales / cuerpo de agua / lagunas | -7.644.044 / -1.135.931 | -11.35931, -76.44044 | NORMALIZED_PENDING_REVIEW |
| 11877 | Parque Temático Machu Picchu Limeño | San Buenaventura | Realizaciones técnicas, científicas y artísticas / otros | -766.737.056.713.562 / -11.486.140.022.678.000 | -11.486140022678000, -76.6737056713562 | NORMALIZED_PENDING_REVIEW |
| 12185 | Iglesia Colonial de San Buenaventura | San Buenaventura | Manifestaciones culturales / arquitectura y espacios urbanos / iglesias | -7.666.179 / -1.148.940 | -11.48940, -76.66179 | NORMALIZED_PENDING_REVIEW |
| 12189 | Sitio Arqueológico Cushpa | San Buenaventura | Manifestaciones culturales / sitios arqueológicos / ciudadelas | -7.665.133 / -1.146.563 | -11.46563, -76.65133 | NORMALIZED_PENDING_REVIEW |
| 14041 | Cascada de Huamanmayo | San Buenaventura | Sitios naturales / caídas de agua / cascadas | -7.663.702.011.108 / -1.146.341.172.905 | -11.46341172905, -76.63702011108 | NORMALIZED_PENDING_REVIEW |
| 14068 | Plaza de Armas de Canta | Canta | Manifestaciones culturales / arquitectura y espacios urbanos / plazas | -766.247.746 / -114.669.625 | -11.4669625, -76.6247746 | NORMALIZED_PENDING_REVIEW |
| 14060 | Plaza de Armas de Obrajillo | Canta | Manifestaciones culturales / arquitectura y espacios urbanos / plazas | -766.198.348 / -114.531.255 | -11.4531255, -76.6198348 | NORMALIZED_PENDING_REVIEW |

El manifiesto por snapshot es la fuente de cada candidato numérico; no se infiere exactitud geodésica por sus decimales. La comparación con los cinco P3 y nueve destinos protegidos, evidencia de acceso, revisión de duplicados, decisión de elegibilidad destino/POI/ambos y relación aprobada siguen pendientes por registro. Checta y Santa Rosa requieren atención de identidad por sus correspondencias nominales con entidades ya conocidas; no se crea vínculo automático. Ninguna de las 17 filas se aprobó o publicó en esta fase.

### Ficha de revisión preliminar del piloto

La tabla anterior funciona como cola de priorización, no como selección editorial final. Para cada uno de los 17 candidatos, el estado comprobado es `NORMALIZED_PENDING_REVIEW`; el único soporte disponible para la ubicación es raw + regla/candidato del snapshot con SHA indicado. Las siguientes decisiones permanecen `PENDING` por recurso: verificación cartográfica/administrativa de la ubicación, comparación de identidad con los cinco P3 y nueve destinos curados, categoría/elegibilidad destino o POI, acceso vial si se propone destino, procedencia/licencia aplicable y decisión editorial. No se registran exclusiones finales porque no se ejecutó una revisión geográfica/identitaria con evidencia suficiente. El objetivo orientativo de 20–50 no impone mínimo ni convierte estos 17 candidatos en aprobados; no se amplió el conjunto con coordenadas o identidades inferidas.

## Validaciones

| Área | Resultado |
|---|---|
| Portal — pruebas Vitest | PASS — 5 pruebas en 3 archivos |
| Portal — TypeScript/Vite build | PASS — `npm run build` |
| OpenAPI | PASS — YAML 1.2 parseado con SnakeYAML; 33 rutas y sin referencias a esquemas inexistentes |
| Flutter | PASS — 314 pruebas aprobadas, 3 omitidas; suite completa reutilizada. No hubo cambios Flutter. |
| Backend `mvn verify -q` | PASS — exit code 0; 103 pruebas reportadas, 0 failures, 0 errors, 16 skipped |
| Perfil del CSV local | PASS — 9 pruebas de parser/normalizador sin omisiones con `-Dgeoguide.test.minceturCsv=...Inventario_recursos_turisticos.csv`; entrada solo lectura con SHA-256 documentado arriba |
| Testcontainers / PostGIS | NOT RUN — 14 pruebas de `PostgisIntegrationTests` omitidas porque no hay entorno Docker válido; no se ejecutó V008 sobre PostgreSQL/PostGIS real |
| Importación real, idempotencia DB, publicación y relación sobre PostGIS | Pendiente por el mismo bloqueo; las pruebas de integración están codificadas para base Testcontainers aislada, pero no cuentan como resultado ejecutado |
| GraphHopper/Search/Route Discovery end-to-end | Pendiente de stack aislado con backend/PostGIS/routing provider; no se consultaron servicios compartidos. |
| OpenAPI, `git diff --check` y escaneo de secretos | PASS al cierre local; no se añadieron archivos de configuración secreta ni credenciales. |

El resultado PARTIAL de la validación integrada anterior se conserva como historial. Esta rama no declara PASS integrado basándose en mocks o pruebas omitidas.

### Seguimiento de validación integral — 2026-11-18

Se inspeccionó el host local antes de crear recursos. No hay ejecutable Docker ni servicio Docker, Podman, PostgreSQL o PostGIS instalados; `wsl --status` informa que WSL no tiene distribuciones instaladas. Tampoco se encontraron utilidades `psql`, `pg_ctl` o `pg_isready`, ni un servicio PostgreSQL. El host reportó 8 GiB de RAM total y aproximadamente 1 GiB libre. No se instalaron runtimes o distribuciones, no se descargaron imágenes ni se crearon contenedores, redes, volúmenes, bases o listeners temporales. No se usó VM ni servicio compartido. Sin un motor PostgreSQL/PostGIS aislado disponible, no se pudo ejecutar `PostgisIntegrationTests`, aplicar Flyway V001–V008, correr la importación/idempotencia en una base real o validar el flujo completo con GraphHopper. Los 14 casos PostGIS permanecen omitidos por falta de Docker; las pruebas aplicables del CSV se ejecutaron aparte y pasaron. Este resultado es una limitación de entorno, no PASS de integración.

## Riesgos y límites

- Los candidatos normalizados no son ubicaciones verificadas ni publicables. Mantener staging y cuarentena; no ejecutar el importador sobre base compartida.
- El snapshot local enumera 17 recursos de provincia Canta, como candidatos de una cola preliminar; la revisión editorial por recurso sigue pendiente y el objetivo 20–50 no relaja los criterios.
- Falta aplicar V008 en PostGIS aislado y ejecutar el flujo importación → revisión → publicación → búsqueda/ruta/Discovery en datos sintéticos.
- No se añadieron fotografías reales ni derechos asumidos. Medios productivos deben tener licencia, atribución y aprobación por activo; offline sigue excluido.
- No se realizó validación física, despliegue, push, PR ni merge.

## Estado de gobierno al cierre

```ini
POI_CATALOG_1_CONTRACT = FROZEN
POI_CATALOG_1_IMPLEMENTATION = COMPLETE
POI_CATALOG_1_VALIDATION = PARTIAL
POI_CATALOG_1_READY_FOR_PR_REVIEW = NO
MINCETUR_6_331 = NORMALIZED_PENDING_REVIEW
MINCETUR_10 = QUARANTINED
MINCETUR_PUBLICATION = NONE
P3_AND_CURATED_DESTINATIONS = PRESERVED
P9_OFFLINE_MEDIA = EXCLUDED
P12_5 = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```

## Validación integral aislada — 2026-11-18

Esta actualización conserva los resultados `PARTIAL` históricos anteriores y registra la ejecución integral autorizada sobre una base temporal nueva. El worktree inició en `codex/poi-catalog-1-discovery`, HEAD `e7e5480744298c4176dbc6287949433e61f51691`, seis commits delante de `origin/main` `7b7fb9c9aec8efe4076a048fb224e4ec92681155`. No se conectó el stack temporal a redes, bases, volúmenes ni secretos del proyecto compartido.

### PostGIS, Flyway y staging MINCETUR

- `mvn -B -q verify` se ejecutó en Maven 3.9.16 / Java 21 contra PostgreSQL 16 + PostGIS 3.4 aislado, con V001–V008 validadas/aplicadas. Resultado: 104 pruebas, 0 fallos, 0 errores, 0 omitidas; `PostgisIntegrationTests`: 15/15 PASS.
- La prueba del CSV de solo lectura verificó su SHA-256 `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66`, 6.341 registros, 6.331 `NORMALIZED_PENDING_REVIEW` y 10 `COORDINATE_FORMAT_AMBIGUOUS`. La segunda importación devolvió el mismo lote y no creó otro lote ni duplicó sus 6.341 filas.
- Los cinco POIs P3 y nueve destinos curados conservaron ID, nombre, geometría y estado antes/después del staging. No se crearon borradores editoriales a partir del CSV; publicaciones reales: cero.
- Las pruebas PostGIS incluyeron revisión/publicación sintética, rechazo de versión obsoleta y de publicación sin las revisiones/evidencias requeridas, relación destino↔POI auditada y preservación de geometrías independientes.

### OIDC/RBAC y portal

- Se reutiliza la evidencia vigente de VALIDATION-4C para navegador, Authorization Code + PKCE, tokens válido/inválido/vencido, roles, portal y estados de error/permiso; esas pruebas no se repitieron porque no hubo cambios en portal, seguridad ni su configuración de producción.
- En el stack OIDC aislado de esta ejecución se volvieron a comprobar tokens firmados por Keycloak sintético y issuer/audience/roles: anónimo `401`, editor en lectura `200`, administrador en lectura `200`, audience incorrecta `401` y operación administrativa prohibida al editor `403`.
- La ejecución de este re-chequeo no configuró identidad productiva ni cambió la política deny-by-default.

### GraphHopper y Route Discovery

- Se repitió la prueba con el PBF de Perú de solo lectura, SHA-256 `a6d7eb406f83ac801327c3d53ca62ddad2facf39be46e5743923a49053a82ec0`, GraphHopper 11.0 y backend conectados únicamente al PostGIS/Compose temporal.
- La búsqueda `Canta` obtuvo el destino curado; PlanRoute Canta→Obrajillo devolvió 2 683,071 m, 320,004 s y 107 coordenadas de geometría vial. Route Discovery devolvió cuatro POIs dentro del corredor, incluido un POI sintético activo a 19,47 m y POIs P3 cercanos.
- Prueba de filtros real: categoría `OTHER` devolvió solo el fixture activo cercano; excluyó el fixture inactivo y el activo fuera del corredor de 1.000 m. Categoría `WATERFALL` no devolvió resultados. Los errores de cobertura del proveedor y la respuesta segura `NO_ROUTE_FOUND` se conservan en la evidencia previa de esta ejecución.

### Límites, aislamiento y cierre

- Rechequeo de recursos: límites efectivos para PostGIS 1.0 GiB/0,50 CPU, GraphHopper 1,25 GiB/0,95 CPU y backend 0,50 GiB/0,40 CPU: máximo agregado simultáneo 2,75 GiB/1,85 CPU, bajo el tope de 3,5 GiB/2 CPU. El uso observado fue inferior a los límites. El runner Maven y Keycloak se ejecutaron en etapas separadas para respetar el mismo presupuesto agregado.
- Los seis servicios preexistentes `geoguide-ai-*` conservaron sus estados; antes y después de la validación estaban activos, y backend, GraphHopper, Redis, MinIO y PostgreSQL reportaron `healthy` cuando tienen healthcheck. No se modificaron ni reiniciaron.
- Se retiraron los contenedores, la red, los volúmenes y el directorio temporal exclusivos `poicat1-fca48c38`. La verificación posterior encontró cero recursos etiquetados de ese proyecto; el directorio temporal VM y el script auxiliar de limpieza ya no existen.
- La limpieza del staging Windows local quedó pendiente: la ruta exacta `D:\Codex\poi-catalog-1-validation-20261118-fca48c38` contiene archivos temporales de esta prueba, incluido `.env` con valores sintéticos. PowerShell verificó que el directorio no contiene subdirectorios y que la ruta resuelta coincide exactamente, pero la revisión automática bloqueó la operación de borrado. No se intentó un método alternativo. El archivo puntero `%TEMP%\poicat1_validation_path.txt` también permanece. Ninguno de estos archivos pertenece al worktree ni al diff Git.
- En el harness de integración, el modo externo permite ejecutar PostGIS con una URL explícita aislada y mantiene Testcontainers como ruta habitual. La suite también permite activar el caso de snapshot completo mediante propiedad opt-in. Se corrigió el fixture de hash para ajustarse al formato uppercase exigido por V006. No hubo cambios de producción.
- No hubo instalación física, despliegue, publicación de candidatos MINCETUR, incorporación de fotografías reales, push, PR ni merge. Se mantienen los límites de P8/P9, `P12_5 = NOT_AUTHORIZED`, `UI_2_MASTER_CLOSURE = NOT_AUTHORIZED` y `PRODUCTION_READINESS = NOT_DECLARED`.

```ini
POI_CATALOG_1_VALIDATION = PARTIAL
POI_CATALOG_1_READY_FOR_PR_REVIEW = NO
V001_V008_POSTGIS = PASS
MINCETUR_STAGING = PASS_6341_6331_10_IDEMPOTENT
P3_AND_CURATED_DESTINATIONS = PRESERVED
EDITORIAL_SYNTHETIC_FLOW = PASS
OIDC_RBAC = PASS
REAL_GRAPHHOPPER_ROUTE_DISCOVERY = PASS
TEMPORARY_VM_STACK_CLEANUP = PASS
TEMPORARY_WINDOWS_STAGING_CLEANUP = BLOCKED_AUTOMATIC_REVIEW
MINCETUR_PUBLICATION = NONE
REAL_PHOTOS = EXCLUDED
P9_OFFLINE_MEDIA = EXCLUDED
P12_5 = NOT_AUTHORIZED
UI_2_MASTER_CLOSURE = NOT_AUTHORIZED
PRODUCTION_READINESS = NOT_DECLARED
```
