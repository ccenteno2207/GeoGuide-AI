# Dataset P3 — Lima → Obrajillo

## Artefactos

- `taxonomy-v1.json`: taxonomía inicial versionada de 15 categorías derivada de
  `docs/05-UX-UI/04-Design-System/POI-Categories.md`.
- `lima-obrajillo-v1.json`: primera versión curada del dataset piloto.

Ambos archivos están separados del DDL Flyway. El loader se activa explícitamente con
`GEOGUIDE_P3_DATA_ENABLED=true`; utiliza identidades UUID y claves lógicas estables, y
puede ejecutarse repetidamente sin duplicar Category, PointOfInterest o Provenance.

## Regla geográfica y distribución

Un POI pertenece a esta versión cuando:

1. está dentro del bounding box P1 `-77.40,-13.50,-75.85,-11.40`;
2. está ubicado en un punto documentado del acceso vial Lima–Canta–Obrajillo o en el
   destino Obrajillo;
3. cuenta con una fuente institucional que justifica su relación con ese trayecto;
4. sus coordenadas pueden contrastarse con OpenStreetMap.

La distribución cumple cuando existe al menos un POI verificable antes de Canta, en
Canta y en Obrajillo. Esta regla binaria evita exigir una cantidad o distancia arbitraria.

## Fuentes y provenance

Los hechos descriptivos proceden del Inventario Nacional de Recursos Turísticos de
MINCETUR. Las coordenadas e identidades cartográficas se contrastaron con OpenStreetMap.

| POI | MINCETUR | OpenStreetMap |
|---|---|---|
| Santuario de Santa Rosa de Quives | ficha `6009` | node `6933500471` |
| Petroglifos de Checta | ficha `2725` | way `516267918` |
| Plaza de Armas de Canta | ficha `14068` | way `450034937` |
| Plaza de Armas de Obrajillo | ficha `14060` | way `450030775` |
| Iglesia San Juan Bautista de Obrajillo | referencia en ficha `14060` | way `450030784` |

Referencias:

- `https://consultasenlinea.mincetur.gob.pe/fichaInventario/index.aspx?cod_Ficha=6009`
- `https://consultasenlinea.mincetur.gob.pe/fichaInventario/index.aspx?cod_Ficha=2725`
- `https://consultasenlinea.mincetur.gob.pe/fichaInventario/index.aspx?cod_Ficha=14068`
- `https://consultasenlinea.mincetur.gob.pe/fichaInventario/index.aspx?cod_Ficha=14060`
- `https://www.openstreetmap.org/copyright`

Para MINCETUR se registra la condición conservadora
`PUBLIC_INFORMATION_SOURCE_TERMS_APPLY`; no se presume una licencia de redistribución
adicional. Para OpenStreetMap se registra ODbL 1.0 y la atribución
`© OpenStreetMap contributors`. El dataset almacena valores factuales mínimos y enlaces
de provenance, no copias extensas de textos o imágenes de las fuentes.

## Corrección de evidencia P1

El caso 6 del routing spike fue rotulado “Lima → Obrajillo”, pero su coordenada final
`-11.6954053,-76.8352259` corresponde al sector de Santa Rosa de Quives. Obrajillo se
encuentra aproximadamente en `-11.453,-76.620`. Ambos puntos están dentro del recorte P1,
pero P3 no presenta la ruta histórica de 54,51 km como validación del trayecto completo.
