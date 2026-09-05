package ai.geoguide.discovery.domain;

import static org.assertj.core.api.Assertions.assertThat;

import ai.geoguide.poi.domain.Category;
import ai.geoguide.poi.domain.GeoPoint;
import ai.geoguide.poi.domain.PoiId;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class CandidateFilterTests {

    private final CandidateFilter filter = new CandidateFilter();

    @Test
    void keepsOnlyActiveCandidatesMatchingCategoriesAndDeduplicatesByPoiId() {
        UUID duplicateId = UUID.fromString("00000000-0000-0000-0000-000000000002");
        RoutePoiCandidate preferred = candidate(duplicateId, "CHURCH", true, 10, 0.3);
        RoutePoiCandidate duplicate = candidate(duplicateId, "CHURCH", true, 20, 0.2);
        RoutePoiCandidate inactive = candidate(UUID.randomUUID(), "CHURCH", false, 1, 0.1);
        RoutePoiCandidate unmatched = candidate(UUID.randomUUID(), "MUSEUM", true, 1, 0.1);

        List<RoutePoiCandidate> filtered = filter.filter(
                List.of(duplicate, inactive, unmatched, preferred),
                new DiscoveryCriteria(Set.of("CHURCH"), 5_000, 20));

        assertThat(filtered).containsExactly(preferred);
    }

    @Test
    void keepsActiveCandidatesWhenNoCategoryFilterExists() {
        RoutePoiCandidate first = candidate(
                UUID.fromString("00000000-0000-0000-0000-000000000002"), "CHURCH", true, 100, 0.4);
        RoutePoiCandidate second = candidate(
                UUID.fromString("00000000-0000-0000-0000-000000000001"), "MUSEUM", true, 50, 0.5);

        List<RoutePoiCandidate> filtered = filter.filter(List.of(first, second), DiscoveryCriteria.defaults());

        assertThat(filtered).containsExactly(second, first);
    }

    private RoutePoiCandidate candidate(UUID id, String categoryCode, boolean active, double distance, double progress) {
        return new RoutePoiCandidate(
                new PoiId(id),
                "POI " + id,
                new Category(UUID.randomUUID(), categoryCode, categoryCode, true),
                new GeoPoint(-12, -77),
                active,
                distance,
                progress);
    }
}
