package ai.geoguide.admin.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.api.Test;

class GeographicReviewServiceTests {
    private final GeographicReviewService service = new GeographicReviewService();

    @Test
    void plausibleCoordinatesRemainPendingUntilReviewerEvidenceExists() {
        var candidate = service.assess(-14.087854, -75.762915, "Ica, Ica, Ica", "source:MINCETUR-237");
        assertThat(candidate.state()).isEqualTo(GeographicReviewService.ReviewState.PENDING_HUMAN_REVIEW);
        assertThat(service.markHumanVerified(candidate, EditorialRole.REVIEWER, "reviewer-2", "map evidence")
                .state()).isEqualTo(GeographicReviewService.ReviewState.HUMAN_VERIFIED);
    }

    @Test
    void outOfPeruOrMissingEvidenceIsQuarantinedAndEditorsCannotVerify() {
        assertThat(service.assess(40, -75, "Lima", "source").state())
                .isEqualTo(GeographicReviewService.ReviewState.QUARANTINED);
        var pending = service.assess(-14, -75, "Lima", "source");
        assertThatThrownBy(() -> service.markHumanVerified(pending, EditorialRole.EDITOR, "editor", "evidence"))
                .isInstanceOf(SecurityException.class);
    }
}
