package ai.geoguide.discovery.application;

import ai.geoguide.discovery.application.port.RoutePoiCandidateQuery;
import ai.geoguide.discovery.domain.CandidateFilter;
import ai.geoguide.discovery.domain.DiscoveryCriteria;
import ai.geoguide.discovery.domain.DiscoveryRankingPolicy;
import ai.geoguide.poi.application.port.CategoryRepository;
import ai.geoguide.routing.application.PlanRouteUseCase;
import ai.geoguide.routing.domain.RoutePoint;
import java.time.Clock;
import java.util.Objects;

public final class RouteDiscoveryUseCase {
    private final PlanRouteUseCase planRouteUseCase;
    private final RoutePoiCandidateQuery candidateQuery;
    private final CategoryRepository categoryRepository;
    private final CandidateFilter candidateFilter;
    private final DiscoveryRankingPolicy rankingPolicy;
    private final Clock clock;

    public RouteDiscoveryUseCase(PlanRouteUseCase planRouteUseCase, RoutePoiCandidateQuery candidateQuery,
            CategoryRepository categoryRepository, CandidateFilter candidateFilter,
            DiscoveryRankingPolicy rankingPolicy, Clock clock) {
        this.planRouteUseCase = Objects.requireNonNull(planRouteUseCase);
        this.candidateQuery = Objects.requireNonNull(candidateQuery);
        this.categoryRepository = Objects.requireNonNull(categoryRepository);
        this.candidateFilter = Objects.requireNonNull(candidateFilter);
        this.rankingPolicy = Objects.requireNonNull(rankingPolicy);
        this.clock = Objects.requireNonNull(clock);
    }

    public RouteDiscoveryResult discover(RoutePoint origin, RoutePoint destination, DiscoveryCriteria criteria) {
        criteria.categoryCodes().forEach(code -> categoryRepository.findByCode(code)
                .filter(category -> category.active())
                .orElseThrow(() -> new IllegalArgumentException("unknown or inactive category: " + code)));
        var route = planRouteUseCase.plan(origin, destination);
        var candidates = candidateFilter.filter(candidateQuery.findAlong(route.geometry(), criteria), criteria);
        return new RouteDiscoveryResult(route, rankingPolicy.rank(candidates, criteria),
                DiscoveryRankingPolicy.ALGORITHM_VERSION, clock.instant());
    }
}
