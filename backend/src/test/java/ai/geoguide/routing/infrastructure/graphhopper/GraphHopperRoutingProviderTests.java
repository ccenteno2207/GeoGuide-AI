package ai.geoguide.routing.infrastructure.graphhopper;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ai.geoguide.routing.application.RoutingError;
import ai.geoguide.routing.application.RoutingException;
import ai.geoguide.routing.domain.Route;
import ai.geoguide.routing.domain.RoutePoint;
import com.sun.net.httpserver.HttpExchange;
import com.sun.net.httpserver.HttpServer;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;
import org.springframework.web.client.RestClient;

class GraphHopperRoutingProviderTests {

    private HttpServer server;

    @AfterEach
    void stopServer() {
        if (server != null) {
            server.stop(0);
        }
    }

    @Test
    void normalizesGraphHopperResponse() throws Exception {
        startServer(200, "{\"paths\":[{\"distance\":10615.548,\"time\":719133,\"points\":{\"coordinates\":[[-77.0459961,-12.0478931],[-77.0344948,-12.1255265]]}}]}");

        Route route = provider().calculate(new RoutePoint(-12.0478931, -77.0459961),
                new RoutePoint(-12.1255265, -77.0344948), "car");

        assertThat(route.distanceMeters()).isEqualTo(10615.548);
        assertThat(route.durationSeconds()).isEqualTo(719.133);
        assertThat(route.geometry().positions()).hasSize(2);
        assertThat(route.geometry().positions().get(0)).isEqualTo(new RoutePoint(-12.0478931, -77.0459961));
    }

    @Test
    void mapsEmptyPathsToNoRoute() throws Exception {
        startServer(200, "{\"paths\":[]}");

        assertThatThrownBy(() -> provider().calculate(new RoutePoint(0, 0), new RoutePoint(1, 1), "car"))
                .isInstanceOf(RoutingException.class)
                .extracting(exception -> ((RoutingException) exception).error())
                .isEqualTo(RoutingError.NO_ROUTE_FOUND);
    }

    @Test
    void mapsMalformedResponseToProviderError() throws Exception {
        startServer(200, "{\"paths\":[{}]}");

        assertThatThrownBy(() -> provider().calculate(new RoutePoint(0, 0), new RoutePoint(1, 1), "car"))
                .isInstanceOf(RoutingException.class)
                .extracting(exception -> ((RoutingException) exception).error())
                .isEqualTo(RoutingError.PROVIDER_ERROR);
    }

    private GraphHopperRoutingProvider provider() {
        return new GraphHopperRoutingProvider(
                RestClient.builder(), "http://localhost:" + server.getAddress().getPort(), Duration.ofSeconds(1));
    }

    private void startServer(int status, String body) throws IOException {
        server = HttpServer.create(new InetSocketAddress("localhost", 0), 0);
        server.createContext("/route", exchange -> respond(exchange, status, body));
        server.start();
    }

    private void respond(HttpExchange exchange, int status, String body) throws IOException {
        byte[] bytes = body.getBytes(StandardCharsets.UTF_8);
        exchange.getResponseHeaders().set("Content-Type", "application/json");
        exchange.sendResponseHeaders(status, bytes.length);
        exchange.getResponseBody().write(bytes);
        exchange.close();
    }
}
