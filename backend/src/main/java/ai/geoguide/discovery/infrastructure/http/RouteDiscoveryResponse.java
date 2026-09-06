package ai.geoguide.discovery.infrastructure.http;

import ai.geoguide.discovery.application.RouteDiscoveryResult;
import java.time.Instant;
import java.util.List;

public record RouteDiscoveryResponse(RouteResponse route, List<Result> results, String algorithmVersion, Instant generatedAt) {
    static RouteDiscoveryResponse from(RouteDiscoveryResult result) {
        var route = result.route();
        return new RouteDiscoveryResponse(new RouteResponse(new DiscoveryRequest.Point(route.origin().latitude(), route.origin().longitude()), new DiscoveryRequest.Point(route.destination().latitude(), route.destination().longitude()), route.distanceMeters(), route.durationSeconds(), new Geometry("LineString", route.geometry().positions().stream().map(p -> List.of(p.longitude(), p.latitude())).toList())), result.results().stream().map(item -> new Result(item.candidate().poiId().value(), item.candidate().name(), item.candidate().category().code(), new DiscoveryRequest.Point(item.candidate().location().latitude(), item.candidate().location().longitude()), item.candidate().distanceToRouteMeters(), item.candidate().routeProgress(), item.score(), item.reasonCodes().stream().map(Enum::name).toList())).toList(), result.algorithmVersion(), result.generatedAt());
    }
    public record RouteResponse(DiscoveryRequest.Point origin, DiscoveryRequest.Point destination, double distanceMeters, double durationSeconds, Geometry geometry) { }
    public record Geometry(String type, List<List<Double>> coordinates) { }
    public record Result(java.util.UUID id, String name, String category, DiscoveryRequest.Point location, double distanceToRouteMeters, double routeProgress, double score, List<String> reasonCodes) { }
}
