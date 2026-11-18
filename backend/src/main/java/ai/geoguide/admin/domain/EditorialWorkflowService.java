package ai.geoguide.admin.domain;

import java.time.Instant;
import java.util.Objects;

/** Pure transition policy; this service never writes public POI records. */
public final class EditorialWorkflowService {
    public Transition transition(EditorialRecord record, long expectedVersion, EditorialAction action,
            EditorialRole role, String actorId, String reason, Instant now) {
        Objects.requireNonNull(record, "record is required");
        Objects.requireNonNull(action, "action is required");
        Objects.requireNonNull(role, "role is required");
        Objects.requireNonNull(now, "now is required");
        if (record.version() != expectedVersion) {
            throw new IllegalStateException("Editorial record version is stale.");
        }
        if (actorId == null || actorId.isBlank() || reason == null || reason.isBlank()) {
            throw new IllegalArgumentException("Actor and audit reason are required for every transition.");
        }

        EditorialState next = switch (action) {
            case SUBMIT_FOR_REVIEW -> {
                requireRole(role, EditorialRole.EDITOR, EditorialRole.ADMINISTRATOR);
                requireState(record, EditorialState.DRAFT, EditorialState.REJECTED);
                yield EditorialState.PENDING_REVIEW;
            }
            case APPROVE -> {
                requireRole(role, EditorialRole.REVIEWER, EditorialRole.ADMINISTRATOR);
                requireState(record, EditorialState.PENDING_REVIEW);
                yield EditorialState.PUBLISHED;
            }
            case REJECT -> {
                requireRole(role, EditorialRole.REVIEWER, EditorialRole.ADMINISTRATOR);
                requireState(record, EditorialState.PENDING_REVIEW);
                yield EditorialState.REJECTED;
            }
            case ARCHIVE -> {
                requireRole(role, EditorialRole.ADMINISTRATOR);
                requireState(record, EditorialState.PUBLISHED, EditorialState.REJECTED, EditorialState.DRAFT);
                yield EditorialState.ARCHIVED;
            }
        };
        var updated = new EditorialRecord(record.id(), next, record.version() + 1);
        var audit = new EditorialAuditEvent(record.id(), actorId, action, record.state(), next,
                updated.version(), reason, now);
        return new Transition(updated, audit);
    }

    private static void requireRole(EditorialRole actual, EditorialRole... allowed) {
        for (EditorialRole role : allowed) {
            if (role == actual) {
                return;
            }
        }
        throw new SecurityException("Role is not allowed to perform this editorial transition.");
    }

    private static void requireState(EditorialRecord record, EditorialState... allowed) {
        for (EditorialState state : allowed) {
            if (record.state() == state) {
                return;
            }
        }
        throw new IllegalStateException("Editorial transition is not allowed from state " + record.state() + ".");
    }

    public record Transition(EditorialRecord record, EditorialAuditEvent auditEvent) {}
}
