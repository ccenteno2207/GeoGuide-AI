package ai.geoguide.admin.domain;

/** A version or editorial-state conflict that prevents a requested workflow transition. */
public class EditorialWorkflowConflictException extends RuntimeException {
    public EditorialWorkflowConflictException(String message) { super(message); }
}
