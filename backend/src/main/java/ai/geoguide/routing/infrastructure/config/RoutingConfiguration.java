package ai.geoguide.routing.infrastructure.config;

import ai.geoguide.routing.application.PlanRouteUseCase;
import ai.geoguide.routing.application.port.RoutingProvider;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@EnableConfigurationProperties(RoutingProperties.class)
public class RoutingConfiguration {

    @Bean
    PlanRouteUseCase planRouteUseCase(RoutingProvider routingProvider, RoutingProperties properties) {
        return new PlanRouteUseCase(routingProvider, properties.profile());
    }
}
