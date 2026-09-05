package ai.geoguide.poi.application.port;

import ai.geoguide.poi.domain.PoiId;
import ai.geoguide.poi.domain.PointOfInterest;
import java.util.Optional;

public interface PoiRepository {

    PointOfInterest save(PointOfInterest poi);

    Optional<PointOfInterest> findById(PoiId id);
}
