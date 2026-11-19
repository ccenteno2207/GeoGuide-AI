# POI-DATA-2 — Auditoría de taxonomía MINCETUR y propuesta de filtro

**Estado:** `POI_DATA_2_TAXONOMY_AUDIT = PARTIAL`  
**Contrato:** `POI_DATA_2_FILTER_CONTRACT = PROPOSED_NOT_APPROVED`  
**Baseline auditado:** `origin/main = 2b94eb459ca711d08c711c732a3310ccb77f36e9`  
**Rama local:** `codex/poi-data-2-taxonomy-audit`  

## Alcance y fuente

Auditoría de solo lectura para la elegibilidad temática del staging MINCETUR. No se modificaron backend, portal, base de datos, reglas de publicación ni inventario fuente. El archivo local estaba abierto en Excel; se leyó con acceso compartido de lectura y no se alteró.

| Propiedad | Resultado verificado |
|---|---|
| Archivo | `D:\Proyectos\Desarrollo\Ruteo\Imagenes\Inventario_recursos_turisticos.csv` |
| SHA-256 | `29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66` |
| Tamaño | 1,565,274 bytes |
| Corte declarado | `20261110` en las 6.341 filas |
| Codificación / delimitador | Windows-1252 / `;` |
| Filas | 6,341 |
| Encabezados de clasificación | `CATEGORÍA`, `TIPO DE CATEGORÍA`, `SUB TIPO CATEGORÍA` |
| Clasificación raíz / tipo / subtipo | 5 raíces / 35 tipos raw / 188 valores raw de subtipo (incluye vacío); 186 subtipos no vacíos tras trim |

Los 12 encabezados del snapshot coinciden con los declarados por `MinceturSnapshotParser`; el parser no infiere columnas alternativas. La evidencia POI-DATA-1 registra 6.341 filas, 6.331 candidatos numéricos de coordenadas `NORMALIZED_PENDING_REVIEW` y 10 en cuarentena. El estado geográfico es independiente del filtro temático.

## Taxonomía observada y frecuencias

### CATEGORÍA (raíz)

| Valor exacto | Registros |
|---|---:|
| 1. SITIOS NATURALES | 2221 |
| 2. MANIFESTACIONES CULTURALES | 2174 |
| 3. FOLCLORE | 849 |
| 4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS | 314 |
| 5. ACONTECIMIENTOS PROGRAMADOS | 783 |

### TIPO DE CATEGORÍA (criterio principal propuesto)

| Valor exacto del CSV | Registros | Decisión temática propuesta |
|---|---:|---|
| Arquitectura y Espacios Urbanos | 1059 | No está en exclusión; candidato sujeto a gates separados |
| Artesanía y Artes | 93 | Excluir (clase aprobada) |
| Artísticos | 27 | No está en exclusión; candidato sujeto a gates separados |
| Centros Científicos y Técnicos | 85 | No está en exclusión; candidato sujeto a gates separados |
| Creencias Populares | 168 | Excluir (clase aprobada) |
| Etnias | 28 | No está en exclusión; candidato sujeto a gates separados |
| Eventos | 196 | Excluir (clase aprobada) |
| Explotaciones  Agropecuarias y Pesqueras | 75 | Excluir (clase aprobada) |
| Explotaciones Industriales | 121 | Excluir (clase aprobada) |
| Explotaciones Mineras | 2 | Excluir (clase aprobada) |
| Ferias y Mercados | 18 | No está en exclusión; candidato sujeto a gates separados |
| Fiestas | 555 | Excluir (clase aprobada) |
| Gastronomía | 290 | Excluir (clase aprobada) |
| Lugares Históricos | 80 | No está en exclusión; candidato sujeto a gates separados |
| Museos y otros | 198 | No está en exclusión; candidato sujeto a gates separados |
| Músicas y Danzas | 252 | Excluir (clase aprobada) |
| Otros | 50 | No está en exclusión; candidato sujeto a gates separados |
| Pueblos | 209 | No está en exclusión; candidato sujeto a gates separados |
| Sitios Arqueológicos | 614 | No está en exclusión; candidato sujeto a gates separados |
| a. Montañas | 135 | No está en exclusión; candidato sujeto a gates separados |
| b. Planicies | 16 | No está en exclusión; candidato sujeto a gates separados |
| c. Valles | 24 | No está en exclusión; candidato sujeto a gates separados |
| d. Quebradas | 69 | No está en exclusión; candidato sujeto a gates separados |
| e. Cañones | 46 | No está en exclusión; candidato sujeto a gates separados |
| f. Pongos | 4 | No está en exclusión; candidato sujeto a gates separados |
| g. Cuerpo de Agua | 433 | No está en exclusión; candidato sujeto a gates separados |
| h. Corrientes de agua | 57 | No está en exclusión; candidato sujeto a gates separados |
| i. Manantiales | 25 | No está en exclusión; candidato sujeto a gates separados |
| j. Caídas de agua | 390 | No está en exclusión; candidato sujeto a gates separados |
| k. Agua termo-mineral | 122 | No está en exclusión; candidato sujeto a gates separados |
| l. Costas | 259 | No está en exclusión; candidato sujeto a gates separados |
| m. Cavidades naturales | 45 | No está en exclusión; candidato sujeto a gates separados |
| n. Áreas Protegidas | 116 | No está en exclusión; candidato sujeto a gates separados |
| o. Otros | 117 | No está en exclusión; candidato sujeto a gates separados |
| ñ. Zonas paisajísticas | 363 | No está en exclusión; candidato sujeto a gates separados |

