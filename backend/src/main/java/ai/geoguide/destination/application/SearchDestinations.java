package ai.geoguide.destination.application;

import ai.geoguide.destination.application.port.DestinationRepository;
import ai.geoguide.destination.domain.Destination;
import java.util.List;

public class SearchDestinations {
    public static final int MAX_LIMIT = 20;
    private final DestinationRepository repository;

    public SearchDestinations(DestinationRepository repository) { this.repository = repository; }

    public List<Destination> search(String query, Integer requestedLimit) {
        String normalized = Destination.normalize(query);
        if (normalized.length() < 2 || normalized.length() > 100) {
            throw new IllegalArgumentException("query must contain 2 to 100 characters");
        }
        int limit = requestedLimit == null ? 10 : requestedLimit;
        if (limit < 1 || limit > MAX_LIMIT) throw new IllegalArgumentException("limit must be between 1 and 20");
        return repository.search(normalized, limit);
    }
}
