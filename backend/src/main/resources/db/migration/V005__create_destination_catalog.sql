CREATE TABLE geo.destination (
    id UUID PRIMARY KEY,
    canonical_name VARCHAR(200) NOT NULL,
    normalized_name VARCHAR(200) NOT NULL,
    destination_type VARCHAR(60) NOT NULL,
    administrative_context VARCHAR(300) NOT NULL,
    location geometry(Point,4326) NOT NULL,
    source_system VARCHAR(120) NOT NULL,
    source_record_id VARCHAR(200) NOT NULL,
    source_url TEXT NOT NULL,
    source_license VARCHAR(160) NOT NULL,
    attribution TEXT NOT NULL,
    verified_at DATE NOT NULL,
    catalog_version VARCHAR(80) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT destination_name_not_blank CHECK (btrim(canonical_name) <> ''),
    CONSTRAINT destination_normalized_name_not_blank CHECK (btrim(normalized_name) <> ''),
    CONSTRAINT destination_type_not_blank CHECK (btrim(destination_type) <> ''),
    CONSTRAINT destination_context_not_blank CHECK (btrim(administrative_context) <> ''),
    CONSTRAINT destination_source_not_blank CHECK (btrim(source_system) <> ''),
    CONSTRAINT destination_record_id_not_blank CHECK (btrim(source_record_id) <> ''),
    CONSTRAINT destination_source_url_not_blank CHECK (btrim(source_url) <> ''),
    CONSTRAINT destination_license_not_blank CHECK (btrim(source_license) <> ''),
    CONSTRAINT destination_attribution_not_blank CHECK (btrim(attribution) <> ''),
    CONSTRAINT destination_catalog_version_not_blank CHECK (btrim(catalog_version) <> ''),
    CONSTRAINT destination_source_record_unique UNIQUE (source_system, source_record_id),
    CONSTRAINT destination_location_srid CHECK (ST_SRID(location) = 4326),
    CONSTRAINT destination_location_nonempty CHECK (NOT ST_IsEmpty(location)),
    CONSTRAINT destination_location_valid CHECK (ST_IsValid(location)),
    CONSTRAINT destination_location_bounds CHECK (
        ST_X(location) BETWEEN -180 AND 180 AND ST_Y(location) BETWEEN -90 AND 90
    )
);

CREATE TABLE geo.destination_alias (
    id UUID PRIMARY KEY,
    destination_id UUID NOT NULL REFERENCES geo.destination(id) ON DELETE CASCADE,
    alias VARCHAR(200) NOT NULL,
    normalized_alias VARCHAR(200) NOT NULL,
    source_reference TEXT NOT NULL,
    CONSTRAINT destination_alias_not_blank CHECK (btrim(alias) <> ''),
    CONSTRAINT destination_normalized_alias_not_blank CHECK (btrim(normalized_alias) <> ''),
    CONSTRAINT destination_alias_source_not_blank CHECK (btrim(source_reference) <> ''),
    CONSTRAINT destination_alias_unique UNIQUE (destination_id, normalized_alias)
);

CREATE INDEX idx_destination_normalized_name ON geo.destination(normalized_name);
CREATE INDEX idx_destination_location_gist ON geo.destination USING GIST(location);
CREATE INDEX idx_destination_alias_normalized ON geo.destination_alias(normalized_alias);
CREATE INDEX idx_destination_alias_destination ON geo.destination_alias(destination_id);
