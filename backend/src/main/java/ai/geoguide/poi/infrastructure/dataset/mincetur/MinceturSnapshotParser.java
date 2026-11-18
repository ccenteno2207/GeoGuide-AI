package ai.geoguide.poi.infrastructure.dataset.mincetur;

import java.io.IOException;
import java.math.BigDecimal;
import java.nio.ByteBuffer;
import java.nio.charset.CharacterCodingException;
import java.nio.charset.Charset;
import java.nio.charset.CodingErrorAction;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.ArrayList;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;

/** Parses a source snapshot without promoting or changing any coordinate. */
public final class MinceturSnapshotParser {
    public static final String PARSER_VERSION = "mincetur-csv-v1";
    public static final String SOURCE_SYSTEM = "MINCETUR_INVENTARIO";
    public static final String DELIMITER = ";";

    private static final List<String> REQUIRED_HEADERS = List.of(
            "REGIÓN", "PROVINCIA", "DISTRITO", "CODIGO DEL RECURSO", "NOMBRE DEL RECURSO",
            "CATEGORÍA", "TIPO DE CATEGORÍA", "SUB TIPO CATEGORÍA", "URL", "LATITUD", "LONGITUD",
            "FECHA_DE_CORTE");
    private static final Pattern SIMPLE_NUMBER = Pattern.compile("^[+-]?\\d+(?:[.,]\\d+)?$");
    private static final Pattern GROUPED_NUMBER = Pattern.compile("^[+-]?\\d{1,3}(?:\\.\\d{3}){2,}$");
    private static final DateTimeFormatter CUTOFF_FORMAT = DateTimeFormatter.BASIC_ISO_DATE;

    public Snapshot parse(String fileName, byte[] sourceBytes) throws IOException {
        String sha256 = sha256(sourceBytes);
        DecodedSource decoded = decode(sourceBytes);
        List<List<String>> rows = parseDelimited(decoded.text(), ';');
        if (rows.isEmpty() || !rows.getFirst().equals(REQUIRED_HEADERS)) {
            throw new IOException("Unexpected MINCETUR CSV header; refusing to infer a column mapping.");
        }

        List<SnapshotRecord> records = new ArrayList<>();
        Map<String, Integer> identityCounts = new LinkedHashMap<>();
        for (int index = 1; index < rows.size(); index++) {
            List<String> row = rows.get(index);
            if (row.size() == 1 && row.getFirst().isBlank()) {
                continue;
            }
            int rowNumber = index + 1;
            if (row.size() != REQUIRED_HEADERS.size()) {
                records.add(SnapshotRecord.malformed(rowNumber, row));
                continue;
            }
            Map<String, String> raw = new LinkedHashMap<>();
            for (int column = 0; column < REQUIRED_HEADERS.size(); column++) {
                raw.put(REQUIRED_HEADERS.get(column), row.get(column));
            }
            String sourceRecordId = raw.get("CODIGO DEL RECURSO").trim();
            if (!sourceRecordId.isEmpty()) {
                identityCounts.merge(sourceRecordId, 1, Integer::sum);
            }
            CoordinateAssessment assessment = assessCoordinates(raw.get("LATITUD"), raw.get("LONGITUD"));
            records.add(new SnapshotRecord(rowNumber, sourceRecordId, raw,
                    assessment.status(), assessment.reason(), null, null, null, null));
        }

        List<SnapshotRecord> withDuplicateStatus = records.stream().map(record -> {
            if (record.status() == RecordStatus.MALFORMED_ROW) {
                return record;
            }
            if (record.sourceRecordId().isBlank()) {
                return record.withStatus(RecordStatus.MALFORMED_ROW, "Missing source record code.");
            }
            if (identityCounts.getOrDefault(record.sourceRecordId(), 0) > 1) {
                return record.withStatus(RecordStatus.DUPLICATE_SOURCE_ID,
                        "Source record code occurs more than once in this snapshot.");
            }
            return record;
        }).toList();

        List<SnapshotRecord> dataRecords = withDuplicateStatus.stream()
                .filter(record -> record.rawFields() != null)
                .toList();
        List<LocalDate> cutoffs = dataRecords.stream()
                .map(record -> parseCutoff(record.rawFields().get("FECHA_DE_CORTE")))
                .filter(java.util.Objects::nonNull).distinct().toList();
        long validCutoffRows = dataRecords.stream()
                .filter(record -> parseCutoff(record.rawFields().get("FECHA_DE_CORTE")) != null).count();
        boolean inconsistentCutoff = cutoffs.size() != 1 || validCutoffRows != dataRecords.size()
                || dataRecords.size() != withDuplicateStatus.size();
        LocalDate cutoff = !inconsistentCutoff ? cutoffs.getFirst() : null;
        return new Snapshot(fileName, sha256, decoded.charset().name(), DELIMITER,
                cutoff, inconsistentCutoff, withDuplicateStatus);
    }

