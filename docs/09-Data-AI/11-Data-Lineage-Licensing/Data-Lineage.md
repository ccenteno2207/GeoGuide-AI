# Data Lineage

## Provenance mínima para P3

Cada POI publicable debe tener al menos una provenance auditable y poder responder:
- ¿de dónde salió?
- ¿cuándo se obtuvo?
- ¿qué referencia verificable existe cuando corresponde?
- ¿qué licencia aplica?
- ¿qué atribución es obligatoria?
- ¿qué método u origen de incorporación se utilizó?

Cuando la fuente proporciona un identificador externo, debe conservarse junto con el
sistema o fuente. Los registros manuales sin ID externo requieren una clave estable y
un origen auditable. La identidad lógica exacta, incluida la de provenance, se define
durante la implementación y debe permitir cargas reproducibles e idempotentes.

P3 no exige una fuente única ni múltiples fuentes, no impone cardinalidad máxima y no
requiere un grafo completo de lineage. La regla de al menos una provenance por POI
publicable se valida en dominio o aplicación, no mediante una constraint SQL compleja.

## Evolución futura

Un modelo ampliado puede incorporar:
- source
- ingestion_batch
- source_record
- poi_source_link
- content_version
- quality_assessment

Este grafo conceptual, las transformaciones múltiples, el versionado avanzado y las
relaciones adicionales de enriquecimiento no son obligatorios para el baseline P3.
Las fuentes y licencias definitivas del dataset se aprueban antes de su carga.
