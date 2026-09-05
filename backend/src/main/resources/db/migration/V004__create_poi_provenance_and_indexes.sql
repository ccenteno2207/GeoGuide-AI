CREATE TABLE geo.poi_provenance (
    id UUID PRIMARY KEY,
    poi_id UUID NOT NULL REFERENCES geo.point_of_interest(id) ON DELETE CASCADE,
    source_system VARCHAR(120) NOT NULL,
    source_record_id VARCHAR(200),
    source_url TEXT,
    retrieved_at TIMESTAMPTZ,
    license VARCHAR(160) NOT NULL,
    attribution TEXT,
    incorporation_method VARCHAR(40) NOT NULL,
    logical_key VARCHAR(200) NOT NULL,
    CONSTRAINT poi_provenance_source_not_blank CHECK (btrim(source_system) <> ''),
    CONSTRAINT poi_provenance_license_not_blank CHECK (btrim(license) <> ''),
    CONSTRAINT poi_provenance_method_not_blank CHECK (btrim(incorporation_method) <> ''),
    CONSTRAINT poi_provenance_logical_key_not_blank CHECK (btrim(logical_key) <> ''),
    CONSTRAINT poi_provenance_logical_identity UNIQUE (source_system, logical_key)
);

CREATE UNIQUE INDEX uq_poi_provenance_external_identity
    ON geo.poi_provenance(source_system, source_record_id)
    WHERE source_record_id IS NOT NULL;

CREATE INDEX idx_point_of_interest_category
    ON geo.point_of_interest(category_id);

CREATE INDEX idx_point_of_interest_location_gist
    ON geo.point_of_interest USING GIST(location);

CREATE INDEX idx_poi_provenance_poi
    ON geo.poi_provenance(poi_id);
