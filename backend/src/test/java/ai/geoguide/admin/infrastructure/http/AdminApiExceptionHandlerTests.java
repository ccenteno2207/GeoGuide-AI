package ai.geoguide.admin.infrastructure.http;

import static org.assertj.core.api.Assertions.assertThat;

import ai.geoguide.media.domain.PoiMediaValidationException;
import java.util.List;
import org.junit.jupiter.api.Test;
import org.springframework.http.HttpStatus;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.bind.MissingServletRequestParameterException;

class AdminApiExceptionHandlerTests {
    private final AdminApiExceptionHandler handler = new AdminApiExceptionHandler();

    @Test
    void mapsMediaValidationToStableFieldErrorWithoutInternalDetails() {
        var exception = new PoiMediaValidationException(400, "AUTHOR_REQUIRED", "author", "AUTHOR_REQUIRED",
                "Indica el autor o titular de derechos.");
        var response = handler.mediaValidation(exception);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody().getProperties()).containsEntry("code", "AUTHOR_REQUIRED")
                .containsEntry("errors", List.of(new PoiMediaValidationException.FieldIssue("author", "AUTHOR_REQUIRED",
                        "Indica el autor o titular de derechos.")));
        assertThat(response.getBody().getDetail()).doesNotContain("stack", "MinIO", "private/");
    }

    @Test
    void mapsMultipartLimitToStructuredPayloadTooLarge() {
        var response = handler.uploadTooLarge(new MaxUploadSizeExceededException(10_485_760));
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.PAYLOAD_TOO_LARGE);
        assertThat(response.getBody().getProperties()).containsEntry("code", "MEDIA_FILE_TOO_LARGE");
        assertThat(response.getBody().getProperties().get("errors").toString()).contains("file", "FILE_TOO_LARGE");
    }

    @Test
    void mapsMissingUploadMetadataToFieldSpecificFeedback() {
        var response = handler.missingUploadField(new MissingServletRequestParameterException("author", "String"));
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody().getProperties()).containsEntry("code", "AUTHOR_REQUIRED");
        assertThat(response.getBody().getProperties().get("errors").toString())
                .contains("author", "AUTHOR_REQUIRED", "Indica el autor o titular de derechos.");
    }
}
