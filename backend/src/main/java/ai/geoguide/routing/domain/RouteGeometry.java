package ai.geoguide.routing.domain;

import java.util.List;

public record RouteGeometry(List<RoutePoint> positions) {

    public RouteGeometry {
        positions = List.copyOf(positions);
        if (positions.size() < 2) {
            throw new IllegalArgumentException("route geometry requires at least two positions");
        }
    }
}
