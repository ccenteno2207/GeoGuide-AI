package ai.geoguide.destination.application.port;

import ai.geoguide.destination.domain.Destination;
import java.util.List;

public interface DestinationRepository {
    List<Destination> search(String normalizedQuery, int limit);
    void saveCatalogEntry(Destination destination, String catalogVersion, java.time.LocalDate verifiedAt);
}
