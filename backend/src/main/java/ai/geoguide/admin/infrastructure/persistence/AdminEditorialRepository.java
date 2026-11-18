package ai.geoguide.admin.infrastructure.persistence;

import ai.geoguide.admin.domain.EditorialState;
import ai.geoguide.admin.domain.EditorialWorkflowConflictException;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

/** Administrative copy of a POI candidate. Public discovery rows change only on explicit publication. */
@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class AdminEditorialRepository {
    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    public AdminEditorialRepository(JdbcTemplate jdbc,ObjectMapper objectMapper) { this.jdbc = jdbc; this.objectMapper=objectMapper; }

    public Page<EditorialView> list(String state, String query,int page,int size) {
        int safePage=Math.max(0,Math.min(page,1_000_000)),safeSize=Math.max(1,Math.min(size,100)),offset=safePage*safeSize;
        long total=jdbc.queryForObject("""
                SELECT count(*) FROM admin.poi_editorial_record
                WHERE (? IS NULL OR editorial_state = ?) AND (? IS NULL OR name ILIKE '%' || ? || '%' OR source_record_id = ?)
                """,
                Long.class,state,state,query,query,query);
        List<EditorialView> content=jdbc.query("""
                SELECT * FROM admin.poi_editorial_record
                WHERE (? IS NULL OR editorial_state = ?)
                  AND (? IS NULL OR name ILIKE '%' || ? || '%' OR source_record_id = ?)
                ORDER BY updated_at DESC, id
                LIMIT ? OFFSET ?
                """, this::map, state, state, query, query, query,safeSize,offset);
        return new Page<>(content,safePage,safeSize,total);
    }

    public Optional<EditorialView> find(UUID id) {
        return jdbc.query("SELECT * FROM admin.poi_editorial_record WHERE id = ?", this::map, id)
                .stream().findFirst();
    }

    @Transactional
    public EditorialView reviewIdentity(UUID id, long expectedVersion, boolean noDuplicate, String actor, String reason) {
        int changed = jdbc.update("""
                UPDATE admin.poi_editorial_record SET identity_review_status=?,
                identity_review_actor=?,identity_reviewed_at=now(),identity_review_reason=?,version=version+1,updated_at=now()
                WHERE id=? AND version=? AND editorial_state IN ('DRAFT','REJECTED')""",
                noDuplicate ? "NO_DUPLICATE" : "MATCH_FOUND", actor, reason, id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Identity review failed because the record is stale or not editable.");
        EditorialView after=find(id).orElseThrow();
        audit(id, actor, noDuplicate ? "NO_DUPLICATE_CONFIRMED" : "POTENTIAL_DUPLICATE_FOUND", reason,
                null, null, expectedVersion + 1, json(java.util.Map.of("identityReviewStatus",after.identityReviewStatus())));
        return after;
    }

    @Transactional
    public EditorialView create(CreateEditorial command, String actor) {
        UUID id = UUID.randomUUID();
        if (command.importRecordId() == null) {
            jdbc.update("""
                    INSERT INTO admin.poi_editorial_record(id,name,description,category_code,latitude,longitude,
                        raw_latitude,raw_longitude,coordinate_normalization_rule,coordinate_validation_evidence,
                        source_license,source_attribution,created_by)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
                    """, id, command.name().trim(), command.description(), command.categoryCode().trim(),
                    command.latitude(), command.longitude(),command.rawLatitude(),command.rawLongitude(),command.normalizationRule(),
                    command.coordinateEvidence(), command.sourceLicense(), command.sourceAttribution(), actor);
        } else {
            int inserted = jdbc.update("""
                    INSERT INTO admin.poi_editorial_record(id,import_record_id,source_record_id,name,administrative_context,
                        category_code,latitude,longitude,raw_latitude,raw_longitude,coordinate_normalization_rule,
                        coordinate_validation_evidence,source_url,created_by)
                    SELECT ?, r.id, r.source_record_id, r.raw_fields->>'NOMBRE DEL RECURSO',
                        concat_ws(' — ', r.raw_fields->>'DISTRITO', r.raw_fields->>'PROVINCIA', r.raw_fields->>'REGIÓN'),
                        ?, r.normalized_latitude, r.normalized_longitude,r.raw_latitude,r.raw_longitude,
                        r.normalization_rule,r.validation_evidence,nullif(r.raw_fields->>'URL',''), ?
                    FROM geo.mincetur_import_record r
                    WHERE r.id = ? AND r.record_status = 'NORMALIZED_PENDING_REVIEW'
                      AND r.normalized_latitude IS NOT NULL AND r.normalized_longitude IS NOT NULL
                    ON CONFLICT (import_record_id) DO NOTHING
                    """, id, command.categoryCode().trim(), actor, command.importRecordId());
            if (inserted != 1) throw new EditorialWorkflowConflictException("Import record is absent, quarantined, or already has an editorial candidate.");
        }
        audit(id, actor, "CREATE", "Editorial candidate created", null, EditorialState.DRAFT.name(), 0,
                command.importRecordId() == null ? "{}" : "{\"source\":\"MINCETUR\"}");
        return find(id).orElseThrow();
    }

    @Transactional
    public EditorialView update(UUID id, long expectedVersion, UpdateEditorial command, String actor, String reason) {
        EditorialView before=find(id).orElseThrow(()->new IllegalArgumentException("Editorial record not found."));
        int changed = jdbc.update("""
                UPDATE admin.poi_editorial_record SET name=?, description=?, category_code=?, latitude=?, longitude=?,
                    coordinate_normalization_rule=?,coordinate_validation_evidence=?,source_license=?, source_attribution=?, geographic_review_status='PENDING',
                    geographic_review_actor=NULL, geographic_reviewed_at=NULL, geographic_review_reason=NULL,
                    identity_review_status='PENDING',identity_review_actor=NULL,identity_reviewed_at=NULL,identity_review_reason=NULL,
                    version=version+1, updated_at=now()
                WHERE id=? AND version=? AND editorial_state IN ('DRAFT','REJECTED')
                """, command.name().trim(), command.description(), command.categoryCode().trim(), command.latitude(),
                command.longitude(),command.normalizationRule(),command.coordinateEvidence(),command.sourceLicense(), command.sourceAttribution(), id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Record is stale, missing, or cannot be edited in its current state.");
        EditorialView after=find(id).orElseThrow();
        audit(id, actor, "UPDATE", reason, before.state(), after.state(), expectedVersion + 1,json(java.util.Map.of("before",before,"after",after)));
        return after;
    }

    @Transactional
    public EditorialView reviewGeography(UUID id, long expectedVersion, boolean approve, String actor, String reason) {
        int changed = jdbc.update("""
                UPDATE admin.poi_editorial_record SET geographic_review_status=?, geographic_review_actor=?,
                    geographic_reviewed_at=now(), geographic_review_reason=?, version=version+1, updated_at=now()
                WHERE id=? AND version=? AND editorial_state IN ('DRAFT','REJECTED')
                  AND latitude IS NOT NULL AND longitude IS NOT NULL
                  AND coordinate_validation_evidence IS NOT NULL AND btrim(coordinate_validation_evidence)<>''
                  AND (? = FALSE OR (latitude BETWEEN -18.5 AND 0 AND longitude BETWEEN -82.5 AND -68.0))
                """, approve ? "APPROVED" : "REJECTED", actor, reason, id, expectedVersion, approve);
        if (changed != 1) throw new EditorialWorkflowConflictException("Geographic review failed: stale record, missing coordinates, or coordinates outside the reviewed Peru bounds.");
        EditorialView after=find(id).orElseThrow();
        audit(id, actor, approve ? "GEOGRAPHY_APPROVED" : "GEOGRAPHY_REJECTED", reason,
                null, null, expectedVersion + 1,json(java.util.Map.of("latitude",after.latitude(),"longitude",after.longitude(),"evidence",after.coordinateEvidence())));
        return after;
    }

    @Transactional
    public EditorialView transition(UUID id, long expectedVersion, String action, String actor, String reason) {
        EditorialView before = find(id).orElseThrow(() -> new IllegalArgumentException("Editorial record not found."));
        if (before.version() != expectedVersion) throw new EditorialWorkflowConflictException("Editorial record version is stale.");
        String next = switch (action) {
            case "SUBMIT_FOR_REVIEW" -> {
                if (!(before.state().equals("DRAFT") || before.state().equals("REJECTED"))) throw new EditorialWorkflowConflictException("Only draft or rejected records can be submitted.");
                yield "PENDING_REVIEW";
            }
            case "APPROVE" -> {
                if (!before.state().equals("PENDING_REVIEW") || !before.geographicReviewStatus().equals("APPROVED")) throw new EditorialWorkflowConflictException("Explicit geographic approval is required before publication.");
                if (!before.identityReviewStatus().equals("NO_DUPLICATE")) throw new EditorialWorkflowConflictException("An explicit identity/duplicate review is required before publication.");
                if (before.sourceLicense() == null || before.sourceAttribution() == null || before.sourceLicense().isBlank() || before.sourceAttribution().isBlank()) throw new EditorialWorkflowConflictException("Documented source license and attribution are required before publication.");
                publish(before);
                yield "PUBLISHED";
            }
            case "REJECT" -> { if (!before.state().equals("PENDING_REVIEW")) throw new EditorialWorkflowConflictException("Only pending records can be rejected."); yield "REJECTED"; }
            case "ARCHIVE" -> { if (!List.of("PUBLISHED","REJECTED","DRAFT").contains(before.state())) throw new EditorialWorkflowConflictException("Record cannot be archived in its current state."); yield "ARCHIVED"; }
            default -> throw new IllegalArgumentException("Unknown editorial action.");
        };
        if (action.equals("ARCHIVE") && before.publishedPoiId() != null) {
            jdbc.update("UPDATE geo.point_of_interest SET active=false,updated_at=now() WHERE id=?", before.publishedPoiId());
        }
        int changed = jdbc.update("""
                UPDATE admin.poi_editorial_record SET editorial_state=?,
                    published_poi_id=CASE WHEN ?='PUBLISHED' THEN id ELSE published_poi_id END,
                    version=version+1, updated_at=now()
                WHERE id=? AND version=?
                """, next, next, id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Editorial record changed concurrently.");
        EditorialView after=find(id).orElseThrow();
        audit(id, actor, action, reason, before.state(), next, expectedVersion + 1,
                json(java.util.Map.of("publishedPoiId",after.publishedPoiId()==null?"":after.publishedPoiId().toString())));
        return after;
    }

    private void publish(EditorialView record) {
        UUID categoryId = jdbc.query("SELECT id FROM geo.category WHERE code=? AND active", (rs, row) -> rs.getObject(1, UUID.class), record.categoryCode())
                .stream().findFirst().orElseThrow(() -> new IllegalStateException("Category code is not an active P3 category."));
        UUID poiId = record.id();
        int exists = jdbc.queryForObject("SELECT count(*) FROM geo.point_of_interest WHERE id=?", Integer.class, poiId);
        if (exists != 0) throw new IllegalStateException("Candidate UUID already exists in the public POI catalog.");
        jdbc.update("""
                INSERT INTO geo.point_of_interest(id,category_id,name,description,location,active,created_at,updated_at)
                VALUES (?,?,?,?,ST_SetSRID(ST_MakePoint(?,?),4326),true,now(),now())
                """, poiId, categoryId, record.name(), record.description(), record.longitude(), record.latitude());
        String sourceKey = record.sourceRecordId() == null ? "editorial:" + record.id() : record.sourceRecordId();
        jdbc.update("""
                INSERT INTO geo.poi_provenance(id,poi_id,source_system,source_record_id,source_url,retrieved_at,
                    license,attribution,incorporation_method,logical_key)
                VALUES (?,?,?, ?,?,now(),?,?,?,?)
                """, UUID.randomUUID(), poiId, record.sourceRecordId() == null ? "ADMIN_CURATED" : "MINCETUR_INVENTARIO",
                record.sourceRecordId(), record.sourceUrl(), record.sourceLicense(), record.sourceAttribution(),
                "ADMINISTRATIVELY_REVIEWED", sourceKey);
    }

    public List<DuplicateCandidate> duplicates(UUID id) {
        var poiMatches = jdbc.query("""
                SELECT e.id, e.name, p.id AS poi_id, p.name AS poi_name,
                       ST_Distance(p.location::geography, ST_SetSRID(ST_MakePoint(e.longitude,e.latitude),4326)::geography) AS distance_m
                FROM admin.poi_editorial_record e JOIN geo.point_of_interest p ON p.active
                WHERE e.id=? AND e.latitude IS NOT NULL AND e.longitude IS NOT NULL
                  AND (lower(trim(p.name))=lower(trim(e.name)) OR EXISTS (SELECT 1 FROM geo.poi_provenance x
                       WHERE x.poi_id=p.id AND x.source_system='MINCETUR_INVENTARIO' AND x.source_record_id=e.source_record_id)
                       OR ST_DWithin(p.location::geography,
                       ST_SetSRID(ST_MakePoint(e.longitude,e.latitude),4326)::geography, 1000))
                ORDER BY distance_m NULLS LAST LIMIT 30
                """, (rs, row) -> new DuplicateCandidate("POI", rs.getObject("poi_id", UUID.class), rs.getString("poi_name"), rs.getObject("distance_m", Double.class)), id);
        var destinationMatches = jdbc.query("""
                SELECT d.id,d.canonical_name AS name,ST_Distance(d.location::geography,
                    ST_SetSRID(ST_MakePoint(e.longitude,e.latitude),4326)::geography) AS distance_m
                FROM admin.poi_editorial_record e JOIN geo.destination d ON d.active
                WHERE e.id=? AND e.latitude IS NOT NULL AND e.longitude IS NOT NULL
                  AND (lower(trim(d.canonical_name))=lower(trim(e.name)) OR
                       (d.source_system='MINCETUR' AND d.source_record_id=e.source_record_id) OR ST_DWithin(d.location::geography,
                       ST_SetSRID(ST_MakePoint(e.longitude,e.latitude),4326)::geography,1000))
                ORDER BY distance_m NULLS LAST LIMIT 30
                """, (rs,row)->new DuplicateCandidate("DESTINATION",rs.getObject("id",UUID.class),rs.getString("name"),rs.getObject("distance_m",Double.class)),id);
        var all = new java.util.ArrayList<DuplicateCandidate>(poiMatches); all.addAll(destinationMatches); return List.copyOf(all);
    }

    private void audit(UUID id, String actor, String action, String reason, String previous, String next, long version, String details) {
        jdbc.update("""
                INSERT INTO admin.poi_editorial_audit(id,editorial_id,actor_id,action,reason,previous_state,next_state,version,details)
                VALUES (?,?,?,?,?,?,?, ?,?::jsonb)""", UUID.randomUUID(), id, actor, action, reason, previous, next, version, details);
    }

    private String json(Object value){try{return objectMapper.writeValueAsString(value);}catch(JsonProcessingException exception){throw new IllegalStateException("Administrative audit details could not be serialized.",exception);}}

    private EditorialView map(ResultSet rs, int row) throws SQLException {
        return new EditorialView(rs.getObject("id", UUID.class), rs.getObject("import_record_id", UUID.class),
                rs.getString("source_record_id"), rs.getString("name"), rs.getString("description"),
                rs.getString("administrative_context"),rs.getString("category_code"),
                rs.getBigDecimal("latitude"), rs.getBigDecimal("longitude"),rs.getString("raw_latitude"),rs.getString("raw_longitude"),
                rs.getString("coordinate_normalization_rule"),rs.getString("coordinate_validation_evidence"), rs.getString("geographic_review_status"),
                rs.getString("identity_review_status"),
                rs.getString("editorial_state"), rs.getString("source_license"), rs.getString("source_attribution"),
                rs.getString("source_url"), rs.getObject("published_poi_id", UUID.class), rs.getLong("version"));
    }

    public record CreateEditorial(UUID importRecordId, String name, String description, String categoryCode,
            BigDecimal latitude, BigDecimal longitude,String rawLatitude,String rawLongitude,String normalizationRule,
            String coordinateEvidence,String sourceLicense, String sourceAttribution) {}
    public record UpdateEditorial(String name, String description, String categoryCode, BigDecimal latitude,
            BigDecimal longitude,String normalizationRule,String coordinateEvidence, String sourceLicense, String sourceAttribution) {}
    public record EditorialView(UUID id, UUID importRecordId, String sourceRecordId, String name, String description,String administrativeContext,
            String categoryCode, BigDecimal latitude, BigDecimal longitude,String rawLatitude,String rawLongitude,
            String normalizationRule,String coordinateEvidence,String geographicReviewStatus,String identityReviewStatus,
            String state, String sourceLicense, String sourceAttribution, String sourceUrl, UUID publishedPoiId, long version) {}
    public record DuplicateCandidate(String entityType,UUID entityId, String name, Double distanceMeters) {}
    public record Page<T>(List<T> content,int page,int size,long totalElements){public int totalPages(){return (int)Math.ceil((double)totalElements/size);}}
}
