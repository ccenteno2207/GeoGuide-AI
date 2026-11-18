package ai.geoguide.admin.infrastructure.http;

import ai.geoguide.admin.domain.EditorialWorkflowConflictException;
import ai.geoguide.media.domain.PoiMediaWorkflowConflictException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

/** Stable admin/media error responses that do not disclose internal exception details. */
@RestControllerAdvice(basePackages = {
        "ai.geoguide.admin.infrastructure.http",
        "ai.geoguide.media.infrastructure.http"
})
public class AdminApiExceptionHandler {
    @ExceptionHandler(IllegalArgumentException.class)
    ResponseEntity<ProblemDetail> invalidRequest(IllegalArgumentException ignored) {
        return problem(HttpStatus.BAD_REQUEST, "La solicitud contiene datos inválidos.");
    }

    @ExceptionHandler(MaxUploadSizeExceededException.class)
    ResponseEntity<ProblemDetail> uploadTooLarge(MaxUploadSizeExceededException ignored) {
        return problem(HttpStatus.PAYLOAD_TOO_LARGE, "El archivo supera el tamaño máximo permitido.");
    }

    @ExceptionHandler({EditorialWorkflowConflictException.class, PoiMediaWorkflowConflictException.class,
            DataIntegrityViolationException.class})
    ResponseEntity<ProblemDetail> conflict(RuntimeException ignored) {
        return problem(HttpStatus.CONFLICT, "El recurso cambió o la transición solicitada no está permitida.");
    }

    private ResponseEntity<ProblemDetail> problem(HttpStatus status, String detail) {
        return ResponseEntity.status(status).body(ProblemDetail.forStatusAndDetail(status, detail));
    }
}
