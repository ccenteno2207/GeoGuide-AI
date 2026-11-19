package ai.geoguide.poi.infrastructure.dataset.mincetur;

import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser.Snapshot;
import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser.SnapshotRecord;
import java.text.Normalizer;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Pattern;
import org.springframework.stereotype.Component;

/** Applies the frozen, snapshot-scoped thematic rules without changing source fields or publication state. */
@Component
public final class MinceturTaxonomyFilter {
    public static final String RULESET_VERSION = "MINCETUR-TAXONOMY-FILTER-v1";
    public static final String APPROVED_SNAPSHOT_SHA256 =
            "29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66";
    private static final LocalDate APPROVED_CUTOFF = LocalDate.of(2026, 11, 10);
    private static final int APPROVED_RECORD_COUNT = 6_341;
    private static final Pattern WHITESPACE = Pattern.compile("\\s+");

    private static final Map<String, String> PRIMARY_EXCLUSION_RULES = Map.ofEntries(
            Map.entry(normalize("Música y Danzas"), "PRIMARY_MUSIC_AND_DANCE"),
            Map.entry(normalize("Músicas y Danzas"), "PRIMARY_MUSIC_AND_DANCE"),
            Map.entry(normalize("Gastronomía"), "PRIMARY_GASTRONOMY"),
            Map.entry(normalize("Fiestas"), "PRIMARY_FESTIVITIES"),
            Map.entry(normalize("Explotación Minera"), "PRIMARY_MINING_EXPLOITATION"),
            Map.entry(normalize("Explotaciones Mineras"), "PRIMARY_MINING_EXPLOITATION"),
            Map.entry(normalize("Explotaciones Industriales"), "PRIMARY_INDUSTRIAL_EXPLOITATION"),
            Map.entry(normalize("Explotaciones Agropecuarias y Pesqueras"), "PRIMARY_AGRICULTURAL_EXPLOITATION"),
            Map.entry(normalize("Eventos"), "PRIMARY_EVENTS"),
            Map.entry(normalize("Creencias Populares"), "PRIMARY_POPULAR_BELIEFS"),
            Map.entry(normalize("Artesanía y Artes"), "PRIMARY_CRAFTS_AND_ARTS"));

    private static final Set<String> VALID_CATEGORY_TYPE_PAIRS = Set.of(
            pair("1. SITIOS NATURALES", "a. Montañas"),
            pair("1. SITIOS NATURALES", "b. Planicies"),
            pair("1. SITIOS NATURALES", "c. Valles"),
            pair("1. SITIOS NATURALES", "d. Quebradas"),
            pair("1. SITIOS NATURALES", "e. Cañones"),
            pair("1. SITIOS NATURALES", "f. Pongos"),
            pair("1. SITIOS NATURALES", "g. Cuerpo de Agua"),
            pair("1. SITIOS NATURALES", "h. Corrientes de agua"),
            pair("1. SITIOS NATURALES", "i. Manantiales"),
            pair("1. SITIOS NATURALES", "j. Caídas de agua"),
            pair("1. SITIOS NATURALES", "k. Agua termo-mineral"),
            pair("1. SITIOS NATURALES", "l. Costas"),
            pair("1. SITIOS NATURALES", "m. Cavidades naturales"),
            pair("1. SITIOS NATURALES", "n. Áreas Protegidas"),
            pair("1. SITIOS NATURALES", "ñ. Zonas paisajísticas"),
            pair("1. SITIOS NATURALES", "o. Otros"),
            pair("2. MANIFESTACIONES CULTURALES", "Arquitectura y Espacios Urbanos"),
            pair("2. MANIFESTACIONES CULTURALES", "Lugares Históricos"),
            pair("2. MANIFESTACIONES CULTURALES", "Museos y otros"),
            pair("2. MANIFESTACIONES CULTURALES", "Otros"),
            pair("2. MANIFESTACIONES CULTURALES", "Pueblos"),
            pair("2. MANIFESTACIONES CULTURALES", "Sitios Arqueológicos"),
            pair("3. FOLCLORE", "Artesanía y Artes"),
            pair("3. FOLCLORE", "Creencias Populares"),
            pair("3. FOLCLORE", "Etnias"),
            pair("3. FOLCLORE", "Ferias y Mercados"),
            pair("3. FOLCLORE", "Gastronomía"),
            pair("3. FOLCLORE", "Músicas y Danzas"),
            pair("3. FOLCLORE", "Música y Danzas"),
            pair("4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS",
                    "Centros Científicos y Técnicos"),
            pair("4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS",
                    "Explotaciones Agropecuarias y Pesqueras"),
            pair("4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS",
                    "Explotaciones Industriales"),
            pair("4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS",
                    "Explotaciones Mineras"),
            pair("4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS",
                    "Explotación Minera"),
            pair("4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS", "Otros"),
            pair("5. ACONTECIMIENTOS PROGRAMADOS", "Artísticos"),
            pair("5. ACONTECIMIENTOS PROGRAMADOS", "Eventos"),
            pair("5. ACONTECIMIENTOS PROGRAMADOS", "Fiestas"),
            pair("5. ACONTECIMIENTOS PROGRAMADOS", "Otros"));

