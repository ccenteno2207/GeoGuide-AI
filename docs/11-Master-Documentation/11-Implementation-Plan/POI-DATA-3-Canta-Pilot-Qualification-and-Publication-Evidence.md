# POI-DATA-3 — Calificación y publicación piloto Canta

**Baseline:** `03fad8e8df3b5c36d51ab7ad8cdc339c53de216d`

**Rama:** `codex/poi-data-3-canta-pilot`

**Contrato:** POI-DATA-1, `MINCETUR-TAXONOMY-FILTER-v1`, P3, P5 y flujo editorial existente.
**Resultado:** `POI_DATA_3_QUALIFICATION = PARTIAL`; `POI_DATA_3_PILOT_PUBLICATION = PARTIAL`.

## Fuente y alcance

Se conservó el archivo original local sin modificar ni copiar al repositorio. Sus metadatos verificados en POI-DATA-1 son: `Inventario_recursos_turisticos.csv`, SHA-256 `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66`, corte declarado `20261110`, 1,565,274 bytes, Windows-1252, delimitador `;`, 12 columnas y 6.341 registros. La clasificación temática se mantuvo separada de la validación geográfica, identidad, revisión editorial y publicación. Los tres códigos excluidos 7174, 7186 y 7187 no se incluyeron en el piloto.

El ruleset POI-DATA-2 deja 4.573 registros elegibles para revisión y 1.768 excluidos de navegación. Diez registros permanecen en cuarentena geográfica; esa cuarentena no se interpreta como elegibilidad o exclusión temática. No se publicaron los registros excluidos ni se convirtió su elegibilidad en aprobación editorial.

## Matriz individual de los 14 candidatos

