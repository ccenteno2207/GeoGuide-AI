package ai.geoguide.admin.infrastructure.persistence;

import ai.geoguide.poi.domain.PoiOperationalInfo;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.List;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class PoiOperationalInfoRepository {
    private final JdbcTemplate jdbc;
    private final ObjectMapper mapper;

    public PoiOperationalInfoRepository(JdbcTemplate jdbc, ObjectMapper mapper) {
        this.jdbc = jdbc;
        this.mapper = mapper;
    }

    public PoiOperationalInfo getAdmin(UUID poiId) {
        requirePoi(poiId, false);
        return find(poiId).orElseGet(() -> PoiOperationalInfo.empty("America/Lima", 0));
    }

    public PoiOperationalInfo getPublic(UUID poiId) {
        requirePoi(poiId, true);
        PoiOperationalInfo info = find(poiId).orElseGet(() -> PoiOperationalInfo.empty("America/Lima", 0));
        return new PoiOperationalInfo(info.timeZone(), info.weeklyHours(),
                info.items().stream().filter(PoiOperationalInfo.OperationalItem::active).toList(), info.version());
    }

    @Transactional
    public PoiOperationalInfo update(UUID poiId, long expectedVersion, String actor, PoiOperationalInfo requested) {
        if (actor == null || actor.isBlank()) throw new IllegalArgumentException("Authenticated actor is required.");
        jdbc.query("SELECT id FROM geo.point_of_interest WHERE id=? FOR UPDATE", (rs, row) -> rs.getObject(1), poiId)
                .stream().findFirst().orElseThrow(() -> new IllegalArgumentException("POI not found."));
        PoiOperationalInfo before = find(poiId).orElseGet(() -> PoiOperationalInfo.empty("America/Lima", 0));
        if (before.version() != expectedVersion) throw new OperationalInfoConflictException("Operational information changed; reload it before saving.");
        PoiOperationalInfo after = new PoiOperationalInfo(requested.timeZone(), requested.weeklyHours(), requested.items(), before.version() + 1);
        String hoursJson = writeJson(after.weeklyHours());
        String itemsJson = writeJson(after.items());
        jdbc.update("""
                INSERT INTO admin.poi_operational_info(poi_id,time_zone,weekly_hours,items,version,updated_by,updated_at)
                VALUES (?, ?, ?::jsonb, ?::jsonb, ?, ?, now())
                ON CONFLICT (poi_id) DO UPDATE SET time_zone=EXCLUDED.time_zone, weekly_hours=EXCLUDED.weekly_hours,
                    items=EXCLUDED.items, version=EXCLUDED.version, updated_by=EXCLUDED.updated_by, updated_at=now()
                """, poiId, after.timeZone(), hoursJson, itemsJson, after.version(), actor.trim());
        jdbc.update("""
                INSERT INTO admin.poi_operational_info_audit(id,poi_id,actor_id,version,before_value,after_value)
                VALUES (?, ?, ?, ?, ?::jsonb, ?::jsonb)
                """, UUID.randomUUID(), poiId, actor.trim(), after.version(), writeJson(before), writeJson(after));
        return after;
    }

    private java.util.Optional<PoiOperationalInfo> find(UUID poiId) {
        return jdbc.query("SELECT time_zone,weekly_hours::text AS weekly_hours,items::text AS items,version FROM admin.poi_operational_info WHERE poi_id=?",
                (rs, row) -> new PoiOperationalInfo(rs.getString("time_zone"), readHours(rs.getString("weekly_hours")),
                        readItems(rs.getString("items")), rs.getLong("version")), poiId).stream().findFirst();
    }

    private void requirePoi(UUID poiId, boolean activeOnly) {
        String sql = activeOnly ? "SELECT id FROM geo.point_of_interest WHERE id=? AND active=TRUE" :
                "SELECT id FROM geo.point_of_interest WHERE id=?";
        jdbc.query(sql, (rs, row) -> rs.getObject(1), poiId).stream().findFirst()
                .orElseThrow(() -> new IllegalArgumentException("POI not found."));
    }

    private List<PoiOperationalInfo.DailyHours> readHours(String json) {
        try { return mapper.readValue(json, new TypeReference<>() {}); }
        catch (Exception ex) { throw new IllegalStateException("Stored POI opening schedule is invalid.", ex); }
    }

    private List<PoiOperationalInfo.OperationalItem> readItems(String json) {
        try { return mapper.readValue(json, new TypeReference<>() {}); }
        catch (Exception ex) { throw new IllegalStateException("Stored POI operational items are invalid.", ex); }
    }

    private String writeJson(Object value) {
        try { return mapper.writeValueAsString(value); }
        catch (Exception ex) { throw new IllegalStateException("Operational information could not be serialized.", ex); }
    }

    public static final class OperationalInfoConflictException extends RuntimeException {
        public OperationalInfoConflictException(String message) { super(message); }
    }
}
