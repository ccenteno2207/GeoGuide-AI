package ai.geoguide.discovery.infrastructure.config;

import ai.geoguide.discovery.application.RouteDiscoveryUseCase;
import ai.geoguide.discovery.application.port.RoutePoiCandidateQuery;
import ai.geoguide.discovery.domain.CandidateFilter;
import ai.geoguide.discovery.domain.DiscoveryRankingPolicy;
import ai.geoguide.poi.application.port.CategoryRepository;
import ai.geoguide.routing.application.PlanRouteUseCase;
import java.time.Clock;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

@Configuration
public class DiscoveryConfiguration {
    @Bean Clock discoveryClock() { return Clock.systemUTC(); }
    @Bean CandidateFilter candidateFilter() { return new CandidateFilter(); }
    @Bean DiscoveryRankingPolicy discoveryRankingPolicy() { return new DiscoveryRankingPolicy(); }
    @Bean @ConditionalOnProperty(name = "spring.datasource.url")
    RouteDiscoveryUseCase routeDiscoveryUseCase(PlanRouteUseCase planner, RoutePoiCandidateQuery query,
            CategoryRepository categories, CandidateFilter filter, DiscoveryRankingPolicy ranking, Clock clock) {
        return new RouteDiscoveryUseCase(planner, query, categories, filter, ranking, clock);
    }
}