    private static final Map<String, String> SECONDARY_EXCLUSION_RULES = Map.of(
            triplet("5. ACONTECIMIENTOS PROGRAMADOS", "Artísticos", "Danza"), "TD-EX-10",
            triplet("5. ACONTECIMIENTOS PROGRAMADOS", "Artísticos", "Música"), "TD-EX-11",
            triplet("3. FOLCLORE", "Ferias y Mercados", "Ferias gastronómicas"), "TD-EX-12");

    public ClassificationResult classify(Snapshot snapshot) {
        boolean supportedSnapshot = isSupportedSnapshot(snapshot);
        Map<Integer, Decision> decisions = new HashMap<>();
        for (SnapshotRecord record : snapshot.records()) {
            Decision decision = supportedSnapshot
                    ? classifyFields(record.rawFields())
                    : review("SNAPSHOT_NOT_APPROVED", "The frozen ruleset is bound to the approved source snapshot.");
            if (decisions.putIfAbsent(record.rowNumber(), decision) != null) {
                throw new IllegalArgumentException("Snapshot contains duplicate source row numbers.");
            }
        }
        return new ClassificationResult(RULESET_VERSION, supportedSnapshot, Map.copyOf(decisions));
    }

    Decision classifyFields(Map<String, String> rawFields) {
        if (rawFields == null) {
            return review("CLASSIFICATION_FIELDS_MISSING", "Raw classification fields are unavailable.");
        }
        String category = normalize(rawFields.get("CATEGORÍA"));
        String type = normalize(rawFields.get("TIPO DE CATEGORÍA"));
        String subtype = normalize(rawFields.get("SUB TIPO CATEGORÍA"));
        if (category.isEmpty() || type.isEmpty()) {
            return review("CLASSIFICATION_FIELDS_MISSING", "Category or primary type is blank.");
        }
        if (!VALID_CATEGORY_TYPE_PAIRS.contains(pair(category, type))) {
            return review("CATEGORY_TYPE_PAIR_UNKNOWN", "Category and type do not match the frozen snapshot taxonomy.");
        }

        String primaryRule = PRIMARY_EXCLUSION_RULES.get(type);
        if (primaryRule != null) {
            return excluded(primaryRule, "Excluded by exact primary type rule.");
        }
        if (subtype.isEmpty()) {
            return review("SUBTYPE_MISSING", "Subtype is required for an otherwise eligible thematic record.");
        }

        String secondaryRule = SECONDARY_EXCLUSION_RULES.get(triplet(category, type, subtype));
        if (secondaryRule != null) {
            return excluded(secondaryRule, "Excluded by exact category, type, and subtype rule.");
        }
        return new Decision(Eligibility.ELIGIBLE_FOR_REVIEW, "NO_EXCLUSION_MATCH",
                "No frozen thematic exclusion matched; geographic, editorial, and publication reviews remain separate.");
    }

    private static boolean isSupportedSnapshot(Snapshot snapshot) {
        return snapshot != null
                && APPROVED_SNAPSHOT_SHA256.equalsIgnoreCase(snapshot.sha256())
                && APPROVED_CUTOFF.equals(snapshot.cutoff())
                && !snapshot.inconsistentCutoff()
                && snapshot.records().size() == APPROVED_RECORD_COUNT
                && snapshot.records().stream().allMatch(record -> record.rawFields() != null
                        && record.rawFields().containsKey("CATEGORÍA")
                        && record.rawFields().containsKey("TIPO DE CATEGORÍA")
                        && record.rawFields().containsKey("SUB TIPO CATEGORÍA"));
    }

    private static Decision excluded(String code, String reason) {
        return new Decision(Eligibility.EXCLUDED_FROM_NAVIGATION, code, reason);
    }

    private static Decision review(String code, String reason) {
        return new Decision(Eligibility.CLASSIFICATION_REVIEW_REQUIRED, code, reason);
    }

    private static String normalize(String value) {
        if (value == null) {
            return "";
        }
        String decomposed = Normalizer.normalize(value, Normalizer.Form.NFD);
        String withoutMarks = decomposed.replaceAll("\\p{M}+", "");
        return WHITESPACE.matcher(withoutMarks.strip().toLowerCase(Locale.ROOT)).replaceAll(" ");
    }

    private static String pair(String category, String type) {
        return normalize(category) + "\u001f" + normalize(type);
    }

    private static String triplet(String category, String type, String subtype) {
        return pair(category, type) + "\u001f" + normalize(subtype);
    }

    public enum Eligibility {
        ELIGIBLE_FOR_REVIEW,
        EXCLUDED_FROM_NAVIGATION,
        CLASSIFICATION_REVIEW_REQUIRED
    }

    public record Decision(Eligibility eligibility, String ruleCode, String reason) {}

    public record ClassificationResult(String rulesetVersion, boolean supportedSnapshot,
            Map<Integer, Decision> decisionsByRowNumber) {
        public Decision decisionFor(SnapshotRecord record) {
            Decision decision = decisionsByRowNumber.get(record.rowNumber());
            if (decision == null) {
                throw new IllegalArgumentException("Taxonomy result does not contain the source row.");
            }
            return decision;
        }
    }
}
