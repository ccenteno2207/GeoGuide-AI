package ai.geoguide.discovery.application.port;

import ai.geoguide.discovery.domain.DiscoveryCriteria;
import ai.geoguide.discovery.domain.RoutePoiCandidate;
import ai.geoguide.routing.domain.RouteGeometry;
import java.util.List;

/** Read-side port for spatial POI discovery along an already planned route. */
public interface RoutePoiCandidateQuery {

    List<RoutePoiCandidate> findAlong(RouteGeometry routeGeometry, DiscoveryCriteria criteria);
}
