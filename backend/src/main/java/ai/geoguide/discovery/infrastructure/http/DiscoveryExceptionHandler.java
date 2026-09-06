package ai.geoguide.discovery.infrastructure.http;
import java.net.URI;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
@RestControllerAdvice
public class DiscoveryExceptionHandler {
 @ExceptionHandler(DiscoveryException.class) ProblemDetail handle(DiscoveryException exception) { HttpStatus status = exception.error() == DiscoveryError.INVALID_DISCOVERY_REQUEST ? HttpStatus.BAD_REQUEST : HttpStatus.INTERNAL_SERVER_ERROR; ProblemDetail problem = ProblemDetail.forStatusAndDetail(status, status == HttpStatus.BAD_REQUEST ? "The discovery request is invalid." : "The discovery service failed."); problem.setType(URI.create("urn:geoguide:discovery:" + exception.error().name().toLowerCase().replace('_','-'))); problem.setProperty("code", exception.error().name()); return problem; }
}
