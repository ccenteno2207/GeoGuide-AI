package ai.geoguide.poi.infrastructure.dataset;

import ai.geoguide.poi.application.port.CategoryRepository;
import ai.geoguide.poi.application.port.PoiRepository;
import ai.geoguide.poi.domain.Category;
import ai.geoguide.poi.domain.GeoPoint;
import ai.geoguide.poi.domain.PoiId;
import ai.geoguide.poi.domain.PointOfInterest;
import ai.geoguide.poi.domain.SourceReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.io.InputStream;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@ConditionalOnProperty(name = "geoguide.p3-data.enabled", havingValue = "true")
public class P3DatasetLoader implements ApplicationRunner {

    private final ObjectMapper objectMapper;
    private final CategoryRepository categoryRepository;
    private final PoiRepository poiRepository;
    private final Resource taxonomyResource;
    private final Resource datasetResource;

    public P3DatasetLoader(
            ObjectMapper objectMapper,
            CategoryRepository categoryRepository,
            PoiRepository poiRepository,
            @Value("${geoguide.p3-data.taxonomy:classpath:data/p3/taxonomy-v1.json}") Resource taxonomyResource,
            @Value("${geoguide.p3-data.dataset:classpath:data/p3/lima-obrajillo-v1.json}") Resource datasetResource) {
        this.objectMapper = objectMapper;
        this.categoryRepository = categoryRepository;
        this.poiRepository = poiRepository;
        this.taxonomyResource = taxonomyResource;
        this.datasetResource = datasetResource;
    }

    @Override
    @Transactional
    public void run(ApplicationArguments args) throws IOException {
        load();
    }

    @Transactional
    public LoadResult load() throws IOException {
        TaxonomyFile taxonomy = read(taxonomyResource, TaxonomyFile.class);
        DatasetFile dataset = read(datasetResource, DatasetFile.class);
        Map<String, Category> categories = new LinkedHashMap<>();
        for (CategoryEntry entry : taxonomy.categories()) {
            Category category = new Category(entry.id(), entry.code(), entry.name(), entry.active());
            categoryRepository.save(category);
            categories.put(category.code(), category);
        }
        for (PoiEntry entry : dataset.pois()) {
            Category category = categories.get(entry.categoryCode());
            if (category == null) {
                throw new IllegalArgumentException("unknown category code: " + entry.categoryCode());
            }
            List<SourceReference> provenance = entry.provenance().stream()
                    .map(P3DatasetLoader::toSourceReference)
                    .toList();
            poiRepository.save(new PointOfInterest(
                    new PoiId(entry.id()), entry.name(), entry.description(), category,
                    new GeoPoint(entry.latitude(), entry.longitude()), entry.active(),
                    entry.createdAt(), entry.updatedAt(), provenance));
        }
        return new LoadResult(taxonomy.version(), dataset.version(), categories.size(), dataset.pois().size());
    }

    private <T> T read(Resource resource, Class<T> type) throws IOException {
        try (InputStream input = resource.getInputStream()) {
            return objectMapper.readValue(input, type);
        }
    }

    private static SourceReference toSourceReference(ProvenanceEntry entry) {
        return new SourceReference(
                entry.id(), entry.sourceSystem(), entry.sourceRecordId(), entry.sourceUrl(),
                entry.retrievedAt(), entry.license(), entry.attribution(),
                entry.incorporationMethod(), entry.logicalKey());
    }

    public record LoadResult(String taxonomyVersion, String datasetVersion, int categoryCount, int poiCount) {}

    public record TaxonomyFile(String version, List<CategoryEntry> categories) {}

    public record CategoryEntry(UUID id, String code, String name, boolean active) {}

    public record DatasetFile(String version, String corridor, List<PoiEntry> pois) {}

    public record PoiEntry(
            UUID id,
            String name,
            String description,
            String categoryCode,
            double latitude,
            double longitude,
            boolean active,
            Instant createdAt,
            Instant updatedAt,
            List<ProvenanceEntry> provenance) {}

    public record ProvenanceEntry(
            UUID id,
            String sourceSystem,
            String sourceRecordId,
            String sourceUrl,
            Instant retrievedAt,
            String license,
            String attribution,
            String incorporationMethod,
            String logicalKey) {}
}
