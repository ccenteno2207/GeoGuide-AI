package ai.geoguide.routing.application;

public final class RoutingException extends RuntimeException {

    private final RoutingError error;

    public RoutingException(RoutingError error) {
        super(error.name());
        this.error = error;
    }

    public RoutingException(RoutingError error, Throwable cause) {
        super(error.name(), cause);
        this.error = error;
    }

    public RoutingError error() {
        return error;
    }
}
