package ai.geoguide.discovery.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatIllegalArgumentException;

import ai.geoguide.poi.domain.Category;
import ai.geoguide.poi.domain.GeoPoint;
import ai.geoguide.poi.domain.PoiId;
import java.util.List;
import java.util.Set;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class DiscoveryRankingPolicyTests {

    private final DiscoveryRankingPolicy rankingPolicy = new DiscoveryRankingPolicy();

    @Test
    void ranksCloserCandidatesFirstWithCanonicalPoiIdTieBreaker() {
        RoutePoiCandidate firstById = candidate("00000000-0000-0000-0000-000000000001", 100, 0);
        RoutePoiCandidate secondById = candidate("00000000-0000-0000-0000-000000000002", 100, 1);
        RoutePoiCandidate farther = candidate("00000000-0000-0000-0000-000000000003", 200, 0.5);

        List<RankedRoutePoiCandidate> ranked = rankingPolicy.rank(
                List.of(farther, secondById, firstById), new DiscoveryCriteria(Set.of("CHURCH"), 5_000, 20));

        assertThat(ranked).extracting(value -> value.candidate().poiId().value())
                .containsExactly(firstById.poiId().value(), secondById.poiId().value(), farther.poiId().value());
        assertThat(ranked.getFirst().reasonCodes())
                .containsExactly(DiscoveryReasonCode.NEAR_ROUTE, DiscoveryReasonCode.CATEGORY_MATCH);
        assertThat(ranked.getFirst().score()).isGreaterThan(ranked.getLast().score());
        assertThat(DiscoveryRankingPolicy.ALGORITHM_VERSION).isEqualTo("DISCOVERY_V1");
    }

    @Test
    void limitsTheRankedResults() {
        List<RankedRoutePoiCandidate> ranked = rankingPolicy.rank(List.of(
                candidate("00000000-0000-0000-0000-000000000001", 1, 0),
                candidate("00000000-0000-0000-0000-000000000002", 2, 0.5)), new DiscoveryCriteria(Set.of(), 5_000, 1));

        assertThat(ranked).hasSize(1);
        assertThat(ranked.getFirst().reasonCodes()).containsExactly(DiscoveryReasonCode.NEAR_ROUTE);
    }

    @Test
    void rejectsInvalidRouteProgress() {
        assertThatIllegalArgumentException().isThrownBy(() -> candidate(
                "00000000-0000-0000-0000-000000000001", 1, 1.01));
    }

    private RoutePoiCandidate candidate(String id, double distance, double progress) {
        return new RoutePoiCandidate(
                new PoiId(UUID.fromString(id)),
                "POI " + id,
                new Category(UUID.randomUUID(), "CHURCH", "Church", true),
                new GeoPoint(-12, -77),
                true,
                distance,
                progress);
    }
}
