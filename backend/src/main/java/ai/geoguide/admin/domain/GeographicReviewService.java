package ai.geoguide.admin.domain;

import ai.geoguide.poi.domain.GeoPoint;
import java.math.BigDecimal;
import java.util.Objects;

/** Separates numeric plausibility from human verification and public publication. */
public final class GeographicReviewService {
    private static final BigDecimal PERU_LAT_MIN = new BigDecimal("-18.5");
    private static final BigDecimal PERU_LAT_MAX = BigDecimal.ZERO;
    private static final BigDecimal PERU_LON_MIN = new BigDecimal("-82.5");
    private static final BigDecimal PERU_LON_MAX = new BigDecimal("-68.0");

    public Assessment assess(double latitude, double longitude, String administrativeContext, String evidenceReference) {
        Objects.requireNonNull(administrativeContext, "administrativeContext is required");
        Objects.requireNonNull(evidenceReference, "evidenceReference is required");
        GeoPoint point = new GeoPoint(latitude, longitude);
        boolean peruPlausible = BigDecimal.valueOf(latitude).compareTo(PERU_LAT_MIN) >= 0
                && BigDecimal.valueOf(latitude).compareTo(PERU_LAT_MAX) <= 0
                && BigDecimal.valueOf(longitude).compareTo(PERU_LON_MIN) >= 0
                && BigDecimal.valueOf(longitude).compareTo(PERU_LON_MAX) <= 0;
        if (administrativeContext.isBlank() || evidenceReference.isBlank() || !peruPlausible) {
            return new Assessment(point, ReviewState.QUARANTINED, "Context, evidence, or Peru plausibility check failed.");
        }
        return new Assessment(point, ReviewState.PENDING_HUMAN_REVIEW,
                "Numeric bounds and referenced evidence are present; human location review is still required.");
    }

    public Assessment markHumanVerified(Assessment assessment, EditorialRole role, String reviewerId,
            String reviewEvidence) {
        Objects.requireNonNull(assessment, "assessment is required");
        if (role != EditorialRole.REVIEWER && role != EditorialRole.ADMINISTRATOR) {
            throw new SecurityException("Only a reviewer or administrator can verify a location.");
        }
        if (assessment.state() != ReviewState.PENDING_HUMAN_REVIEW || reviewerId == null || reviewerId.isBlank()
                || reviewEvidence == null || reviewEvidence.isBlank()) {
            throw new IllegalArgumentException("A pending candidate, reviewer identity, and evidence are required.");
        }
        return new Assessment(assessment.point(), ReviewState.HUMAN_VERIFIED,
                "Verified by " + reviewerId.trim() + ": " + reviewEvidence.trim());
    }

    public enum ReviewState { PENDING_HUMAN_REVIEW, HUMAN_VERIFIED, QUARANTINED }
    public record Assessment(GeoPoint point, ReviewState state, String rationale) {}
}