### SUB TIPO CATEGORÍA

Frecuencias por valor raw exacto. `∅` representa la única celda vacía. El conteo incluye variantes de espacios para preservar el dato: 188 valores exactos incluyendo vacío; 186 valores no vacíos después de trim.

| Valor exacto | Registros |
|---|---:|
| ∅ (vacío) | 1 |
| Acuarios | 1 |
| Acuicultura | 2 |
| Agricultura | 35 |
| Aguajales | 2 |
| Aguas Termales | 1 |
| Alamedas | 9 |
| Albuferas | 1 |
| Alfarería y cerámica | 7 |
| Altiplanos | 1 |
| Andenes | 18 |
| Artesanales | 22 |
| Bahías | 1 |
| Bares | 1 |
| Barrios tradicionales | 13 |
| Basílica | 5 |
| Bebidas Típicas | 46 |
| Biblioteca | 4 |
| Bodegas de pisco, vinos y/u otros licores | 84 |
| Bofedales | 1 |
| Bosque de Piedra | 1 |
| Bosques | 64 |
| Bosques de protección | 5 |
| Bulevares | 6 |
| CITES(artesanía, turismo,agroindustriales) | 1 |
| Caletas | 14 |
| Camino Paisajista | 3 |
| Camino Pintoresco | 13 |
| Campos santos | 8 |
| Canales de riego | 2 |
| Capilla | 39 |
| Casa de Valor Arquitectónico | 47 |
| Casa-Hacienda | 38 |
| Casas Históricas | 7 |
| Casas Museo | 21 |
| Casas haciendas | 7 |
| Cascadas | 148 |
| Casona | 13 |
| Casonas | 1 |
| Castillo | 2 |
| Cataratas | 242 |
| Catedral | 9 |
| Cavernas | 7 |
| Cañones | 46 |
| Cementerios | 38 |
| Centrales Hidroeléctricas | 1 |
| Centros Históricos | 7 |
| Centros Productivos | 20 |
| Centros de rescate o conservación | 15 |
| Cerros | 69 |
| Cestería | 4 |
| Ciudadelas | 44 |
| Collpas | 24 |
| Complejo Histórico | 1 |
| Complejo monumental | 8 |
| Concursos | 9 |
| Convento | 9 |
| Cordillera | 6 |
| Costa | 2 |
| Costumbres | 28 |
| Cotos de Caza | 4 |
| Criaderos | 3 |
| Cuarteles | 1 |
| Cuentos | 16 |
| Cuestas | 2 |
| Cuevas | 23 |
| Danza | 12 |
| Deportivos | 6 |
| Desiertos | 1 |
| Dulces Típicos | 54 |
| Dunas | 5 |
| Embarcaderos | 4 |
| Escuela o Colegio | 2 |
| Esculturales | 3 |
| Esteros | 1 |
| Explotaciones mineras | 2 |
| Ferias (no Artesanales) | 25 |
| Ferias Artesanales | 9 |
| Ferias gastronómicas | 3 |
| Festivales | 120 |
| Fiestas Tradicionales(Herranza, carnavales, otros) | 122 |
| Fiestas religiosas-patronales | 411 |
| Formaciones rocosas(bosque de piedra) | 80 |
| Fortalezas | 23 |
| Fábricas | 7 |
| Galerías Expositiva | 5 |
| Geiser | 8 |
| Geoglifos (Grabado en tierra) | 14 |
| Glorietas | 1 |
| Granadería | 11 |
| Gruta | 2 |
| Grutas | 18 |
| Históricos | 35 |
| Humedales | 25 |
| Iglesias | 216 |
| Indumentaria | 3 |
| Instrumentos musicales | 2 |
| Islas | 23 |
| Jardines Botánicos y Viveros | 12 |
| Lagos | 16 |
| Lagunas | 382 |
| Lomas | 10 |
| Lugares paleontológicos(Fósiles) | 6 |
| Lugares pintorescos de flora y fauna | 41 |
| Madera/carpintería (escultura) | 4 |
| Malecones | 20 |
| Manantiales | 25 |
| Manglares | 2 |
| Mariposarios | 6 |
| Mercados  Artesanales | 3 |
| Miradores | 88 |
| Miradores naturales | 234 |
| Mitos | 26 |
| Molino | 17 |
| Monasterio | 3 |
| Muelles | 9 |
| Murallas | 3 |
| Museos | 121 |
| Museos de sitio | 13 |
| Máscaras | 1 |
| Música | 1 |
| Música y Danzas | 252 |
| Nevado | 38 |
| Ojos de agua | 51 |
| Orfebrería | 5 |
| Otros | 460 |
| Otros␠ (espacio final raw) | 11 |
| Palacio | 4 |
| Palacios | 1 |
| Pampas | 6 |
| Pantano | 2 |
| Parques | 68 |
| Parques Nacionales | 16 |
| Parques arqueológicos | 10 |
| Paseos peatonales | 19 |
| Pasos o Abras | 2 |
| Penínsulas | 2 |
| Petroglifos (Grabados en piedra) | 49 |
| Piedras | 5 |
| Piezas con valor artístico | 1 |
| Piezas con valor histórico | 7 |
| Pinacotecas(Pinturas) | 2 |
| Pintura Rupestre | 38 |
| Pinturas | 1 |
| Pinturas murales | 3 |
| Piscigranja | 18 |
| Platos Típicos | 179 |
| Playas | 203 |
| Plaza | 14 |
| Plazas | 138 |
| Plazuelas | 17 |
| Pongos | 4 |
| Puentes | 48 |
| Puentes Modernos | 5 |
| Puertos | 5 |
| Puntas | 1 |
| Quebradas | 69 |
| Recintos ceremoniales | 14 |
| Refugio de Vida Silvestre | 2 |
| Represas | 7 |
| Reservas Comunales | 8 |
| Reservas Nacionales | 18 |
| Reservas Paisajistas | 3 |
| Rápidos | 1 |
| Ríos | 54 |
| Salas de Exhibición | 26 |
| Salinas | 4 |
| Santuario | 33 |
| Santuarios | 2 |
| Santuarios Históricos | 3 |
| Santuarios Nacionales | 8 |
| Selva | 21 |
| Sierra␠ (espacio final raw) | 5 |
| Sitios de Batalla | 9 |
| Teatro | 4 |
| Tejidos(lanas, fibras de animales, fibra vegetal. Etc) | 49 |
| Templo | 100 |
| Templos | 112 |
| Tradicionales | 148 |
| Tradiciones | 30 |
| Túneles | 1 |
| Valles | 24 |
| Volcanes | 14 |
| Zonas Reservadas | 7 |
| Zonas arqueológicas | 215 |
| Zoológicos | 5 |
| Áreas de conservación privada | 17 |
| Áreas de conservación regional | 14 |

