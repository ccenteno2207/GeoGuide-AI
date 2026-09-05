package ai.geoguide.poi.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;

class GeoPointTests {

    @ParameterizedTest
    @ValueSource(doubles = {-90, 0, 90})
    void acceptsValidLatitude(double latitude) {
        assertThat(new GeoPoint(latitude, 0).latitude()).isEqualTo(latitude);
    }

    @ParameterizedTest
    @ValueSource(doubles = {-90.0001, 90.0001, Double.NaN, Double.POSITIVE_INFINITY})
    void rejectsInvalidLatitude(double latitude) {
        assertThatThrownBy(() -> new GeoPoint(latitude, 0))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @ParameterizedTest
    @ValueSource(doubles = {-180, 0, 180})
    void acceptsValidLongitude(double longitude) {
        assertThat(new GeoPoint(0, longitude).longitude()).isEqualTo(longitude);
    }

    @ParameterizedTest
    @ValueSource(doubles = {-180.0001, 180.0001, Double.NaN, Double.NEGATIVE_INFINITY})
    void rejectsInvalidLongitude(double longitude) {
        assertThatThrownBy(() -> new GeoPoint(0, longitude))
                .isInstanceOf(IllegalArgumentException.class);
    }
}
