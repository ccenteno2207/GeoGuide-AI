package ai.geoguide.routing.infrastructure.http;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;

public record RoutePlanRequest(@NotNull @Valid PointDto origin, @NotNull @Valid PointDto destination) {
}