### Matriz raíz × tipo

`Otros` se conserva como valor literal y aparece en tres raíces. Ninguna categoría raíz completa se excluye por inferencia.

| CATEGORÍA | TIPO DE CATEGORÍA | Registros |
|---|---|---:|
| 1. SITIOS NATURALES | a. Montañas | 135 |
| 1. SITIOS NATURALES | b. Planicies | 16 |
| 1. SITIOS NATURALES | c. Valles | 24 |
| 1. SITIOS NATURALES | d. Quebradas | 69 |
| 1. SITIOS NATURALES | e. Cañones | 46 |
| 1. SITIOS NATURALES | f. Pongos | 4 |
| 1. SITIOS NATURALES | g. Cuerpo de Agua | 433 |
| 1. SITIOS NATURALES | h. Corrientes de agua | 57 |
| 1. SITIOS NATURALES | i. Manantiales | 25 |
| 1. SITIOS NATURALES | j. Caídas de agua | 390 |
| 1. SITIOS NATURALES | k. Agua termo-mineral | 122 |
| 1. SITIOS NATURALES | l. Costas | 259 |
| 1. SITIOS NATURALES | m. Cavidades naturales | 45 |
| 1. SITIOS NATURALES | n. Áreas Protegidas | 116 |
| 1. SITIOS NATURALES | o. Otros | 117 |
| 1. SITIOS NATURALES | ñ. Zonas paisajísticas | 363 |
| 2. MANIFESTACIONES CULTURALES | Arquitectura y Espacios Urbanos | 1059 |
| 2. MANIFESTACIONES CULTURALES | Lugares Históricos | 80 |
| 2. MANIFESTACIONES CULTURALES | Museos y otros | 198 |
| 2. MANIFESTACIONES CULTURALES | Otros | 14 |
| 2. MANIFESTACIONES CULTURALES | Pueblos | 209 |
| 2. MANIFESTACIONES CULTURALES | Sitios Arqueológicos | 614 |
| 3. FOLCLORE | Artesanía y Artes | 93 |
| 3. FOLCLORE | Creencias Populares | 168 |
| 3. FOLCLORE | Etnias | 28 |
| 3. FOLCLORE | Ferias y Mercados | 18 |
| 3. FOLCLORE | Gastronomía | 290 |
| 3. FOLCLORE | Músicas y Danzas | 252 |
| 4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS | Centros Científicos y Técnicos | 85 |
| 4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS | Explotaciones  Agropecuarias y Pesqueras | 75 |
| 4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS | Explotaciones Industriales | 121 |
| 4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS | Explotaciones Mineras | 2 |
| 4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS | Otros | 31 |
| 5. ACONTECIMIENTOS PROGRAMADOS | Artísticos | 27 |
| 5. ACONTECIMIENTOS PROGRAMADOS | Eventos | 196 |
| 5. ACONTECIMIENTOS PROGRAMADOS | Fiestas | 555 |
| 5. ACONTECIMIENTOS PROGRAMADOS | Otros | 5 |

