package ai.geoguide.poi.domain;

import java.util.Objects;
import java.util.UUID;

public record PoiId(UUID value) {

    public PoiId {
        Objects.requireNonNull(value, "value is required");
    }
}
