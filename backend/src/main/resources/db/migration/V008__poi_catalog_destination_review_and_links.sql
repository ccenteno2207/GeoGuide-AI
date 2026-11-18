-- Additive evidence fields for new identity reviews; historical rows remain unchanged.
ALTER TABLE admin.poi_editorial_record
    ADD COLUMN identity_review_evidence TEXT;

CREATE TABLE admin.destination_editorial_record (
    id UUID PRIMARY KEY,
    import_record_id UUID UNIQUE REFERENCES geo.mincetur_import_record(id) ON DELETE RESTRICT,
    source_record_id VARCHAR(200),
    canonical_name VARCHAR(200) NOT NULL,
    destination_type VARCHAR(60) NOT NULL,
    administrative_context VARCHAR(600),
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
    identity_review_evidence TEXT,
    access_review_status VARCHAR(24) NOT NULL DEFAULT 'PENDING',
    access_review_actor VARCHAR(200),
    access_reviewed_at TIMESTAMPTZ,
    access_review_reason TEXT,
    access_review_evidence TEXT,
    editorial_state VARCHAR(24) NOT NULL DEFAULT 'DRAFT',
    published_destination_id UUID UNIQUE REFERENCES geo.destination(id) ON DELETE RESTRICT,
    version BIGINT NOT NULL DEFAULT 0,
    created_by VARCHAR(200) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT admin_destination_name_nonblank CHECK (btrim(canonical_name) <> ''),
    CONSTRAINT admin_destination_type_nonblank CHECK (btrim(destination_type) <> ''),
    CONSTRAINT admin_destination_version_nonnegative CHECK (version >= 0),
    CONSTRAINT admin_destination_coordinate_pair CHECK ((latitude IS NULL) = (longitude IS NULL)),
    CONSTRAINT admin_destination_geo_status CHECK (geographic_review_status IN ('PENDING','APPROVED','REJECTED')),
    CONSTRAINT admin_destination_identity_status CHECK (identity_review_status IN ('PENDING','NO_DUPLICATE','MATCH_FOUND')),
    CONSTRAINT admin_destination_access_status CHECK (access_review_status IN ('PENDING','APPROVED','REJECTED')),
    CONSTRAINT admin_destination_identity_evidence CHECK (identity_review_status='PENDING' OR
        (identity_review_actor IS NOT NULL AND identity_reviewed_at IS NOT NULL AND identity_review_reason IS NOT NULL
         AND btrim(identity_review_reason)<>'' AND identity_review_evidence IS NOT NULL
         AND btrim(identity_review_evidence)<>'')),
    CONSTRAINT admin_destination_geo_approval_evidence CHECK (geographic_review_status <> 'APPROVED' OR
        (latitude BETWEEN -18.5 AND 0 AND longitude BETWEEN -82.5 AND -68.0
         AND coordinate_validation_evidence IS NOT NULL AND btrim(coordinate_validation_evidence)<>''
         AND geographic_review_actor IS NOT NULL AND geographic_reviewed_at IS NOT NULL
         AND geographic_review_reason IS NOT NULL AND btrim(geographic_review_reason)<>'')),
    CONSTRAINT admin_destination_access_evidence CHECK (access_review_status='PENDING' OR
        (access_review_actor IS NOT NULL AND access_reviewed_at IS NOT NULL AND access_review_reason IS NOT NULL
         AND btrim(access_review_reason)<>'' AND access_review_evidence IS NOT NULL AND btrim(access_review_evidence)<>'')),
    CONSTRAINT admin_destination_state CHECK (editorial_state IN ('DRAFT','PENDING_REVIEW','PUBLISHED','REJECTED','ARCHIVED')),
    CONSTRAINT admin_destination_published_identity CHECK (
        (editorial_state='PUBLISHED' AND published_destination_id IS NOT NULL)
        OR editorial_state='ARCHIVED'
        OR (editorial_state IN ('DRAFT','PENDING_REVIEW','REJECTED') AND published_destination_id IS NULL))
);

CREATE INDEX idx_admin_destination_state_updated
    ON admin.destination_editorial_record(editorial_state, updated_at DESC);
