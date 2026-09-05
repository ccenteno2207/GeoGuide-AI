package ai.geoguide.discovery.domain;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;

public final class DiscoveryRankingPolicy {

    public static final String ALGORITHM_VERSION = "DISCOVERY_V1";

    private static final Comparator<RankedRoutePoiCandidate> RANKING_ORDER = Comparator
            .comparingDouble(RankedRoutePoiCandidate::score).reversed()
            .thenComparing(ranked -> ranked.candidate().poiId().value().toString());

    public List<RankedRoutePoiCandidate> rank(List<RoutePoiCandidate> candidates, DiscoveryCriteria criteria) {
        Objects.requireNonNull(candidates, "candidates are required");
        Objects.requireNonNull(criteria, "criteria is required");

        return candidates.stream()
                .map(candidate -> toRankedCandidate(candidate, criteria))
                .sorted(RANKING_ORDER)
                .limit(criteria.limit())
                .toList();
    }

    private RankedRoutePoiCandidate toRankedCandidate(RoutePoiCandidate candidate, DiscoveryCriteria criteria) {
        List<DiscoveryReasonCode> reasonCodes = new ArrayList<>();
        reasonCodes.add(DiscoveryReasonCode.NEAR_ROUTE);
        if (criteria.hasCategoryFilter()) {
            reasonCodes.add(DiscoveryReasonCode.CATEGORY_MATCH);
        }
        return new RankedRoutePoiCandidate(candidate, scoreFor(candidate.distanceToRouteMeters()), reasonCodes);
    }

    private double scoreFor(double distanceToRouteMeters) {
        return 1d / (1d + distanceToRouteMeters);
    }
}
