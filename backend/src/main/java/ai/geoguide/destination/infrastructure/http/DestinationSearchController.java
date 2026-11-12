package ai.geoguide.destination.infrastructure.http;

import ai.geoguide.destination.application.SearchDestinations;
import ai.geoguide.destination.domain.Destination;
import java.util.List;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/v1/destinations")
@ConditionalOnProperty(name = "spring.datasource.url")
public class DestinationSearchController {
    private final SearchDestinations search;
    public DestinationSearchController(SearchDestinations search) { this.search = search; }

    @PostMapping("/search")
    public SearchResponse search(@RequestBody SearchRequest request) {
        try {
            return new SearchResponse(search.search(request.query(), request.limit()).stream().map(SearchResult::from).toList());
        } catch (IllegalArgumentException exception) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, exception.getMessage());
        }
    }

    public record SearchRequest(String query, Integer limit) {}
    public record SearchResponse(List<SearchResult> results) {}
    public record SearchResult(String id, String name, String type, String administrativeContext,
            double latitude, double longitude, String source, String sourceUrl, String license, String attribution) {
        static SearchResult from(Destination d) { return new SearchResult(d.id().toString(), d.canonicalName(), d.type(),
                d.administrativeContext(), d.latitude(), d.longitude(), d.sourceSystem(), d.sourceUrl(), d.license(), d.attribution()); }
    }
}
