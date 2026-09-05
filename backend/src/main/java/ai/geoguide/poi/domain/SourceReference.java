package ai.geoguide.poi.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

public record SourceReference(
        UUID id,
        String sourceSystem,
        String sourceRecordId,
        String sourceUrl,
        Instant retrievedAt,
        String license,
        String attribution,
        String incorporationMethod,
        String logicalKey) {

    public SourceReference {
        Objects.requireNonNull(id, "id is required");
        sourceSystem = requireText(sourceSystem, "sourceSystem");
        sourceRecordId = trimToNull(sourceRecordId);
        sourceUrl = trimToNull(sourceUrl);
        license = requireText(license, "license");
        attribution = trimToNull(attribution);
        incorporationMethod = requireText(incorporationMethod, "incorporationMethod");
        logicalKey = requireText(logicalKey, "logicalKey");
    }

    private static String requireText(String value, String field) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(field + " is required");
        }
        return value.trim();
    }

    private static String trimToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