    private static CoordinateAssessment assessCoordinates(String rawLatitude, String rawLongitude) {
        if (rawLatitude == null || rawLongitude == null || rawLatitude.isBlank() || rawLongitude.isBlank()) {
            return new CoordinateAssessment(RecordStatus.COORDINATE_FORMAT_AMBIGUOUS,
                    "One or both source coordinate fields are empty.");
        }
        if (GROUPED_NUMBER.matcher(rawLatitude.trim()).matches()
                || GROUPED_NUMBER.matcher(rawLongitude.trim()).matches()) {
            return new CoordinateAssessment(RecordStatus.COORDINATE_FORMAT_AMBIGUOUS,
                    "Coordinate contains repeated grouping punctuation; decimal position and precision are not recoverable from this snapshot alone.");
        }
        if (!SIMPLE_NUMBER.matcher(rawLatitude.trim()).matches()
                || !SIMPLE_NUMBER.matcher(rawLongitude.trim()).matches()) {
            return new CoordinateAssessment(RecordStatus.COORDINATE_FORMAT_AMBIGUOUS,
                    "Coordinate does not use a single unambiguous decimal representation.");
        }
        try {
            BigDecimal latitudeValue = new BigDecimal(rawLatitude.trim().replace(',', '.'));
            BigDecimal longitudeValue = new BigDecimal(rawLongitude.trim().replace(',', '.'));
            if (latitudeValue.abs().compareTo(BigDecimal.valueOf(180)) > 0
                    || longitudeValue.abs().compareTo(BigDecimal.valueOf(180)) > 0) {
                return new CoordinateAssessment(RecordStatus.COORDINATE_FORMAT_AMBIGUOUS,
                        "At least one source coordinate exceeds global longitude bounds.");
            }
        } catch (NumberFormatException exception) {
            return new CoordinateAssessment(RecordStatus.COORDINATE_FORMAT_AMBIGUOUS,
                    "Coordinate is not a valid decimal value.");
        }
        return new CoordinateAssessment(RecordStatus.COORDINATE_MAPPING_UNVERIFIED,
                "Coordinate syntax is decimal, but no mapping is approved for this snapshot hash.");
    }

    private static LocalDate parseCutoff(String value) {
        if (value == null || !value.trim().matches("\\d{8}")) {
            return null;
        }
        try {
            return LocalDate.parse(value.trim(), CUTOFF_FORMAT);
        } catch (DateTimeParseException exception) {
            return null;
        }
    }

