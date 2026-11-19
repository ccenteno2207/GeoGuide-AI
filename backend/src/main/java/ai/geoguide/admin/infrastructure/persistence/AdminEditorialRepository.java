package ai.geoguide.admin.infrastructure.persistence;

import ai.geoguide.admin.domain.EditorialState;
import ai.geoguide.admin.domain.EditorialCategoryMismatchException;
import ai.geoguide.admin.domain.MinceturPoiCategoryMapper;
import ai.geoguide.admin.domain.EditorialWorkflowConflictException;
import ai.geoguide.destination.domain.Destination;
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

    public Page<EditorialView> list(String state, String query, String locality, String category, int page, int size) {
        int safePage=Math.max(0,Math.min(page,1_000_000)),safeSize=Math.max(1,Math.min(size,100)),offset=safePage*safeSize;
        long total=jdbc.queryForObject("""
                SELECT count(*) FROM admin.poi_editorial_record
                WHERE (CAST(? AS VARCHAR) IS NULL OR editorial_state = ?)
                  AND (CAST(? AS TEXT) IS NULL OR name ILIKE '%' || ? || '%' OR source_record_id = ?)
                  AND (CAST(? AS TEXT) IS NULL OR administrative_context ILIKE '%' || ? || '%')
                  AND (CAST(? AS TEXT) IS NULL OR category_code = ?)
                """,
                Long.class,state,state,query,query,query,locality,locality,category,category);
        List<EditorialView> content=jdbc.query("""
                SELECT * FROM admin.poi_editorial_record
                WHERE (CAST(? AS VARCHAR) IS NULL OR editorial_state = ?)
                  AND (CAST(? AS TEXT) IS NULL OR name ILIKE '%' || ? || '%' OR source_record_id = ?)
                  AND (CAST(? AS TEXT) IS NULL OR administrative_context ILIKE '%' || ? || '%')
                  AND (CAST(? AS TEXT) IS NULL OR category_code = ?)
                ORDER BY updated_at DESC, id
                LIMIT ? OFFSET ?
                """, this::map, state, state, query, query, query, locality, locality, category, category,safeSize,offset);
        return new Page<>(content,safePage,safeSize,total);
    }

    public Optional<EditorialView> find(UUID id) {
        return jdbc.query("SELECT * FROM admin.poi_editorial_record WHERE id = ?", this::map, id)
                .stream().findFirst();
    }

    @Transactional
    public EditorialView reviewIdentity(UUID id, long expectedVersion, boolean noDuplicate,
            String actor, String reason, String evidence) {
        if (evidence == null || evidence.isBlank()) throw new IllegalArgumentException("Identity review evidence is required.");
        int changed = jdbc.update("""
                UPDATE admin.poi_editorial_record SET identity_review_status=?,
                identity_review_actor=?,identity_reviewed_at=now(),identity_review_reason=?,identity_review_evidence=?,
                version=version+1,updated_at=now()
                WHERE id=? AND version=? AND editorial_state IN ('DRAFT','REJECTED')""",
                noDuplicate ? "NO_DUPLICATE" : "MATCH_FOUND", actor, reason, evidence.trim(), id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Identity review failed because the record is stale or not editable.");
        EditorialView after=find(id).orElseThrow();
        audit(id, actor, noDuplicate ? "NO_DUPLICATE_CONFIRMED" : "POTENTIAL_DUPLICATE_FOUND", reason,
                null, null, expectedVersion + 1, json(java.util.Map.of("identityReviewStatus",after.identityReviewStatus(),
                        "evidence", evidence.trim())));
        return after;
    }

    @Transactional
    public EditorialView create(CreateEditorial command, String actor) {
        UUID id = UUID.randomUUID();
        validateKnownMinceturCategory(command.importRecordId(), command.categoryCode());
        if (command.importRecordId() == null) {
            jdbc.update("""
                    INSERT INTO admin.poi_editorial_record(id,name,description,administrative_context,category_code,latitude,longitude,
                        raw_latitude,raw_longitude,coordinate_normalization_rule,coordinate_validation_evidence,
                        source_license,source_attribution,created_by)
                    VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    """, id, command.name().trim(), command.description(), command.administrativeContext(), command.categoryCode().trim(),
                    command.latitude(), command.longitude(),command.rawLatitude(),command.rawLongitude(),command.normalizationRule(),
                    command.coordinateEvidence(), command.sourceLicense(), command.sourceAttribution(), actor);
        } else {
            int inserted = jdbc.update("""
                    INSERT INTO admin.poi_editorial_record(id,import_record_id,source_record_id,name,administrative_context,
                        category_code,latitude,longitude,raw_latitude,raw_longitude,coordinate_normalization_rule,
                        coordinate_validation_evidence,source_url,source_license,source_attribution,created_by)
                    SELECT ?, r.id, r.source_record_id, r.raw_fields->>'NOMBRE DEL RECURSO',
                        concat_ws(' — ', r.raw_fields->>'DISTRITO', r.raw_fields->>'PROVINCIA', r.raw_fields->>'REGIÓN'),
                        ?, r.normalized_latitude, r.normalized_longitude,r.raw_latitude,r.raw_longitude,
                        r.normalization_rule,r.validation_evidence,nullif(r.raw_fields->>'URL',''), ?, ?, ?
                    FROM geo.mincetur_import_record r
                    JOIN geo.mincetur_import_batch b ON b.id = r.batch_id
                    WHERE r.id = ? AND r.record_status = 'NORMALIZED_PENDING_REVIEW'
                      AND r.thematic_eligibility = 'ELIGIBLE_FOR_REVIEW'
                      AND b.taxonomy_filter_version = 'MINCETUR-TAXONOMY-FILTER-v1'
                      AND r.normalized_latitude IS NOT NULL AND r.normalized_longitude IS NOT NULL
                    ON CONFLICT (import_record_id) DO NOTHING
                    """, id, command.categoryCode().trim(), command.sourceLicense(), command.sourceAttribution(), actor,
                    command.importRecordId());
            if (inserted != 1) throw new EditorialWorkflowConflictException("Import record is absent, quarantined, thematically excluded or unreviewed, uses an unsupported taxonomy filter, or already has an editorial candidate.");
        }
        audit(id, actor, "CREATE", "Editorial candidate created", null, EditorialState.DRAFT.name(), 0,
                command.importRecordId() == null ? "{}" : "{\"source\":\"MINCETUR\"}");
        return find(id).orElseThrow();
    }

    private void validateKnownMinceturCategory(UUID importRecordId, String categoryCode) {
        if (importRecordId == null) return;
        List<String> sourceTypes = jdbc.query("SELECT raw_fields->>'TIPO DE CATEGORÍA' FROM geo.mincetur_import_record WHERE id=?",
                (rs, row) -> rs.getString(1), importRecordId);
        String sourceType = sourceTypes.isEmpty() ? null : sourceTypes.getFirst();
        String suggested = MinceturPoiCategoryMapper.suggestedCategoryCode(sourceType);
        if (suggested != null && !suggested.equals(categoryCode == null ? null : categoryCode.trim())) {
            throw new EditorialCategoryMismatchException(suggested);
        }
    }

    @Transactional
    public EditorialView createChangeRequest(UUID poiId, String actor) {
        UUID id = UUID.randomUUID();
        int inserted = jdbc.update("""
                INSERT INTO admin.poi_editorial_record(id,target_poi_id,name,description,administrative_context,category_code,
                    latitude,longitude,coordinate_validation_evidence,source_record_id,source_url,source_license,source_attribution,created_by)
                SELECT ?,p.id,p.name,p.description,NULL,c.code,ST_Y(p.location),ST_X(p.location),
                    'Coordinates copied from the existing curated POI; reviewer must confirm before approval.',
                    prov.source_record_id,prov.source_url,prov.license,prov.attribution,?
                FROM geo.point_of_interest p JOIN geo.category c ON c.id=p.category_id
                LEFT JOIN LATERAL (SELECT source_record_id,source_url,license,attribution FROM geo.poi_provenance
                    WHERE poi_id=p.id ORDER BY source_system,logical_key LIMIT 1) prov ON TRUE
                WHERE p.id=?
                ON CONFLICT (target_poi_id) WHERE target_poi_id IS NOT NULL
                    AND editorial_state IN ('DRAFT','OBSERVED','PENDING_REVIEW') DO NOTHING
                """, id, actor, poiId);
        if (inserted != 1) throw new EditorialWorkflowConflictException("Existing POI is inactive, missing, or already has a change request.");
        audit(id, actor, "CREATE_CHANGE_REQUEST", "Editorial change request created for an existing POI", null,
                EditorialState.DRAFT.name(), 0, json(java.util.Map.of("targetPoiId", poiId.toString())));
        return find(id).orElseThrow();
    }

    @Transactional
    public EditorialView update(UUID id, long expectedVersion, UpdateEditorial command, String actor, String reason) {
        EditorialView before=find(id).orElseThrow(()->new IllegalArgumentException("Editorial record not found."));
        int changed = jdbc.update("""
                UPDATE admin.poi_editorial_record SET name=?, description=?, administrative_context=?, category_code=?, latitude=?, longitude=?,
                    coordinate_normalization_rule=?,coordinate_validation_evidence=?,source_license=?, source_attribution=?, geographic_review_status='PENDING',
                    geographic_review_actor=NULL, geographic_reviewed_at=NULL, geographic_review_reason=NULL,
                    identity_review_status='PENDING',identity_review_actor=NULL,identity_reviewed_at=NULL,
                    identity_review_reason=NULL,identity_review_evidence=NULL,
                    version=version+1, updated_at=now()
                WHERE id=? AND version=? AND editorial_state IN ('DRAFT','OBSERVED','REJECTED')
                """, command.name().trim(), command.description(), command.administrativeContext(), command.categoryCode().trim(), command.latitude(),
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
    public EditorialView transition(UUID id, long expectedVersion, String action, String actor, String reason,
            String evidence) {
        if (evidence == null || evidence.isBlank()) throw new IllegalArgumentException("Editorial decision evidence is required.");
        EditorialView before = find(id).orElseThrow(() -> new IllegalArgumentException("Editorial record not found."));
        if (before.version() != expectedVersion) throw new EditorialWorkflowConflictException("Editorial record version is stale.");
        String next = switch (action) {
            case "SUBMIT_FOR_REVIEW" -> {
                if (!(before.state().equals("DRAFT") || before.state().equals("OBSERVED") || before.state().equals("REJECTED"))) throw new EditorialWorkflowConflictException("Only draft, observed or rejected records can be submitted.");
                if (!before.geographicReviewStatus().equals("APPROVED")
                        || !before.identityReviewStatus().equals("NO_DUPLICATE")
                        || before.identityReviewEvidence() == null || before.identityReviewEvidence().isBlank()) {
                    throw new EditorialWorkflowConflictException("Geographic and evidenced identity reviews are required before submission.");
                }
                if (before.sourceLicense() == null || before.sourceAttribution() == null
                        || before.sourceLicense().isBlank() || before.sourceAttribution().isBlank()) {
                    throw new EditorialWorkflowConflictException("Source license and attribution are required before submission.");
                }
                yield "PENDING_REVIEW";
            }
            case "APPROVE" -> {
                if (!before.state().equals("PENDING_REVIEW") || !before.geographicReviewStatus().equals("APPROVED")) throw new EditorialWorkflowConflictException("Explicit geographic approval is required before publication.");
                if (!before.identityReviewStatus().equals("NO_DUPLICATE")) throw new EditorialWorkflowConflictException("An explicit identity/duplicate review is required before publication.");
                if (before.identityReviewEvidence() == null || before.identityReviewEvidence().isBlank()) throw new EditorialWorkflowConflictException("Evidenced identity review is required before publication.");
                if (before.sourceLicense() == null || before.sourceAttribution() == null || before.sourceLicense().isBlank() || before.sourceAttribution().isBlank()) throw new EditorialWorkflowConflictException("Documented source license and attribution are required before publication.");
                validateKnownMinceturCategory(before.importRecordId(), before.categoryCode());
                if (before.importRecordId() == null && before.targetPoiId() == null) ensureManualRecordIsNotThematicallyExcluded(before.name());
                publish(before);
                yield "APPROVED";
            }
            case "OBSERVE" -> { if (!before.state().equals("PENDING_REVIEW")) throw new EditorialWorkflowConflictException("Only pending records can be observed."); yield "OBSERVED"; }
            case "SUSPEND" -> { if (!before.state().equals("APPROVED") && !before.state().equals("PUBLISHED")) throw new EditorialWorkflowConflictException("Only approved records can be suspended."); yield "SUSPENDED"; }
            case "RESTORE_APPROVAL" -> { if (!before.state().equals("SUSPENDED")) throw new EditorialWorkflowConflictException("Only suspended records can be restored to approval."); yield "APPROVED"; }
            case "REJECT" -> { if (!before.state().equals("PENDING_REVIEW")) throw new EditorialWorkflowConflictException("Only pending records can be rejected."); yield "REJECTED"; }
            case "ARCHIVE" -> { if (!List.of("PUBLISHED","APPROVED","SUSPENDED","REJECTED","DRAFT","OBSERVED").contains(before.state())) throw new EditorialWorkflowConflictException("Record cannot be archived in its current state."); yield "ARCHIVED"; }
            default -> throw new IllegalArgumentException("Unknown editorial action.");
        };
        if (action.equals("ARCHIVE") && before.publishedPoiId() != null) {
            jdbc.update("UPDATE geo.point_of_interest SET active=false,updated_at=now() WHERE id=?", before.publishedPoiId());
        }
        if ((action.equals("SUSPEND") || action.equals("RESTORE_APPROVAL")) && before.publishedPoiId() != null) {
            jdbc.update("UPDATE geo.point_of_interest SET active=false,updated_at=now() WHERE id=?", before.publishedPoiId());
        }
        int changed = jdbc.update("""
                UPDATE admin.poi_editorial_record SET editorial_state=?,
                    active=CASE WHEN ? IN ('ARCHIVED','OBSERVED','REJECTED','SUSPENDED','APPROVED') THEN FALSE ELSE active END,
                    published_poi_id=CASE WHEN ? IN ('APPROVED','PUBLISHED') THEN COALESCE(target_poi_id,id) ELSE published_poi_id END,
                    version=version+1, updated_at=now()
                WHERE id=? AND version=?
                """, next, next, next, id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Editorial record changed concurrently.");
        EditorialView after=find(id).orElseThrow();
        audit(id, actor, action, reason, before.state(), next, expectedVersion + 1,
                json(java.util.Map.of("decisionEvidence", evidence.trim(),
                        "publishedPoiId",after.publishedPoiId()==null?"":after.publishedPoiId().toString())));
        return after;
    }

    private void publish(EditorialView record) {
        UUID categoryId = jdbc.query("SELECT id FROM geo.category WHERE code=? AND active", (rs, row) -> rs.getObject(1, UUID.class), record.categoryCode())
                .stream().findFirst().orElseThrow(() -> new IllegalStateException("Category code is not an active P3 category."));
        if (record.targetPoiId() != null) {
            int updated = jdbc.update("""
                    UPDATE geo.point_of_interest SET category_id=?,name=?,description=?,
                        location=ST_SetSRID(ST_MakePoint(?,?),4326),active=false,updated_at=now()
                    WHERE id=?
                    """, categoryId, record.name(), record.description(), record.longitude(), record.latitude(), record.targetPoiId());
            if (updated != 1) throw new EditorialWorkflowConflictException("The existing POI change request target no longer exists.");
            return;
        }
        UUID poiId = record.id();
        int exists = jdbc.queryForObject("SELECT count(*) FROM geo.point_of_interest WHERE id=?", Integer.class, poiId);
        if (exists != 0) throw new IllegalStateException("Candidate UUID already exists in the public POI catalog.");
        jdbc.update("""
                INSERT INTO geo.point_of_interest(id,category_id,name,description,location,active,created_at,updated_at)
                VALUES (?,?,?,?,ST_SetSRID(ST_MakePoint(?,?),4326),false,now(),now())
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

    @Transactional
    public EditorialView setActivation(UUID id, long expectedVersion, boolean active, String actor, String reason, String evidence) {
        if (reason == null || reason.isBlank() || evidence == null || evidence.isBlank())
            throw new IllegalArgumentException("Activation reason and evidence are required.");
        EditorialView before = find(id).orElseThrow(() -> new IllegalArgumentException("Editorial record not found."));
        if (before.version() != expectedVersion) throw new EditorialWorkflowConflictException("Editorial record version is stale.");
        if (active) {
            if (!before.state().equals("APPROVED") || before.publishedPoiId() == null
                    || !before.geographicReviewStatus().equals("APPROVED")
                    || !before.identityReviewStatus().equals("NO_DUPLICATE")
                    || before.sourceLicense() == null || before.sourceLicense().isBlank()
                    || before.sourceAttribution() == null || before.sourceAttribution().isBlank())
                throw new EditorialWorkflowConflictException("Only approved, geographically and identity-reviewed records with documented provenance can be activated.");
            if (before.importRecordId() == null && before.targetPoiId() == null) {
                ensureManualRecordIsNotThematicallyExcluded(before.name());
            } else if (before.importRecordId() != null) {
                Integer eligible = jdbc.queryForObject("SELECT count(*) FROM geo.mincetur_import_record WHERE id=? AND thematic_eligibility='ELIGIBLE_FOR_REVIEW' AND record_status='NORMALIZED_PENDING_REVIEW'",
                        Integer.class, before.importRecordId());
                if (eligible == null || eligible != 1) throw new EditorialWorkflowConflictException("The MINCETUR candidate is not publication eligible.");
            } else {
                Integer excluded = jdbc.queryForObject("""
                        SELECT count(*) FROM geo.poi_provenance prov JOIN geo.mincetur_import_record r
                          ON prov.source_system='MINCETUR_INVENTARIO' AND prov.source_record_id=r.source_record_id
                        WHERE prov.poi_id=? AND r.thematic_eligibility='EXCLUDED_FROM_NAVIGATION'
                        """, Integer.class, before.targetPoiId());
                if (excluded != null && excluded > 0) throw new EditorialWorkflowConflictException("The existing POI has an excluded MINCETUR source and cannot be activated.");
            }
        } else if (!List.of("APPROVED", "PUBLISHED", "SUSPENDED").contains(before.state())) {
            throw new EditorialWorkflowConflictException("Only an approved or legacy published POI can be deactivated.");
        }
        int poiChanged = jdbc.update("""
                UPDATE geo.point_of_interest p SET active=?,updated_at=now()
                WHERE p.id=? AND (?=FALSE OR EXISTS (SELECT 1 FROM geo.category c WHERE c.id=p.category_id AND c.active))
                  AND (?=FALSE OR NOT EXISTS (
                    SELECT 1 FROM geo.poi_provenance prov JOIN geo.mincetur_import_record r
                      ON prov.source_system='MINCETUR_INVENTARIO' AND prov.source_record_id=r.source_record_id
                    WHERE prov.poi_id=p.id AND r.thematic_eligibility='EXCLUDED_FROM_NAVIGATION'))
                """, active, before.publishedPoiId(), active, active);
        if (poiChanged != 1) throw new EditorialWorkflowConflictException("POI activation is blocked by missing catalog entry, inactive category, or thematic exclusion.");
        int changed = jdbc.update("UPDATE admin.poi_editorial_record SET active=?,version=version+1,updated_at=now() WHERE id=? AND version=?",
                active, id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Editorial record changed concurrently.");
        EditorialView after = find(id).orElseThrow();
        jdbc.update("""
                INSERT INTO admin.poi_activation_audit(id,poi_id,actor_id,action,reason,evidence,previous_active,next_active)
                VALUES (?,?,?,?,?,?,?,?)
                """, UUID.randomUUID(), before.publishedPoiId(), actor, active ? "ACTIVATE" : "DEACTIVATE",
                reason.trim(), evidence.trim(), before.active(), active);
        audit(id, actor, active ? "ACTIVATE" : "DEACTIVATE", reason, before.state(), after.state(), expectedVersion + 1,
                json(java.util.Map.of("evidence", evidence.trim(), "active", active, "poiId", before.publishedPoiId().toString())));
        return after;
    }

    private void ensureManualRecordIsNotThematicallyExcluded(String name) {
        String normalizedName = Destination.normalize(name);
        List<String> excludedNames = jdbc.query("""
                SELECT r.raw_fields->>'NOMBRE DEL RECURSO'
                FROM geo.mincetur_import_record r
                WHERE r.thematic_eligibility='EXCLUDED_FROM_NAVIGATION'
                  AND r.raw_fields->>'NOMBRE DEL RECURSO' IS NOT NULL
                """, (rs, row) -> rs.getString(1));
        if (excludedNames.stream().anyMatch(excluded -> Destination.normalize(excluded).equals(normalizedName))) {
            throw new EditorialWorkflowConflictException(
                    "A manually created POI exactly matches a MINCETUR resource excluded from navigation and cannot be published through the manual workflow.");
        }
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
                rs.getString("identity_review_status"), rs.getString("identity_review_evidence"),
                rs.getString("editorial_state"), rs.getString("source_license"), rs.getString("source_attribution"),
                rs.getString("source_url"), rs.getObject("published_poi_id", UUID.class), rs.getBoolean("active"),
                rs.getObject("target_poi_id", UUID.class), rs.getLong("version"));
    }

    public record CreateEditorial(UUID importRecordId, String name, String description, String categoryCode,
            BigDecimal latitude, BigDecimal longitude,String rawLatitude,String rawLongitude,String normalizationRule,
            String coordinateEvidence,String sourceLicense, String sourceAttribution, String administrativeContext) {
        public CreateEditorial(UUID importRecordId, String name, String description, String categoryCode,
                BigDecimal latitude, BigDecimal longitude, String rawLatitude, String rawLongitude,
                String normalizationRule, String coordinateEvidence, String sourceLicense, String sourceAttribution) {
            this(importRecordId, name, description, categoryCode, latitude, longitude, rawLatitude, rawLongitude,
                    normalizationRule, coordinateEvidence, sourceLicense, sourceAttribution, null);
        }
    }
    public record UpdateEditorial(String name, String description, String categoryCode, BigDecimal latitude,
            BigDecimal longitude,String normalizationRule,String coordinateEvidence, String sourceLicense, String sourceAttribution,
            String administrativeContext) {
        public UpdateEditorial(String name, String description, String categoryCode, BigDecimal latitude,
                BigDecimal longitude, String normalizationRule, String coordinateEvidence, String sourceLicense,
                String sourceAttribution) {
            this(name, description, categoryCode, latitude, longitude, normalizationRule, coordinateEvidence,
                    sourceLicense, sourceAttribution, null);
        }
    }
    public record EditorialView(UUID id, UUID importRecordId, String sourceRecordId, String name, String description,String administrativeContext,
            String categoryCode, BigDecimal latitude, BigDecimal longitude,String rawLatitude,String rawLongitude,
             String normalizationRule,String coordinateEvidence,String geographicReviewStatus,String identityReviewStatus,
             String identityReviewEvidence,
            String state, String sourceLicense, String sourceAttribution, String sourceUrl, UUID publishedPoiId, boolean active,
            UUID targetPoiId, long version) {}
    public record DuplicateCandidate(String entityType,UUID entityId, String name, Double distanceMeters) {}
    public record Page<T>(List<T> content,int page,int size,long totalElements){public int totalPages(){return (int)Math.ceil((double)totalElements/size);}}
}
