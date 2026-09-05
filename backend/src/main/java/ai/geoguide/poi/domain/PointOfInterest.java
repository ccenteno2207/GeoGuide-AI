package ai.geoguide.poi.domain;

import java.time.Instant;
import java.util.List;
import java.util.Objects;

public record PointOfInterest(
        PoiId id,
        String name,
        String description,
        Category category,
        GeoPoint location,
        boolean active,
        Instant createdAt,
        Instant updatedAt,
        List<SourceReference> provenance) {

    public PointOfInterest {
        Objects.requireNonNull(id, "id is required");
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("name is required");
        }
        name = name.trim();
        description = description == null || description.isBlank() ? null : description.trim();
        Objects.requireNonNull(category, "category is required");
        Objects.requireNonNull(location, "location is required");
        Objects.requireNonNull(createdAt, "createdAt is required");
        Objects.requireNonNull(updatedAt, "updatedAt is required");
        if (updatedAt.isBefore(createdAt)) {
            throw new IllegalArgumentException("updatedAt cannot be before createdAt");
        }
        provenance = List.copyOf(Objects.requireNonNull(provenance, "provenance is required"));
        if (provenance.isEmpty()) {
            throw new IllegalArgumentException("a publishable POI requires provenance");
        }
    }
}
