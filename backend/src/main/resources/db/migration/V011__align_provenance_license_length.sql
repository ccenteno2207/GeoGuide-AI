-- Keep provenance license text compatible with the 240-character editorial field.
ALTER TABLE geo.poi_provenance
    ALTER COLUMN license TYPE VARCHAR(240);
