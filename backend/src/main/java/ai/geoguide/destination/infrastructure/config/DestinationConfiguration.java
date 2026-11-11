package ai.geoguide.destination.infrastructure.config;

import ai.geoguide.destination.application.SearchDestinations;
import ai.geoguide.destination.application.port.DestinationRepository;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnProperty(name = "spring.datasource.url")
public class DestinationConfiguration {
    @Bean
    SearchDestinations searchDestinations(DestinationRepository repository) {
        return new SearchDestinations(repository);
    }
}
