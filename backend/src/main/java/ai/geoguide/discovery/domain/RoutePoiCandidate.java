package ai.geoguide.discovery.domain;

import ai.geoguide.poi.domain.Category;
import ai.geoguide.poi.domain.GeoPoint;
import ai.geoguide.poi.domain.PoiId;
import java.util.Objects;

public record RoutePoiCandidate(
        PoiId poiId,
        String name,
        Category category,
        GeoPoint location,
        boolean active,
        double distanceToRouteMeters,
        double routeProgress,
        String description,
        ProvenanceSummary provenance,
        String primaryMediaPath,
        String tourismSummary) {

    public RoutePoiCandidate(PoiId poiId, String name, Category category, GeoPoint location,
            boolean active, double distanceToRouteMeters, double routeProgress) {
        this(poiId, name, category, location, active, distanceToRouteMeters, routeProgress, null, null, null, null);
    }

    public RoutePoiCandidate(PoiId poiId,String name,Category category,GeoPoint location,boolean active,
            double distanceToRouteMeters,double routeProgress,String description,ProvenanceSummary provenance){
        this(poiId,name,category,location,active,distanceToRouteMeters,routeProgress,description,provenance,null,null);
    }

    public RoutePoiCandidate(PoiId poiId,String name,Category category,GeoPoint location,boolean active,
            double distanceToRouteMeters,double routeProgress,String description,ProvenanceSummary provenance,String primaryMediaPath){
        this(poiId,name,category,location,active,distanceToRouteMeters,routeProgress,description,provenance,primaryMediaPath,null);
    }

    public RoutePoiCandidate {
        Objects.requireNonNull(poiId, "poiId is required");
        if (name == null || name.isBlank()) {
            throw new IllegalArgumentException("name is required");
        }
        name = name.trim();
        Objects.requireNonNull(category, "category is required");
        Objects.requireNonNull(location, "location is required");
        if (!Double.isFinite(distanceToRouteMeters) || distanceToRouteMeters < 0) {
            throw new IllegalArgumentException("distanceToRouteMeters must be finite and non-negative");
        }
        if (!Double.isFinite(routeProgress) || routeProgress < 0 || routeProgress > 1) {
            throw new IllegalArgumentException("routeProgress must be between 0 and 1");
        }
        description = description == null || description.isBlank() ? null : description.trim();
        tourismSummary = tourismSummary == null || tourismSummary.isBlank() ? null : tourismSummary.trim();
    }
}
