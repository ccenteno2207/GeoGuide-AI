package ai.geoguide.admin.domain;

import java.net.URI;
import java.util.List;

/** Plain-text editorial content. Rendering clients must treat fields as text, never trusted HTML. */
public record PoiTourismContent(
        String summary,
        String description,
        String history,
        String significance,
        String visitorExperience,
        List<String> interestingFacts,
        List<String> recommendations,
        String practicalInfo,
        String officialUrl) {

    public PoiTourismContent {
        summary = bounded(summary, 500, "summary");
        description = bounded(description, 12_000, "description");
        history = bounded(history, 12_000, "history");
        significance = bounded(significance, 8_000, "significance");
        visitorExperience = bounded(visitorExperience, 8_000, "visitorExperience");
        practicalInfo = bounded(practicalInfo, 6_000, "practicalInfo");
        interestingFacts = boundedList(interestingFacts, "interestingFacts");
        recommendations = boundedList(recommendations, "recommendations");
        officialUrl = bounded(officialUrl, 2_000, "officialUrl");
        if (!officialUrl.isBlank()) {
            try {
                URI uri = URI.create(officialUrl);
                if (!"https".equalsIgnoreCase(uri.getScheme()) || uri.getHost() == null || uri.getUserInfo() != null) {
                    throw new IllegalArgumentException("Official URL must be an absolute HTTPS address without embedded credentials.");
                }
            } catch (IllegalArgumentException ex) {
                throw new IllegalArgumentException("Official URL must be a valid HTTPS address.", ex);
            }
        }
    }

    public static PoiTourismContent empty() {
        return new PoiTourismContent("", "", "", "", "", List.of(), List.of(), "", "");
    }

    private static String bounded(String value, int max, String field) {
        String normalized = value == null ? "" : value.strip();
        if (normalized.length() > max) throw new IllegalArgumentException(field + " exceeds the allowed length.");
        return normalized;
    }

    private static List<String> boundedList(List<String> values, String field) {
        if (values == null) return List.of();
        if (values.size() > 20) throw new IllegalArgumentException(field + " may contain at most 20 entries.");
        return values.stream().map(value -> bounded(value, 1_000, field)).filter(value -> !value.isBlank()).toList();
    }
}
