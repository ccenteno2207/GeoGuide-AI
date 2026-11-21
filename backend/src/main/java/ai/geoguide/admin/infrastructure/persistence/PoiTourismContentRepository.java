package ai.geoguide.admin.infrastructure.persistence;

import ai.geoguide.admin.domain.PoiTourismContent;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class PoiTourismContentRepository {
    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper;

    public PoiTourismContentRepository(JdbcTemplate jdbc, ObjectMapper mapper) {
        this.jdbc = jdbc;
        this.mapper = mapper;
    }

    public AdminContent getAdmin(UUID poiId) {
        requirePoi(poiId, false);
        Working working = working(poiId).orElse(null);
        Published published = published(poiId).orElse(null);
        List<RevisionSummary> history = jdbc.query("""
                SELECT id, version, state, created_by, created_at
                FROM admin.poi_content_revision WHERE poi_id=? ORDER BY version DESC LIMIT 50
                """, (rs, row) -> new RevisionSummary(rs.getObject("id", UUID.class), rs.getLong("version"),
                rs.getString("state"), rs.getString("created_by"), rs.getTimestamp("created_at").toInstant()), poiId);
        return new AdminContent(poiId, working == null ? 0 : working.version(),
                working == null ? "NONE" : working.state(), working == null ? PoiTourismContent.empty() : working.content(),
                published == null ? null : published.version(), published == null ? PoiTourismContent.empty() : published.content(),
                published == null ? null : published.publishedAt(), history);
    }

    public PublicContent getPublic(UUID poiId) {
        requirePoi(poiId, true);
        Published published = published(poiId).orElse(null);
        List<PublicPhoto> photos = jdbc.query("""
                SELECT id, alt_text, display_order, is_primary, author, attribution, license
                FROM media.poi_asset WHERE poi_id=? AND review_state='PUBLISHED'
                ORDER BY is_primary DESC, display_order, created_at, id
                """, (rs, row) -> new PublicPhoto(rs.getObject("id", UUID.class),
                "/api/v1/pois/" + poiId + "/media/" + rs.getObject("id", UUID.class) + "/content",
                rs.getString("alt_text"), rs.getBoolean("is_primary"), rs.getInt("display_order"),
                rs.getString("author"), rs.getString("attribution"), rs.getString("license")), poiId);
        return new PublicContent(poiId, published == null ? null : published.version(),
                published == null ? null : published.publishedAt(), published == null ? PoiTourismContent.empty() : published.content(), photos);
    }

    @Transactional
    public AdminContent saveDraft(UUID poiId, long expectedVersion, PoiTourismContent content, String actor, String reason) {
        requireActorReason(actor, reason);
        lockPoi(poiId);
        Working before = working(poiId).orElse(null);
        long currentVersion = before == null ? 0 : before.version();
        if (currentVersion != expectedVersion) throw new PoiContentConflictException("Tourism content changed; reload it before saving.");
        if (before != null && "PENDING_REVIEW".equals(before.state())) {
            throw new PoiContentConflictException("Content is pending review; it cannot be edited until the review is resolved.");
        }
        long nextVersion = currentVersion + 1;
        UUID revisionId = UUID.randomUUID();
        String json = toJson(content);
        jdbc.update("""
                INSERT INTO admin.poi_content_revision(id,poi_id,version,state,content,created_by)
                VALUES (?,?,?,'DRAFT',?::jsonb,?)
                """, revisionId, poiId, nextVersion, json, actor.strip());
        jdbc.update("""
                INSERT INTO admin.poi_content_working_set(poi_id,revision_id,version,updated_at)
                VALUES (?,?,?,now())
                ON CONFLICT (poi_id) DO UPDATE SET revision_id=EXCLUDED.revision_id, version=EXCLUDED.version, updated_at=now()
                """, poiId, revisionId, nextVersion);
        audit(poiId, revisionId, actor, "SAVE_DRAFT", reason, nextVersion,
                before == null ? null : before.state(), "DRAFT", before == null ? null : before.content(), content);
        return getAdmin(poiId);
    }

    @Transactional
    public AdminContent submit(UUID poiId, long expectedVersion, String actor, String reason) {
        requireActorReason(actor, reason);
        lockPoi(poiId);
        Working current = requireWorking(poiId, expectedVersion);
        if (!"DRAFT".equals(current.state())) throw new PoiContentConflictException("Only a saved draft can be submitted for review.");
        int changed = jdbc.update("""
                UPDATE admin.poi_content_revision SET state='PENDING_REVIEW', reviewed_by=?, reviewed_at=now(), review_reason=?
                WHERE id=? AND state='DRAFT'
                """, actor.strip(), reason.strip(), current.revisionId());
        if (changed != 1) throw new PoiContentConflictException("Content changed while it was being submitted.");
        audit(poiId, current.revisionId(), actor, "SUBMIT", reason, current.version(), "DRAFT", "PENDING_REVIEW", current.content(), current.content());
        return getAdmin(poiId);
    }

    @Transactional
    public AdminContent publish(UUID poiId, long expectedVersion, String actor, String reason) {
        requireActorReason(actor, reason);
        lockPoi(poiId);
        Working current = requireWorking(poiId, expectedVersion);
        if (!"PENDING_REVIEW".equals(current.state())) throw new PoiContentConflictException("Only content pending review can be published.");
        int changed = jdbc.update("""
                UPDATE admin.poi_content_revision SET state='PUBLISHED', reviewed_by=?, reviewed_at=now(), review_reason=?
                WHERE id=? AND state='PENDING_REVIEW'
                """, actor.strip(), reason.strip(), current.revisionId());
        if (changed != 1) throw new PoiContentConflictException("Content changed while it was being published.");
        jdbc.update("UPDATE admin.poi_content_revision SET state='SUPERSEDED' WHERE poi_id=? AND id<>? AND state='PUBLISHED'",
                poiId, current.revisionId());
        jdbc.update("""
                INSERT INTO geo.poi_published_content(poi_id,revision_id,version,content,published_by,published_at)
                SELECT poi_id,id,version,content,?,now() FROM admin.poi_content_revision WHERE id=?
                ON CONFLICT (poi_id) DO UPDATE SET revision_id=EXCLUDED.revision_id,version=EXCLUDED.version,
                    content=EXCLUDED.content,published_by=EXCLUDED.published_by,published_at=now()
                """, actor.strip(), current.revisionId());
        audit(poiId, current.revisionId(), actor, "PUBLISH", reason, current.version(), "PENDING_REVIEW", "PUBLISHED", current.content(), current.content());
        return getAdmin(poiId);
    }

    @Transactional
    public AdminContent revertTo(UUID poiId, UUID targetRevisionId, long expectedVersion, String actor, String reason) {
        requireActorReason(actor, reason);
        lockPoi(poiId);
        Working before = requireWorking(poiId, expectedVersion);
        PoiTourismContent target = jdbc.query("SELECT content::text FROM admin.poi_content_revision WHERE id=? AND poi_id=?",
                (rs, row) -> fromJson(rs.getString(1)), targetRevisionId, poiId).stream().findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Content revision not found for this POI."));
        long nextVersion = before.version() + 1;
        UUID revisionId = UUID.randomUUID();
        jdbc.update("INSERT INTO admin.poi_content_revision(id,poi_id,version,state,content,created_by) VALUES (?,?,?,'DRAFT',?::jsonb,?)",
                revisionId, poiId, nextVersion, toJson(target), actor.strip());
        jdbc.update("UPDATE admin.poi_content_working_set SET revision_id=?,version=?,updated_at=now() WHERE poi_id=? AND version=?",
                revisionId, nextVersion, poiId, expectedVersion);
        audit(poiId, revisionId, actor, "REVERT_TO_REVISION", reason, nextVersion, before.state(), "DRAFT", before.content(), target);
        return getAdmin(poiId);
    }

    private Working requireWorking(UUID poiId, long expectedVersion) {
        Working value = working(poiId).orElseThrow(() -> new PoiContentConflictException("No saved content draft exists."));
        if (value.version() != expectedVersion) throw new PoiContentConflictException("Tourism content version is stale; reload it before continuing.");
        return value;
    }

    private Optional<Working> working(UUID poiId) {
        return jdbc.query("""
                SELECT w.revision_id,w.version,r.state,r.content::text AS content
                FROM admin.poi_content_working_set w JOIN admin.poi_content_revision r ON r.id=w.revision_id
                WHERE w.poi_id=?
                """, (rs, row) -> new Working(rs.getObject("revision_id", UUID.class), rs.getLong("version"),
                rs.getString("state"), fromJson(rs.getString("content"))), poiId).stream().findFirst();
    }

    private Optional<Published> published(UUID poiId) {
        return jdbc.query("SELECT version,content::text AS content,published_at FROM geo.poi_published_content WHERE poi_id=?",
                (rs, row) -> new Published(rs.getLong("version"), fromJson(rs.getString("content")), rs.getTimestamp("published_at").toInstant()), poiId).stream().findFirst();
    }

    private void lockPoi(UUID poiId) {
        jdbc.query("SELECT id FROM geo.point_of_interest WHERE id=? FOR UPDATE", (rs, row) -> rs.getObject(1), poiId)
                .stream().findFirst().orElseThrow(() -> new IllegalArgumentException("POI not found."));
    }

    private void requirePoi(UUID poiId, boolean activeOnly) {
        String sql = activeOnly ? "SELECT id FROM geo.point_of_interest WHERE id=? AND active=TRUE" :
                "SELECT id FROM geo.point_of_interest WHERE id=?";
        jdbc.query(sql, (rs, row) -> rs.getObject(1), poiId).stream().findFirst()
                .orElseThrow(() -> new IllegalArgumentException("POI not found."));
    }

    private void audit(UUID poiId, UUID revisionId, String actor, String action, String reason, long version,
            String beforeState, String afterState, PoiTourismContent before, PoiTourismContent after) {
        jdbc.update("""
                INSERT INTO admin.poi_content_audit(id,poi_id,revision_id,actor_id,action,reason,version,before_state,after_state,before_content,after_content)
                VALUES (?,?,?,?,?,?,?,?,?,?::jsonb,?::jsonb)
                """, UUID.randomUUID(), poiId, revisionId, actor.strip(), action, reason.strip(), version,
                beforeState, afterState, before == null ? null : toJson(before), after == null ? null : toJson(after));
    }

    private static void requireActorReason(String actor, String reason) {
        if (actor == null || actor.isBlank()) throw new IllegalArgumentException("Authenticated actor is required.");
        if (reason == null || reason.isBlank()) throw new IllegalArgumentException("An audit reason is required.");
    }

    private String toJson(PoiTourismContent content) {
        try { return mapper.writeValueAsString(content); }
        catch (JsonProcessingException ex) { throw new IllegalStateException("Tourism content could not be serialized.", ex); }
    }

    private PoiTourismContent fromJson(String json) {
        try { return mapper.readValue(json, PoiTourismContent.class); }
        catch (Exception ex) { throw new IllegalStateException("Stored tourism content is invalid.", ex); }
    }

    public record AdminContent(UUID poiId, long draftVersion, String draftState, PoiTourismContent draftContent,
            Long publishedVersion, PoiTourismContent publishedContent, Instant publishedAt, List<RevisionSummary> revisions) { }
    public record PublicContent(UUID poiId, Long publishedVersion, Instant publishedAt, PoiTourismContent content, List<PublicPhoto> photos) { }
    public record PublicPhoto(UUID id, String path, String altText, boolean primary, int displayOrder,
            String author, String attribution, String license) { }
    public record RevisionSummary(UUID id, long version, String state, String createdBy, Instant createdAt) { }
    private record Working(UUID revisionId, long version, String state, PoiTourismContent content) { }
    private record Published(long version, PoiTourismContent content, Instant publishedAt) { }

    public static final class PoiContentConflictException extends RuntimeException {
        public PoiContentConflictException(String message) { super(message); }
    }
}
