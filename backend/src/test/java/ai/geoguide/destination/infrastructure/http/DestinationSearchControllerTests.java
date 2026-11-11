package ai.geoguide.destination.infrastructure.http;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import ai.geoguide.destination.application.SearchDestinations;
import ai.geoguide.destination.application.port.DestinationRepository;
import ai.geoguide.destination.domain.Destination;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;

class DestinationSearchControllerTests {
    private final DestinationRepository repository = mock(DestinationRepository.class);
    private MockMvc mvc;

    @BeforeEach
    void setUp() {
        mvc = MockMvcBuilders.standaloneSetup(new DestinationSearchController(new SearchDestinations(repository))).build();
    }

    @Test
    void returnsContextCoordinatesAndAttributionForExplicitSearch() throws Exception {
        var destination = new Destination(UUID.randomUUID(), "Plaza De Armas De Canta", null, "LANDMARK",
                "Lima, Canta, CANTA", -11.4669625, -76.6247746, "MINCETUR", "14068",
                "https://example.test/14068", "ODC-BY-1.0", "MINCETUR — Inventario", List.of());
        when(repository.search("plaza de armas de canta", 10)).thenReturn(List.of(destination));

        mvc.perform(post("/api/v1/destinations/search").contentType("application/json")
                        .content("{\"query\":\"PLAZA DE ARMAS DE CANTA\"}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.results[0].name").value("Plaza De Armas De Canta"))
                .andExpect(jsonPath("$.results[0].administrativeContext").value("Lima, Canta, CANTA"))
                .andExpect(jsonPath("$.results[0].latitude").value(-11.4669625))
                .andExpect(jsonPath("$.results[0].attribution").value("MINCETUR — Inventario"));
    }

    @Test
    void rejectsQueryBelowMinimumLength() throws Exception {
        mvc.perform(post("/api/v1/destinations/search").contentType("application/json")
                        .content("{\"query\":\"a\"}"))
                .andExpect(status().isBadRequest());
    }
}
