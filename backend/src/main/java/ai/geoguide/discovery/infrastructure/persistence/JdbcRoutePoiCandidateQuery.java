package ai.geoguide.discovery.infrastructure.persistence;

import ai.geoguide.discovery.application.port.RoutePoiCandidateQuery;
import ai.geoguide.discovery.domain.DiscoveryCriteria;
import ai.geoguide.discovery.domain.RoutePoiCandidate;
import ai.geoguide.poi.domain.Category;
import ai.geoguide.poi.domain.GeoPoint;
import ai.geoguide.poi.domain.PoiId;
import ai.geoguide.routing.domain.RouteGeometry;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class JdbcRoutePoiCandidateQuery implements RoutePoiCandidateQuery {

    private final JdbcTemplate jdbcTemplate;

    public JdbcRoutePoiCandidateQuery(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    public List<RoutePoiCandidate> findAlong(RouteGeometry routeGeometry, DiscoveryCriteria criteria) {
        String categoryClause = criteria.categoryCodes().isEmpty()
                ? "" : " AND c.code IN (" + String.join(",", java.util.Collections.nCopies(criteria.categoryCodes().size(), "?")) + ")";
        String sql = """
                WITH route AS (SELECT ST_SetSRID(ST_GeomFromGeoJSON(?), 4326) AS geometry)
                SELECT p.id, p.name, p.active, c.id AS category_id, c.code AS category_code,
                       c.name AS category_name, c.active AS category_active,
                       ST_Y(p.location) AS latitude, ST_X(p.location) AS longitude,
                       ST_Distance(p.location::geography, route.geometry::geography) AS distance_meters,
                       ST_LineLocatePoint(route.geometry, p.location) AS route_progress
                FROM geo.point_of_interest p
                JOIN geo.category c ON c.id = p.category_id
                CROSS JOIN route
                WHERE p.active = true
                  AND p.location && ST_Expand(route.geometry, ? / 111320.0)
                  AND ST_DWithin(p.location::geography, route.geometry::geography, ?)
                """ + categoryClause + " ORDER BY distance_meters, p.id LIMIT ?";
        List<Object> parameters = new ArrayList<>();
        parameters.add(asGeoJson(routeGeometry));
        parameters.add(criteria.corridorMeters());
        parameters.add(criteria.corridorMeters());
        parameters.addAll(criteria.categoryCodes());
        parameters.add(criteria.limit());
        return jdbcTemplate.query(sql, (rs, rowNum) -> new RoutePoiCandidate(
                new PoiId(rs.getObject("id", UUID.class)), rs.getString("name"),
                new Category(rs.getObject("category_id", UUID.class), rs.getString("category_code"),
                        rs.getString("category_name"), rs.getBoolean("category_active")),
                new GeoPoint(rs.getDouble("latitude"), rs.getDouble("longitude")), rs.getBoolean("active"),
                rs.getDouble("distance_meters"), rs.getDouble("route_progress")), parameters.toArray());
    }

    private String asGeoJson(RouteGeometry geometry) {
        return geometry.positions().stream()
                .map(point -> "[" + point.longitude() + "," + point.latitude() + "]")
                .collect(java.util.stream.Collectors.joining(",", "{\"type\":\"LineString\",\"coordinates\":[", "]}"));
    }
}
