package ai.geoguide.routing.infrastructure.http;

import ai.geoguide.routing.application.RoutingError;
import ai.geoguide.routing.application.RoutingException;
import java.net.URI;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

@RestControllerAdvice
public class RoutingExceptionHandler {

    @ExceptionHandler(RoutingException.class)
    ProblemDetail handleRoutingException(RoutingException exception) {
        return problem(exception.error());
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ProblemDetail handleValidationException(MethodArgumentNotValidException exception) {
        return problem(RoutingError.INVALID_REQUEST);
    }

    private ProblemDetail problem(RoutingError error) {
        HttpStatus status = switch (error) {
            case INVALID_REQUEST -> HttpStatus.BAD_REQUEST;
            case NO_ROUTE_FOUND -> HttpStatus.NOT_FOUND;
            case PROVIDER_TIMEOUT -> HttpStatus.GATEWAY_TIMEOUT;
            case PROVIDER_UNAVAILABLE -> HttpStatus.SERVICE_UNAVAILABLE;
            case PROVIDER_ERROR -> HttpStatus.BAD_GATEWAY;
        };
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, publicDetail(error));
        problem.setType(URI.create("urn:geoguide:routing:" + error.name().toLowerCase().replace('_', '-')));
        problem.setProperty("code", error.name());
        return problem;
    }

    private String publicDetail(RoutingError error) {
        return switch (error) {
            case INVALID_REQUEST -> "The routing request is invalid.";
            case PROVIDER_TIMEOUT -> "The routing provider timed out.";
            case PROVIDER_UNAVAILABLE -> "The routing provider is unavailable.";
            case NO_ROUTE_FOUND -> "No route was found.";
            case PROVIDER_ERROR -> "The routing provider returned an invalid response.";
        };
    }
}
