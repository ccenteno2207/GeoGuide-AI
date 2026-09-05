package ai.geoguide.routing.application;

import static org.assertj.core.api.Assertions.assertThat;

import ai.geoguide.routing.domain.Route;
import ai.geoguide.routing.domain.RouteGeometry;
import ai.geoguide.routing.domain.RoutePoint;
import java.util.List;
import org.junit.jupiter.api.Test;

class PlanRouteUseCaseTests {

    @Test
    void delegatesWithConfiguredProfile() {
        RoutePoint origin = new RoutePoint(-12.0, -77.0);
        RoutePoint destination = new RoutePoint(-12.1, -77.1);
        Route expected = new Route(origin, destination, 1, 2, new RouteGeometry(List.of(origin, destination)));
        CapturingProvider provider = new CapturingProvider(expected);

        Route actual = new PlanRouteUseCase(provider, "car").plan(origin, destination);

        assertThat(actual).isEqualTo(expected);
        assertThat(provider.profile).isEqualTo("car");
    }

    private static final class CapturingProvider implements ai.geoguide.routing.application.port.RoutingProvider {
        private final Route route;
        private String profile;

        private CapturingProvider(Route route) {
            this.route = route;
        }

        @Override
        public Route calculate(RoutePoint origin, RoutePoint destination, String profile) {
            this.profile = profile;
            return route;
        }
    }
}
