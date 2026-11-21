CREATE TABLE admin.poi_operational_info (
    poi_id UUID PRIMARY KEY REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    time_zone VARCHAR(80) NOT NULL DEFAULT 'America/Lima',
    weekly_hours JSONB NOT NULL,
    items JSONB NOT NULL DEFAULT '[]'::jsonb,
    version BIGINT NOT NULL DEFAULT 1,
    updated_by VARCHAR(200) NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT poi_operational_info_timezone_nonblank CHECK (btrim(time_zone) <> ''),
    CONSTRAINT poi_operational_info_version_positive CHECK (version > 0),
    CONSTRAINT poi_operational_info_actor_nonblank CHECK (btrim(updated_by) <> ''),
    CONSTRAINT poi_operational_info_hours_array CHECK (jsonb_typeof(weekly_hours) = 'array'),
    CONSTRAINT poi_operational_info_items_array CHECK (jsonb_typeof(items) = 'array')
);

CREATE TABLE admin.poi_operational_info_audit (
    id UUID PRIMARY KEY,
    poi_id UUID NOT NULL REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    actor_id VARCHAR(200) NOT NULL,
    version BIGINT NOT NULL,
    before_value JSONB NOT NULL,
    after_value JSONB NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT poi_operational_audit_actor_nonblank CHECK (btrim(actor_id) <> ''),
    CONSTRAINT poi_operational_audit_version_positive CHECK (version > 0)
);

CREATE INDEX idx_poi_operational_audit_time
    ON admin.poi_operational_info_audit(poi_id, occurred_at DESC);

CREATE FUNCTION admin.reject_poi_operational_audit_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'POI operational audit records are append-only';
END;
$$;

CREATE TRIGGER trg_poi_operational_audit_immutable
    BEFORE UPDATE OR DELETE ON admin.poi_operational_info_audit
    FOR EACH ROW EXECUTE FUNCTION admin.reject_poi_operational_audit_mutation();
