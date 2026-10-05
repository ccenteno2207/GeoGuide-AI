package ai.geoguide.discovery.domain;

/** User-safe provenance projection; internal provenance fields never cross this boundary. */
public record ProvenanceSummary(String sourceLabel, String sourceUrl, String attribution) {
    public ProvenanceSummary {
        if (sourceLabel == null || sourceLabel.isBlank()) {
            throw new IllegalArgumentException("sourceLabel is required");
        }
        sourceLabel = sourceLabel.trim();
        sourceUrl = blankToNull(sourceUrl);
        attribution = blankToNull(attribution);
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
