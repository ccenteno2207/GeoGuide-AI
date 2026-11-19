package ai.geoguide.admin.domain;

import java.text.Normalizer;
import java.util.Locale;
import java.util.Map;

/** Exact, conservative mapping from MINCETUR type to the existing P3 category taxonomy. */
public final class MinceturPoiCategoryMapper {
    private static final Map<String, String> CATEGORY_BY_TYPE = Map.of(
            "sitios arqueologicos", "ARCHAEOLOGICAL_SITE");

    private MinceturPoiCategoryMapper() {}

    /** Returns null when no reviewed mapping exists; unknown types require explicit editorial selection. */
    public static String suggestedCategoryCode(String minceturType) {
        if (minceturType == null || minceturType.isBlank()) return null;
        String normalized = Normalizer.normalize(minceturType, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "")
                .trim()
                .replaceAll("\\s+", " ")
                .toLowerCase(Locale.ROOT);
        return CATEGORY_BY_TYPE.get(normalized);
    }
}
