package ai.geoguide.discovery.application;

import ai.geoguide.discovery.domain.RankedRoutePoiCandidate;
import ai.geoguide.routing.domain.Route;
import java.time.Instant;
import java.util.List;
import java.util.Objects;

public record RouteDiscoveryResult(Route route, List<RankedRoutePoiCandidate> results,
                                   String algorithmVersion, Instant generatedAt) {
    public RouteDiscoveryResult {
        Objects.requireNonNull(route, "route is required");
        results = List.copyOf(results);
        Objects.requireNonNull(algorithmVersion, "algorithmVersion is required");
        Objects.requireNonNull(generatedAt, "generatedAt is required");
    }
}
