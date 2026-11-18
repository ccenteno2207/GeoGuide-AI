package ai.geoguide.media.infrastructure.minio;

import io.minio.MinioClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConditionalOnProperty(name = "geoguide.media.storage.enabled", havingValue = "true")
public class MinioStorageConfiguration {
    @Bean
    MinioClient minioClient(@Value("${geoguide.media.storage.endpoint}") String endpoint,
            @Value("${geoguide.media.storage.access-key}") String accessKey,
            @Value("${geoguide.media.storage.secret-key}") String secretKey) {
        if (endpoint.isBlank() || accessKey.isBlank() || secretKey.isBlank()) {
            throw new IllegalStateException("MinIO endpoint and credentials are required when private media storage is enabled.");
        }
        return MinioClient.builder().endpoint(endpoint).credentials(accessKey, secretKey).build();
    }
}
