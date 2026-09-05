package ai.geoguide.discovery.domain;

import java.util.Collection;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

public final class CandidateFilter {

    private static final Comparator<RoutePoiCandidate> CANONICAL_CANDIDATE_ORDER = Comparator
            .comparingDouble(RoutePoiCandidate::distanceToRouteMeters)
            .thenComparingDouble(RoutePoiCandidate::routeProgress)
            .thenComparing(candidate -> candidate.poiId().value().toString());

    public List<RoutePoiCandidate> filter(Collection<RoutePoiCandidate> candidates, DiscoveryCriteria criteria) {
        Objects.requireNonNull(candidates, "candidates are required");
        Objects.requireNonNull(criteria, "criteria is required");

        Map<java.util.UUID, RoutePoiCandidate> uniqueCandidates = new LinkedHashMap<>();
        candidates.stream()
                .filter(Objects::nonNull)
                .filter(RoutePoiCandidate::active)
                .filter(candidate -> !criteria.hasCategoryFilter()
                        || criteria.categoryCodes().contains(candidate.category().code()))
                .forEach(candidate -> uniqueCandidates.merge(
                        candidate.poiId().value(), candidate, CandidateFilter::preferredCandidate));

        return uniqueCandidates.values().stream().sorted(CANONICAL_CANDIDATE_ORDER).toList();
    }

    private static RoutePoiCandidate preferredCandidate(RoutePoiCandidate left, RoutePoiCandidate right) {
        return CANONICAL_CANDIDATE_ORDER.compare(left, right) <= 0 ? left : right;
    }
}
