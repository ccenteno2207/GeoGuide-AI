package ai.geoguide.admin.domain;

import java.util.Objects;
import java.util.UUID;

/** Editorial workflow state is isolated from P3's legacy public `active` flag. */
public record EditorialRecord(UUID id, EditorialState state, long version) {
    public EditorialRecord {
        Objects.requireNonNull(id, "id is required");
        Objects.requireNonNull(state, "state is required");
        if (version < 0) {
            throw new IllegalArgumentException("version cannot be negative");
        }
    }

    public static EditorialRecord draft(UUID id) {
        return new EditorialRecord(id, EditorialState.DRAFT, 0);
    }
}