| Código MINCETUR | Identidad / tipo | Resultado geográfico e identidad | Revisión, publicación y acción |
|---:|---|---|---|
| 1851 | Sitio Arqueológico Cantamarca — Sitios Arqueológicos / Templos | Candidato normalizado; MINCETUR y contexto PROMPERÚ identifican el sitio. OSM node `1649971847` coincide a aproximadamente 15 m. Sin duplicado en P3 o destinos curados. | Revisión geográfica e identidad aprobadas; fuente/licencia y atribución registradas; publicado como POI en el piloto aislado. No se creó destino ni se afirmó acceso. |
| 2725 | Petroglifos de Checta — Sitios Arqueológicos / Petroglifos | Identidad coincide con POI P3 `02000000-0000-0000-0000-000000000002` y destino curado existente. | Coincidencia existente; sin duplicado ni nueva publicación. Se preservaron POI y destino. |
| 5559 | Laguna Chuchun — Cuerpo de Agua / Lagunas | Ubicación no resuelta con la precisión necesaria. El candidato (~`-11.374894,-76.439496`) difiere de referencias públicas (~`-11.36944,-76.43979`) y de un punto de cámara (~`-11.362475,-76.439821`); la laguna es extensa. | Bloqueado antes de revisión/publicación: falta una geometría puntual o representativa con evidencia verificable. |
| 5560 | Cascada Pomora — Caídas de agua / Cascadas | La ficha MINCETUR sitúa el recurso en Cullhuay/km 137; OSM node `6916477011` con nombre coincidente queda a ~8–9 km del candidato staged. | Bloqueado: conflicto material entre ubicación del candidato y corroboración independiente. Resolver coordenada y contexto antes de aprobar geografía. |
| 6009 | Santuario de Santa Rosa de Quives — Arquitectura y Espacios Urbanos / Santuario | Coincide con POI P3 `02000000-0000-0000-0000-000000000001` y destino curado existente. | Coincidencia existente; sin nueva publicación. Se conservaron geometría, provenance e identidad existentes. |
| 7173 | Pueblo de San Buenaventura — Pueblos / Tradicionales | OSM settlement coincide aproximadamente con el candidato, pero no hay categoría de dominio P3 revisada para publicar una localidad como POI; tampoco se calificó como destino de acceso. | Bloqueado: requiere decisión/mapeo de dominio y revisión de si es POI, destino o ambos; la proximidad cartográfica no basta. |
| 13029 | Cordillera de la Viuda — Montañas / Cordillera | Recurso extenso; la ficha refiere km 145, no un punto representativo revisado. | Bloqueado: requiere geometría o punto representativo con criterio y evidencia aprobables. |
| 13016 | Laguna de Siete Colores — Cuerpo de Agua / Lagunas | MINCETUR también la denomina Laguna Calancayo. OSM en ~`-11.34097,-76.44139` difiere ~2 km del candidato (~`-11.35931,-76.44044`); contexto administrativo también requiere conciliación. | Bloqueado: resolver alias/identidad, punto y discrepancia administrativa antes de publicar. |
| 11877 | Parque Temático Machu Picchu Limeño — Otros / Otros | Elegible temáticamente, pero no existe mapeo exacto revisado desde `Otros` a una categoría soportada por el dominio P3. | Bloqueado: no se usó fallback genérico `OTHER`; se requiere mapeo de categoría basado en evidencia. |
| 12185 | Iglesia Colonial de San Buenaventura — Arquitectura y Espacios Urbanos / Iglesias | MINCETUR identifica la iglesia histórica. OSM way `450034994` coincide a ~19 m. No es la Iglesia San Juan Bautista de Obrajillo (identidad distinta). Sin duplicado P3/destinos. | Revisión geográfica e identidad aprobadas; provenance registrada; publicado como POI en el piloto. Sin afirmación de acceso ni creación de destino. |
| 12189 | Sitio Arqueológico Cushpa — Sitios Arqueológicos / Ciudadelas | El candidato (~`-11.46563,-76.65133`) difiere ~1,76 km de la coordenada referencial convertida del registro cultural Cushpa/Auquimarca (~`-11.48119,-76.65457`); identidad Cushpa/Auquimarca no está resuelta. | Bloqueado: la ubicación de referencia no es un punto exacto y falta reconciliar identidad y geometría. |
| 14041 | Cascada de Huamanmayo — Caídas de agua / Cascadas | MINCETUR identifica la cascada y registra condiciones de acceso en terreno comunal. OSM node `1651111731` coincide a ~28 m. Sin duplicado P3/destinos. | Revisión geográfica e identidad aprobadas; provenance registrada; publicado como POI únicamente. La ficha de acceso no se transforma en garantía de acceso ni destino de ruta. |
| 14068 | Plaza de Armas de Canta — Arquitectura y Espacios Urbanos / Plazas | Coincide con POI P3 `02000000-0000-0000-0000-000000000003` y destino curado existente. | Coincidencia existente; sin nueva publicación. Se preservaron registros existentes. |
| 14060 | Plaza de Armas de Obrajillo — Arquitectura y Espacios Urbanos / Plazas | Coincide con POI P3 `02000000-0000-0000-0000-000000000004` y destino curado existente. | Coincidencia existente; sin nueva publicación. Se preservaron registros existentes. |

**Resumen:** 3 candidatos nuevos calificados y publicados en el piloto efímero; 4 coinciden con datos ya publicados y no se duplicaron; 7 bloqueados individualmente. La matriz cubre los 14 códigos; ningún bloqueo detuvo la calificación de otros candidatos.

## Provenance y publicación

Para los tres POIs nuevos se registró `ODC-BY-1.0 (MINCETUR inventory); ODbL-1.0 (OSM coordinate source)` y atribución `MINCETUR — Inventario Nacional de Recursos Turísticos; © OpenStreetMap contributors`. Las fichas MINCETUR respaldan identidad y contexto; los objetos OSM citados se utilizaron como corroboración cartográfica independiente. Esto no afirma que las coordenadas staged originales procedan de OSM. El uso, redistribución y atribución deben seguir sus licencias aplicables.

