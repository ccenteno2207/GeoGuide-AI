package ai.geoguide.discovery.domain;

import java.util.LinkedHashSet;
import java.util.Objects;
import java.util.Set;

public record DiscoveryCriteria(Set<String> categoryCodes, int corridorMeters, int limit) {

    public static final int DEFAULT_CORRIDOR_METERS = 5_000;
    public static final int MIN_CORRIDOR_METERS = 1_000;
    public static final int MAX_CORRIDOR_METERS = 10_000;
    public static final int DEFAULT_LIMIT = 20;
    public static final int MAX_LIMIT = 50;

    public DiscoveryCriteria {
        categoryCodes = normalizeCategoryCodes(categoryCodes);
        if (corridorMeters < MIN_CORRIDOR_METERS || corridorMeters > MAX_CORRIDOR_METERS) {
            throw new IllegalArgumentException("corridorMeters must be between %d and %d"
                    .formatted(MIN_CORRIDOR_METERS, MAX_CORRIDOR_METERS));
        }
        if (limit < 1 || limit > MAX_LIMIT) {
            throw new IllegalArgumentException("limit must be between 1 and %d".formatted(MAX_LIMIT));
        }
    }

    public static DiscoveryCriteria defaults() {
        return new DiscoveryCriteria(Set.of(), DEFAULT_CORRIDOR_METERS, DEFAULT_LIMIT);
    }

    public boolean hasCategoryFilter() {
        return !categoryCodes.isEmpty();
    }

    private static Set<String> normalizeCategoryCodes(Set<String> categoryCodes) {
        if (categoryCodes == null || categoryCodes.isEmpty()) {
            return Set.of();
        }
        LinkedHashSet<String> normalized = new LinkedHashSet<>();
        for (String categoryCode : categoryCodes) {
            String value = Objects.requireNonNull(categoryCode, "categoryCode is required").trim();
            if (value.isEmpty()) {
                throw new IllegalArgumentException("categoryCode is required");
            }
            normalized.add(value);
        }
        return Set.copyOf(normalized);
    }
}
