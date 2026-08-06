# Pipeline de Ingestión

Source
→ Raw/Staging
→ Parse
→ Normalize
→ Validate
→ Deduplicate
→ Geospatial Validation
→ Enrich
→ Quality Score
→ Review cuando sea necesario
→ Publish Golden Record.

## Modos
- batch;
- manual/admin;
- API futura.

## Idempotencia
Reprocesar un lote no debe crear duplicados.

## Identidad
Mantener `source_id` + `source_system` además del UUID interno.
