package ai.geoguide.routing.infrastructure.config;

import java.time.Duration;
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties("geoguide.routing")
public record RoutingProperties(String baseUrl, Duration timeout, String profile) {

    public RoutingProperties {
        if (baseUrl == null || baseUrl.isBlank()) {
            baseUrl = "http://graphhopper:8989";
        }
        if (timeout == null || timeout.isNegative() || timeout.isZero()) {
            timeout = Duration.ofSeconds(10);
        }
        if (profile == null || profile.isBlank()) {
            profile = "car";
        }
    }
}