    private static DecodedSource decode(byte[] bytes) throws IOException {
        byte[] content = bytes;
        if (bytes.length >= 3 && (bytes[0] & 0xff) == 0xef && (bytes[1] & 0xff) == 0xbb
                && (bytes[2] & 0xff) == 0xbf) {
            content = java.util.Arrays.copyOfRange(bytes, 3, bytes.length);
        }
        try {
            var decoder = StandardCharsets.UTF_8.newDecoder()
                    .onMalformedInput(CodingErrorAction.REPORT).onUnmappableCharacter(CodingErrorAction.REPORT);
            return new DecodedSource(decoder.decode(ByteBuffer.wrap(content)).toString(), StandardCharsets.UTF_8);
        } catch (CharacterCodingException invalidUtf8) {
            Charset windows1252 = Charset.forName("windows-1252");
            return new DecodedSource(windows1252.decode(ByteBuffer.wrap(bytes)).toString(), windows1252);
        }
    }

    private static List<List<String>> parseDelimited(String input, char delimiter) throws IOException {
        List<List<String>> rows = new ArrayList<>();
        List<String> row = new ArrayList<>();
        StringBuilder field = new StringBuilder();
        boolean quoted = false;
        for (int index = 0; index < input.length(); index++) {
            char current = input.charAt(index);
            if (quoted) {
                if (current == '"' && index + 1 < input.length() && input.charAt(index + 1) == '"') {
                    field.append('"');
                    index++;
                } else if (current == '"') {
                    quoted = false;
                } else {
                    field.append(current);
                }
            } else if (current == '"') {
                if (!field.isEmpty()) {
                    throw new IOException("Unexpected quote in unquoted MINCETUR CSV field.");
                }
                quoted = true;
            } else if (current == delimiter) {
                row.add(field.toString());
                field.setLength(0);
            } else if (current == '\n' || current == '\r') {
                if (current == '\r' && index + 1 < input.length() && input.charAt(index + 1) == '\n') {
                    index++;
                }
                row.add(field.toString());
                field.setLength(0);
                if (!(row.size() == 1 && row.getFirst().isEmpty())) {
                    rows.add(List.copyOf(row));
                }
                row.clear();
            } else {
                field.append(current);
            }
        }
        if (quoted) {
            throw new IOException("Unclosed quoted field in MINCETUR CSV.");
        }
        if (!row.isEmpty() || !field.isEmpty()) {
            row.add(field.toString());
            rows.add(List.copyOf(row));
        }
        return rows;
    }

    private static String sha256(byte[] bytes) {
        try {
            return HexFormat.of().withUpperCase().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
        } catch (NoSuchAlgorithmException impossible) {
            throw new IllegalStateException("SHA-256 is unavailable.", impossible);
        }
    }

    private record DecodedSource(String text, Charset charset) {}
    private record CoordinateAssessment(RecordStatus status, String reason) {}

    public enum RecordStatus {
        COORDINATE_FORMAT_AMBIGUOUS,
        COORDINATE_MAPPING_UNVERIFIED,
        DUPLICATE_SOURCE_ID,
        MALFORMED_ROW
    }

    public record Snapshot(String sourceFileName, String sha256, String encoding, String delimiter,
            LocalDate cutoff, boolean inconsistentCutoff, List<SnapshotRecord> records) {}

    public record SnapshotRecord(int rowNumber, String sourceRecordId, Map<String, String> rawFields,
            RecordStatus status, String quarantineReason, BigDecimal normalizedLatitude,
            BigDecimal normalizedLongitude, String normalizationRule, String validationEvidence) {
        private static SnapshotRecord malformed(int rowNumber, List<String> fields) {
            Map<String, String> rawFields = new LinkedHashMap<>();
            for (int index = 0; index < fields.size(); index++) {
                rawFields.put("_field_" + index, fields.get(index));
            }
            return new SnapshotRecord(rowNumber, "", Map.copyOf(rawFields),
                    RecordStatus.MALFORMED_ROW, "CSV row does not match the required header width.",
                    null, null, null, null);
        }

        private SnapshotRecord withStatus(RecordStatus nextStatus, String reason) {
            return new SnapshotRecord(rowNumber, sourceRecordId, rawFields, nextStatus, reason,
                    normalizedLatitude, normalizedLongitude, normalizationRule, validationEvidence);
        }
    }
}
