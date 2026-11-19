package ai.geoguide.poi.infrastructure.dataset.mincetur;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturTaxonomyFilter.Eligibility;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

class MinceturTaxonomyFilterTests {
    private final MinceturTaxonomyFilter filter = new MinceturTaxonomyFilter();
    private final MinceturSnapshotParser parser = new MinceturSnapshotParser();

    @Test
    void appliesNinePrimaryExclusionsAndExplicitAliasesByNormalizedExactEquality() {
        assertExcluded("3. FOLCLORE", "MÚSICAS Y DANZAS", "Música y Danzas", "PRIMARY_MUSIC_AND_DANCE");
        assertExcluded("3. FOLCLORE", "Gastronomía", "Platos Típicos", "PRIMARY_GASTRONOMY");
        assertExcluded("5. ACONTECIMIENTOS PROGRAMADOS", "Fiestas", "", "PRIMARY_FESTIVITIES");
        assertExcluded("4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS",
                "Explotación Minera", "Minas", "PRIMARY_MINING_EXPLOITATION");
        assertExcluded("4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS",
                "Explotaciones Industriales", "Fábricas", "PRIMARY_INDUSTRIAL_EXPLOITATION");
        assertExcluded("4. REALIZACIONES TÉCNICAS, CIENTÍFICAS Y ARTÍSTICAS CONTEMPORÁNEAS",
                "Explotaciones   Agropecuarias y Pesqueras", "Agricultura", "PRIMARY_AGRICULTURAL_EXPLOITATION");
        assertExcluded("5. ACONTECIMIENTOS PROGRAMADOS", "Eventos", "Festivales", "PRIMARY_EVENTS");
        assertExcluded("3. FOLCLORE", "Creencias Populares", "Mitos", "PRIMARY_POPULAR_BELIEFS");
        assertExcluded("3. FOLCLORE", "Artesanía y Artes", "Artesanales", "PRIMARY_CRAFTS_AND_ARTS");
    }

    @Test
    void appliesThreeSecondaryRulesOnlyForTheirExactCategoryTypeAndSubtype() {
        assertExcluded("5. ACONTECIMIENTOS PROGRAMADOS", "Artísticos", "DANZA", "TD-EX-10");
        assertExcluded("5. ACONTECIMIENTOS PROGRAMADOS", "Artísticos", "Música", "TD-EX-11");
        assertExcluded("3. FOLCLORE", "Ferias y Mercados", "Ferias gastronómicas", "TD-EX-12");

        assertThat(filter.classifyFields(fields("5. ACONTECIMIENTOS PROGRAMADOS", "Artísticos", "Teatro"))
                .eligibility()).isEqualTo(Eligibility.ELIGIBLE_FOR_REVIEW);
        assertThat(filter.classifyFields(fields("3. FOLCLORE", "Ferias y Mercados", "Ferias regionales"))
                .eligibility()).isEqualTo(Eligibility.ELIGIBLE_FOR_REVIEW);
    }

    @Test
    void requiresKnownCategoryTypePairsAndCompleteClassification() {
        assertThat(filter.classifyFields(fields("1. SITIOS NATURALES", "Gastronomía", "Platos Típicos"))
                .ruleCode()).isEqualTo("CATEGORY_TYPE_PAIR_UNKNOWN");
        assertThat(filter.classifyFields(fields("1. SITIOS NATURALES", "g. Cuerpo de Agua", " "))
                .ruleCode()).isEqualTo("SUBTYPE_MISSING");
        assertThat(filter.classifyFields(Map.of("CATEGORÍA", "1. SITIOS NATURALES"))
                .eligibility()).isEqualTo(Eligibility.CLASSIFICATION_REVIEW_REQUIRED);
    }

    @Test
    void unsupportedSnapshotFailsClosedWithoutDroppingRowsOrChangingRawFields() throws Exception {
        String csv = header() + "\r\n" + row("1", "Laguna", "g. Cuerpo de Agua", "Lagunas") + "\r\n";
        var snapshot = parser.parse("different.csv", csv.getBytes(StandardCharsets.UTF_8));

        var result = filter.classify(snapshot);

        assertThat(result.supportedSnapshot()).isFalse();
        assertThat(result.rulesetVersion()).isEqualTo(MinceturTaxonomyFilter.RULESET_VERSION);
        assertThat(result.decisionsByRowNumber()).hasSize(1);
        assertThat(result.decisionFor(snapshot.records().getFirst()).ruleCode()).isEqualTo("SNAPSHOT_NOT_APPROVED");
        assertThat(snapshot.records().getFirst().rawFields().get("NOMBRE DEL RECURSO")).isEqualTo("Laguna");
    }

