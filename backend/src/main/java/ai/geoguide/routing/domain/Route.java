package ai.geoguide.routing.domain;

public record Route(
        RoutePoint origin,
        RoutePoint destination,
        double distanceMeters,
        double durationSeconds,
        RouteGeometry geometry) {

    public Route {
        if (!Double.isFinite(distanceMeters) || distanceMeters < 0) {
            throw new IllegalArgumentException("distanceMeters must be finite and non-negative");
        }
        if (!Double.isFinite(durationSeconds) || durationSeconds < 0) {
            throw new IllegalArgumentException("durationSeconds must be finite and non-negative");
        }
    }
}
