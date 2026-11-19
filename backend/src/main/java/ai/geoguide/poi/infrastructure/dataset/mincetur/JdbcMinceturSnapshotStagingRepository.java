package ai.geoguide.poi.infrastructure.dataset.mincetur;

import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser.Snapshot;
import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser.SnapshotRecord;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.UUID;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
@ConditionalOnProperty(name = "spring.datasource.url")
public class JdbcMinceturSnapshotStagingRepository {
    private final JdbcTemplate jdbc;
    private final ObjectMapper objectMapper;
    private final MinceturTaxonomyFilter taxonomyFilter;

    public JdbcMinceturSnapshotStagingRepository(JdbcTemplate jdbc, ObjectMapper objectMapper,
            MinceturTaxonomyFilter taxonomyFilter) {
        this.jdbc = jdbc;
        this.objectMapper = objectMapper;
        this.taxonomyFilter = taxonomyFilter;
    }

    @Transactional
    public UUID stage(Snapshot snapshot) {
        MinceturTaxonomyFilter.ClassificationResult classification = taxonomyFilter.classify(snapshot);
        int quarantined = Math.toIntExact(snapshot.records().stream()
                .filter(record -> record.status() != MinceturSnapshotParser.RecordStatus.NORMALIZED_PENDING_REVIEW)
                .count());
        jdbc.update("""
                INSERT INTO geo.mincetur_import_batch(
                    id, source_system, source_file_name, source_sha256, source_cutoff,
                    detected_encoding, delimiter, parser_version, record_count,
                    quarantined_count, cutoff_inconsistent, taxonomy_filter_version, batch_status)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'STAGED_REQUIRES_REVIEW')
                ON CONFLICT (source_sha256, parser_version, taxonomy_filter_version) DO NOTHING
                """, UUID.randomUUID(), MinceturSnapshotParser.SOURCE_SYSTEM,
                snapshot.sourceFileName(), snapshot.sha256(), snapshot.cutoff(), snapshot.encoding(),
                snapshot.delimiter(), MinceturSnapshotParser.PARSER_VERSION, snapshot.records().size(),
                quarantined, snapshot.inconsistentCutoff(), classification.rulesetVersion());
        UUID batchId = jdbc.queryForObject("""
                SELECT id FROM geo.mincetur_import_batch
                WHERE source_sha256 = ? AND parser_version = ? AND taxonomy_filter_version = ?
                """, UUID.class, snapshot.sha256(), MinceturSnapshotParser.PARSER_VERSION,
                classification.rulesetVersion());

        for (SnapshotRecord record : snapshot.records()) {
            insertRecord(batchId, record, classification.decisionFor(record));
        }
        return batchId;
    }

    private void insertRecord(UUID batchId, SnapshotRecord record, MinceturTaxonomyFilter.Decision decision) {
        String rawJson;
        try {
            rawJson = objectMapper.writeValueAsString(record.rawFields());
        } catch (JsonProcessingException exception) {
            throw new IllegalStateException("Could not serialize a raw MINCETUR staging row.", exception);
        }
        String rawLatitude = record.rawFields().get("LATITUD");
        String rawLongitude = record.rawFields().get("LONGITUD");
        jdbc.update("""
                INSERT INTO geo.mincetur_import_record(
                    id, batch_id, row_number, source_record_id, raw_fields, raw_latitude,
                    raw_longitude, normalized_latitude, normalized_longitude,
                    normalization_rule, validation_evidence, record_status, quarantine_reason,
                    thematic_eligibility, thematic_rule_code, thematic_reason)
                VALUES (?, ?, ?, NULLIF(?, ''), ?::jsonb, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ON CONFLICT (batch_id, row_number) DO NOTHING
                """, UUID.randomUUID(), batchId, record.rowNumber(), record.sourceRecordId(), rawJson,
                rawLatitude, rawLongitude, record.normalizedLatitude(), record.normalizedLongitude(),
                record.normalizationRule(), record.validationEvidence(), record.status().name(),
                record.quarantineReason(), decision.eligibility().name(), decision.ruleCode(), decision.reason());
    }
}
