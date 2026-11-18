package ai.geoguide.admin.infrastructure.http;

import ai.geoguide.admin.domain.EditorialWorkflowConflictException;
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
    void invalidRequestsReturnBadRequestWithoutLeakingInternalExceptionText() {
        var response = handler.invalidRequest(new IllegalArgumentException("SQL fragments"));

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().getDetail()).doesNotContain("SQL fragments");
    }
}
