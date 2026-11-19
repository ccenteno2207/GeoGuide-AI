package ai.geoguide.admin.domain;

/** Safe, actionable conflict raised when an editorial P3 category contradicts a known MINCETUR type mapping. */
public final class EditorialCategoryMismatchException extends EditorialWorkflowConflictException {
    public EditorialCategoryMismatchException(String expectedCategoryCode) {
        super("El tipo MINCETUR corresponde a la categoría P3 " + expectedCategoryCode
                + ". Devuelva el expediente a Observado, corrija la categoría y repita las revisiones antes de aprobar.");
    }
}
