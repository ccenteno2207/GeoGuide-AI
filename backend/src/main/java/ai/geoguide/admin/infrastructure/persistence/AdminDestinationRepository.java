package ai.geoguide.admin.infrastructure.persistence;

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

/** Independent editorial workflow for search destinations; never publishes a POI implicitly. */
@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class AdminDestinationRepository {
    private static final BigDecimal LAT_MIN = new BigDecimal("-18.5");
    private static final BigDecimal LAT_MAX = BigDecimal.ZERO;
    private static final BigDecimal LON_MIN = new BigDecimal("-82.5");
    private static final BigDecimal LON_MAX = new BigDecimal("-68.0");

    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;

    public AdminDestinationRepository(JdbcTemplate jdbc, ObjectMapper objectMapper) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
    }

    public Page<DestinationEditorialView> list(String state, String query, int page, int size) {
        int safePage = Math.max(0, Math.min(page, 1_000_000));
        int safeSize = Math.max(1, Math.min(size, 100));
        int offset = safePage * safeSize;
        long total = jdbc.queryForObject("""
                SELECT count(*) FROM admin.destination_editorial_record
                WHERE (CAST(? AS VARCHAR) IS NULL OR editorial_state = ?)
                  AND (CAST(? AS TEXT) IS NULL OR canonical_name ILIKE '%' || ? || '%' OR source_record_id = ?)
                """, Long.class, state, state, query, query, query);
        List<DestinationEditorialView> rows = jdbc.query("""
                SELECT * FROM admin.destination_editorial_record
                WHERE (CAST(? AS VARCHAR) IS NULL OR editorial_state = ?)
                  AND (CAST(? AS TEXT) IS NULL OR canonical_name ILIKE '%' || ? || '%' OR source_record_id = ?)
                ORDER BY updated_at DESC, id LIMIT ? OFFSET ?
                """, this::map, state, state, query, query, query, safeSize, offset);
        return new Page<>(rows, safePage, safeSize, total);
    }

    public Optional<DestinationEditorialView> find(UUID id) {
        return jdbc.query("SELECT * FROM admin.destination_editorial_record WHERE id=?", this::map, id)
                .stream().findFirst();
    }

    @Transactional
    public DestinationEditorialView createFromImport(UUID importRecordId, String destinationType,
            String sourceLicense, String sourceAttribution, String actor) {
        if (blank(destinationType)) throw new IllegalArgumentException("Destination type is required.");
        UUID id = UUID.randomUUID();
        int inserted = jdbc.update("""
                INSERT INTO admin.destination_editorial_record(id, import_record_id, source_record_id,
                    canonical_name, destination_type, administrative_context, latitude, longitude,
                    raw_latitude, raw_longitude, coordinate_normalization_rule, coordinate_validation_evidence,
                    source_url, source_license, source_attribution, created_by)
                SELECT ?, r.id, r.source_record_id, r.raw_fields->>'NOMBRE DEL RECURSO', ?,
                    concat_ws(' — ', r.raw_fields->>'DISTRITO', r.raw_fields->>'PROVINCIA', r.raw_fields->>'REGIÓN'),
                    r.normalized_latitude, r.normalized_longitude, r.raw_latitude, r.raw_longitude,
                    r.normalization_rule, r.validation_evidence, nullif(r.raw_fields->>'URL',''), ?, ?, ?
                FROM geo.mincetur_import_record r
                WHERE r.id=? AND r.record_status='NORMALIZED_PENDING_REVIEW'
                  AND r.normalized_latitude IS NOT NULL AND r.normalized_longitude IS NOT NULL
                ON CONFLICT (import_record_id) DO NOTHING
                """, id, destinationType.trim(), sourceLicense, sourceAttribution, actor, importRecordId);
        if (inserted != 1) throw new EditorialWorkflowConflictException(
                "Import record is absent, quarantined, or already has a destination candidate.");
        audit(id, actor, "CREATE_FROM_IMPORT", "Destination candidate created from immutable MINCETUR staging row.",
                null, "DRAFT", 0, "{\"source\":\"MINCETUR\"}");
        return find(id).orElseThrow();
    }

    @Transactional
    public DestinationEditorialView create(CreateDestination command, String actor) {
        requireText(command.canonicalName(), "Destination name");
        requireText(command.destinationType(), "Destination type");
        requireText(command.administrativeContext(), "Administrative context");
        UUID id = UUID.randomUUID();
        jdbc.update("""
                INSERT INTO admin.destination_editorial_record(id, canonical_name, destination_type,
                    administrative_context, latitude, longitude, raw_latitude, raw_longitude,
                    coordinate_normalization_rule, coordinate_validation_evidence, source_url,
                    source_license, source_attribution, source_record_id, created_by)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                """, id, command.canonicalName().trim(), command.destinationType().trim(),
                command.administrativeContext().trim(), command.latitude(), command.longitude(),
                command.rawLatitude(), command.rawLongitude(), command.normalizationRule(),
                command.coordinateEvidence(), command.sourceUrl(), command.sourceLicense(),
                command.sourceAttribution(), command.sourceRecordId(), actor);
        audit(id, actor, "CREATE", "Destination candidate created.", null, "DRAFT", 0, "{}");
        return find(id).orElseThrow();
    }

    @Transactional
    public DestinationEditorialView update(UUID id, long expectedVersion, UpdateDestination command,
            String actor, String reason) {
        requireReason(reason);
        DestinationEditorialView before = find(id).orElseThrow(() -> new IllegalArgumentException("Destination candidate not found."));
        int changed = jdbc.update("""
                UPDATE admin.destination_editorial_record SET canonical_name=?, destination_type=?,
                    administrative_context=?, latitude=?, longitude=?, coordinate_normalization_rule=?,
                    coordinate_validation_evidence=?, source_url=?, source_license=?, source_attribution=?,
                    geographic_review_status='PENDING', geographic_review_actor=NULL, geographic_reviewed_at=NULL,
                    geographic_review_reason=NULL, identity_review_status='PENDING', identity_review_actor=NULL,
                    identity_reviewed_at=NULL, identity_review_reason=NULL, identity_review_evidence=NULL,
                    access_review_status='PENDING',
                    access_review_actor=NULL, access_reviewed_at=NULL, access_review_reason=NULL,
                    access_review_evidence=NULL, version=version+1, updated_at=now()
                WHERE id=? AND version=? AND editorial_state IN ('DRAFT','REJECTED')
                """, command.canonicalName().trim(), command.destinationType().trim(),
                command.administrativeContext().trim(), command.latitude(), command.longitude(),
                command.normalizationRule(), command.coordinateEvidence(), command.sourceUrl(),
                command.sourceLicense(), command.sourceAttribution(), id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Destination candidate is stale or not editable.");
        DestinationEditorialView after = find(id).orElseThrow();
        audit(id, actor, "UPDATE", reason, before.state(), after.state(), expectedVersion + 1,
                json(java.util.Map.of("before", before, "after", after)));
        return after;
    }

    @Transactional
    public DestinationEditorialView reviewGeography(UUID id, long expectedVersion, boolean approve,
            String actor, String reason) {
        requireReason(reason);
        if (approve) find(id).filter(r -> peruPoint(r.latitude(), r.longitude()))
                .orElseThrow(() -> new EditorialWorkflowConflictException("Geographic review requires a plausible Peru coordinate."));
        int changed = jdbc.update("""
                UPDATE admin.destination_editorial_record SET geographic_review_status=?,
                    geographic_review_actor=?, geographic_reviewed_at=now(), geographic_review_reason=?,
                    version=version+1, updated_at=now()
                WHERE id=? AND version=? AND editorial_state IN ('DRAFT','REJECTED')
                  AND latitude IS NOT NULL AND longitude IS NOT NULL
                  AND coordinate_validation_evidence IS NOT NULL AND btrim(coordinate_validation_evidence)<>''
                """, approve ? "APPROVED" : "REJECTED", actor, reason, id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Geographic review is stale or lacks coordinate evidence.");
        DestinationEditorialView after = find(id).orElseThrow();
        audit(id, actor, approve ? "GEOGRAPHY_APPROVED" : "GEOGRAPHY_REJECTED", reason,
                null, null, expectedVersion + 1, json(java.util.Map.of("coordinateEvidence", after.coordinateEvidence())));
        return after;
    }

    @Transactional
    public DestinationEditorialView reviewIdentity(UUID id, long expectedVersion, boolean noDuplicate,
            String actor, String reason, String evidence) {
        requireReason(reason);
        requireText(evidence, "Identity review evidence");
        int changed = jdbc.update("""
                UPDATE admin.destination_editorial_record SET identity_review_status=?, identity_review_actor=?,
                    identity_reviewed_at=now(), identity_review_reason=?, identity_review_evidence=?,
                    version=version+1, updated_at=now()
                WHERE id=? AND version=? AND editorial_state IN ('DRAFT','REJECTED')
                """, noDuplicate ? "NO_DUPLICATE" : "MATCH_FOUND", actor, reason, evidence.trim(), id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Identity review is stale or not editable.");
        DestinationEditorialView after = find(id).orElseThrow();
        audit(id, actor, noDuplicate ? "NO_DUPLICATE_CONFIRMED" : "POTENTIAL_DUPLICATE_FOUND", reason,
                null, null, expectedVersion + 1, json(java.util.Map.of("evidence", evidence.trim())));
        return after;
    }

    @Transactional
    public DestinationEditorialView reviewAccess(UUID id, long expectedVersion, boolean approved,
            String actor, String reason, String evidence) {
        requireReason(reason);
        requireText(evidence, "Access review evidence");
        int changed = jdbc.update("""
                UPDATE admin.destination_editorial_record SET access_review_status=?, access_review_actor=?,
                    access_reviewed_at=now(), access_review_reason=?, access_review_evidence=?,
                    version=version+1, updated_at=now()
                WHERE id=? AND version=? AND editorial_state IN ('DRAFT','REJECTED')
                  AND geographic_review_status='APPROVED' AND latitude IS NOT NULL AND longitude IS NOT NULL
                """, approved ? "APPROVED" : "REJECTED", actor, reason, evidence.trim(), id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Access review requires current geographic approval and version.");
        DestinationEditorialView after = find(id).orElseThrow();
        audit(id, actor, approved ? "ACCESS_APPROVED" : "ACCESS_REJECTED", reason,
                null, null, expectedVersion + 1, json(java.util.Map.of("evidence", evidence.trim())));
        return after;
    }

    @Transactional
    public DestinationEditorialView transition(UUID id, long expectedVersion, String action,
            String actor, String reason, String evidence) {
        requireReason(reason);
        requireText(evidence, "Decision evidence");
        DestinationEditorialView before = find(id).orElseThrow(() -> new IllegalArgumentException("Destination candidate not found."));
        if (before.version() != expectedVersion) throw new EditorialWorkflowConflictException("Destination candidate version is stale.");
        String next = switch (action) {
            case "SUBMIT_FOR_REVIEW" -> {
                if (!List.of("DRAFT", "REJECTED").contains(before.state())) throw new EditorialWorkflowConflictException("Only draft or rejected candidates can be submitted.");
                if (!"APPROVED".equals(before.geographicReviewStatus())
                        || !"NO_DUPLICATE".equals(before.identityReviewStatus())
                        || !"APPROVED".equals(before.accessReviewStatus())) {
                    throw new EditorialWorkflowConflictException("Geography, identity and access reviews must be complete before submission.");
                }
                requireText(before.sourceLicense(), "Source license");
                requireText(before.sourceAttribution(), "Source attribution");
                yield "PENDING_REVIEW";
            }
            case "APPROVE" -> {
                if (!"PENDING_REVIEW".equals(before.state())
                        || !"APPROVED".equals(before.geographicReviewStatus())
                        || !"NO_DUPLICATE".equals(before.identityReviewStatus())
                        || !"APPROVED".equals(before.accessReviewStatus())) {
                    throw new EditorialWorkflowConflictException("Geography, identity and access approvals are independently required.");
                }
                requireText(before.sourceLicense(), "Source license");
                requireText(before.sourceAttribution(), "Source attribution");
                publishDestination(before);
                yield "PUBLISHED";
            }
            case "REJECT" -> {
                if (!"PENDING_REVIEW".equals(before.state())) throw new EditorialWorkflowConflictException("Only pending candidates can be rejected.");
                yield "REJECTED";
            }
            case "ARCHIVE" -> {
                if (!List.of("PUBLISHED", "REJECTED", "DRAFT").contains(before.state())) throw new EditorialWorkflowConflictException("Candidate cannot be archived in this state.");
                yield "ARCHIVED";
            }
            default -> throw new IllegalArgumentException("Unknown destination editorial action.");
        };
        if ("ARCHIVE".equals(action) && before.publishedDestinationId() != null) {
            jdbc.update("UPDATE geo.destination SET active=false WHERE id=?", before.publishedDestinationId());
        }
        int changed = jdbc.update("""
                UPDATE admin.destination_editorial_record SET editorial_state=?,
                    published_destination_id=CASE WHEN ?='PUBLISHED' THEN id ELSE published_destination_id END,
                    version=version+1, updated_at=now() WHERE id=? AND version=?
                """, next, next, id, expectedVersion);
        if (changed != 1) throw new EditorialWorkflowConflictException("Destination candidate changed concurrently.");
        DestinationEditorialView after = find(id).orElseThrow();
        audit(id, actor, action, reason, before.state(), next, expectedVersion + 1,
                json(java.util.Map.of("evidence", evidence.trim(), "publishedDestinationId",
                        after.publishedDestinationId() == null ? "" : after.publishedDestinationId().toString())));
        return after;
    }

    public List<DuplicateCandidate> duplicates(UUID id) {
        return jdbc.query("""
                SELECT 'DESTINATION' AS entity_type, d.id AS entity_id, d.canonical_name AS name,
                    ST_Distance(d.location::geography, ST_SetSRID(ST_MakePoint(e.longitude,e.latitude),4326)::geography) AS distance_m
                FROM admin.destination_editorial_record e JOIN geo.destination d ON d.active
                WHERE e.id=? AND e.latitude BETWEEN -90 AND 90 AND e.longitude BETWEEN -180 AND 180
                  AND (lower(trim(d.canonical_name))=lower(trim(e.canonical_name))
                    OR (d.source_system='MINCETUR' AND d.source_record_id=e.source_record_id)
                    OR ST_DWithin(d.location::geography,ST_SetSRID(ST_MakePoint(e.longitude,e.latitude),4326)::geography,1000))
                UNION ALL
                SELECT 'POI', p.id, p.name,
                    ST_Distance(p.location::geography,ST_SetSRID(ST_MakePoint(e.longitude,e.latitude),4326)::geography)
                FROM admin.destination_editorial_record e JOIN geo.point_of_interest p ON p.active
                WHERE e.id=? AND e.latitude BETWEEN -90 AND 90 AND e.longitude BETWEEN -180 AND 180
                  AND (lower(trim(p.name))=lower(trim(e.canonical_name)) OR ST_DWithin(p.location::geography,
                      ST_SetSRID(ST_MakePoint(e.longitude,e.latitude),4326)::geography,1000))
                ORDER BY distance_m NULLS LAST LIMIT 50
                """, (rs, n) -> new DuplicateCandidate(rs.getString("entity_type"),
                rs.getObject("entity_id", UUID.class), rs.getString("name"), rs.getObject("distance_m", Double.class)), id, id);
    }

    private void publishDestination(DestinationEditorialView record) {
        String sourceId = record.sourceRecordId() == null ? "editorial:" + record.id() : record.sourceRecordId();
        String sourceSystem = record.sourceRecordId() == null ? "ADMIN_CURATED" : "MINCETUR";
        jdbc.update("""
                INSERT INTO geo.destination(id,canonical_name,normalized_name,destination_type,administrative_context,
                    location,source_system,source_record_id,source_url,source_license,attribution,verified_at,catalog_version,active)
                VALUES (?,?,?,?,?,ST_SetSRID(ST_MakePoint(?,?),4326),?,?,?,?,?,CURRENT_DATE,'poi-catalog-1-v1',true)
                """, record.id(), record.canonicalName(), Destination.normalize(record.canonicalName()),
                record.destinationType(), record.administrativeContext(), record.longitude(), record.latitude(),
                sourceSystem, sourceId, record.sourceUrl(), record.sourceLicense(), record.sourceAttribution());
    }

    private void audit(UUID id, String actor, String action, String reason, String previous, String next,
            long version, String details) {
        jdbc.update("""
                INSERT INTO admin.destination_editorial_audit(id,destination_editorial_id,actor_id,action,reason,
                    previous_state,next_state,version,details) VALUES (?,?,?,?,?,?,?, ?,?::jsonb)
                """, UUID.randomUUID(), id, actor, action, reason, previous, next, version, details);
    }

    private String json(Object value) {
        try { return objectMapper.writeValueAsString(value); }
        catch (JsonProcessingException e) { throw new IllegalStateException("Could not serialize destination audit evidence.", e); }
    }

    private DestinationEditorialView map(ResultSet rs, int row) throws SQLException {
        return new DestinationEditorialView(rs.getObject("id", UUID.class), rs.getObject("import_record_id", UUID.class),
                rs.getString("source_record_id"), rs.getString("canonical_name"), rs.getString("destination_type"),
                rs.getString("administrative_context"), rs.getBigDecimal("latitude"), rs.getBigDecimal("longitude"),
                rs.getString("raw_latitude"), rs.getString("raw_longitude"), rs.getString("coordinate_normalization_rule"),
                rs.getString("coordinate_validation_evidence"), rs.getString("source_url"), rs.getString("source_license"),
                rs.getString("source_attribution"), rs.getString("geographic_review_status"),
                rs.getString("identity_review_status"), rs.getString("identity_review_evidence"),
                rs.getString("access_review_status"),
                rs.getString("access_review_evidence"), rs.getString("editorial_state"),
                rs.getObject("published_destination_id", UUID.class), rs.getLong("version"));
    }

    private static boolean peruPoint(BigDecimal latitude, BigDecimal longitude) {
        return latitude != null && longitude != null && latitude.compareTo(LAT_MIN) >= 0
                && latitude.compareTo(LAT_MAX) <= 0 && longitude.compareTo(LON_MIN) >= 0
                && longitude.compareTo(LON_MAX) <= 0;
    }
    private static void requireReason(String value) { requireText(value, "Audit reason"); }
    private static void requireText(String value, String label) {
        if (blank(value)) throw new IllegalArgumentException(label + " is required.");
    }
    private static boolean blank(String value) { return value == null || value.isBlank(); }

    public record CreateDestination(String canonicalName, String destinationType,
            String administrativeContext, BigDecimal latitude, BigDecimal longitude, String rawLatitude,
            String rawLongitude, String normalizationRule, String coordinateEvidence, String sourceUrl,
            String sourceLicense, String sourceAttribution, String sourceRecordId) {}
    public record UpdateDestination(String canonicalName, String destinationType, String administrativeContext,
            BigDecimal latitude, BigDecimal longitude, String normalizationRule, String coordinateEvidence,
            String sourceUrl, String sourceLicense, String sourceAttribution) {}
    public record DestinationEditorialView(UUID id, UUID importRecordId, String sourceRecordId, String canonicalName,
            String destinationType, String administrativeContext, BigDecimal latitude, BigDecimal longitude,
            String rawLatitude, String rawLongitude, String normalizationRule, String coordinateEvidence,
            String sourceUrl, String sourceLicense, String sourceAttribution, String geographicReviewStatus,
            String identityReviewStatus, String identityReviewEvidence, String accessReviewStatus,
            String accessReviewEvidence, String state,
            UUID publishedDestinationId, long version) {}
    public record DuplicateCandidate(String entityType, UUID entityId, String name, Double distanceMeters) {}
    public record Page<T>(List<T> content, int page, int size, long totalElements) {
        public int totalPages() { return (int) Math.ceil((double) totalElements / size); }
    }
}
