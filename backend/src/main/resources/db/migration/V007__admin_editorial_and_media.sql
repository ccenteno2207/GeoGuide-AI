CREATE SCHEMA IF NOT EXISTS admin;
CREATE SCHEMA IF NOT EXISTS media;

CREATE TABLE admin.poi_editorial_record (
    id UUID PRIMARY KEY,
    import_record_id UUID REFERENCES geo.mincetur_import_record(id) ON DELETE RESTRICT,
    source_record_id VARCHAR(200),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    administrative_context VARCHAR(600),
    category_code VARCHAR(80) NOT NULL,
    -- Keep the full staging candidate precision; the curated raw token is also retained separately.
    latitude NUMERIC,
    longitude NUMERIC,
    raw_latitude TEXT,
    raw_longitude TEXT,
    coordinate_normalization_rule VARCHAR(160),
    coordinate_validation_evidence TEXT,
    source_url TEXT,
    source_license VARCHAR(240),
    source_attribution TEXT,
    geographic_review_status VARCHAR(24) NOT NULL DEFAULT 'PENDING',
    geographic_review_actor VARCHAR(200),
    geographic_reviewed_at TIMESTAMPTZ,
    geographic_review_reason TEXT,
    identity_review_status VARCHAR(24) NOT NULL DEFAULT 'PENDING',
    identity_review_actor VARCHAR(200),
    identity_reviewed_at TIMESTAMPTZ,
    identity_review_reason TEXT,
    editorial_state VARCHAR(24) NOT NULL DEFAULT 'DRAFT',
    published_poi_id UUID UNIQUE REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    version BIGINT NOT NULL DEFAULT 0,
    created_by VARCHAR(200) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT admin_editorial_name_nonblank CHECK (btrim(name) <> ''),
    CONSTRAINT admin_editorial_category_nonblank CHECK (btrim(category_code) <> ''),
    CONSTRAINT admin_editorial_version_nonnegative CHECK (version >= 0),
    CONSTRAINT admin_editorial_coordinate_pair CHECK ((latitude IS NULL) = (longitude IS NULL)),
    CONSTRAINT admin_editorial_geo_status CHECK (geographic_review_status IN ('PENDING','APPROVED','REJECTED')),
    CONSTRAINT admin_editorial_identity_status CHECK (identity_review_status IN ('PENDING','NO_DUPLICATE','MATCH_FOUND')),
    CONSTRAINT admin_editorial_identity_evidence CHECK (identity_review_status='PENDING' OR
        (identity_review_actor IS NOT NULL AND identity_reviewed_at IS NOT NULL AND identity_review_reason IS NOT NULL
         AND btrim(identity_review_reason)<>'')),
    CONSTRAINT admin_editorial_state CHECK (editorial_state IN ('DRAFT','PENDING_REVIEW','PUBLISHED','REJECTED','ARCHIVED')),
    CONSTRAINT admin_editorial_geo_approval_evidence CHECK (
        geographic_review_status <> 'APPROVED' OR
        (latitude BETWEEN -18.5 AND 0 AND longitude BETWEEN -82.5 AND -68.0
         AND geographic_review_actor IS NOT NULL AND geographic_reviewed_at IS NOT NULL
         AND geographic_review_reason IS NOT NULL AND btrim(geographic_review_reason) <> ''
         AND coordinate_validation_evidence IS NOT NULL AND btrim(coordinate_validation_evidence) <> '')
    ),
    CONSTRAINT admin_editorial_published_identity CHECK (
        (editorial_state IN ('PUBLISHED','ARCHIVED') AND published_poi_id IS NOT NULL)
        OR (editorial_state IN ('DRAFT','PENDING_REVIEW','REJECTED') AND published_poi_id IS NULL)
    ),
    CONSTRAINT admin_editorial_import_unique UNIQUE (import_record_id)
);

CREATE INDEX idx_admin_editorial_state_updated ON admin.poi_editorial_record(editorial_state, updated_at DESC);
CREATE INDEX idx_admin_editorial_geo_review ON admin.poi_editorial_record(geographic_review_status, updated_at DESC);
CREATE INDEX idx_admin_editorial_source_id ON admin.poi_editorial_record(source_record_id);

