package ai.geoguide.routing.infrastructure.graphhopper;

import ai.geoguide.routing.application.RoutingError;
import ai.geoguide.routing.application.RoutingException;
import ai.geoguide.routing.application.port.RoutingProvider;
import ai.geoguide.routing.domain.Route;
import ai.geoguide.routing.domain.RouteGeometry;
import ai.geoguide.routing.domain.RoutePoint;
import com.fasterxml.jackson.databind.JsonNode;
import java.net.SocketTimeoutException;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.http.HttpStatusCode;
import org.springframework.web.client.ResourceAccessException;
import org.springframework.web.client.RestClient;
import org.springframework.web.client.RestClientResponseException;

public final class GraphHopperRoutingProvider implements RoutingProvider {

    private final RestClient restClient;

    public GraphHopperRoutingProvider(RestClient.Builder restClientBuilder, String baseUrl, Duration timeout) {
        SimpleClientHttpRequestFactory requestFactory = new SimpleClientHttpRequestFactory();
        requestFactory.setConnectTimeout(timeout);
        requestFactory.setReadTimeout(timeout);
        this.restClient = restClientBuilder.baseUrl(baseUrl).requestFactory(requestFactory).build();
    }

    @Override
    public Route calculate(RoutePoint origin, RoutePoint destination, String profile) {
        try {
            JsonNode response = restClient.get()
                    .uri(builder -> builder.path("/route")
                            .queryParam("point", origin.latitude() + "," + origin.longitude())
                            .queryParam("point", destination.latitude() + "," + destination.longitude())
                            .queryParam("profile", profile)
                            .queryParam("points_encoded", false)
                            .build())
                    .retrieve()
                    .onStatus(HttpStatusCode::is4xxClientError, (request, clientResponse) -> {
                        throw new RoutingException(RoutingError.NO_ROUTE_FOUND);
                    })
                    .onStatus(HttpStatusCode::is5xxServerError, (request, clientResponse) -> {
                        throw new RoutingException(RoutingError.PROVIDER_ERROR);
                    })
                    .body(JsonNode.class);
            return toRoute(origin, destination, response);
        } catch (RoutingException exception) {
            throw exception;
        } catch (ResourceAccessException exception) {
            if (hasTimeoutCause(exception)) {
                throw new RoutingException(RoutingError.PROVIDER_TIMEOUT, exception);
            }
            throw new RoutingException(RoutingError.PROVIDER_UNAVAILABLE, exception);
        } catch (RestClientResponseException exception) {
            throw new RoutingException(RoutingError.PROVIDER_ERROR, exception);
        } catch (RuntimeException exception) {
            throw new RoutingException(RoutingError.PROVIDER_ERROR, exception);
        }
    }

    private Route toRoute(RoutePoint origin, RoutePoint destination, JsonNode response) {
        if (response == null || !response.path("paths").isArray() || response.path("paths").isEmpty()) {
            throw new RoutingException(RoutingError.NO_ROUTE_FOUND);
        }
        JsonNode path = response.path("paths").get(0);
        JsonNode coordinates = path.path("points").path("coordinates");
        if (!path.path("distance").isNumber() || !path.path("time").isNumber() || !coordinates.isArray()) {
            throw new RoutingException(RoutingError.PROVIDER_ERROR);
        }
        List<RoutePoint> positions = new ArrayList<>();
        for (JsonNode coordinate : coordinates) {
            if (!coordinate.isArray() || coordinate.size() < 2
                    || !coordinate.get(0).isNumber() || !coordinate.get(1).isNumber()) {
                throw new RoutingException(RoutingError.PROVIDER_ERROR);
            }
            try {
                positions.add(new RoutePoint(coordinate.get(1).asDouble(), coordinate.get(0).asDouble()));
            } catch (IllegalArgumentException exception) {
                throw new RoutingException(RoutingError.PROVIDER_ERROR, exception);
            }
        }
        try {
            return new Route(origin, destination, path.path("distance").asDouble(),
                    path.path("time").asDouble() / 1000d, new RouteGeometry(positions));
        } catch (IllegalArgumentException exception) {
            throw new RoutingException(RoutingError.PROVIDER_ERROR, exception);
        }
    }

    private boolean hasTimeoutCause(Throwable throwable) {
        Throwable current = throwable;
        while (current != null) {
            if (current instanceof SocketTimeoutException) {
                return true;
            }
            current = current.getCause();
        }
        return false;
    }
}
