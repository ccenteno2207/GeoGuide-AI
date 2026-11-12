package ai.geoguide.destination.infrastructure.dataset;

import ai.geoguide.destination.application.port.DestinationRepository;
import ai.geoguide.destination.domain.Destination;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

@Component
@ConditionalOnProperty(name = "geoguide.destination-catalog.enabled", havingValue = "true")
public class DestinationCatalogLoader implements ApplicationRunner {
    private final ObjectMapper mapper;
    private final DestinationRepository repository;
    private final Resource resource;

    public DestinationCatalogLoader(ObjectMapper mapper, DestinationRepository repository,
            @Value("${geoguide.destination-catalog.resource:classpath:data/destination-search/mincetur-pilot-v1.json}") Resource resource) {
        this.mapper = mapper; this.repository = repository; this.resource = resource;
    }

    @Override @Transactional
    public void run(ApplicationArguments args) throws IOException { load(); }

    @Transactional
    public int load() throws IOException {
        Catalog catalog;
        try (var input = resource.getInputStream()) {
            catalog = mapper.readValue(input, Catalog.class);
        }
        for (Entry entry : catalog.destinations()) {
            UUID id = UUID.nameUUIDFromBytes((catalog.sourceSystem() + ":" + entry.sourceRecordId()).getBytes(java.nio.charset.StandardCharsets.UTF_8));
            List<Destination.Alias> aliases = entry.aliases().stream().map(alias -> new Destination.Alias(
                    UUID.nameUUIDFromBytes((id + ":" + Destination.normalize(alias.name())).getBytes(java.nio.charset.StandardCharsets.UTF_8)),
                    alias.name(), null, alias.sourceReference())).toList();
            Destination destination = new Destination(id, entry.canonicalName(), null, entry.type(), entry.context(),
                    entry.latitude(), entry.longitude(), catalog.sourceSystem(), entry.sourceRecordId(), entry.sourceUrl(),
                    catalog.sourceLicense(), catalog.attribution(), aliases);
            repository.saveCatalogEntry(destination, catalog.version(), LocalDate.parse(catalog.retrievedAt()));
        }
        return catalog.destinations().size();
    }

    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Catalog(String version, String sourceSystem, String sourceLicense, String attribution,
            String retrievedAt, List<Entry> destinations) {}
    @JsonIgnoreProperties(ignoreUnknown = true)
    public record Entry(String sourceRecordId, String canonicalName, String type, String context,
            double latitude, double longitude, String sourceUrl, List<AliasEntry> aliases) {}
    public record AliasEntry(String name, String sourceReference) {}
}
