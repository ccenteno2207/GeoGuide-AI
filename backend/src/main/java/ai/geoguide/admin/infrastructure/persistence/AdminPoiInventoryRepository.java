package ai.geoguide.admin.infrastructure.persistence;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import ai.geoguide.admin.domain.EditorialWorkflowConflictException;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** Read inventory and audited activation controls for POIs that predate editorial records. */
@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class AdminPoiInventoryRepository {
    private final JdbcTemplate jdbc;

    public AdminPoiInventoryRepository(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    public Page list(String query, String category, Boolean active, int page, int size) {
        int safePage = Math.max(0, Math.min(page, 1_000_000));
        int safeSize = Math.max(1, Math.min(size, 100));
        long total = jdbc.queryForObject("""
                SELECT count(*) FROM geo.point_of_interest p JOIN geo.category c ON c.id=p.category_id
                WHERE (CAST(? AS TEXT) IS NULL OR p.name ILIKE '%' || ? || '%')
                  AND (CAST(? AS TEXT) IS NULL OR c.code=?)
                  AND (CAST(? AS BOOLEAN) IS NULL OR p.active=?)
                """, Long.class, query, query, category, category, active, active);
        List<PoiView> rows = jdbc.query("""
                SELECT p.id,p.name,p.description,c.code AS category_code,c.name AS category_name,p.active,p.updated_at,
                    prov.source_system,prov.source_record_id,prov.source_url,prov.license,prov.attribution
                FROM geo.point_of_interest p JOIN geo.category c ON c.id=p.category_id
                LEFT JOIN LATERAL (SELECT source_system,source_record_id,source_url,license,attribution
                    FROM geo.poi_provenance WHERE poi_id=p.id ORDER BY source_system,logical_key LIMIT 1) prov ON TRUE
                WHERE (CAST(? AS TEXT) IS NULL OR p.name ILIKE '%' || ? || '%')
                  AND (CAST(? AS TEXT) IS NULL OR c.code=?)
                  AND (CAST(? AS BOOLEAN) IS NULL OR p.active=?)
                ORDER BY p.name,p.id LIMIT ? OFFSET ?
                """, this::map, query, query, category, category, active, active, safeSize, safePage * safeSize);
        return new Page(rows, safePage, safeSize, total);
    }

    @Transactional
    public PoiView setActive(UUID id, Instant expectedUpdatedAt, boolean active, String actor, String reason, String evidence) {
        if (active) throw new EditorialWorkflowConflictException("Reactivation requires an approved editorial change request.");
        PoiView before = jdbc.query("""
                SELECT p.id,p.name,p.description,c.code AS category_code,c.name AS category_name,p.active,p.updated_at,
                    prov.source_system,prov.source_record_id,prov.source_url,prov.license,prov.attribution
                FROM geo.point_of_interest p JOIN geo.category c ON c.id=p.category_id
                LEFT JOIN LATERAL (SELECT source_system,source_record_id,source_url,license,attribution
                    FROM geo.poi_provenance WHERE poi_id=p.id ORDER BY source_system,logical_key LIMIT 1) prov ON TRUE
                WHERE p.id=? FOR UPDATE OF p
                """, this::map, id).stream().findFirst().orElseThrow(() -> new IllegalArgumentException("POI not found."));
        if (!before.updatedAt().equals(expectedUpdatedAt)) throw new IllegalStateException("POI version is stale.");
        if (reason == null || reason.isBlank() || evidence == null || evidence.isBlank() || actor == null || actor.isBlank())
            throw new IllegalArgumentException("Actor, reason and evidence are required for activation changes.");
        int changed = jdbc.update("""
                UPDATE geo.point_of_interest p SET active=?,updated_at=now()
                WHERE p.id=? AND (?=FALSE OR EXISTS (SELECT 1 FROM geo.category c WHERE c.id=p.category_id AND c.active))
                  AND (?=FALSE OR NOT EXISTS (
                    SELECT 1 FROM geo.poi_provenance prov JOIN geo.mincetur_import_record r
                      ON prov.source_system='MINCETUR_INVENTARIO' AND prov.source_record_id=r.source_record_id
                    WHERE prov.poi_id=p.id AND r.thematic_eligibility='EXCLUDED_FROM_NAVIGATION'))
                """, active, id, active, active);
        if (changed != 1) throw new IllegalStateException("Activation is blocked by inactive category or excluded MINCETUR eligibility.");
        jdbc.update("""
                INSERT INTO admin.poi_activation_audit(id,poi_id,actor_id,action,reason,evidence,previous_active,next_active)
                VALUES (?,?,?,?,?,?,?,?)
                """, UUID.randomUUID(), id, actor, active ? "ACTIVATE" : "DEACTIVATE", reason.trim(), evidence.trim(), before.active(), active);
        return jdbc.query("""
                SELECT p.id,p.name,p.description,c.code AS category_code,c.name AS category_name,p.active,p.updated_at,
                    prov.source_system,prov.source_record_id,prov.source_url,prov.license,prov.attribution
                FROM geo.point_of_interest p JOIN geo.category c ON c.id=p.category_id
                LEFT JOIN LATERAL (SELECT source_system,source_record_id,source_url,license,attribution
                    FROM geo.poi_provenance WHERE poi_id=p.id ORDER BY source_system,logical_key LIMIT 1) prov ON TRUE
                WHERE p.id=?
                """, this::map, id).getFirst();
    }

    public List<ActivationAudit> audit(UUID id) {
        return jdbc.query("SELECT actor_id,action,reason,evidence,previous_active,next_active,occurred_at FROM admin.poi_activation_audit WHERE poi_id=? ORDER BY occurred_at DESC",
                (rs, row) -> new ActivationAudit(rs.getString("actor_id"), rs.getString("action"), rs.getString("reason"), rs.getString("evidence"),
                        rs.getBoolean("previous_active"), rs.getBoolean("next_active"), rs.getTimestamp("occurred_at").toInstant()), id);
    }

    private PoiView map(ResultSet rs, int row) throws SQLException {
        return new PoiView(rs.getObject("id", UUID.class), rs.getString("name"), rs.getString("description"),
                rs.getString("category_code"), rs.getString("category_name"), rs.getBoolean("active"), rs.getTimestamp("updated_at").toInstant(),
                rs.getString("source_system"), rs.getString("source_record_id"), rs.getString("source_url"), rs.getString("license"), rs.getString("attribution"));
    }

    public record PoiView(UUID id, String name, String description, String categoryCode, String categoryName, boolean active,
            Instant updatedAt, String sourceSystem, String sourceRecordId, String sourceUrl, String license, String attribution) {}
    public record ActivationAudit(String actor, String action, String reason, String evidence, boolean previousActive, boolean nextActive, Instant occurredAt) {}
    public record Page(List<PoiView> content, int page, int size, long totalElements) {}
}
