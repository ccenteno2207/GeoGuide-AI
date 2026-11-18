package ai.geoguide.admin.infrastructure.persistence;

import java.math.BigDecimal;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class AdminImportReadRepository {
    private final JdbcTemplate jdbc;
    public AdminImportReadRepository(JdbcTemplate jdbc) { this.jdbc = jdbc; }

    public List<BatchView> batches() {
        return jdbc.query("""
                SELECT b.id,b.source_file_name,b.source_sha256,b.source_cutoff,b.record_count,b.quarantined_count,
                       count(r.id) FILTER(WHERE r.record_status='NORMALIZED_PENDING_REVIEW') AS candidates,
                       count(r.id) FILTER(WHERE r.record_status<>'NORMALIZED_PENDING_REVIEW') AS quarantined
                FROM geo.mincetur_import_batch b LEFT JOIN geo.mincetur_import_record r ON r.batch_id=b.id
                GROUP BY b.id ORDER BY b.created_at DESC LIMIT 100
                """, (rs, n) -> new BatchView(rs.getObject("id", UUID.class), rs.getString("source_file_name"),
                rs.getString("source_sha256"), rs.getObject("source_cutoff", LocalDate.class), rs.getInt("record_count"),
                rs.getLong("candidates"), rs.getLong("quarantined")));
    }

    public Page<ImportRecordView> records(UUID batchId, String status, String query,int page,int size) {
        int safePage=Math.max(0,Math.min(page,1_000_000)),safeSize=Math.max(1,Math.min(size,500)),offset=safePage*safeSize;
        long total=jdbc.queryForObject("""
                SELECT count(*) FROM geo.mincetur_import_record r
                WHERE r.batch_id=? AND (? IS NULL OR r.record_status=?)
                  AND (? IS NULL OR r.source_record_id=? OR r.raw_fields->>'NOMBRE DEL RECURSO' ILIKE '%'||?||'%')
                """,
                Long.class,batchId,status,status,query,query,query);
        List<ImportRecordView> content=jdbc.query("""
                SELECT r.id,r.source_record_id,r.row_number,r.raw_fields->>'NOMBRE DEL RECURSO' AS name,
                       r.raw_fields->>'CATEGORÍA' AS source_category,r.raw_fields->>'REGIÓN' AS region,
                       r.raw_fields->>'PROVINCIA' AS province,r.raw_fields->>'DISTRITO' AS district,
                       r.raw_fields->>'URL' AS source_url,r.raw_latitude,r.raw_longitude,
                       r.normalized_latitude,r.normalized_longitude,r.normalization_rule,r.validation_evidence,
                       r.record_status,r.quarantine_reason,(e.id IS NOT NULL) AS has_editorial_record
                FROM geo.mincetur_import_record r LEFT JOIN admin.poi_editorial_record e ON e.import_record_id=r.id
                WHERE r.batch_id=? AND (? IS NULL OR r.record_status=?)
                  AND (? IS NULL OR r.source_record_id=? OR r.raw_fields->>'NOMBRE DEL RECURSO' ILIKE '%'||?||'%')
                ORDER BY r.row_number LIMIT ? OFFSET ?
                """, (rs, n) -> new ImportRecordView(rs.getObject("id", UUID.class),rs.getString("source_record_id"),
                rs.getInt("row_number"),rs.getString("name"),rs.getString("source_category"),rs.getString("region"),
                rs.getString("province"),rs.getString("district"),rs.getString("source_url"),rs.getString("raw_latitude"),
                rs.getString("raw_longitude"),rs.getBigDecimal("normalized_latitude"),rs.getBigDecimal("normalized_longitude"),
                rs.getString("normalization_rule"),rs.getString("validation_evidence"),rs.getString("record_status"),
                rs.getString("quarantine_reason"),rs.getBoolean("has_editorial_record")),batchId,status,status,query,query,query,safeSize,offset);
        return new Page<>(content,safePage,safeSize,total);
    }

    public record BatchView(UUID id,String fileName,String sha256,LocalDate cutoff,int total,long candidates,long quarantined) {}
    public record ImportRecordView(UUID id,String sourceRecordId,int rowNumber,String name,String sourceCategory,
            String region,String province,String district,String sourceUrl,String rawLatitude,String rawLongitude,
            BigDecimal normalizedLatitude,BigDecimal normalizedLongitude,String normalizationRule,String validationEvidence,
            String status,String quarantineReason,boolean hasEditorialRecord) {}
    public record Page<T>(List<T> content,int page,int size,long totalElements){public int totalPages(){return (int)Math.ceil((double)totalElements/size);}}
}
