package ai.geoguide.discovery.infrastructure.http;

import ai.geoguide.discovery.domain.DiscoveryCriteria;
import ai.geoguide.routing.domain.RoutePoint;
import java.util.LinkedHashSet;
import java.util.List;

public record DiscoveryRequest(Point origin, Point destination, List<String> categories, Integer corridorMeters, Integer limit) {
    public RoutePoint originPoint() { return toPoint(origin, "origin"); }
    public RoutePoint destinationPoint() { return toPoint(destination, "destination"); }
    public DiscoveryCriteria criteria() {
        try {
            return new DiscoveryCriteria(categories == null ? java.util.Set.of() : new LinkedHashSet<>(categories),
                    corridorMeters == null ? DiscoveryCriteria.DEFAULT_CORRIDOR_METERS : corridorMeters,
                    limit == null ? DiscoveryCriteria.DEFAULT_LIMIT : limit);
        } catch (RuntimeException exception) { throw new DiscoveryException(DiscoveryError.INVALID_DISCOVERY_REQUEST); }
    }
    private RoutePoint toPoint(Point point, String name) {
        try { return new RoutePoint(point.latitude(), point.longitude()); }
        catch (RuntimeException exception) { throw new DiscoveryException(DiscoveryError.INVALID_DISCOVERY_REQUEST); }
    }
    public record Point(Double latitude, Double longitude) { }
}
