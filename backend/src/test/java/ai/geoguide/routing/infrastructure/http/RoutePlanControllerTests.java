package ai.geoguide.routing.infrastructure.http;

import static org.assertj.core.api.Assertions.assertThat;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.geoguide.GeoGuideApplication;
import ai.geoguide.routing.application.RoutingError;
import ai.geoguide.routing.application.RoutingException;
import ai.geoguide.routing.application.port.RoutingProvider;
import ai.geoguide.routing.domain.Route;
import ai.geoguide.routing.domain.RouteGeometry;
import ai.geoguide.routing.domain.RoutePoint;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Primary;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

@SpringBootTest(classes = {GeoGuideApplication.class, RoutePlanControllerTests.TestRoutingConfiguration.class}, properties = {
        "spring.autoconfigure.exclude=org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration,org.springframework.boot.autoconfigure.flyway.FlywayAutoConfiguration"
})
@AutoConfigureMockMvc
class RoutePlanControllerTests {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private TestRoutingProvider routingProvider;

    @BeforeEach
    void resetProvider() {
        routingProvider.reset();
    }

    @Test
    void returnsGeoJsonForValidRoute() throws Exception {
        mockMvc.perform(post("/api/v1/routes/plan").contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"origin":{"latitude":-12.0478931,"longitude":-77.0459961},
                                 "destination":{"latitude":-12.1255265,"longitude":-77.0344948}}
                                """))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.distanceMeters").value(10615.548))
                .andExpect(jsonPath("$.durationSeconds").value(719.133))
                .andExpect(jsonPath("$.geometry.type").value("LineString"))
                .andExpect(jsonPath("$.geometry.coordinates[0][0]").value(-77.0459961));
    }

    @Test
    void rejectsInvalidRequestWithoutCallingProvider() throws Exception {
        mockMvc.perform(post("/api/v1/routes/plan").contentType(MediaType.APPLICATION_JSON)
                        .content("{" + "\"origin\":{\"latitude\":99,\"longitude\":0}}"))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.code").value("INVALID_REQUEST"));

        assertThat(routingProvider.calls.get()).isZero();
    }

    @Test
    void mapsRoutingErrorsToProblemDetails() throws Exception {
        assertProblem(RoutingError.PROVIDER_TIMEOUT, 504);
        assertProblem(RoutingError.PROVIDER_UNAVAILABLE, 503);
        assertProblem(RoutingError.NO_ROUTE_FOUND, 404);
        assertProblem(RoutingError.PROVIDER_ERROR, 502);
    }

    private void assertProblem(RoutingError error, int status) throws Exception {
        routingProvider.error = error;
        mockMvc.perform(post("/api/v1/routes/plan").contentType(MediaType.APPLICATION_JSON)
                        .content("""
                                {"origin":{"latitude":0,"longitude":0},"destination":{"latitude":1,"longitude":1}}
                                """))
                .andExpect(status().is(status))
                .andExpect(jsonPath("$.code").value(error.name()));
    }

    @TestConfiguration
    static class TestRoutingConfiguration {
        @Bean
        @Primary
        TestRoutingProvider testRoutingProvider() {
            return new TestRoutingProvider();
        }
    }

    static final class TestRoutingProvider implements RoutingProvider {
        private final AtomicInteger calls = new AtomicInteger();
        private RoutingError error;

        void reset() {
            calls.set(0);
            error = null;
        }

        @Override
        public Route calculate(RoutePoint origin, RoutePoint destination, String profile) {
            calls.incrementAndGet();
            if (error != null) {
                throw new RoutingException(error);
            }
            return new Route(origin, destination, 10615.548, 719.133,
                    new RouteGeometry(List.of(origin, destination)));
        }
    }
}
