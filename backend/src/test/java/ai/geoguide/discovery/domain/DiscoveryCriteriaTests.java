package ai.geoguide.discovery.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatIllegalArgumentException;

import java.util.Set;
import org.junit.jupiter.api.Test;

class DiscoveryCriteriaTests {

    @Test
    void providesFrozenDefaults() {
        DiscoveryCriteria criteria = DiscoveryCriteria.defaults();

        assertThat(criteria.categoryCodes()).isEmpty();
        assertThat(criteria.corridorMeters()).isEqualTo(5_000);
        assertThat(criteria.limit()).isEqualTo(20);
    }

    @Test
    void acceptsFrozenBoundariesAndNormalizesCategoryCodes() {
        DiscoveryCriteria criteria = new DiscoveryCriteria(Set.of(" HISTORIC_CHURCH "), 1_000, 50);

        assertThat(criteria.categoryCodes()).containsExactly("HISTORIC_CHURCH");
    }

    @Test
    void rejectsCriteriaOutsideFrozenBounds() {
        assertThatIllegalArgumentException().isThrownBy(() -> new DiscoveryCriteria(Set.of(), 999, 20));
        assertThatIllegalArgumentException().isThrownBy(() -> new DiscoveryCriteria(Set.of(), 10_001, 20));
        assertThatIllegalArgumentException().isThrownBy(() -> new DiscoveryCriteria(Set.of(), 5_000, 0));
        assertThatIllegalArgumentException().isThrownBy(() -> new DiscoveryCriteria(Set.of(), 5_000, 51));
    }
}