## Exclusiones aprobadas y normalización exacta

La decisión de producto aplica a igualdad del campo `TIPO DE CATEGORÍA`, con alias explícitos. Para comparación se propone trim, colapso de espacios Unicode, normalización NFD sin diacríticos y minúsculas invariantes. No se elimina puntuación ni se hacen coincidencias parciales; la celda raw permanece preservada.

| Clase aprobada | Valor raw observado | Registros | Tratamiento exacto |
|---|---|---:|---|
| Música y Danzas | Músicas y Danzas | 252 | plural raw explícito |
| Gastronomía | Gastronomía | 290 | acentos/caja normalizados |
| Fiestas | Fiestas | 555 | igualdad |
| Explotación Minera | Explotaciones Mineras | 2 | alias plural explícito |
| Explotaciones Industriales | Explotaciones Industriales | 121 | igualdad |
| Explotaciones Agropecuarias y Pesqueras | Explotaciones  Agropecuarias y Pesqueras | 75 | doble espacio raw colapsado |
| Eventos | Eventos | 196 | igualdad |
| Creencias Populares | Creencias Populares | 168 | igualdad |
| Artesanía y Artes | Artesanía y Artes | 93 | acentos/caja normalizados |
| **Total excluido** |  | **1,752** | Nueve clases exactas/alias; sin substring matching |

## Calidad de clasificación y conteos cruzados

