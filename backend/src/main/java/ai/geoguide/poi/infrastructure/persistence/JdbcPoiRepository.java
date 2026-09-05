package ai.geoguide.poi.infrastructure.persistence;

import ai.geoguide.poi.application.port.PoiRepository;
import ai.geoguide.poi.domain.Category;
import ai.geoguide.poi.domain.GeoPoint;
import ai.geoguide.poi.domain.PoiId;
import ai.geoguide.poi.domain.PointOfInterest;
import ai.geoguide.poi.domain.SourceReference;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class JdbcPoiRepository implements PoiRepository {

    private final JdbcTemplate jdbcTemplate;

    public JdbcPoiRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @Override
    @Transactional
    public PointOfInterest save(PointOfInterest poi) {
        upsertCategory(poi.category());
        upsertPoi(poi);
        for (SourceReference source : poi.provenance()) {
            upsertProvenance(poi.id(), source);
        }
        return poi;
    }

    @Override
    public Optional<PointOfInterest> findById(PoiId id) {
        List<PointOfInterest> results = jdbcTemplate.query("""
                SELECT p.id, p.name, p.description, p.active, p.created_at, p.updated_at,
                       ST_Y(p.location) AS latitude, ST_X(p.location) AS longitude,
                       c.id AS category_id, c.code AS category_code,
                       c.name AS category_name, c.active AS category_active
                FROM geo.point_of_interest p
                JOIN geo.category c ON c.id = p.category_id
                WHERE p.id = ?
                """, (rs, rowNum) -> mapPoi(rs), id.value());
        return results.stream().findFirst();
    }

    private PointOfInterest mapPoi(ResultSet rs) throws SQLException {
        PoiId id = new PoiId(rs.getObject("id", UUID.class));
        Category category = new Category(
                rs.getObject("category_id", UUID.class),
                rs.getString("category_code"),
                rs.getString("category_name"),
                rs.getBoolean("category_active"));
        List<SourceReference> provenance = jdbcTemplate.query("""
                SELECT id, source_system, source_record_id, source_url, retrieved_at,
                       license, attribution, incorporation_method, logical_key
                FROM geo.poi_provenance
                WHERE poi_id = ?
                ORDER BY source_system, logical_key
                """, (sourceRs, rowNum) -> mapSource(sourceRs), id.value());
        return new PointOfInterest(
                id,
                rs.getString("name"),
                rs.getString("description"),
                category,
                new GeoPoint(rs.getDouble("latitude"), rs.getDouble("longitude")),
                rs.getBoolean("active"),
                rs.getTimestamp("created_at").toInstant(),
                rs.getTimestamp("updated_at").toInstant(),
                provenance);
    }

    private SourceReference mapSource(ResultSet rs) throws SQLException {
        Timestamp retrievedAt = rs.getTimestamp("retrieved_at");
        return new SourceReference(
                rs.getObject("id", UUID.class),
                rs.getString("source_system"),
                rs.getString("source_record_id"),
                rs.getString("source_url"),
                retrievedAt == null ? null : retrievedAt.toInstant(),
                rs.getString("license"),
                rs.getString("attribution"),
                rs.getString("incorporation_method"),
                rs.getString("logical_key"));
    }

    private void upsertCategory(Category category) {
        jdbcTemplate.update("""
                INSERT INTO geo.category (id, code, name, active)
                VALUES (?, ?, ?, ?)
                ON CONFLICT (code) DO UPDATE
                SET name = EXCLUDED.name, active = EXCLUDED.active
                """, category.id(), category.code(), category.name(), category.active());
    }

    private void upsertPoi(PointOfInterest poi) {
        jdbcTemplate.update("""
                INSERT INTO geo.point_of_interest
                    (id, category_id, name, description, location, active, created_at, updated_at)
                VALUES (?, ?, ?, ?, ST_SetSRID(ST_MakePoint(?, ?), 4326), ?, ?, ?)
                ON CONFLICT (id) DO UPDATE
                SET category_id = EXCLUDED.category_id,
                    name = EXCLUDED.name,
                    description = EXCLUDED.description,
                    location = EXCLUDED.location,
                    active = EXCLUDED.active,
                    updated_at = EXCLUDED.updated_at
                """,
                poi.id().value(), poi.category().id(), poi.name(), poi.description(),
                poi.location().longitude(), poi.location().latitude(), poi.active(),
                Timestamp.from(poi.createdAt()), Timestamp.from(poi.updatedAt()));
    }

    private void upsertProvenance(PoiId poiId, SourceReference source) {
        jdbcTemplate.update("""
                INSERT INTO geo.poi_provenance
                    (id, poi_id, source_system, source_record_id, source_url, retrieved_at,
                     license, attribution, incorporation_method, logical_key)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT (source_system, logical_key) DO UPDATE
                SET poi_id = EXCLUDED.poi_id,
                    source_record_id = EXCLUDED.source_record_id,
                    source_url = EXCLUDED.source_url,
                    retrieved_at = EXCLUDED.retrieved_at,
                    license = EXCLUDED.license,
                    attribution = EXCLUDED.attribution,
                    incorporation_method = EXCLUDED.incorporation_method
                """,
                source.id(), poiId.value(), source.sourceSystem(), source.sourceRecordId(),
                source.sourceUrl(), source.retrievedAt() == null ? null : Timestamp.from(source.retrievedAt()),
                source.license(), source.attribution(), source.incorporationMethod(), source.logicalKey());
    }
}