    @Test
    void classifiesOwnerProvidedSnapshotAtFrozenCountsWhenPathIsSupplied() throws Exception {
        String configuredPath = System.getProperty("geoguide.test.minceturCsv", "");
        assumeTrue(!configuredPath.isBlank(), "Set geoguide.test.minceturCsv to classify the owner snapshot.");
        byte[] bytes = Files.readAllBytes(Path.of(configuredPath));
        var snapshot = parser.parse(Path.of(configuredPath).getFileName().toString(), bytes);

        var result = filter.classify(snapshot);
        long excluded = result.decisionsByRowNumber().values().stream()
                .filter(decision -> decision.eligibility() == Eligibility.EXCLUDED_FROM_NAVIGATION).count();
        long eligible = result.decisionsByRowNumber().values().stream()
                .filter(decision -> decision.eligibility() == Eligibility.ELIGIBLE_FOR_REVIEW).count();
        long review = result.decisionsByRowNumber().values().stream()
                .filter(decision -> decision.eligibility() == Eligibility.CLASSIFICATION_REVIEW_REQUIRED).count();

        assertThat(snapshot.sha256()).isEqualTo(MinceturTaxonomyFilter.APPROVED_SNAPSHOT_SHA256);
        assertThat(result.supportedSnapshot()).isTrue();
        assertThat(snapshot.records()).hasSize(6_341);
        assertThat(excluded).isEqualTo(1_768);
        assertThat(eligible).isEqualTo(4_573);
        assertThat(review).isZero();
        assertThat(snapshot.records()).anySatisfy(record -> assertThat(record.rawFields().get("CODIGO DEL RECURSO"))
                .isEqualTo("14342"));
    }

    @Test
    void repeatedClassificationIsDeterministicAndKeepsAllCoordinateQuarantinesIndependent() throws Exception {
        String configuredPath = System.getProperty("geoguide.test.minceturCsv", "");
        assumeTrue(!configuredPath.isBlank(), "Set geoguide.test.minceturCsv to classify the owner snapshot.");
        var parsed = parser.parse(Path.of(configuredPath).getFileName().toString(),
                Files.readAllBytes(Path.of(configuredPath)));
        var manifest = new ClassPathResource("data/destination-search/mincetur-20261110-coordinate-recovery-v1.json");
        var snapshot = new MinceturSnapshotCoordinateNormalizer(new ObjectMapper())
                .normalize(parsed, manifest.getInputStream());
        var first = filter.classify(snapshot);
        var second = filter.classify(snapshot);

        assertThat(second).isEqualTo(first);
        assertThat(snapshot.records().stream()
                .filter(record -> record.status() == MinceturSnapshotParser.RecordStatus.COORDINATE_FORMAT_AMBIGUOUS))
                .hasSize(10);
        assertThat(snapshot.records().stream()
                .filter(record -> record.status() == MinceturSnapshotParser.RecordStatus.COORDINATE_FORMAT_AMBIGUOUS)
                .filter(record -> first.decisionFor(record).eligibility() == Eligibility.EXCLUDED_FROM_NAVIGATION))
                .hasSize(2);
    }

    private void assertExcluded(String category, String type, String subtype, String ruleCode) {
        var decision = filter.classifyFields(fields(category, type, subtype));
        assertThat(decision.eligibility()).isEqualTo(Eligibility.EXCLUDED_FROM_NAVIGATION);
        assertThat(decision.ruleCode()).isEqualTo(ruleCode);
    }

    private static Map<String, String> fields(String category, String type, String subtype) {
        return Map.of("CATEGORÍA", category, "TIPO DE CATEGORÍA", type, "SUB TIPO CATEGORÍA", subtype);
    }

    private static String header() {
        return String.join(";", "REGIÓN", "PROVINCIA", "DISTRITO", "CODIGO DEL RECURSO", "NOMBRE DEL RECURSO",
                "CATEGORÍA", "TIPO DE CATEGORÍA", "SUB TIPO CATEGORÍA", "URL", "LATITUD", "LONGITUD",
                "FECHA_DE_CORTE");
    }

    private static String row(String id, String name, String type, String subtype) {
        return String.join(";", "Lima", "Canta", "Canta", id, name, "1. SITIOS NATURALES", type,
                subtype, "https://example.test/poi", "-76.0", "-11.0", "20261110");
    }
}