| Medida | Conteo | Interpretación |
|---|---:|---|
| Inventario original | 6,341 | Filas del snapshot identificado |
| Excluido por tipo | 1,752 | Exclusión temática primaria |
| Pasa regla primaria | 4,589 | No es aprobación como POI/destino |
| Conflictos tipo–subtipo | 16 | Artísticos/Danza 12; Artísticos/Música 1; Ferias y Mercados/Ferias gastronómicas 3 |
| Elegible para revisión temática, sin conflicto detectado | 4,573 | Cola de revisión; no significa POI/destino aprobado y aún requiere gates geográficos/editoriales |
| Clasificación insuficiente/conflictiva para inclusión automática | 16 | Requiere revisión de tipo–subtipo antes de resolver elegibilidad |
| Categoría raíz vacía | 0 | Cobertura completa |
| Tipo vacío | 0 | Cobertura completa de campo primario |
| Subtipo vacío | 1 | Código 14342 `La Q’Ocha Fiesta`; tipo `Fiestas`, ya excluido por regla primaria |
| Cuarentena por coordenadas | 10 | Diez IDs registrados por POI-DATA-1, independiente de tema |
| Cuarentena ∩ exclusión temática | 2 | Códigos 14810 (Músicas y Danzas) y 14798 (Fiestas) |
| Cuarentena de tipo no excluido | 8 | Ocho; permanecen geográficamente en cuarentena |

Variantes de whitespace observadas: `TIPO DE CATEGORÍA` contiene dos espacios internos en `Explotaciones␠␠Agropecuarias y Pesqueras` (75 filas); en subtipos aparecen `Mercados␠␠Artesanales` (3), `Otros␠` (11) y `Sierra␠` (5). `␠` representa un espacio literal. La comparación propuesta colapsa whitespace para igualdad, pero raw conserva cada forma. No se detectó valor con acento/caja que cambiara la regla fuera de alias expresos.

Los 16 conflictos secundarios son señales para revisión, no una ampliación automática de las exclusiones. En particular, no se usa una búsqueda parcial para convertir `Ferias gastronómicas` en exclusión; se retiene para revisión de clasificación. El único subtipo vacío ya queda excluido por `TIPO`, por lo que no genera un candidato temáticamente indeterminado.

### Cuarentena cruzada con taxonomía

| Código | Recurso | Tipo | Resultado temático |
|---:|---|---|---|
| 559 | Quebrada Los Cedros | d. Quebradas | No excluido; geografía en cuarentena |
| 3923 | Complejo Arqueologico De Arascorgue | Sitios Arqueológicos | No excluido; geografía en cuarentena |
| 6871 | Cañon De Ushto | e. Cañones | No excluido; geografía en cuarentena |
| 6905 | Sitios Arqueológico De Yaumanpata Y Murallapunta | Sitios Arqueológicos | No excluido; geografía en cuarentena |
| 11104 | Mirador Turístico Juan Huido | ñ. Zonas paisajísticas | No excluido; geografía en cuarentena |
| 14707 | Iglesia Matriz Santo Domingo De Guzmán De Tauca | Arquitectura y Espacios Urbanos | No excluido; geografía en cuarentena |
| 14737 | Mirador Natural Cruz De La Esperanza - Tauca | ñ. Zonas paisajísticas | No excluido; geografía en cuarentena |
| 14738 | Pueblo Tradicional De Tauca | Pueblos | No excluido; geografía en cuarentena |
| 14798 | Fiestas Patronales De Marachanca | Fiestas | Excluido |
| 14810 | Danza Las Mascaritas De Pacarán | Músicas y Danzas | Excluido |

## Impacto en el piloto Canta (17 candidatos)

La elegibilidad temática solo indica que una fila puede pasar a revisiones posteriores. No valida coordenadas, identidad, dominio (destino/POI), derechos ni publicación.

| Código | Recurso | Tipo | Resultado |
|---:|---|---|---|
| 1851 | Sitio Arqueológico Cantamarca | Sitios Arqueológicos | Permanece como candidato a revisión |
| 2725 | Petroglifos De Checta | Sitios Arqueológicos | Permanece como candidato a revisión |
| 5559 | Laguna Chuchun | g. Cuerpo de Agua | Permanece como candidato a revisión |
| 5560 | Cascada Pomora | j. Caídas de agua | Permanece como candidato a revisión |
| 6009 | Santuario De Santa Rosa De Quives | Arquitectura y Espacios Urbanos | Permanece como candidato a revisión |
| 7173 | Pueblo De San Buenaventura | Pueblos | Permanece como candidato a revisión |
| 7174 | Danza Los Chunchitos De San Buenaventura | Músicas y Danzas | Excluido: Músicas y Danzas |
| 7186 | Danza Los Negritos De San José | Músicas y Danzas | Excluido: Músicas y Danzas |
| 7187 | Danza Los Viejitos De San José | Músicas y Danzas | Excluido: Músicas y Danzas |
| 13029 | Cordillera De La Viuda | a. Montañas | Permanece como candidato a revisión |
| 13016 | Laguna De Siete Colores | g. Cuerpo de Agua | Permanece como candidato a revisión |
| 11877 | Parque Temático Machu Picchu Limeño | Otros | Permanece como candidato a revisión |
| 12185 | Iglesia Colonial De San Buenaventura | Arquitectura y Espacios Urbanos | Permanece como candidato a revisión |
| 12189 | Sitio Arqueológico Cushpa | Sitios Arqueológicos | Permanece como candidato a revisión |
| 14041 | Cascada De Huamanmayo | j. Caídas de agua | Permanece como candidato a revisión |
| 14068 | Plaza De Armas De Canta | Arquitectura y Espacios Urbanos | Permanece como candidato a revisión |
| 14060 | Plaza De Armas De Obrajillo | Arquitectura y Espacios Urbanos | Permanece como candidato a revisión |

