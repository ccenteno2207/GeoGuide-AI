package ai.geoguide.media.domain;

import java.util.List;

/** Safe, stable validation feedback for media requests; never contains file bytes or storage details. */
public final class PoiMediaValidationException extends RuntimeException {
    private final int status;
    private final String code;
    private final List<FieldIssue> errors;

    public PoiMediaValidationException(int status, String code, String field, String fieldCode, String message) {
        super(message);
        this.status = status;
        this.code = code;
        this.errors = List.of(new FieldIssue(field, fieldCode, message));
    }

    public int status() { return status; }
    public String code() { return code; }
    public List<FieldIssue> errors() { return errors; }

    public record FieldIssue(String field, String code, String message) { }
}
