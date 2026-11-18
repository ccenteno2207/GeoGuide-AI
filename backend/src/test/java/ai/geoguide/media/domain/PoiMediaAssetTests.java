package ai.geoguide.media.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class PoiMediaAssetTests {
    @Test
    void realAssetCannotPublishWithoutDocumentedRights() {
        var unverified = asset(PoiMediaAsset.RightsStatus.UNVERIFIED, null, null, null)
                .submitForReview();
        assertThatThrownBy(() -> unverified.publish(PoiMediaAsset.MediaReviewerRole.REVIEWER,
                "reviewer", Instant.now(), "approved"))
                .isInstanceOf(IllegalStateException.class).hasMessageContaining("documented rights");
    }

    @Test
    void syntheticRightsDocumentedAssetHasExplicitReviewAndWithdrawalLifecycle() {
        var pending = asset(PoiMediaAsset.RightsStatus.DOCUMENTED,
                "CC-BY-4.0", "Example creator", "rights-ticket:demo-1").submitForReview();
        var published = pending.publish(PoiMediaAsset.MediaReviewerRole.REVIEWER, "reviewer-3",
                Instant.parse("2026-11-17T13:00:00Z"), "demo fixture approved");
        assertThat(published.state()).isEqualTo(PoiMediaAsset.MediaState.PUBLISHED);
        assertThat(published.withdraw().state()).isEqualTo(PoiMediaAsset.MediaState.WITHDRAWN);
        assertThatThrownBy(() -> pending.publish(PoiMediaAsset.MediaReviewerRole.EDITOR,
                "reviewer-3", Instant.now(), "ok"))
                .isInstanceOf(IllegalStateException.class);
    }

    private static PoiMediaAsset asset(PoiMediaAsset.RightsStatus rights, String license,
            String attribution, String evidence) {
        return new PoiMediaAsset(UUID.randomUUID(), UUID.randomUUID(), "opaque/private/key",
                "image/png", "A".repeat(64), 128, "synthetic fixture", "https://example.test/source",
                license, attribution, evidence, rights, PoiMediaAsset.MediaState.DRAFT, 0);
    }
}
