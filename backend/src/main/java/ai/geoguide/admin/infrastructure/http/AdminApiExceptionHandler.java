package ai.geoguide.admin.infrastructure.http;

import ai.geoguide.admin.domain.EditorialWorkflowConflictException;
import ai.geoguide.admin.domain.EditorialCategoryMismatchException;
import ai.geoguide.admin.infrastructure.persistence.PoiOperationalInfoRepository.OperationalInfoConflictException;
import ai.geoguide.admin.infrastructure.persistence.PoiTourismContentRepository.PoiContentConflictException;
import ai.geoguide.media.domain.PoiMediaWorkflowConflictException;
import ai.geoguide.media.domain.PoiMediaValidationException;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.multipart.MaxUploadSizeExceededException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.MissingServletRequestParameterException;
import org.springframework.web.multipart.support.MissingServletRequestPartException;

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
        return mediaProblem(HttpStatus.PAYLOAD_TOO_LARGE, "MEDIA_FILE_TOO_LARGE", "El archivo supera el tamaño máximo permitido.",
                java.util.List.of(new PoiMediaValidationException.FieldIssue("file", "FILE_TOO_LARGE", "El archivo supera el tamaño máximo permitido.")));
    }

    @ExceptionHandler(PoiMediaValidationException.class)
    ResponseEntity<ProblemDetail> mediaValidation(PoiMediaValidationException exception) {
        HttpStatus status = HttpStatus.valueOf(exception.status());
        return mediaProblem(status, exception.code(), exception.getMessage(), exception.errors());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<ProblemDetail> invalidFields(MethodArgumentNotValidException exception) {
        var errors = exception.getBindingResult().getFieldErrors().stream()
                .map(error -> new PoiMediaValidationException.FieldIssue(error.getField(),
                        "NotBlank".equals(error.getCode()) ? "REQUIRED" : "INVALID_VALUE",
                        validationMessage(error.getField(), error.getCode())))
                .distinct().toList();
        return mediaProblem(HttpStatus.BAD_REQUEST, "INVALID_FORM_FIELDS",
                "Corrige los campos indicados y vuelve a intentarlo.", errors);
    }

    private String validationMessage(String field, String validationCode) {
        if ("NotBlank".equals(validationCode)) return switch (field) {
            case "license" -> "Indica la licencia o autorización que corresponde a la fotografía.";
            case "attribution" -> "Indica la atribución que debe acompañar a la fotografía.";
            case "evidenceReference" -> "Adjunta o describe la evidencia verificable de autorización de uso.";
            case "reason" -> "Indica el motivo de auditoría de esta modificación.";
            default -> "Completa este campo obligatorio.";
        };
        return switch (field) {
            case "expectedVersion" -> "Recarga la información para obtener una versión válida.";
            case "altText" -> "Escribe un texto alternativo de hasta 500 caracteres.";
            case "displayOrder" -> "El orden debe ser cero o un número positivo.";
            default -> "Revisa el formato o valor de este campo.";
        };
    }

    @ExceptionHandler({MissingServletRequestParameterException.class, MissingServletRequestPartException.class})
    ResponseEntity<ProblemDetail> missingUploadField(Exception exception) {
        String field = exception instanceof MissingServletRequestParameterException missing
                ? missing.getParameterName() : ((MissingServletRequestPartException) exception).getRequestPartName();
        String code = switch (field) {
            case "file" -> "FILE_REQUIRED";
            case "author" -> "AUTHOR_REQUIRED";
            case "sourceUrl" -> "SOURCE_REQUIRED";
            default -> "FIELD_REQUIRED";
        };
        String message = switch (field) {
            case "file" -> "Selecciona un archivo JPEG o PNG válido.";
            case "author" -> "Indica el autor o titular de derechos.";
            case "sourceUrl" -> "Indica la fuente de la imagen.";
            default -> "Completa este campo obligatorio.";
        };
        return mediaProblem(HttpStatus.BAD_REQUEST, code, "Completa los campos obligatorios de la carga.",
                java.util.List.of(new PoiMediaValidationException.FieldIssue(field, code, message)));
    }

    @ExceptionHandler(EditorialCategoryMismatchException.class)
    ResponseEntity<ProblemDetail> categoryMismatch(EditorialCategoryMismatchException exception) {
        ProblemDetail detail = ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, exception.getMessage());
        detail.setProperty("code", "EDITORIAL_CATEGORY_MISMATCH");
        return ResponseEntity.status(HttpStatus.CONFLICT).body(detail);
    }

    @ExceptionHandler({EditorialWorkflowConflictException.class, PoiMediaWorkflowConflictException.class,
            DataIntegrityViolationException.class})
    ResponseEntity<ProblemDetail> conflict(RuntimeException ignored) {
        return problem(HttpStatus.CONFLICT, "El recurso cambió o la transición solicitada no está permitida.");
    }

    @ExceptionHandler(OperationalInfoConflictException.class)
    ResponseEntity<ProblemDetail> operationalInfoConflict(OperationalInfoConflictException ignored) {
        return problem(HttpStatus.CONFLICT, "La información operativa cambió. Recargue la ficha y vuelva a guardar.");
    }

    @ExceptionHandler(PoiContentConflictException.class)
    ResponseEntity<ProblemDetail> poiContentConflict(PoiContentConflictException exception) {
        ProblemDetail detail = ProblemDetail.forStatusAndDetail(HttpStatus.CONFLICT, exception.getMessage());
        detail.setProperty("code", "POI_CONTENT_CONFLICT");
        return ResponseEntity.status(HttpStatus.CONFLICT).body(detail);
    }

    private ResponseEntity<ProblemDetail> problem(HttpStatus status, String detail) {
        return ResponseEntity.status(status).body(ProblemDetail.forStatusAndDetail(status, detail));
    }

    private ResponseEntity<ProblemDetail> mediaProblem(HttpStatus status, String code, String detail,
            java.util.List<PoiMediaValidationException.FieldIssue> errors) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, detail);
        problem.setProperty("code", code);
        problem.setProperty("errors", errors);
        return ResponseEntity.status(status).body(problem);
    }
}
