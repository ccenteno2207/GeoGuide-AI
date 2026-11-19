package ai.geoguide.admin.domain;

/** Deterministic work-queue labels only; no classification grants review or publication approval. */
public enum MinceturReviewClassification {
    QUARANTINED,
    POI_AND_DESTINATION_EDITORIALS_EXIST,
    POI_EDITORIAL_EXISTS,
    DESTINATION_EDITORIAL_EXISTS,
    UNASSIGNED_CANDIDATE;

    public static MinceturReviewClassification classify(String importStatus,
            boolean poiDraftExists, boolean destinationDraftExists) {
        if (!"NORMALIZED_PENDING_REVIEW".equals(importStatus)) return QUARANTINED;
        if (poiDraftExists && destinationDraftExists) return POI_AND_DESTINATION_EDITORIALS_EXIST;
        if (poiDraftExists) return POI_EDITORIAL_EXISTS;
        if (destinationDraftExists) return DESTINATION_EDITORIAL_EXISTS;
        return UNASSIGNED_CANDIDATE;
    }
}
