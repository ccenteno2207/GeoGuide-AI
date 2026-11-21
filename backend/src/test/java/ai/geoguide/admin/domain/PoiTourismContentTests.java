package ai.geoguide.admin.domain;

import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class PoiTourismContentTests {
    @Test
    void blocksProvisionalTextWithoutRejectingValidTourismLanguage() {
        var provisional = new PoiTourismContent(
                "Que va aquí", "Texto provisional", "", "", "", List.of(), List.of(), "", "");
        var valid = new PoiTourismContent(
                "Visítanos todo el año", "Abierto todo el año, excepto feriados.", "", "", "",
                List.of(), List.of(), "", "");

        assertThat(provisional.publicationIssues()).contains("summary", "description");
        assertThat(valid.publicationIssues()).isEmpty();
    }
}
