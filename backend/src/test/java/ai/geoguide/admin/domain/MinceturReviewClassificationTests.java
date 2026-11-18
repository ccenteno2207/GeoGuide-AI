package ai.geoguide.admin.domain;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class MinceturReviewClassificationTests {
    @Test
    void labelsOnlyDeterministicQueueStateAndNeverPromotesUnverifiedRows() {
        assertThat(MinceturReviewClassification.classify("COORDINATE_FORMAT_AMBIGUOUS", false, false))
                .isEqualTo(MinceturReviewClassification.QUARANTINED);
        assertThat(MinceturReviewClassification.classify("NORMALIZED_PENDING_REVIEW", false, false))
                .isEqualTo(MinceturReviewClassification.UNASSIGNED_CANDIDATE);
        assertThat(MinceturReviewClassification.classify("NORMALIZED_PENDING_REVIEW", true, false))
                .isEqualTo(MinceturReviewClassification.POI_EDITORIAL_EXISTS);
        assertThat(MinceturReviewClassification.classify("NORMALIZED_PENDING_REVIEW", false, true))
                .isEqualTo(MinceturReviewClassification.DESTINATION_EDITORIAL_EXISTS);
        assertThat(MinceturReviewClassification.classify("NORMALIZED_PENDING_REVIEW", true, true))
                .isEqualTo(MinceturReviewClassification.POI_AND_DESTINATION_EDITORIALS_EXIST);
        assertThat(MinceturReviewClassification.values()).containsExactly(
                MinceturReviewClassification.QUARANTINED,
                MinceturReviewClassification.POI_AND_DESTINATION_EDITORIALS_EXIST,
                MinceturReviewClassification.POI_EDITORIAL_EXISTS,
                MinceturReviewClassification.DESTINATION_EDITORIAL_EXISTS,
                MinceturReviewClassification.UNASSIGNED_CANDIDATE);
    }
}
