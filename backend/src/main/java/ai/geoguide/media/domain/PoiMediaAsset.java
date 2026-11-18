package ai.geoguide.media.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

/** Rights-aware metadata. Binary content remains behind a private object storage port. */
public record PoiMediaAsset(UUID id, UUID poiId, String objectKey, String contentType,
        String sha256, long sizeBytes, String author, String sourceUrl,
        String license, String attribution, String rightsEvidenceReference,
        RightsStatus rightsStatus, MediaState state, long version) {
    public PoiMediaAsset {
        Objects.requireNonNull(id, "id is required");
        Objects.requireNonNull(poiId, "poiId is required");
        requireText(objectKey, "objectKey");
        requireText(contentType, "contentType");
        if (sha256 == null || !sha256.matches("[A-Fa-f0-9]{64}")) {
            throw new IllegalArgumentException("sha256 must contain 64 hexadecimal characters");
        }
        if (sizeBytes < 1 || version < 0) {
            throw new IllegalArgumentException("sizeBytes must be positive and version cannot be negative");
        }
        requireText(author, "author");
        requireText(sourceUrl, "sourceUrl");
        Objects.requireNonNull(rightsStatus, "rightsStatus is required");
        Objects.requireNonNull(state, "state is required");
    }

    public PoiMediaAsset submitForReview() {
        if (state != MediaState.DRAFT) {
            throw new IllegalStateException("Only draft media can be submitted for review.");
        }
        return withState(MediaState.PENDING_REVIEW);
    }

    public PoiMediaAsset publish(MediaReviewerRole reviewerRole, String reviewerId, Instant reviewedAt, String auditReason) {
        if (state != MediaState.PENDING_REVIEW || rightsStatus != RightsStatus.DOCUMENTED
                || blank(license) || blank(attribution) || blank(rightsEvidenceReference)
                || (reviewerRole != MediaReviewerRole.REVIEWER && reviewerRole != MediaReviewerRole.ADMINISTRATOR)
                || blank(reviewerId) || reviewedAt == null || blank(auditReason)) {
            throw new IllegalStateException("Publication requires documented rights, attribution, and a reviewer decision.");
        }
        return withState(MediaState.PUBLISHED);
    }

    public PoiMediaAsset withdraw() {
        if (state != MediaState.PUBLISHED) {
            throw new IllegalStateException("Only published media can be withdrawn.");
        }
        return withState(MediaState.WITHDRAWN);
    }

    private PoiMediaAsset withState(MediaState next) {
        return new PoiMediaAsset(id, poiId, objectKey, contentType, sha256, sizeBytes,
                author, sourceUrl, license, attribution, rightsEvidenceReference,
                rightsStatus, next, version + 1);
    }

    private static void requireText(String value, String field) {
        if (blank(value)) {
            throw new IllegalArgumentException(field + " is required");
        }
    }

    private static boolean blank(String value) { return value == null || value.isBlank(); }

    public enum RightsStatus { UNVERIFIED, DOCUMENTED }
    public enum MediaState { DRAFT, PENDING_REVIEW, PUBLISHED, REJECTED, WITHDRAWN }
    public enum MediaReviewerRole { ADMINISTRATOR, EDITOR, REVIEWER }
}
