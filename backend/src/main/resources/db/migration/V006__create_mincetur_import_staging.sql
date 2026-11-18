CREATE TABLE geo.mincetur_import_batch (
    id UUID PRIMARY KEY,
    source_system VARCHAR(80) NOT NULL,
    source_file_name VARCHAR(255) NOT NULL,
    source_sha256 CHAR(64) NOT NULL,
    source_cutoff DATE,
    detected_encoding VARCHAR(40) NOT NULL,
    delimiter VARCHAR(4) NOT NULL,
    parser_version VARCHAR(80) NOT NULL,
    record_count INTEGER NOT NULL,
    quarantined_count INTEGER NOT NULL,
    cutoff_inconsistent BOOLEAN NOT NULL DEFAULT FALSE,
    batch_status VARCHAR(40) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT mincetur_import_source_not_blank CHECK (btrim(source_system) <> ''),
    CONSTRAINT mincetur_import_file_not_blank CHECK (btrim(source_file_name) <> ''),
    CONSTRAINT mincetur_import_sha256_format CHECK (source_sha256 ~ '^[A-F0-9]{64}$'),
    CONSTRAINT mincetur_import_encoding_not_blank CHECK (btrim(detected_encoding) <> ''),
    CONSTRAINT mincetur_import_delimiter_not_blank CHECK (btrim(delimiter) <> ''),
    CONSTRAINT mincetur_import_parser_not_blank CHECK (btrim(parser_version) <> ''),
    CONSTRAINT mincetur_import_counts_valid CHECK (
        record_count >= 0 AND quarantined_count >= 0 AND quarantined_count <= record_count
    ),
    CONSTRAINT mincetur_import_status_valid CHECK (batch_status IN ('STAGED_REQUIRES_REVIEW')),
    CONSTRAINT mincetur_import_snapshot_version_unique UNIQUE (source_sha256, parser_version)
);

CREATE TABLE geo.mincetur_import_record (
    id UUID PRIMARY KEY,
    batch_id UUID NOT NULL REFERENCES geo.mincetur_import_batch(id) ON DELETE CASCADE,
    row_number INTEGER NOT NULL,
    source_record_id VARCHAR(200),
    raw_fields JSONB NOT NULL,
    raw_latitude TEXT,
    raw_longitude TEXT,
    normalized_latitude NUMERIC,
    normalized_longitude NUMERIC,
    normalization_rule VARCHAR(160),
    validation_evidence TEXT,
    record_status VARCHAR(48) NOT NULL,
    quarantine_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT mincetur_record_row_positive CHECK (row_number > 0),
    CONSTRAINT mincetur_record_status_valid CHECK (record_status IN (
        'COORDINATE_FORMAT_AMBIGUOUS', 'COORDINATE_MAPPING_UNVERIFIED',
        'DUPLICATE_SOURCE_ID', 'MALFORMED_ROW'
    )),
    CONSTRAINT mincetur_record_coordinate_pair CHECK (
        (normalized_latitude IS NULL AND normalized_longitude IS NULL)
        OR (normalized_latitude IS NOT NULL AND normalized_longitude IS NOT NULL)
    ),
    CONSTRAINT mincetur_record_not_published CHECK (
        normalized_latitude IS NULL AND normalized_longitude IS NULL
    ),
    CONSTRAINT mincetur_record_batch_row_unique UNIQUE (batch_id, row_number)
);

CREATE INDEX idx_mincetur_import_batch_status_created
    ON geo.mincetur_import_batch(batch_status, created_at DESC);
CREATE INDEX idx_mincetur_import_record_batch_status
    ON geo.mincetur_import_record(batch_id, record_status);
CREATE INDEX idx_mincetur_import_record_source_id
    ON geo.mincetur_import_record(source_record_id);
