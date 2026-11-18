package ai.geoguide.admin.domain;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

/** Immutable audit fact. Persistence and retention are intentionally provided by an adapter. */
public record EditorialAuditEvent(UUID recordId, String actorId, EditorialAction action,
        EditorialState fromState, EditorialState toState, long resultingVersion,
        String reason, Instant occurredAt) {
    public EditorialAuditEvent {
        Objects.requireNonNull(recordId, "recordId is required");
        if (actorId == null || actorId.isBlank()) {
            throw new IllegalArgumentException("actorId is required");
        }
        Objects.requireNonNull(action, "action is required");
        Objects.requireNonNull(fromState, "fromState is required");
        Objects.requireNonNull(toState, "toState is required");
        if (resultingVersion < 1) {
            throw new IllegalArgumentException("resultingVersion must be positive");
        }
        if (reason == null || reason.isBlank()) {
            throw new IllegalArgumentException("a non-blank audit reason is required");
        }
        reason = reason.trim();
        Objects.requireNonNull(occurredAt, "occurredAt is required");
    }
}
