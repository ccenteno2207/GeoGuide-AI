package ai.geoguide.routing.infrastructure.config;

import ai.geoguide.routing.application.PlanRouteUseCase;
import ai.geoguide.routing.application.port.RoutingProvider;
import ai.geoguide.routing.infrastructure.graphhopper.GraphHopperRoutingProvider;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
@EnableConfigurationProperties(RoutingProperties.class)
public class RoutingConfiguration {

    @Bean
    RoutingProvider routingProvider(
            RestClient.Builder restClientBuilder, ObjectMapper objectMapper, RoutingProperties properties) {
        return new GraphHopperRoutingProvider(
                restClientBuilder, objectMapper, properties.baseUrl(), properties.timeout());
    }

    @Bean
    PlanRouteUseCase planRouteUseCase(RoutingProvider routingProvider, RoutingProperties properties) {
        return new PlanRouteUseCase(routingProvider, properties.profile());
    }
}
