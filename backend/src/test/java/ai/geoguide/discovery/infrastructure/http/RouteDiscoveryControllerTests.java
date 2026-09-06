package ai.geoguide.discovery.infrastructure.http;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.geoguide.discovery.application.RouteDiscoveryResult;
import ai.geoguide.discovery.application.RouteDiscoveryUseCase;
import ai.geoguide.routing.application.RoutingError;
import ai.geoguide.routing.application.RoutingException;
import ai.geoguide.routing.domain.Route;
import ai.geoguide.routing.domain.RouteGeometry;
import ai.geoguide.routing.domain.RoutePoint;
import ai.geoguide.routing.infrastructure.http.RoutingExceptionHandler;
import java.time.Instant;
import java.util.List;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class RouteDiscoveryControllerTests {
    private RouteDiscoveryUseCase useCase;
    private MockMvc mockMvc;

    @BeforeEach
    void setUp() {
        useCase = org.mockito.Mockito.mock(RouteDiscoveryUseCase.class);
        mockMvc = MockMvcBuilders.standaloneSetup(new RouteDiscoveryController(useCase))
                .setControllerAdvice(new DiscoveryExceptionHandler(), new RoutingExceptionHandler()).build();
    }

    @Test
    void returnsEmptyDiscoveryResponseWithDefaults() throws Exception {
        RoutePoint origin = new RoutePoint(-12, -77);
        RoutePoint destination = new RoutePoint(-11, -76);
        Route route = new Route(origin, destination, 1, 2, new RouteGeometry(List.of(origin, destination)));
        when(useCase.discover(any(), any(), any())).thenReturn(
                new RouteDiscoveryResult(route, List.of(), "DISCOVERY_V1", Instant.parse("2026-09-05T00:00:00Z")));
        performValid().andExpect(status().isOk()).andExpect(jsonPath("$.route.geometry.type").value("LineString"))
                .andExpect(jsonPath("$.results").isEmpty()).andExpect(jsonPath("$.algorithmVersion").value("DISCOVERY_V1"));
    }

    @Test
    void rejectsInvalidRequest() throws Exception {
        mockMvc.perform(post("/api/v1/routes/discover").contentType(MediaType.APPLICATION_JSON)
                        .content("{\"origin\":{\"latitude\":99,\"longitude\":0}}"))
                .andExpect(status().isBadRequest()).andExpect(jsonPath("$.code").value("INVALID_DISCOVERY_REQUEST"));
    }

    @Test
    void preservesRoutingErrors() throws Exception {
        when(useCase.discover(any(), any(), any())).thenThrow(new RoutingException(RoutingError.PROVIDER_TIMEOUT));
        performValid().andExpect(status().isGatewayTimeout()).andExpect(jsonPath("$.code").value("PROVIDER_TIMEOUT"));
    }

    @Test
    void mapsUnexpectedDiscoveryErrors() throws Exception {
        when(useCase.discover(any(), any(), any())).thenThrow(new IllegalStateException("internal detail"));
        performValid().andExpect(status().isInternalServerError()).andExpect(jsonPath("$.code").value("DISCOVERY_ERROR"));
    }

    private ResultActions performValid() throws Exception {
        return mockMvc.perform(post("/api/v1/routes/discover").contentType(MediaType.APPLICATION_JSON).content(
                "{\"origin\":{\"latitude\":-12,\"longitude\":-77},\"destination\":{\"latitude\":-11,\"longitude\":-76}}"));
    }
}
