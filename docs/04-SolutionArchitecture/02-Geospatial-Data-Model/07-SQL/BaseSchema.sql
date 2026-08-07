CREATE EXTENSION IF NOT EXISTS postgis;
CREATE SCHEMA core;
CREATE SCHEMA geo;
CREATE TABLE geo.point_of_interest(
 id UUID PRIMARY KEY,
 name VARCHAR(200) NOT NULL,
 location geometry(Point,4326) NOT NULL
);
CREATE INDEX idx_poi_location ON geo.point_of_interest USING GIST(location);
