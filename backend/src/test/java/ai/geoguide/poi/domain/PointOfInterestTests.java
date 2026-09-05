package ai.geoguide.poi.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Instant;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class PointOfInterestTests {

    private static final Instant NOW = Instant.parse("2026-01-01T00:00:00Z");
    private static final Category CATEGORY = new Category(UUID.randomUUID(), "CULTURAL", "Cultural", true);
    private static final SourceReference SOURCE = new SourceReference(
            UUID.randomUUID(), "geoguide", null, null, NOW, "CURATED", null, "MANUAL", "test-poi");

    @Test
    void createsPoiWithRequiredValues() {
        PointOfInterest poi = poi("  Plaza histórica  ", List.of(SOURCE), NOW);

        assertThat(poi.name()).isEqualTo("Plaza histórica");
        assertThat(poi.active()).isTrue();
        assertThat(poi.provenance()).containsExactly(SOURCE);
    }

    @Test
    void rejectsBlankName() {
        assertThatThrownBy(() -> poi(" ", List.of(SOURCE), NOW))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("name");
    }

    @Test
    void rejectsMissingProvenance() {
        assertThatThrownBy(() -> poi("POI", List.of(), NOW))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("provenance");
    }

    @Test
    void rejectsUpdatedAtBeforeCreatedAt() {
        assertThatThrownBy(() -> poi("POI", List.of(SOURCE), NOW.minusSeconds(1)))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("updatedAt");
    }

    private PointOfInterest poi(String name, List<SourceReference> sources, Instant updatedAt) {
        return new PointOfInterest(
                new PoiId(UUID.randomUUID()), name, null, CATEGORY, new GeoPoint(-11.9, -77.0),
                true, NOW, updatedAt, sources);
    }
}