CREATE TABLE admin.poi_editorial_audit (
    id UUID PRIMARY KEY,
    editorial_id UUID NOT NULL REFERENCES admin.poi_editorial_record(id) ON DELETE RESTRICT,
    actor_id VARCHAR(200) NOT NULL,
    action VARCHAR(40) NOT NULL,
    reason TEXT NOT NULL,
    previous_state VARCHAR(24),
    next_state VARCHAR(24),
    version BIGINT NOT NULL,
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT admin_audit_actor_nonblank CHECK (btrim(actor_id) <> ''),
    CONSTRAINT admin_audit_action_nonblank CHECK (btrim(action) <> ''),
    CONSTRAINT admin_audit_reason_nonblank CHECK (btrim(reason) <> '')
);

CREATE INDEX idx_admin_audit_editorial_time ON admin.poi_editorial_audit(editorial_id, occurred_at DESC);

CREATE TABLE media.poi_asset (
    id UUID PRIMARY KEY,
    poi_id UUID NOT NULL REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    object_key VARCHAR(240) NOT NULL UNIQUE,
    content_type VARCHAR(80) NOT NULL,
    sha256 CHAR(64) NOT NULL,
    size_bytes BIGINT NOT NULL,
    width INTEGER NOT NULL,
    height INTEGER NOT NULL,
    author VARCHAR(240) NOT NULL,
    source_url TEXT NOT NULL,
    license VARCHAR(240),
    attribution TEXT,
    rights_evidence_reference TEXT,
    rights_status VARCHAR(24) NOT NULL DEFAULT 'UNVERIFIED',
    review_state VARCHAR(24) NOT NULL DEFAULT 'DRAFT',
    is_primary BOOLEAN NOT NULL DEFAULT FALSE,
    version BIGINT NOT NULL DEFAULT 0,
    created_by VARCHAR(200) NOT NULL,
    reviewed_by VARCHAR(200),
    reviewed_at TIMESTAMPTZ,
    review_reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT poi_asset_content_type CHECK (content_type IN ('image/jpeg','image/png')),
    CONSTRAINT poi_asset_hash CHECK (sha256 ~ '^[A-Fa-f0-9]{64}$'),
    CONSTRAINT poi_asset_size CHECK (size_bytes > 0 AND width > 0 AND height > 0),
    CONSTRAINT poi_asset_author_source_nonblank CHECK (btrim(author) <> '' AND btrim(source_url) <> ''),
    CONSTRAINT poi_asset_rights_status CHECK (rights_status IN ('UNVERIFIED','DOCUMENTED')),
    CONSTRAINT poi_asset_review_state CHECK (review_state IN ('DRAFT','PENDING_REVIEW','PUBLISHED','REJECTED','WITHDRAWN')),
    CONSTRAINT poi_asset_primary_published CHECK (NOT is_primary OR review_state = 'PUBLISHED'),
    CONSTRAINT poi_asset_published_rights CHECK (
        review_state <> 'PUBLISHED' OR (rights_status = 'DOCUMENTED'
        AND license IS NOT NULL AND btrim(license) <> ''
        AND attribution IS NOT NULL AND btrim(attribution) <> ''
        AND rights_evidence_reference IS NOT NULL AND btrim(rights_evidence_reference) <> ''
        AND reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL AND review_reason IS NOT NULL AND btrim(review_reason) <> '')
    )
);

CREATE UNIQUE INDEX uq_poi_asset_primary_published ON media.poi_asset(poi_id)
    WHERE is_primary AND review_state = 'PUBLISHED';
CREATE INDEX idx_poi_asset_published ON media.poi_asset(poi_id, review_state, is_primary);

CREATE TABLE media.poi_asset_audit (
    id UUID PRIMARY KEY,
    asset_id UUID NOT NULL REFERENCES media.poi_asset(id) ON DELETE RESTRICT,
    actor_id VARCHAR(200) NOT NULL,
    action VARCHAR(40) NOT NULL,
    reason TEXT NOT NULL,
    prior_state VARCHAR(24),
    next_state VARCHAR(24),
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT poi_asset_audit_required_text CHECK (btrim(actor_id)<>'' AND btrim(action)<>'' AND btrim(reason)<>'')
);
CREATE INDEX idx_poi_asset_audit ON media.poi_asset_audit(asset_id,occurred_at DESC);

CREATE FUNCTION admin.reject_audit_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Audit records are append-only';
END;
$$;

CREATE TRIGGER trg_admin_editorial_audit_immutable
    BEFORE UPDATE OR DELETE ON admin.poi_editorial_audit
    FOR EACH ROW EXECUTE FUNCTION admin.reject_audit_mutation();

CREATE TRIGGER trg_media_asset_audit_immutable
    BEFORE UPDATE OR DELETE ON media.poi_asset_audit
    FOR EACH ROW EXECUTE FUNCTION admin.reject_audit_mutation();
