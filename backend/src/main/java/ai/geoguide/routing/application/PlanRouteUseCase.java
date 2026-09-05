package ai.geoguide.routing.application;

import ai.geoguide.routing.application.port.RoutingProvider;
import ai.geoguide.routing.domain.Route;
import ai.geoguide.routing.domain.RoutePoint;
import java.util.Objects;

public final class PlanRouteUseCase {

    private final RoutingProvider routingProvider;
    private final String profile;

    public PlanRouteUseCase(RoutingProvider routingProvider, String profile) {
        this.routingProvider = Objects.requireNonNull(routingProvider);
        this.profile = Objects.requireNonNull(profile);
    }

    public Route plan(RoutePoint origin, RoutePoint destination) {
        return routingProvider.calculate(origin, destination, profile);
    }
}
