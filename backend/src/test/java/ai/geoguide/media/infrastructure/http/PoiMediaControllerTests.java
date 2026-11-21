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

    @Test
    void ownedPhotoResponseExposesReceiptAndNullableExternalSourceWithoutStorageKey() throws Exception {
        Asset asset = new Asset(UUID.randomUUID(), UUID.randomUUID(), "private/opaque", "image/jpeg",
                "B".repeat(64), 256, 2, 2, "Synthetic author", null, "Rutea publication authorization",
                "© Synthetic author", "authorization-fixture:1", "UNVERIFIED", "DRAFT", false, 0,
                "synthetic image", 0, "OWN_PHOTOGRAPH", null, "Obrajillo", true,
                "OWN_PHOTO_DECLARATION_V1", "synthetic-editor", null,
                "Declaration text fixture");

        var response = objectMapper.valueToTree(PoiMediaController.toResponse(asset));

        assertThat(response.get("sourceType").asText()).isEqualTo("OWN_PHOTOGRAPH");
        assertThat(response.get("sourceUrl").isNull()).isTrue();
        assertThat(response.get("authorDeclarationAccepted").asBoolean()).isTrue();
        assertThat(response.get("authorDeclarationBy").asText()).isEqualTo("synthetic-editor");
        assertThat(response.get("authorDeclarationVersion").asText()).isEqualTo("OWN_PHOTO_DECLARATION_V1");
        assertThat(response.get("objectKey")).isNull();
    }
}
