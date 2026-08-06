CREATE SCHEMA IF NOT EXISTS geo;

CREATE TABLE IF NOT EXISTS geo.category (
    id UUID PRIMARY KEY,
    code VARCHAR(80) NOT NULL UNIQUE,
    name VARCHAR(120) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS geo.point_of_interest (
    id UUID PRIMARY KEY,
    category_id UUID NOT NULL REFERENCES geo.category(id),
    name VARCHAR(200) NOT NULL,
    description TEXT,
    historical_description TEXT,
    location geometry(Point,4326) NOT NULL,
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_poi_location
ON geo.point_of_interest USING GIST(location);

CREATE INDEX IF NOT EXISTS idx_poi_category
ON geo.point_of_interest(category_id);
