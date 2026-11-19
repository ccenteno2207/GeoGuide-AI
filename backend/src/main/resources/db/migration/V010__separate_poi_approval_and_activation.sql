-- Preserve existing public state while adding the independent editorial activation gate.
ALTER TABLE admin.poi_editorial_record
    ADD COLUMN active BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN target_poi_id UUID REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT;

CREATE UNIQUE INDEX uq_admin_editorial_target_poi
    ON admin.poi_editorial_record(target_poi_id)
    WHERE target_poi_id IS NOT NULL AND editorial_state IN ('DRAFT','OBSERVED','PENDING_REVIEW');

UPDATE admin.poi_editorial_record r
SET active = p.active
FROM geo.point_of_interest p
WHERE r.published_poi_id = p.id;

ALTER TABLE admin.poi_editorial_record
    DROP CONSTRAINT admin_editorial_state,
    ADD CONSTRAINT admin_editorial_state CHECK (editorial_state IN
        ('DRAFT','PENDING_REVIEW','OBSERVED','APPROVED','SUSPENDED','PUBLISHED','REJECTED','ARCHIVED'));

ALTER TABLE admin.poi_editorial_record
    DROP CONSTRAINT admin_editorial_published_identity,
    ADD CONSTRAINT admin_editorial_published_identity CHECK (
        (editorial_state IN ('APPROVED','SUSPENDED','PUBLISHED','ARCHIVED') AND published_poi_id IS NOT NULL)
        OR (editorial_state IN ('DRAFT','PENDING_REVIEW','OBSERVED','REJECTED','ARCHIVED') AND published_poi_id IS NULL)
    ),
    ADD CONSTRAINT admin_editorial_activation_state CHECK (
        NOT active OR editorial_state IN ('APPROVED','PUBLISHED')
    );

CREATE TABLE admin.poi_activation_audit (
    id UUID PRIMARY KEY,
    poi_id UUID NOT NULL REFERENCES geo.point_of_interest(id) ON DELETE RESTRICT,
    actor_id VARCHAR(200) NOT NULL,
    action VARCHAR(24) NOT NULL CHECK (action IN ('ACTIVATE','DEACTIVATE','SUSPEND','RESTORE_APPROVAL')),
    reason TEXT NOT NULL,
    evidence TEXT NOT NULL,
    previous_active BOOLEAN NOT NULL,
    next_active BOOLEAN NOT NULL,
    occurred_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT admin_poi_activation_audit_text CHECK
        (btrim(actor_id) <> '' AND btrim(reason) <> '' AND btrim(evidence) <> '')
);
CREATE INDEX idx_admin_poi_activation_audit_time
    ON admin.poi_activation_audit(poi_id, occurred_at DESC);

CREATE FUNCTION admin.reject_activation_audit_mutation() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    RAISE EXCEPTION 'Activation audit records are append-only';
END;
$$;
CREATE TRIGGER trg_admin_poi_activation_audit_immutable
    BEFORE UPDATE OR DELETE ON admin.poi_activation_audit
    FOR EACH ROW EXECUTE FUNCTION admin.reject_activation_audit_mutation();
