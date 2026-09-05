package ai.geoguide.routing.domain;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.List;
import org.junit.jupiter.api.Test;

class RouteTests {

    @Test
    void geometryRequiresTwoPositions() {
        assertThatThrownBy(() -> new RouteGeometry(List.of(new RoutePoint(0, 0))))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void routeRejectsNegativeDistance() {
        RoutePoint point = new RoutePoint(0, 0);
        RouteGeometry geometry = new RouteGeometry(List.of(point, new RoutePoint(1, 1)));

        assertThatThrownBy(() -> new Route(point, point, -1, 0, geometry))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
