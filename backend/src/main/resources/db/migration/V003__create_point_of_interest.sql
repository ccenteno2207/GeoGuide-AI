CREATE TABLE geo.point_of_interest (
    id UUID PRIMARY KEY,
    category_id UUID NOT NULL REFERENCES geo.category(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    location geometry(Point,4326) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL,
    CONSTRAINT point_of_interest_name_not_blank CHECK (btrim(name) <> ''),
    CONSTRAINT point_of_interest_updated_after_created CHECK (updated_at >= created_at)
);
