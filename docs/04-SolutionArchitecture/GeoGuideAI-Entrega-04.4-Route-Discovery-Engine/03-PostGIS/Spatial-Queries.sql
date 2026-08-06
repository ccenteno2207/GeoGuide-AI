-- Ejemplos de referencia para el MVP.
-- Ajustar nombres de schema según la Entrega 04.2.

-- 1. Buscar POIs dentro de un corredor de 5 km
WITH route AS (
  SELECT ST_GeomFromGeoJSON(:route_geojson) AS geom
)
SELECT
    p.id,
    p.name,
    ST_Distance(p.location::geography, r.geom::geography) AS distance_to_route_m
FROM geo.point_of_interest p
CROSS JOIN route r
WHERE ST_DWithin(
    p.location::geography,
    r.geom::geography,
    :corridor_meters
)
ORDER BY distance_to_route_m
LIMIT :limit;

-- 2. Posición del POI a lo largo de la ruta
WITH route AS (
  SELECT ST_GeomFromGeoJSON(:route_geojson) AS geom
)
SELECT
    p.id,
    ST_LineLocatePoint(
      ST_Transform(r.geom, 3857),
      ST_Transform(p.location, 3857)
    ) AS route_progress
FROM geo.point_of_interest p
CROSS JOIN route r
WHERE p.id = :poi_id;
