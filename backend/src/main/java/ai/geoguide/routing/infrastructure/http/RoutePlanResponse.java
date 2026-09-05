package ai.geoguide.routing.infrastructure.http;

import ai.geoguide.routing.domain.Route;
import java.util.List;

public record RoutePlanResponse(
        PointDto origin,
        PointDto destination,
        double distanceMeters,
        double durationSeconds,
        GeoJsonLineString geometry) {

    static RoutePlanResponse from(Route route) {
        return new RoutePlanResponse(
                from(route.origin()),
                from(route.destination()),
                route.distanceMeters(),
                route.durationSeconds(),
                new GeoJsonLineString("LineString", route.geometry().positions().stream()
                        .map(point -> List.of(point.longitude(), point.latitude()))
                        .toList()));
    }

    private static PointDto from(ai.geoguide.routing.domain.RoutePoint point) {
        return new PointDto(point.latitude(), point.longitude());
    }

    public record GeoJsonLineString(String type, List<List<Double>> coordinates) {
    }
}
