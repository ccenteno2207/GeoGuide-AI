package ai.geoguide.admin.infrastructure.persistence;

import ai.geoguide.admin.domain.EditorialWorkflowConflictException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** Explicit review ledger linking a destination representation to a POI without copying state or geometry. */
@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class AdminDestinationPoiRelationshipRepository {
    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    public AdminDestinationPoiRelationshipRepository(JdbcTemplate jdbc, ObjectMapper objectMapper) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
    }

    public Page<RelationshipView> list(String status, int page, int size) {
        int safePage = Math.max(0, Math.min(page, 1_000_000));
        int safeSize = Math.max(1, Math.min(size, 100));
        int offset = safePage * safeSize;
        long total = jdbc.queryForObject("""
                SELECT count(*) FROM admin.destination_poi_relationship
                WHERE CAST(? AS VARCHAR) IS NULL OR relationship_status=?
                """, Long.class, status, status);
        List<RelationshipView> rows = jdbc.query("""
                SELECT r.*, d.canonical_name AS destination_name, p.name AS poi_name
                FROM admin.destination_poi_relationship r
                JOIN geo.destination d ON d.id=r.destination_id
                JOIN geo.point_of_interest p ON p.id=r.poi_id
                WHERE CAST(? AS VARCHAR) IS NULL OR r.relationship_status=?
                ORDER BY r.updated_at DESC, r.id LIMIT ? OFFSET ?
                """, this::map, status, status, safeSize, offset);
        return new Page<>(rows, safePage, safeSize, total);
    }

    public Optional<RelationshipView> find(UUID id) {
        return jdbc.query("""
                SELECT r.*, d.canonical_name AS destination_name, p.name AS poi_name
                FROM admin.destination_poi_relationship r
                JOIN geo.destination d ON d.id=r.destination_id
                JOIN geo.point_of_interest p ON p.id=r.poi_id WHERE r.id=?
                """, this::map, id).stream().findFirst();
    }

    @Transactional
    public RelationshipView create(CreateRelationship request, String actor) {
        if (!List.of("SAME_RESOURCE", "RELATED_RESOURCE").contains(request.relationshipType())) {
            throw new IllegalArgumentException("Relationship type is invalid.");
        }
        requireText(request.reason(), "Relationship reason");
        requireText(request.evidence(), "Relationship evidence");
        UUID id = UUID.randomUUID();
        int inserted = jdbc.update("""
                INSERT INTO admin.destination_poi_relationship(id,destination_id,poi_id,relationship_type,
                    created_by,created_reason,created_evidence)
                SELECT ?,d.id,p.id,?,?,?,? FROM geo.destination d CROSS JOIN geo.point_of_interest p
                WHERE d.id=? AND d.active=true AND p.id=? AND p.active=true
                """, id, request.relationshipType(), actor, request.reason().trim(), request.evidence().trim(),
                request.destinationId(), request.poiId());
        if (inserted != 1) throw new EditorialWorkflowConflictException("Relationship requires existing active destination and POI records.");
        audit(id, actor, "CREATE_PENDING", request.reason(), null, "PENDING", 0,
                json(java.util.Map.of("destinationId", request.destinationId(), "poiId", request.poiId(),
                        "relationshipType", request.relationshipType(), "evidence", request.evidence().trim())));
        return find(id).orElseThrow();
    }

    @Transactional
    public RelationshipView review(UUID id, long expectedVersion, boolean approve, String actor,
            String reason, String evidence) {
        requireText(reason, "Review reason");
        requireText(evidence, "Review evidence");
        int changed = jdbc.update("""
                UPDATE admin.destination_poi_relationship AS relationship SET relationship_status=?, reviewed_by=?,
                    reviewed_at=now(), review_reason=?, review_evidence=?, version=version+1, updated_at=now()
                WHERE relationship.id=? AND relationship.version=? AND relationship.relationship_status='PENDING'
                  AND EXISTS (SELECT 1 FROM geo.destination d WHERE d.id=relationship.destination_id AND d.active)
                  AND EXISTS (SELECT 1 FROM geo.point_of_interest p WHERE p.id=relationship.poi_id AND p.active)
                """, approve ? "APPROVED" : "REJECTED", actor, reason.trim(), evidence.trim(), id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Relationship is stale, inactive, or no longer pending.");
        RelationshipView after = find(id).orElseThrow();
        audit(id, actor, approve ? "APPROVE" : "REJECT", reason, "PENDING", after.status(),
                expectedVersion + 1, json(java.util.Map.of("evidence", evidence.trim())));
        return after;
    }

    private void audit(UUID id, String actor, String action, String reason, String previous, String next,
            long version, String details) {
        jdbc.update("""
                INSERT INTO admin.destination_poi_relationship_audit(id,relationship_id,actor_id,action,reason,
                    previous_status,next_status,version,details) VALUES (?,?,?,?,?,?,?, ?,?::jsonb)
                """, UUID.randomUUID(), id, actor, action, reason.trim(), previous, next, version, details);
    }

    private String json(Object value) {
        try { return objectMapper.writeValueAsString(value); }
        catch (JsonProcessingException e) { throw new IllegalStateException("Could not serialize relationship audit evidence.", e); }
    }

    private RelationshipView map(ResultSet rs, int row) throws SQLException {
        return new RelationshipView(rs.getObject("id", UUID.class), rs.getObject("destination_id", UUID.class),
                rs.getString("destination_name"), rs.getObject("poi_id", UUID.class), rs.getString("poi_name"),
                rs.getString("relationship_type"), rs.getString("relationship_status"), rs.getString("created_by"),
                rs.getString("created_reason"), rs.getString("created_evidence"), rs.getString("reviewed_by"),
                rs.getString("review_reason"), rs.getString("review_evidence"), rs.getLong("version"));
    }

    private static void requireText(String text, String field) {
        if (text == null || text.isBlank()) throw new IllegalArgumentException(field + " is required.");
    }

    public record CreateRelationship(UUID destinationId, UUID poiId, String relationshipType,
            String reason, String evidence) {}
    public record RelationshipView(UUID id, UUID destinationId, String destinationName, UUID poiId,
            String poiName, String relationshipType, String status, String createdBy, String createdReason,
            String createdEvidence, String reviewedBy, String reviewReason, String reviewEvidence, long version) {}
    public record Page<T>(List<T> content, int page, int size, long totalElements) {
        public int totalPages() { return (int) Math.ceil((double) totalElements / size); }
    }
}
