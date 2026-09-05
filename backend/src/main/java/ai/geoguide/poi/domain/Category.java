package ai.geoguide.poi.domain;

import java.util.Objects;
import java.util.UUID;

public record Category(UUID id, String code, String name, boolean active) {

    public Category {
        Objects.requireNonNull(id, "id is required");
        code = requireText(code, "code");
        name = requireText(name, "name");
    }

    private static String requireText(String value, String field) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(field + " is required");
        }
        return value.trim();
    }
}
