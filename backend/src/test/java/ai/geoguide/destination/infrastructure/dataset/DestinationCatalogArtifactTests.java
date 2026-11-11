package ai.geoguide.destination.infrastructure.dataset;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.InputStream;
import org.junit.jupiter.api.Test;

class DestinationCatalogArtifactTests {
    private final ObjectMapper mapper = new ObjectMapper();

    @Test
    void pilotCatalogContainsOnlyCoordinateValidSourcedEntries() throws Exception {
        try (InputStream input = getClass().getResourceAsStream("/data/destination-search/mincetur-pilot-v1.json")) {
            var catalog = mapper.readValue(input, DestinationCatalogLoader.Catalog.class);
            assertThat(catalog.version()).isEqualTo("mincetur-pilot-v1");
            assertThat(catalog.sourceLicense()).isEqualTo("ODC-BY-1.0");
            assertThat(catalog.destinations()).hasSize(9);
            assertThat(catalog.destinations()).allSatisfy(entry -> {
                assertThat(entry.sourceRecordId()).isNotBlank();
                assertThat(entry.sourceUrl()).startsWith("https://");
                assertThat(entry.latitude()).isBetween(-18.5, 0.0);
                assertThat(entry.longitude()).isBetween(-82.0, -68.0);
            });
        }
    }
}