Referencias de identidad y contraste de los POIs nuevos: [ficha MINCETUR 1851](https://consultasenlinea.mincetur.gob.pe/fichaInventario/index.aspx?cod_Ficha=1851), [OSM node 1649971847](https://www.openstreetmap.org/node/1649971847), [PROMPERÚ Cantamarca](https://target2.promperu.gob.pe/destinos/lima/canta/sitio-arqueologico-de-cantamarca); [ficha MINCETUR 12185](https://consultasenlinea.mincetur.gob.pe/fichaInventario/index.aspx?cod_Ficha=12185), [OSM way 450034994](https://www.openstreetmap.org/way/450034994); [ficha MINCETUR 14041](https://consultasenlinea.mincetur.gob.pe/fichaInventario/index.aspx?cod_Ficha=14041), [OSM node 1651111731](https://www.openstreetmap.org/node/1651111731). Los datos OSM se atribuyen a © OpenStreetMap contributors y se rigen por ODbL.

No se publicaron horarios, precios, fotografías, servicios, rutas de acceso ni coordenadas de destino no respaldados. Para los recursos sin acceso confirmado, la publicación como POI no constituye una promesa de acceso. No se modificaron los cinco POIs P3 ni los nueve destinos curados.

## Validación del piloto aislado

La prueba de integración `PostgisIntegrationTests.cantaPilotPublishesOnlyIndependentlyReviewedPoiCandidates` ejecutó Flyway V001–V009 sobre una base PostgreSQL 16/PostGIS 3.4 efímera y comprobó staging del snapshot completo, carga P3 y los nueve destinos, el flujo editorial existente y tres aprobaciones explícitas. Verificó para cada publicación SRID 4326 y orden X=longitud/Y=latitud; también consultó Route Discovery sobre un corredor que cruza cada punto y encontró el POI recién publicado.

Resultado del test focalizado final: **1/1 PASS**. Después de agregar la aserción Route Discovery, `mvnw verify` pasó **112/112 pruebas**, incluidas las **17/17 pruebas** de `PostgisIntegrationTests`. El test piloto comprobó 8 POIs activos (los cinco P3 más los tres del piloto), 9 destinos activos sin variación, 3 expedientes publicados, 4.573 elegibles, 1.768 excluidos y 10 en cuarentena. Las pruebas de rechazo editorial para registros excluidos y persistencia de licencia/atribución también pasaron dentro de la suite.

Entorno temporal exclusivo: contenedor `postgis/postgis:16-3.4`, red y nombre de proyecto únicos, sin volumen persistente; límite del contenedor 2 GiB / 1,5 CPU, tmpfs para datos, puerto del host enlazado a loopback y túnel SSH de loopback. La publicación solo existió dentro de la base de desarrollo aislada; no tocó base compartida ni productiva. Tras terminar la validación, se retiraron únicamente el contenedor/red/túnel creados para este piloto y se verificó que los servicios preexistentes seguían saludables. Los datos efímeros no se conservan.

## Cambios de implementación

- `AdminEditorialRepository` ahora impide crear un borrador editorial desde una fila importada si no está en `NORMALIZED_PENDING_REVIEW`, no tiene `ELIGIBLE_FOR_REVIEW`, no pertenece a un lote con `MINCETUR-TAXONOMY-FILTER-v1`, carece de coordenadas normalizadas o ya tiene conflicto idempotente. También persiste licencia y atribución al crear el expediente.
- Se ampliaron las pruebas PostGIS para comprobar elegibilidad, provenance, tres publicaciones individuales y disponibilidad inmediata en Route Discovery.
- No se agregaron migraciones, cambios API, contratos ni snapshots; no se agregaron el CSV fuente, APK, imágenes, credenciales ni archivos temporales al repositorio.

## Límites y estado

La cualificación es parcial porque siete candidatos necesitan evidencia adicional. La publicación piloto también es parcial: tres altas nuevas y cuatro coincidencias preexistentes; no implica importación o despliegue en catálogo operativo, ni valida acceso físico o el estado del terreno. Los resultados de licencia/provenance no autorizan distribución más allá de los términos de las fuentes. No se realizó validación física, instalación, push, PR, merge o despliegue productivo.

```ini
POI_DATA_3_QUALIFICATION = PARTIAL
POI_DATA_3_PILOT_PUBLICATION = PARTIAL
POI_DATA_3_PUBLISHED_COUNT = 3
POI_DATA_3_EXISTING_MATCH_COUNT = 4
POI_DATA_3_BLOCKED_COUNT = 7
POI_DATA_3_PRODUCTION_DEPLOYMENT = NOT_AUTHORIZED
```
