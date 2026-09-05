package ai.geoguide.routing.application.port;

import ai.geoguide.routing.domain.Route;
import ai.geoguide.routing.domain.RoutePoint;

public interface RoutingProvider {

    Route calculate(RoutePoint origin, RoutePoint destination, String profile);
}
