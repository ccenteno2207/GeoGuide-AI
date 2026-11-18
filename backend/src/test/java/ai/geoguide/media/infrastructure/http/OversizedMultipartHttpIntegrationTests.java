package ai.geoguide.media.infrastructure.http;

import static org.assertj.core.api.Assertions.assertThat;

import ai.geoguide.admin.infrastructure.http.AdminApiExceptionHandler;
import java.util.concurrent.atomic.AtomicInteger;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringBootConfiguration;
import org.springframework.boot.autoconfigure.EnableAutoConfiguration;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.actuate.autoconfigure.security.servlet.ManagementWebSecurityAutoConfiguration;
import org.springframework.boot.autoconfigure.security.servlet.SecurityAutoConfiguration;
import org.springframework.boot.autoconfigure.security.servlet.SecurityFilterAutoConfiguration;
import org.springframework.boot.autoconfigure.security.oauth2.resource.servlet.OAuth2ResourceServerAutoConfiguration;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Import;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

@SpringBootTest(
        classes = OversizedMultipartHttpIntegrationTests.TestApplication.class,
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = {
                "spring.servlet.multipart.max-file-size=1KB",
                "spring.servlet.multipart.max-request-size=2KB",
                "spring.servlet.multipart.resolve-lazily=true"
        })
class OversizedMultipartHttpIntegrationTests {

    @Autowired
    private TestRestTemplate client;

    @Autowired
    private UploadProbe uploadProbe;

    @Test
    void oversizedMultipartReturns413BeforeUploadHandlerCanPersistAnything() {
        byte[] oversizedBytes = new byte[4096];
        MultiValueMap<String, Object> parts = new LinkedMultiValueMap<>();
        parts.add("file", new ByteArrayResource(oversizedBytes) {
            @Override
            public String getFilename() {
                return "synthetic-oversized.png";
            }
        });

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.MULTIPART_FORM_DATA);
        var response = client.postForEntity("/api/v1/admin/pois/synthetic/media",
                new HttpEntity<>(parts, headers), String.class);

        assertThat(response.getStatusCode().value()).isEqualTo(413);
        assertThat(response.getHeaders().getContentType())
                .as("status=%s body=%s", response.getStatusCode(), response.getBody())
                .isNotNull();
        assertThat(response.getHeaders().getContentType().toString()).contains("application/problem+json");
        assertThat(response.getBody()).contains("El archivo supera el tamaño máximo permitido.")
                .doesNotContain("MaxUploadSizeExceededException", "FileSizeLimitExceededException", "synthetic-oversized.png");
        assertThat(uploadProbe.invocations()).isZero();
    }

    @SpringBootConfiguration
    @EnableAutoConfiguration(exclude = {
            SecurityAutoConfiguration.class,
            SecurityFilterAutoConfiguration.class,
            OAuth2ResourceServerAutoConfiguration.class,
            DataSourceAutoConfiguration.class,
            ManagementWebSecurityAutoConfiguration.class
    })
    @Import(AdminApiExceptionHandler.class)
    static class TestApplication {
        @Bean
        UploadProbe uploadProbe() {
            return new UploadProbe();
        }
    }

    @org.springframework.web.bind.annotation.RestController
    static class UploadProbe {
        private final AtomicInteger calls = new AtomicInteger();

        @org.springframework.web.bind.annotation.PostMapping(
                path = "/api/v1/admin/pois/synthetic/media",
                consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
        void upload(@org.springframework.web.bind.annotation.RequestParam("file")
                org.springframework.web.multipart.MultipartFile file) {
            calls.incrementAndGet();
        }

        int invocations() {
            return calls.get();
        }
    }
}
