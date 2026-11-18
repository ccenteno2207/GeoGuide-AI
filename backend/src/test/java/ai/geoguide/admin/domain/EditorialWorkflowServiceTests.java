package ai.geoguide.admin.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class EditorialWorkflowServiceTests {
    private final EditorialWorkflowService service = new EditorialWorkflowService();

    @Test
    void editorSubmitsAndReviewerPublishesWithImmutableAuditFacts() {
        var draft = EditorialRecord.draft(UUID.randomUUID());
        var submitted = service.transition(draft, 0, EditorialAction.SUBMIT_FOR_REVIEW,
                EditorialRole.EDITOR, "editor-7", "Content reviewed", Instant.parse("2026-11-17T12:00:00Z"));
        var published = service.transition(submitted.record(), 1, EditorialAction.APPROVE,
                EditorialRole.REVIEWER, "reviewer-2", "Evidence verified", Instant.parse("2026-11-17T12:05:00Z"));

        assertThat(submitted.record().state()).isEqualTo(EditorialState.PENDING_REVIEW);
        assertThat(published.record().state()).isEqualTo(EditorialState.PUBLISHED);
        assertThat(published.record().version()).isEqualTo(2);
        assertThat(published.auditEvent()).satisfies(event -> {
            assertThat(event.actorId()).isEqualTo("reviewer-2");
            assertThat(event.fromState()).isEqualTo(EditorialState.PENDING_REVIEW);
            assertThat(event.toState()).isEqualTo(EditorialState.PUBLISHED);
            assertThat(event.reason()).isEqualTo("Evidence verified");
        });
    }

    @Test
    void rejectsUnauthorizedRoleAndStaleVersion() {
        var draft = EditorialRecord.draft(UUID.randomUUID());
        assertThatThrownBy(() -> service.transition(draft, 0, EditorialAction.APPROVE,
                EditorialRole.EDITOR, "editor", "try publish", Instant.now()))
                .isInstanceOf(SecurityException.class);
        assertThatThrownBy(() -> service.transition(draft, 1, EditorialAction.SUBMIT_FOR_REVIEW,
                EditorialRole.EDITOR, "editor", "stale write", Instant.now()))
                .isInstanceOf(IllegalStateException.class).hasMessageContaining("stale");
    }
}
