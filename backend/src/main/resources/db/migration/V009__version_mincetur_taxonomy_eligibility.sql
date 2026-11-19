ALTER TABLE geo.mincetur_import_batch
    ADD COLUMN taxonomy_filter_version VARCHAR(100) NOT NULL DEFAULT 'UNAPPLIED';

ALTER TABLE geo.mincetur_import_batch
    DROP CONSTRAINT mincetur_import_snapshot_version_unique;

ALTER TABLE geo.mincetur_import_batch
    ADD CONSTRAINT mincetur_import_snapshot_taxonomy_version_unique
        UNIQUE (source_sha256, parser_version, taxonomy_filter_version),
    ADD CONSTRAINT mincetur_import_taxonomy_filter_not_blank
        CHECK (btrim(taxonomy_filter_version) <> '');

ALTER TABLE geo.mincetur_import_record
    ADD COLUMN thematic_eligibility VARCHAR(40) NOT NULL DEFAULT 'CLASSIFICATION_REVIEW_REQUIRED',
    ADD COLUMN thematic_rule_code VARCHAR(80) NOT NULL DEFAULT 'UNAPPLIED',
    ADD COLUMN thematic_reason TEXT NOT NULL DEFAULT 'Existing staged row has no taxonomy assessment.';

ALTER TABLE geo.mincetur_import_record
    ADD CONSTRAINT mincetur_record_thematic_eligibility_valid
        CHECK (thematic_eligibility IN (
            'ELIGIBLE_FOR_REVIEW', 'EXCLUDED_FROM_NAVIGATION', 'CLASSIFICATION_REVIEW_REQUIRED')),
    ADD CONSTRAINT mincetur_record_thematic_rule_not_blank
        CHECK (btrim(thematic_rule_code) <> '');

CREATE INDEX idx_mincetur_import_record_batch_thematic
    ON geo.mincetur_import_record(batch_id, thematic_eligibility, record_status);
