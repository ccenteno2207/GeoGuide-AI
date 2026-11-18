package ai.geoguide.poi.infrastructure.dataset.mincetur;

import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser.RecordStatus;
import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser.Snapshot;
import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser.SnapshotRecord;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import org.springframework.stereotype.Component;

/** Applies only the record-level coordinate rule cross-checked for one exact MINCETUR snapshot. */
@Component
public final class MinceturSnapshotCoordinateNormalizer {
    public static final String RULE_VERSION = "mincetur-local-20261110-coordinate-recovery-v1";
    private static final Pattern PUNCTUATED_DIGITS = Pattern.compile("^-?\\d+(?:\\.\\d+)*$");
    private static final BigDecimal PERU_LATITUDE_MIN = new BigDecimal("-18.5");
    private static final BigDecimal PERU_LATITUDE_MAX = BigDecimal.ZERO;
    private static final BigDecimal PERU_LONGITUDE_MIN = new BigDecimal("-82.5");
    private static final BigDecimal PERU_LONGITUDE_MAX = new BigDecimal("-68.0");

    private final ObjectMapper objectMapper;

    public MinceturSnapshotCoordinateNormalizer(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
    }

    public Snapshot normalize(Snapshot snapshot, InputStream manifestStream) throws IOException {
        Manifest manifest = objectMapper.readValue(manifestStream, Manifest.class);
        if (!snapshot.sha256().equalsIgnoreCase(manifest.localSnapshot().sha256())) {
            // A newer/different snapshot has no approved transform; keep the parser's quarantine states intact.
            return snapshot;
        }
        validateSnapshotMatch(snapshot, manifest);
        Map<String, CoordinateRule> rules = manifest.acceptedRecords().stream()
                .collect(java.util.stream.Collectors.toUnmodifiableMap(
                        CoordinateRule::sourceRecordId, rule -> rule));
        List<SnapshotRecord> records = snapshot.records().stream().map(record -> {
            CoordinateRule rule = rules.get(record.sourceRecordId());
            if (rule == null || record.status() == RecordStatus.DUPLICATE_SOURCE_ID
                    || record.status() == RecordStatus.MALFORMED_ROW) {
                return record;
            }
            try {
                BigDecimal longitude = insertDecimal(record.rawFields().get("LATITUD"),
                        rule.sourceFieldLATITUDDecimalPosition());
                BigDecimal latitude = insertDecimal(record.rawFields().get("LONGITUD"),
                        rule.sourceFieldLONGITUDDecimalPosition());
                validatePeruPoint(latitude, longitude);
                String evidence = "Exact snapshot SHA-256 " + snapshot.sha256()
                        + "; per-record decimal positions cross-checked against comparison snapshot SHA-256 "
                        + manifest.comparisonSnapshot().sha256()
                        + "; numerical match tolerance 1e-10 degrees. Candidate only; not geodetically verified or published.";
                return record.withNormalizedCoordinates(latitude, longitude, RULE_VERSION, evidence);
            } catch (IllegalArgumentException invalidCandidate) {
                return record.withStatus(RecordStatus.COORDINATE_FORMAT_AMBIGUOUS,
                        "Manifest candidate failed numeric or Peru-bounds validation: " + invalidCandidate.getMessage());
            }
        }).toList();
        return new Snapshot(snapshot.sourceFileName(), snapshot.sha256(), snapshot.encoding(), snapshot.delimiter(),
                snapshot.cutoff(), snapshot.inconsistentCutoff(), records);
    }

    private static void validateSnapshotMatch(Snapshot snapshot, Manifest manifest) throws IOException {
        SnapshotIdentity local = manifest.localSnapshot();
        if (!RULE_VERSION.equals(manifest.manifestVersion())
                || !"SNAPSHOT_SPECIFIC_CROSSCHECKED_NOT_PUBLISHED".equals(manifest.status())
                || !snapshot.sha256().equalsIgnoreCase(local.sha256())
                || !snapshot.encoding().equalsIgnoreCase(local.encoding())
                || !snapshot.delimiter().equals(local.delimiter())
                || snapshot.cutoff() == null || !snapshot.cutoff().equals(LocalDate.parse(local.cutoff()))
                || snapshot.records().size() != local.recordCount()
                || snapshot.inconsistentCutoff()) {
            throw new IOException("Coordinate recovery manifest does not match this exact source snapshot.");
        }
        Comparison comparison = manifest.comparison();
        if (manifest.acceptedRecords() == null
                || manifest.acceptedRecords().size() != comparison.acceptedRecords()
                || manifest.quarantine() == null
                || manifest.acceptedRecords().stream().map(CoordinateRule::sourceRecordId).distinct().count()
                        != manifest.acceptedRecords().size()
                || manifest.acceptedRecords().size() + manifest.quarantine().size() != local.recordCount()) {
            throw new IOException("Coordinate recovery manifest has inconsistent accepted/quarantine counts.");
        }
    }

    private static BigDecimal insertDecimal(String token, int decimalPosition) {
        if (token == null || !PUNCTUATED_DIGITS.matcher(token.trim()).matches()
                || decimalPosition < 1 || decimalPosition > 2) {
            throw new IllegalArgumentException("invalid source token or decimal position");
        }
        String value = token.trim();
        boolean negative = value.startsWith("-");
        String digits = value.replaceAll("[^0-9]", "");
        if (digits.length() <= decimalPosition) {
            throw new IllegalArgumentException("not enough digits for decimal position");
        }
        String normalized = digits.substring(0, decimalPosition) + "." + digits.substring(decimalPosition);
        return new BigDecimal((negative ? "-" : "") + normalized);
    }

    private static void validatePeruPoint(BigDecimal latitude, BigDecimal longitude) {
        if (latitude.compareTo(BigDecimal.valueOf(-90)) < 0 || latitude.compareTo(BigDecimal.valueOf(90)) > 0
                || longitude.compareTo(BigDecimal.valueOf(-180)) < 0 || longitude.compareTo(BigDecimal.valueOf(180)) > 0) {
            throw new IllegalArgumentException("outside global coordinate bounds");
        }
        if (latitude.compareTo(PERU_LATITUDE_MIN) < 0 || latitude.compareTo(PERU_LATITUDE_MAX) > 0
                || longitude.compareTo(PERU_LONGITUDE_MIN) < 0 || longitude.compareTo(PERU_LONGITUDE_MAX) > 0) {
            throw new IllegalArgumentException("outside configured Peru plausibility bounds");
        }
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record Manifest(String manifestVersion, String status, SnapshotIdentity localSnapshot,
            Comparison comparison, List<CoordinateRule> acceptedRecords, List<Quarantine> quarantine,
            ComparisonSnapshot comparisonSnapshot) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record SnapshotIdentity(String sha256, String cutoff, String encoding, String delimiter, int recordCount) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record Comparison(int acceptedRecords) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record ComparisonSnapshot(String sha256) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record CoordinateRule(String sourceRecordId, int sourceFieldLATITUDDecimalPosition,
            int sourceFieldLONGITUDDecimalPosition) {}

    @JsonIgnoreProperties(ignoreUnknown = true)
    private record Quarantine(String sourceRecordId, String reason) {}
}
