package ai.geoguide.media.infrastructure.http;

import static org.assertj.core.api.Assertions.assertThat;

import ai.geoguide.media.infrastructure.persistence.PoiMediaRepository.Asset;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class PoiMediaControllerTests {
    private final ObjectMapper objectMapper = new ObjectMapper();

    @Test
    void administrativeResponseDoesNotExposePrivateStorageObjectKey() throws Exception {
        Asset asset = new Asset(UUID.randomUUID(), UUID.randomUUID(), "private/internal/key", "image/png",
                "A".repeat(64), 128, 1, 1, "synthetic", "fixture:media", "CC0", "synthetic attribution",
                "fixture evidence", "DOCUMENTED", "PUBLISHED", true, 3);

        var response = objectMapper.valueToTree(PoiMediaController.toResponse(asset));

        assertThat(response.has("objectKey")).isFalse();
        assertThat(response.has("private/internal/key")).isFalse();
        assertThat(response.get("id").asText()).isEqualTo(asset.id().toString());
        assertThat(response.get("state").asText()).isEqualTo("PUBLISHED");
    }
}
