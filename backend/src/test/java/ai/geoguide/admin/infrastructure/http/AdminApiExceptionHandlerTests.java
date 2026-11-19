package ai.geoguide.admin.infrastructure.http;

import ai.geoguide.admin.domain.EditorialWorkflowConflictException;
import ai.geoguide.admin.domain.EditorialCategoryMismatchException;
import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;

class AdminApiExceptionHandlerTests {
    private final AdminApiExceptionHandler handler = new AdminApiExceptionHandler();

    @Test
    void stateTransitionsReturnConflictWithoutLeakingInternalExceptionText() {
        var response = handler.conflict(new EditorialWorkflowConflictException("database query details"));

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getDetail()).doesNotContain("database query details");
    }

    @Test
    void categoryMismatchConflictExplainsTheRequiredEditorialCorrection() {
        var response = handler.categoryMismatch(new EditorialCategoryMismatchException("ARCHAEOLOGICAL_SITE"));

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getDetail()).contains("ARCHAEOLOGICAL_SITE", "Observado", "repita las revisiones");
        assertThat(response.getBody().getProperties()).containsEntry("code", "EDITORIAL_CATEGORY_MISMATCH");
    }

    @Test
    void invalidRequestsReturnBadRequestWithoutLeakingInternalExceptionText() {
        var response = handler.invalidRequest(new IllegalArgumentException("SQL fragments"));

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getDetail()).doesNotContain("SQL fragments");
    }

    @Test
    void oversizedMultipartReturnsPayloadTooLargeWithoutLeakingParserDetails() {
        var response = handler.uploadTooLarge(
                new org.springframework.web.multipart.MaxUploadSizeExceededException(10_485_760));

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.PAYLOAD_TOO_LARGE);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getDetail())
                .isEqualTo("El archivo supera el tamaño máximo permitido.")
                .doesNotContain("MaxUploadSizeExceededException", "10_485_760");
    }
}
