package ai.geoguide.destination.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ai.geoguide.destination.application.port.DestinationRepository;
import ai.geoguide.destination.domain.Destination;
import java.util.List;
import org.junit.jupiter.api.Test;

class SearchDestinationsTests {
    private final DestinationRepository repository = mock(DestinationRepository.class);
    private final SearchDestinations search = new SearchDestinations(repository);

    @Test
    void normalizesAccentsAndWhitespaceAndUsesDefaultLimit() {
        when(repository.search("plaza de armas", 10)).thenReturn(List.of());
        assertThat(search.search("  PLÁZA   de Armas ", null)).isEmpty();
        verify(repository).search("plaza de armas", 10);
    }

    @Test
    void rejectsShortLongAndInvalidLimits() {
        assertThatThrownBy(() -> search.search("a", null)).isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> search.search("x".repeat(101), 10)).isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> search.search("Canta", 21)).isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void normalizesAccentsAndWhitespaceInQueryText() {
        assertThat(Destination.normalize("LÍNEAS   Y GEÓGLIFOS")).isEqualTo("lineas y geoglifos");
    }
}
