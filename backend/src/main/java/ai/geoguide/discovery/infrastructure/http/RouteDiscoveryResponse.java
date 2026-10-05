package ai.geoguide.discovery.infrastructure.http;

import ai.geoguide.discovery.application.RouteDiscoveryResult;
import java.time.Instant;
import java.util.List;
import ai.geoguide.discovery.domain.ProvenanceSummary;

public record RouteDiscoveryResponse(RouteResponse route, List<Result> results, String algorithmVersion, Instant generatedAt) {
    static RouteDiscoveryResponse from(RouteDiscoveryResult result) {
        var route = result.route();
        return new RouteDiscoveryResponse(new RouteResponse(new DiscoveryRequest.Point(route.origin().latitude(), route.origin().longitude()), new DiscoveryRequest.Point(route.destination().latitude(), route.destination().longitude()), route.distanceMeters(), route.durationSeconds(), new Geometry("LineString", route.geometry().positions().stream().map(p -> List.of(p.longitude(), p.latitude())).toList())), result.results().stream().map(item -> {
            var candidate = item.candidate();
            ProvenanceSummary provenance = candidate.provenance();
            return new Result(candidate.poiId().value(), candidate.name(), candidate.category().code(),
                    new DiscoveryRequest.Point(candidate.location().latitude(), candidate.location().longitude()),
                    candidate.distanceToRouteMeters(), candidate.routeProgress(), item.score(),
                    item.reasonCodes().stream().map(Enum::name).toList(), candidate.description(),
                    provenance == null ? null : provenance.sourceLabel(),
                    provenance == null ? null : provenance.sourceUrl(),
                    provenance == null ? null : provenance.attribution());
        }).toList(), result.algorithmVersion(), result.generatedAt());
    }
    public record RouteResponse(DiscoveryRequest.Point origin, DiscoveryRequest.Point destination, double distanceMeters, double durationSeconds, Geometry geometry) { }
    public record Geometry(String type, List<List<Double>> coordinates) { }
    public record Result(java.util.UUID id, String name, String category, DiscoveryRequest.Point location, double distanceToRouteMeters, double routeProgress, double score, List<String> reasonCodes, String description, String sourceLabel, String sourceUrl, String attribution) { }
}
