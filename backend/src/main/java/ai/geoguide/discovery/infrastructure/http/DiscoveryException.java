package ai.geoguide.discovery.infrastructure.http;
public class DiscoveryException extends RuntimeException { private final DiscoveryError error; public DiscoveryException(DiscoveryError error) { this.error = error; } public DiscoveryError error() { return error; } }