Resultado piloto: **14** de 17 permanecen candidatos a revisión temática; **3** quedan excluidos: códigos 7174, 7186 y 7187. Ningún registro se aprueba o publica por esta auditoría.

## Propuesta de contrato POI-DATA-2 (no aprobada)

### Elegibilidad temática

- Preservar snapshot, SHA, corte, encabezados y valores raw.
- Aplicar una tabla versionada de exclusión por igualdad normalizada de `TIPO DE CATEGORÍA`, con aliases explícitos y auditables.
- Validar la pareja `CATEGORÍA × TIPO` contra la taxonomía del snapshot. Pareja desconocida, tipo vacío o conflicto secundario se marca `CLASSIFICATION_REVIEW_REQUIRED`; nunca se publica automáticamente.
- Usar `SUB TIPO CATEGORÍA` como control de coherencia. Señal excluida exacta bajo tipo no excluido pasa a revisión. En esta muestra hay 16 conflictos. No usar `contains`/fuzzy matching; `Ferias gastronómicas` requiere resolución explícita.
- No excluir raíces completas ni ampliar las nueve clases por similitud. `Artísticos`, `Ferias y Mercados` y `Otros` no entran automáticamente en exclusión; filas en conflicto esperan revisión.

### Validación geográfica

- Es gate independiente. El candidato numérico `NORMALIZED_PENDING_REVIEW` no equivale a coordenada aprobada; cuarentena se conserva sin modificación.
- De los diez IDs en cuarentena, ocho no pertenecen a tipos excluidos y dos sí. El filtro no remueve cuarentena ni crea geometría.
- No alterar los cinco P3 ni destinos curados; no habilitar Route Discovery como efecto de elegibilidad temática.

### Revisión editorial y publicación

- La elegibilidad temática solo crea una cola de revisión. Antes de publicar se requieren revisión geográfica, identidad/duplicados, procedencia/derechos y decisión de dominio (destino, POI o ambos), conforme a los contratos existentes.
- Publicación solo por decisión explícita, autorizada y auditada. Importar, filtrar o reprocesar nunca publica automáticamente.
- Reimportar no sobrescribe snapshot raw ni retrocede decisiones editoriales/geográficas.

## Estado y decisiones posteriores

```ini
POI_DATA_2_TAXONOMY_AUDIT = PARTIAL
POI_DATA_2_FILTER_CONTRACT = PROPOSED_NOT_APPROVED
POI_DATA_2_IMPLEMENTATION = NOT_AUTHORIZED
MINCETUR_PUBLICATION = NOT_EXECUTED
```

La decisión posterior necesaria es aprobar o ajustar el tratamiento de los 16 conflictos tipo–subtipo antes de implementar el filtro. Recomendación: mantenerlos en revisión por registro, sin ampliar clases excluidas automáticamente. Este documento no altera reglas existentes ni autoriza implementación.

## Validación documental

- SHA-256, corte, codificación, delimitador y totales recalculados directamente del snapshot local; hash coincide con POI-DATA-1 evidence.
- Conteos temáticos calculados desde `TIPO DE CATEGORÍA`; cruces y conflictos calculados desde las tres columnas raw.
- Normalización se ejecutó en memoria únicamente para comparación; no se cambió el CSV ni el staging.
- Backend, portal, migraciones, base persistente y reglas de publicación: sin cambios.

