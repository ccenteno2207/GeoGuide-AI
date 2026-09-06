package ai.geoguide.discovery.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ai.geoguide.discovery.domain.CandidateFilter;
import ai.geoguide.discovery.domain.DiscoveryCriteria;
import ai.geoguide.discovery.domain.DiscoveryRankingPolicy;
import ai.geoguide.discovery.domain.RoutePoiCandidate;
import ai.geoguide.poi.application.port.CategoryRepository;
import ai.geoguide.poi.domain.Category;
import ai.geoguide.poi.domain.GeoPoint;
import ai.geoguide.poi.domain.PoiId;
import ai.geoguide.routing.application.PlanRouteUseCase;
import ai.geoguide.routing.domain.Route;
import ai.geoguide.routing.domain.RouteGeometry;
import ai.geoguide.routing.domain.RoutePoint;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class RouteDiscoveryUseCaseTests {
    private final Category museum = new Category(UUID.fromString("10000000-0000-0000-0000-000000000001"), "MUSEUM", "Museum", true);
    private final Route route = new Route(new RoutePoint(-12, -77.02), new RoutePoint(-12, -76.98), 4_000, 300,
            new RouteGeometry(List.of(new RoutePoint(-12, -77.02), new RoutePoint(-12, -76.98))));

    @Test
    void composesP4RouteWithRankedCandidatesAndLimit() {
        var useCase = useCase(List.of(candidate("00000000-0000-0000-0000-000000000002", 20), candidate("00000000-0000-0000-0000-000000000001", 10)));
        var result = useCase.discover(route.origin(), route.destination(), new DiscoveryCriteria(java.util.Set.of("MUSEUM"), 5_000, 1));
        assertThat(result.route()).isSameAs(route);
        assertThat(result.results()).hasSize(1);
        assertThat(result.results().getFirst().candidate().poiId().value()).isEqualTo(UUID.fromString("00000000-0000-0000-0000-000000000001"));
        assertThat(result.generatedAt()).isEqualTo(Instant.parse("2026-09-05T00:00:00Z"));
    }

    @Test
    void propagatesInheritedRoutingFailures() {
        var failingPlanner = new PlanRouteUseCase((origin, destination, profile) -> { throw new IllegalStateException("routing unavailable"); }, "car");
        var useCase = new RouteDiscoveryUseCase(failingPlanner, (geometry, criteria) -> List.of(), categories(), new CandidateFilter(), new DiscoveryRankingPolicy(), Clock.systemUTC());
        assertThatThrownBy(() -> useCase.discover(route.origin(), route.destination(), DiscoveryCriteria.defaults()))
                .isInstanceOf(IllegalStateException.class).hasMessage("routing unavailable");
    }

    @Test
    void rejectsUnknownCategoryBeforePlanning() {
        var useCase = useCase(List.of());
        assertThatThrownBy(() -> useCase.discover(route.origin(), route.destination(),
                new DiscoveryCriteria(java.util.Set.of("UNKNOWN"), 5_000, 20)))
                .isInstanceOf(IllegalArgumentException.class).hasMessageContaining("unknown");
    }

    private RouteDiscoveryUseCase useCase(List<RoutePoiCandidate> candidates) {
        return new RouteDiscoveryUseCase(new PlanRouteUseCase((origin, destination, profile) -> route, "car"),
                (geometry, criteria) -> candidates, categories(), new CandidateFilter(), new DiscoveryRankingPolicy(),
                Clock.fixed(Instant.parse("2026-09-05T00:00:00Z"), ZoneOffset.UTC));
    }

    private CategoryRepository categories() {
        return new CategoryRepository() {
            public Category save(Category category) { return category; }
            public Optional<Category> findByCode(String code) { return "MUSEUM".equals(code) ? Optional.of(museum) : Optional.empty(); }
        };
    }

    private RoutePoiCandidate candidate(String id, double distance) {
        return new RoutePoiCandidate(new PoiId(UUID.fromString(id)), "POI " + id, museum, new GeoPoint(-12, -77), true, distance, .5);
    }
}
