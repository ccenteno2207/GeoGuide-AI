package ai.geoguide.discovery.domain;

import java.util.List;
import java.util.Objects;

public record RankedRoutePoiCandidate(
        RoutePoiCandidate candidate,
        double score,
        List<DiscoveryReasonCode> reasonCodes) {

    public RankedRoutePoiCandidate {
        Objects.requireNonNull(candidate, "candidate is required");
        if (!Double.isFinite(score) || score < 0) {
            throw new IllegalArgumentException("score must be finite and non-negative");
        }
        reasonCodes = List.copyOf(Objects.requireNonNull(reasonCodes, "reasonCodes are required"));
        if (reasonCodes.isEmpty()) {
            throw new IllegalArgumentException("reasonCodes are required");
        }
    }
}