CREATE INDEX idx_admin_destination_source_id
    ON admin.destination_editorial_record(source_record_id);

CREATE TABLE admin.destination_editorial_audit (
    id UUID PRIMARY KEY,
    destination_editorial_id UUID NOT NULL REFERENCES admin.destination_editorial_record(id) ON DELETE RESTRICT,
    actor_id VARCHAR(200) NOT NULL,
    action VARCHAR(40) NOT NULL,
    reason TEXT NOT NULL,
    previous_state VARCHAR(24),
    next_state VARCHAR(24),
    version BIGINT NOT NULL,
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT admin_destination_audit_required_text CHECK
        (btrim(actor_id)<>'' AND btrim(action)<>'' AND btrim(reason)<>'')
);
CREATE INDEX idx_admin_destination_audit_time
    ON admin.destination_editorial_audit(destination_editorial_id, occurred_at DESC);

CREATE TABLE admin.destination_poi_relationship (
    id UUID PRIMARY KEY,
    destination_id UUID NOT NULL REFERENCES geo.destination(id) ON DELETE RESTRICT,
    poi_id UUID NOT NULL REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    relationship_type VARCHAR(32) NOT NULL,
    relationship_status VARCHAR(16) NOT NULL DEFAULT 'PENDING',
    created_by VARCHAR(200) NOT NULL,
    created_reason TEXT NOT NULL,
    created_evidence TEXT NOT NULL,
    reviewed_by VARCHAR(200),
    reviewed_at TIMESTAMPTZ,
    review_reason TEXT,
    review_evidence TEXT,
    version BIGINT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT admin_destination_poi_type CHECK (relationship_type IN ('SAME_RESOURCE','RELATED_RESOURCE')),
    CONSTRAINT admin_destination_poi_status CHECK (relationship_status IN ('PENDING','APPROVED','REJECTED')),
    CONSTRAINT admin_destination_poi_version CHECK (version >= 0),
    CONSTRAINT admin_destination_poi_creation_evidence CHECK
        (btrim(created_by)<>'' AND btrim(created_reason)<>'' AND btrim(created_evidence)<>''),
    CONSTRAINT admin_destination_poi_review_evidence CHECK (relationship_status='PENDING' OR
        (reviewed_by IS NOT NULL AND reviewed_at IS NOT NULL AND review_reason IS NOT NULL
         AND btrim(review_reason)<>'' AND review_evidence IS NOT NULL AND btrim(review_evidence)<>'')),
    CONSTRAINT admin_destination_poi_unique_pair UNIQUE(destination_id, poi_id)
);
CREATE INDEX idx_admin_destination_poi_by_destination
    ON admin.destination_poi_relationship(destination_id, relationship_status);
CREATE INDEX idx_admin_destination_poi_by_poi
    ON admin.destination_poi_relationship(poi_id, relationship_status);

CREATE TABLE admin.destination_poi_relationship_audit (
    id UUID PRIMARY KEY,
    relationship_id UUID NOT NULL REFERENCES admin.destination_poi_relationship(id) ON DELETE RESTRICT,
    actor_id VARCHAR(200) NOT NULL,
    action VARCHAR(40) NOT NULL,
    reason TEXT NOT NULL,
    previous_status VARCHAR(16),
    next_status VARCHAR(16),
    version BIGINT NOT NULL,
    details JSONB NOT NULL DEFAULT '{}'::jsonb,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT admin_destination_poi_audit_required_text CHECK
        (btrim(actor_id)<>'' AND btrim(action)<>'' AND btrim(reason)<>'')
);
CREATE INDEX idx_admin_destination_poi_audit_time
    ON admin.destination_poi_relationship_audit(relationship_id, occurred_at DESC);

CREATE TRIGGER trg_admin_destination_audit_immutable
    BEFORE UPDATE OR DELETE ON admin.destination_editorial_audit
    FOR EACH ROW EXECUTE FUNCTION admin.reject_audit_mutation();
CREATE TRIGGER trg_admin_destination_poi_audit_immutable
    BEFORE UPDATE OR DELETE ON admin.destination_poi_relationship_audit
    FOR EACH ROW EXECUTE FUNCTION admin.reject_audit_mutation();
