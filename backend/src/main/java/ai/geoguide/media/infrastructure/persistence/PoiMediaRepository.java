package ai.geoguide.media.infrastructure.persistence;

import ai.geoguide.media.domain.PoiMediaWorkflowConflictException;
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

@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class PoiMediaRepository {
    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;
    public PoiMediaRepository(JdbcTemplate jdbc,ObjectMapper objectMapper) { this.jdbc = jdbc; this.objectMapper=objectMapper; }

    @Transactional
    public Asset create(Asset asset, String actor) {
        Integer active = jdbc.query("SELECT 1 FROM geo.point_of_interest WHERE id=? AND active", (rs,n)->rs.getInt(1), asset.poiId()).stream().findFirst().orElse(null);
        if (active == null) throw new IllegalArgumentException("Only an existing active POI can receive media.");
        jdbc.update("""
                INSERT INTO media.poi_asset(id,poi_id,object_key,content_type,sha256,size_bytes,width,height,
                author,source_url,created_by,alt_text,display_order) VALUES (?,?,?,?,?,?,?,?,?,?,?, ?,
                COALESCE((SELECT MAX(display_order)+1 FROM media.poi_asset WHERE poi_id=?),0))""", asset.id(),asset.poiId(),asset.objectKey(),
                asset.contentType(),asset.sha256(),asset.sizeBytes(),asset.width(),asset.height(),asset.author(),asset.sourceUrl(),actor,
                asset.altText(), asset.poiId());
        audit(asset.id(),actor,"UPLOAD","Image uploaded as private draft",null,"DRAFT",
                json(java.util.Map.of("contentType",asset.contentType(),"sha256",asset.sha256(),"sizeBytes",asset.sizeBytes(),"author",asset.author(),"sourceUrl",asset.sourceUrl(),"version",asset.version())));
        return find(asset.id()).orElseThrow();
    }

    public Optional<Asset> find(UUID id) {
        return jdbc.query("SELECT * FROM media.poi_asset WHERE id=?",this::map,id).stream().findFirst();
    }

    public List<Asset> byPoi(UUID poiId) {
        return jdbc.query("SELECT * FROM media.poi_asset WHERE poi_id=? ORDER BY created_at DESC",this::map,poiId);
    }

    public List<AuditEvent> history(UUID assetId) {
        if (find(assetId).isEmpty()) throw new IllegalArgumentException("Media asset not found.");
        return jdbc.query("""
                SELECT actor_id,action,reason,prior_state,next_state,details::text AS details,occurred_at
                FROM media.poi_asset_audit WHERE asset_id=? ORDER BY occurred_at DESC LIMIT 100
                """, (rs, row) -> new AuditEvent(rs.getString("actor_id"), rs.getString("action"),
                rs.getString("reason"), rs.getString("prior_state"), rs.getString("next_state"),
                rs.getString("details"), rs.getTimestamp("occurred_at").toInstant()), assetId);
    }

    public Optional<Asset> primaryPublished(UUID poiId) {
        return jdbc.query("""
                SELECT m.* FROM media.poi_asset m JOIN geo.point_of_interest p ON p.id=m.poi_id
                WHERE m.poi_id=? AND m.review_state='PUBLISHED' AND m.is_primary AND p.active""",this::map,poiId).stream().findFirst();
    }

    public Optional<Asset> publishedPhoto(UUID poiId, UUID assetId) {
        return jdbc.query("""
                SELECT m.* FROM media.poi_asset m JOIN geo.point_of_interest p ON p.id=m.poi_id
                WHERE m.poi_id=? AND m.id=? AND m.review_state='PUBLISHED' AND p.active
                """, this::map, poiId, assetId).stream().findFirst();
    }

    public List<Asset> publishedPhotos(UUID poiId) {
        return jdbc.query("""
                SELECT m.* FROM media.poi_asset m JOIN geo.point_of_interest p ON p.id=m.poi_id
                WHERE m.poi_id=? AND m.review_state='PUBLISHED' AND p.active
                ORDER BY m.is_primary DESC,m.display_order,m.created_at,m.id
                """, this::map, poiId);
    }

    @Transactional
    public List<Asset> reorder(UUID poiId, List<PresentationOrder> requested, String actor, String reason) {
        if (actor == null || actor.isBlank() || reason == null || reason.isBlank())
            throw new IllegalArgumentException("Actor and audit reason are required.");
        jdbc.query("SELECT id FROM geo.point_of_interest WHERE id=? FOR UPDATE", (rs,row)->rs.getObject(1), poiId)
                .stream().findFirst().orElseThrow(() -> new IllegalArgumentException("POI not found."));
        List<Asset> current = byPoi(poiId);
        if (requested.size() != current.size() || requested.stream().map(PresentationOrder::id).distinct().count() != requested.size())
            throw new PoiMediaWorkflowConflictException("The submitted gallery order is incomplete or duplicated.");
        for (PresentationOrder item : requested) {
            Asset asset = current.stream().filter(a -> a.id().equals(item.id())).findFirst()
                    .orElseThrow(() -> new PoiMediaWorkflowConflictException("A photo does not belong to this POI."));
            if (asset.version() != item.expectedVersion()) throw new PoiMediaWorkflowConflictException("A photo changed concurrently; reload the gallery.");
            if (item.displayOrder() < 0) throw new IllegalArgumentException("Photo order must be non-negative.");
        }
        for (PresentationOrder item : requested) {
            Asset old = current.stream().filter(a -> a.id().equals(item.id())).findFirst().orElseThrow();
            if (old.displayOrder() == item.displayOrder()) continue;
            int changed = jdbc.update("UPDATE media.poi_asset SET display_order=?,version=version+1 WHERE id=? AND version=?",
                    item.displayOrder(), item.id(), item.expectedVersion());
            if (changed != 1) throw new PoiMediaWorkflowConflictException("A photo changed concurrently; reload the gallery.");
            audit(item.id(),actor,"REORDER",reason,old.state(),old.state(),json(java.util.Map.of(
                    "from",old.displayOrder(),"to",item.displayOrder(),"version",item.expectedVersion()+1)));
        }
        return byPoi(poiId);
    }

    @Transactional
    public Asset updatePresentation(UUID id, long expectedVersion, String altText, int displayOrder, String actor, String reason) {
        if (altText == null || altText.isBlank() || altText.length() > 500 || displayOrder < 0)
            throw new IllegalArgumentException("A concise alternative description and valid order are required.");
        if (actor == null || actor.isBlank() || reason == null || reason.isBlank())
            throw new IllegalArgumentException("Actor and audit reason are required.");
        Asset before = find(id).orElseThrow(() -> new IllegalArgumentException("Media asset not found."));
        if (before.version() != expectedVersion) throw new PoiMediaWorkflowConflictException("Photo version is stale; reload the gallery.");
        if (!before.state().equals("DRAFT") && !before.state().equals("REJECTED") && !before.state().equals("PUBLISHED"))
            throw new PoiMediaWorkflowConflictException("Photo presentation can be edited only before publication or on a published photo.");
        int changed = jdbc.update("UPDATE media.poi_asset SET alt_text=?,display_order=?,version=version+1 WHERE id=? AND version=?",
                altText.strip(),displayOrder,id,expectedVersion);
        if (changed != 1) throw new PoiMediaWorkflowConflictException("Photo changed concurrently; reload the gallery.");
        audit(id,actor,"PRESENTATION_UPDATED",reason,before.state(),before.state(),json(java.util.Map.of(
                "altText",altText.strip(),"displayOrder",displayOrder,"version",expectedVersion+1)));
        return find(id).orElseThrow();
    }

    @Transactional
    public Asset updateRights(UUID id,long expectedVersion,String license,String attribution,String evidence,String actor,String reason) {
        int n=jdbc.update("""
                UPDATE media.poi_asset SET license=?,attribution=?,rights_evidence_reference=?,
                rights_status='DOCUMENTED',version=version+1 WHERE id=? AND version=? AND review_state IN ('DRAFT','REJECTED')""",
                license,attribution,evidence,id,expectedVersion);
        if(n!=1) throw new PoiMediaWorkflowConflictException("Rights metadata can be edited only on a draft or rejected asset.");
        audit(id,actor,"RIGHTS_DOCUMENTED",reason,null,null,
                json(java.util.Map.of("license",license,"attribution",attribution,"evidenceReference",evidence,"version",expectedVersion+1))); return find(id).orElseThrow();
    }

    @Transactional
    public Asset action(UUID id,long expectedVersion,String action,String actor,String reason,boolean makePrimary) {
        Asset a=find(id).orElseThrow(()->new IllegalArgumentException("Media asset not found."));
        if(a.version()!=expectedVersion)throw new PoiMediaWorkflowConflictException("Media asset version is stale.");
        String next=switch(action){
            case "SUBMIT" -> {if(!a.state().equals("DRAFT")&&!a.state().equals("REJECTED"))throw new PoiMediaWorkflowConflictException("Asset cannot be submitted from current state.");yield "PENDING_REVIEW";}
            case "PUBLISH" -> {if(!a.state().equals("PENDING_REVIEW")||!a.rightsDocumented()||a.altText().isBlank())throw new PoiMediaWorkflowConflictException("Publication requires pending review, documented rights, and alternative text.");yield "PUBLISHED";}
            case "REJECT" -> {if(!a.state().equals("PENDING_REVIEW"))throw new PoiMediaWorkflowConflictException("Only pending media can be rejected.");yield "REJECTED";}
            case "WITHDRAW" -> {if(!a.state().equals("PUBLISHED"))throw new PoiMediaWorkflowConflictException("Only published media can be withdrawn.");yield "WITHDRAWN";}
            default -> throw new IllegalArgumentException("Unknown media action.");
        };
        if(action.equals("PUBLISH")) {
            if(makePrimary) jdbc.update("UPDATE media.poi_asset SET is_primary=false WHERE poi_id=? AND is_primary",a.poiId());
            int changed=jdbc.update("""
                    UPDATE media.poi_asset SET review_state=?,reviewed_by=?,reviewed_at=now(),review_reason=?,
                    is_primary=?,version=version+1 WHERE id=? AND version=?""",next,actor,reason,makePrimary,id,expectedVersion);
            if(changed!=1)throw new PoiMediaWorkflowConflictException("Media asset version changed concurrently.");
        } else {
            int changed=jdbc.update("UPDATE media.poi_asset SET review_state=?,review_reason=?,is_primary=CASE WHEN ?='WITHDRAW' THEN false ELSE is_primary END,version=version+1 WHERE id=? AND version=?",
                    next,reason,action,id,expectedVersion);
            if(changed!=1)throw new PoiMediaWorkflowConflictException("Media asset version changed concurrently.");
        }
        audit(id,actor,action,reason,a.state(),next,
                json(java.util.Map.of("makePrimary",action.equals("PUBLISH")&&makePrimary,"version",expectedVersion+1))); return find(id).orElseThrow();
    }

    private void audit(UUID id,String actor,String action,String reason,String from,String to){
        audit(id,actor,action,reason,from,to,"{}");
    }
    private void audit(UUID id,String actor,String action,String reason,String from,String to,String details){
        jdbc.update("INSERT INTO media.poi_asset_audit(id,asset_id,actor_id,action,reason,prior_state,next_state,details) VALUES (?,?,?,?,?,?,?,?::jsonb)",
                UUID.randomUUID(),id,actor,action,reason,from,to,details);
    }
    private String json(Object value){try{return objectMapper.writeValueAsString(value);}catch(JsonProcessingException e){throw new IllegalStateException("Media audit details could not be serialized.",e);}}
    private Asset map(ResultSet r,int n)throws SQLException{return new Asset(r.getObject("id",UUID.class),r.getObject("poi_id",UUID.class),
            r.getString("object_key"),r.getString("content_type"),r.getString("sha256"),r.getLong("size_bytes"),r.getInt("width"),r.getInt("height"),
            r.getString("author"),r.getString("source_url"),r.getString("license"),r.getString("attribution"),r.getString("rights_evidence_reference"),
            r.getString("rights_status"),r.getString("review_state"),r.getBoolean("is_primary"),r.getLong("version"),
            r.getString("alt_text"),r.getInt("display_order"));}
    public record Asset(UUID id,UUID poiId,String objectKey,String contentType,String sha256,long sizeBytes,int width,int height,
            String author,String sourceUrl,String license,String attribution,String rightsEvidence,String rightsStatus,
            String state,boolean primary,long version,String altText,int displayOrder){
        public Asset(UUID id,UUID poiId,String objectKey,String contentType,String sha256,long sizeBytes,int width,int height,
                String author,String sourceUrl,String license,String attribution,String rightsEvidence,String rightsStatus,String state,boolean primary,long version) {
            this(id,poiId,objectKey,contentType,sha256,sizeBytes,width,height,author,sourceUrl,license,attribution,rightsEvidence,
                    rightsStatus,state,primary,version,"",0);
        }
        public boolean rightsDocumented(){return "DOCUMENTED".equals(rightsStatus)&&license!=null&&!license.isBlank()&&attribution!=null&&!attribution.isBlank()&&rightsEvidence!=null&&!rightsEvidence.isBlank();}}
    public record PresentationOrder(UUID id,long expectedVersion,int displayOrder) { }
    public record AuditEvent(String actor, String action, String reason, String priorState, String nextState,
            String details, java.time.Instant occurredAt) { }
}
