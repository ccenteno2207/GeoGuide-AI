# UI2-SEARCH-001 — fuente y cobertura del catálogo piloto

## Fuente y corte

- Publicador: Ministerio de Comercio Exterior y Turismo (MINCETUR).
- Conjunto: [Inventario Nacional de Recursos Turísticos](https://www.datosabiertos.gob.pe/dataset/inventario-nacional-de-recursos-tur%C3%ADsticos).
- Recurso CSV: `https://www.mincetur.gob.pe/Datos_abiertos/DGET/Inventario_recursos_turisticos.csv` (recurso CKAN `227cb3d6-5aff-46a1-aa32-2069e875b040`).
- Licencia declarada en el portal: [Open Data Commons Attribution License (ODC-BY)](http://opendefinition.org/licenses/odc-by/); atribución entregada por cada resultado y conservada en `destination`.
- Corte y descarga verificada: 2026-11-10; SHA-256 del archivo fuente: `F66AE874FAD26E899ABD023A47B96E980D194A563D7F0E7CB202A95D221D263E`.
- Carga: JSON versionado `backend/src/main/resources/data/destination-search/mincetur-pilot-v1.json`; loader opt-in mediante `geoguide.destination-catalog.enabled=true`, desactivado por defecto y destinado a bases locales/efímeras autorizadas.

## Calidad, cobertura y límites

El CSV declara columnas `LATITUD` y `LONGITUD` con valores intercambiados respecto de su significado geográfico aparente: los valores de `LATITUD` del archivo son longitudes y los de `LONGITUD` son latitudes. El mapeo usado en el JSON se verificó contra rangos geográficos peruanos y fichas oficiales de MINCETUR; por ello latitude = valor de la columna fuente `LONGITUD`, longitude = valor de `LATITUD`. No se exportó ninguna coordenada fuera de esos controles.

El corte contiene nueve recursos con ficha y coordenadas verificadas en Lima, Ica y Arequipa. Incluye plazas y atractivos turísticos, no entradas independientes de localidades; búsquedas como «Canta» pueden coincidir con un recurso asociado, pero no implican que exista una entidad localidad en el catálogo. No es cobertura nacional. Recursos candidatos que no pudieron verificarse, incluidos lugares sin ficha fuente identificable, quedan excluidos.

Los POIs del snapshot del corredor existente no se copiaron a este catálogo global: su alcance sigue siendo de descubrimiento por ruta y la reutilización exige verificar por registro procedencia/licencia y evitar duplicados. Se mantienen en su flujo actual de Route Discovery.

El único alias cargado es «Plaza de Armas de Lima» para «Plaza Mayor De Lima»: la ficha MINCETUR 3348 dice explícitamente que también se llama «Plaza de Armas». Se retiraron «Oasis de Huacachina» y «Líneas de Nazca» del catálogo funcional porque las fichas MINCETUR aprobadas para los registros 237 y 254 no verifican esas formas como alias. No se amplía la fuente aprobada para añadir sinónimos de otros portales. No se copiaron imágenes ni se usaron proveedores externos. Las búsquedas no se guardan ni se registran como historial.
