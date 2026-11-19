package ai.geoguide.admin.domain;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class MinceturPoiCategoryMapperTests {
    @Test
    void mapsTheExactArchaeologicalTypeToTheExistingP3Category() {
        assertThat(MinceturPoiCategoryMapper.suggestedCategoryCode("Sitios Arqueológicos"))
                .isEqualTo("ARCHAEOLOGICAL_SITE");
        assertThat(MinceturPoiCategoryMapper.suggestedCategoryCode("  SITIOS   ARQUEOLOGICOS  "))
                .isEqualTo("ARCHAEOLOGICAL_SITE");
    }

    @Test
    void leavesUnknownOrMissingTypesForExplicitEditorialSelection() {
        assertThat(MinceturPoiCategoryMapper.suggestedCategoryCode("Cataratas" )).isNull();
        assertThat(MinceturPoiCategoryMapper.suggestedCategoryCode(null)).isNull();
        assertThat(MinceturPoiCategoryMapper.suggestedCategoryCode(" ")).isNull();
    }
}
