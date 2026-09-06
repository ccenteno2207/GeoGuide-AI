package ai.geoguide.discovery.infrastructure.http;

import ai.geoguide.discovery.application.RouteDiscoveryUseCase;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;

@RestController
@ConditionalOnProperty(name = "spring.datasource.url")
@RequestMapping("/api/v1/routes")
public class RouteDiscoveryController {
    private final RouteDiscoveryUseCase useCase;
    public RouteDiscoveryController(RouteDiscoveryUseCase useCase) { this.useCase = useCase; }
    @PostMapping("/discover")
    public RouteDiscoveryResponse discover(@RequestBody DiscoveryRequest request) {
        try { return RouteDiscoveryResponse.from(useCase.discover(request.originPoint(), request.destinationPoint(), request.criteria())); }
        catch (DiscoveryException exception) { throw exception; }
        catch (IllegalArgumentException exception) { throw new DiscoveryException(DiscoveryError.INVALID_DISCOVERY_REQUEST); }
        catch (ai.geoguide.routing.application.RoutingException exception) { throw exception; }
        catch (RuntimeException exception) { throw new DiscoveryException(DiscoveryError.DISCOVERY_ERROR); }
    }
}
