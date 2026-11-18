package ai.geoguide.media.domain;

/** A version, rights, or publication-state conflict in the POI media workflow. */
public class PoiMediaWorkflowConflictException extends RuntimeException {
    public PoiMediaWorkflowConflictException(String message) { super(message); }
}
