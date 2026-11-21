ALTER TABLE media.poi_asset
    ALTER COLUMN source_url DROP NOT NULL,
    ADD COLUMN source_type VARCHAR(24) NOT NULL DEFAULT 'EXTERNAL_SOURCE',
    ADD COLUMN capture_date DATE,
    ADD COLUMN capture_place VARCHAR(300),
    ADD COLUMN author_declaration_version VARCHAR(40),
    ADD COLUMN author_declaration_text TEXT,
    ADD COLUMN author_declaration_by VARCHAR(200),
    ADD COLUMN author_declaration_at TIMESTAMPTZ,
    ADD COLUMN author_declaration_asset_version BIGINT;

ALTER TABLE media.poi_asset
    DROP CONSTRAINT poi_asset_author_source_nonblank,
    ADD CONSTRAINT poi_asset_author_nonblank CHECK (btrim(author) <> ''),
    ADD CONSTRAINT poi_asset_source_type CHECK (source_type IN ('OWN_PHOTOGRAPH','EXTERNAL_SOURCE')),
    ADD CONSTRAINT poi_asset_source_provenance CHECK (
        (source_type = 'EXTERNAL_SOURCE' AND source_url IS NOT NULL AND btrim(source_url) <> ''
            AND author_declaration_version IS NULL AND author_declaration_by IS NULL
            AND author_declaration_text IS NULL AND author_declaration_at IS NULL
            AND author_declaration_asset_version IS NULL)
        OR
        (source_type = 'OWN_PHOTOGRAPH' AND source_url IS NULL
            AND author_declaration_version IS NOT NULL AND btrim(author_declaration_version) <> ''
            AND author_declaration_text IS NOT NULL AND btrim(author_declaration_text) <> ''
            AND author_declaration_by IS NOT NULL AND btrim(author_declaration_by) <> ''
            AND author_declaration_at IS NOT NULL
            AND author_declaration_asset_version IS NOT NULL AND author_declaration_asset_version >= 0)
    ),
    ADD CONSTRAINT poi_asset_capture_place_length CHECK (capture_place IS NULL OR length(capture_place) <= 300);
