package ai.geoguide.poi.infrastructure.dataset;

import static org.assertj.core.api.Assertions.assertThat;

import com.fasterxml.jackson.databind.json.JsonMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import java.util.HashSet;
import org.junit.jupiter.api.Test;

class P3DatasetArtifactTests {

    private final JsonMapper objectMapper = JsonMapper.builder()
            .addModule(new JavaTimeModule())
            .build();

    @Test
    void taxonomyHasStableUniqueDocumentedCategories() throws Exception {
        try (var input = getClass().getResourceAsStream("/data/p3/taxonomy-v1.json")) {
            P3DatasetLoader.TaxonomyFile taxonomy = objectMapper.readValue(
                    input, P3DatasetLoader.TaxonomyFile.class);

            assertThat(taxonomy.version()).isEqualTo("p3-taxonomy-v1");
            assertThat(taxonomy.categories()).hasSize(15);
            assertThat(taxonomy.categories().stream().map(P3DatasetLoader.CategoryEntry::code))
                    .doesNotHaveDuplicates()
                    .contains("ARCHAEOLOGICAL_SITE", "HISTORIC_CHURCH", "MONUMENT", "WATERFALL");
        }
    }

    @Test
    void datasetIsTraceableDistributedAndInsideP1Coverage() throws Exception {
        try (var input = getClass().getResourceAsStream("/data/p3/lima-obrajillo-v1.json")) {
            P3DatasetLoader.DatasetFile dataset = objectMapper.readValue(
                    input, P3DatasetLoader.DatasetFile.class);

            assertThat(dataset.version()).isEqualTo("p3-lima-obrajillo-v1");
            assertThat(dataset.corridor()).isEqualTo("Lima → Obrajillo");
            assertThat(dataset.pois()).isNotEmpty();
            assertThat(dataset.pois().stream().map(P3DatasetLoader.PoiEntry::id)).doesNotHaveDuplicates();
            assertThat(dataset.pois().stream().map(P3DatasetLoader.PoiEntry::latitude))
                    .allMatch(latitude -> latitude >= -13.50 && latitude <= -11.40);
            assertThat(dataset.pois().stream().map(P3DatasetLoader.PoiEntry::longitude))
                    .allMatch(longitude -> longitude >= -77.40 && longitude <= -75.85);
            assertThat(dataset.pois()).allMatch(poi -> !poi.provenance().isEmpty());
            assertThat(dataset.pois().stream().flatMap(poi -> poi.provenance().stream())
                    .map(P3DatasetLoader.ProvenanceEntry::logicalKey))
                    .doesNotHaveDuplicates();
            assertThat(new HashSet<>(dataset.pois().stream()
                    .map(poi -> Math.round(poi.latitude() * 100))
                    .toList())).hasSizeGreaterThan(1);
        }
    }
}
