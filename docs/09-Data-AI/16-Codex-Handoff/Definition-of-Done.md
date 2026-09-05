# Definition of Done Data & AI

- [ ] fuente identificada;
- [ ] licencia registrada;
- [ ] ingestión reproducible;
- [ ] lineage;
- [ ] validaciones;
- [ ] deduplicación;
- [ ] coordenadas válidas;
- [ ] tests;
- [ ] AI content distinguible;
- [ ] prompts/modelos versionados;
- [ ] evaluación documentada;
- [ ] privacidad revisada;
- [ ] core funciona sin LLM.

## Cierre de datos P3

El contrato integral y prevalente está en
[P3 Definition of Done](../../11-Master-Documentation/11-Implementation-Plan/P3-Definition-of-Done.md).

- [ ] la taxonomía está aprobada y versionada antes del seed;
- [ ] el dataset Lima → Obrajillo está versionado;
- [ ] cada POI publicable tiene al menos una provenance auditable;
- [ ] fuentes, licencias o condiciones de uso y atribuciones aplicables están registradas;
- [ ] las coordenadas y geometrías son válidas en WGS84/SRID 4326;
- [ ] no quedan duplicados abiertos;
- [ ] la carga puede reproducirse desde artefactos versionados;
- [ ] una segunda carga no duplica categorías, POIs ni provenance y conserva el estado
  lógico cuando la entrada no cambia;
- [ ] los cambios de fuente tienen un resultado determinista y auditable;
- [ ] las reglas binarias aplicables del
  [Framework de Calidad](../04-Data-Quality/Data-Quality-Framework.md) cumplen;
- [ ] la versión exacta del dataset recibe aprobación humana y satisface
  [R3](../../11-Master-Documentation/11-Implementation-Plan/Release-Gates.md).

La IA generativa no es requisito de P3. Tampoco se imponen cantidades, scores de calidad
ni porcentajes de revisión que no hayan sido aprobados.
