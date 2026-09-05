package ai.geoguide.routing.infrastructure.http;

import ai.geoguide.routing.application.PlanRouteUseCase;
import ai.geoguide.routing.domain.Route;
import ai.geoguide.routing.domain.RoutePoint;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/routes")
public class RoutePlanController {

    private final PlanRouteUseCase planRouteUseCase;

    public RoutePlanController(PlanRouteUseCase planRouteUseCase) {
        this.planRouteUseCase = planRouteUseCase;
    }

    @PostMapping("/plan")
    public RoutePlanResponse plan(@Valid @RequestBody RoutePlanRequest request) {
        Route route = planRouteUseCase.plan(
                new RoutePoint(request.origin().latitude(), request.origin().longitude()),
                new RoutePoint(request.destination().latitude(), request.destination().longitude()));
        return RoutePlanResponse.from(route);
    }
}
