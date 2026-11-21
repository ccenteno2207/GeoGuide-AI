CREATE TABLE admin.poi_content_revision (
    id UUID PRIMARY KEY,
    poi_id UUID NOT NULL REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    version BIGINT NOT NULL,
    state VARCHAR(24) NOT NULL,
    content JSONB NOT NULL,
    created_by VARCHAR(200) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    reviewed_by VARCHAR(200),
    reviewed_at TIMESTAMPTZ,
    review_reason TEXT,
    CONSTRAINT poi_content_revision_version_positive CHECK (version > 0),
    CONSTRAINT poi_content_revision_state CHECK (state IN ('DRAFT','PENDING_REVIEW','PUBLISHED','SUPERSEDED')),
    CONSTRAINT poi_content_revision_content_object CHECK (jsonb_typeof(content) = 'object'),
    CONSTRAINT poi_content_revision_actor_nonblank CHECK (btrim(created_by) <> ''),
    CONSTRAINT poi_content_revision_unique_version UNIQUE (poi_id, version)
);

CREATE INDEX idx_poi_content_revision_history ON admin.poi_content_revision(poi_id, version DESC);

CREATE TABLE admin.poi_content_working_set (
    poi_id UUID PRIMARY KEY REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    revision_id UUID NOT NULL UNIQUE REFERENCES admin.poi_content_revision(id) ON DELETE RESTRICT,
    version BIGINT NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT poi_content_working_set_version_positive CHECK (version > 0)
);

CREATE TABLE geo.poi_published_content (
    poi_id UUID PRIMARY KEY REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    revision_id UUID NOT NULL UNIQUE REFERENCES admin.poi_content_revision(id) ON DELETE RESTRICT,
    version BIGINT NOT NULL,
    content JSONB NOT NULL,
    published_by VARCHAR(200) NOT NULL,
    published_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT poi_published_content_version_positive CHECK (version > 0),
    CONSTRAINT poi_published_content_object CHECK (jsonb_typeof(content) = 'object'),
    CONSTRAINT poi_published_content_actor_nonblank CHECK (btrim(published_by) <> '')
);

CREATE TABLE admin.poi_content_audit (
    id UUID PRIMARY KEY,
    poi_id UUID NOT NULL REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    revision_id UUID REFERENCES admin.poi_content_revision(id) ON DELETE RESTRICT,
    actor_id VARCHAR(200) NOT NULL,
    action VARCHAR(32) NOT NULL,
    reason TEXT NOT NULL,
    version BIGINT NOT NULL,
    before_state VARCHAR(24),
    after_state VARCHAR(24),
    before_content JSONB,
    after_content JSONB,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT poi_content_audit_actor_nonblank CHECK (btrim(actor_id) <> ''),
    CONSTRAINT poi_content_audit_action_nonblank CHECK (btrim(action) <> ''),
    CONSTRAINT poi_content_audit_reason_nonblank CHECK (btrim(reason) <> ''),
    CONSTRAINT poi_content_audit_version_positive CHECK (version > 0)
);

CREATE INDEX idx_poi_content_audit_history ON admin.poi_content_audit(poi_id, occurred_at DESC);

CREATE FUNCTION admin.reject_poi_content_audit_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Audit records are append-only';
END;
$$;

CREATE TRIGGER trg_poi_content_audit_immutable
    BEFORE UPDATE OR DELETE ON admin.poi_content_audit
    FOR EACH ROW EXECUTE FUNCTION admin.reject_poi_content_audit_mutation();

CREATE FUNCTION admin.reject_poi_content_revision_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF TG_OP = 'DELETE' THEN
        RAISE EXCEPTION 'Content revisions are immutable';
    END IF;
    IF OLD.content IS DISTINCT FROM NEW.content
       OR OLD.poi_id IS DISTINCT FROM NEW.poi_id OR OLD.version IS DISTINCT FROM NEW.version
       OR OLD.created_by IS DISTINCT FROM NEW.created_by OR OLD.created_at IS DISTINCT FROM NEW.created_at THEN
        RAISE EXCEPTION 'Content revisions are immutable';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_poi_content_revision_immutable
    BEFORE UPDATE OR DELETE ON admin.poi_content_revision
    FOR EACH ROW EXECUTE FUNCTION admin.reject_poi_content_revision_mutation();

ALTER TABLE media.poi_asset
    ADD COLUMN alt_text VARCHAR(500) NOT NULL DEFAULT '',
    ADD COLUMN display_order INTEGER NOT NULL DEFAULT 0,
    ADD CONSTRAINT poi_asset_display_order_nonnegative CHECK (display_order >= 0);

CREATE INDEX idx_poi_asset_public_gallery
    ON media.poi_asset(poi_id, display_order, created_at)
    WHERE review_state = 'PUBLISHED';
