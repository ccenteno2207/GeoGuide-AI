package ai.geoguide.destination.domain;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

public record Destination(
        UUID id, String canonicalName, String normalizedName, String type,
        String administrativeContext, double latitude, double longitude,
        String sourceSystem, String sourceRecordId, String sourceUrl,
        String license, String attribution, List<Alias> aliases) {

    public Destination {
        if (id == null || blank(canonicalName) || blank(type) || blank(administrativeContext)
                || blank(sourceSystem) || blank(sourceRecordId) || blank(sourceUrl)
                || blank(license) || blank(attribution)
                || !Double.isFinite(latitude) || latitude < -90 || latitude > 90
                || !Double.isFinite(longitude) || longitude < -180 || longitude > 180) {
            throw new IllegalArgumentException("destination data is invalid");
        }
        normalizedName = normalize(canonicalName);
        aliases = aliases == null ? List.of() : List.copyOf(aliases);
    }

    public static String normalize(String value) {
        String decomposed = Normalizer.normalize(value == null ? "" : value, Normalizer.Form.NFD);
        return Normalizer.normalize(decomposed.replaceAll("\\p{M}+", ""), Normalizer.Form.NFC)
                .trim().replaceAll("\\s+", " ").toLowerCase(Locale.ROOT);
    }

    private static boolean blank(String value) { return value == null || value.isBlank(); }

    public record Alias(UUID id, String value, String normalizedValue, String sourceReference) {
        public Alias {
            if (id == null || value == null || value.isBlank() || sourceReference == null || sourceReference.isBlank()) {
                throw new IllegalArgumentException("destination alias is invalid");
            }
            normalizedValue = normalize(value);
        }
    }
}
