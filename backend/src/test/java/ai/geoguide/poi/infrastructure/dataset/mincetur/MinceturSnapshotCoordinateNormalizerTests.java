package ai.geoguide.poi.infrastructure.dataset.mincetur;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser.RecordStatus;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import org.junit.jupiter.api.Test;

class MinceturSnapshotCoordinateNormalizerTests {
    private final MinceturSnapshotParser parser = new MinceturSnapshotParser();
    private final MinceturSnapshotCoordinateNormalizer normalizer =
            new MinceturSnapshotCoordinateNormalizer(new ObjectMapper());

    @Test
    void recoversOnlyExactOwnerSnapshotAndKeepsTenExceptionsQuarantined() throws IOException {
        String configuredPath = System.getProperty("geoguide.test.minceturCsv", "");
        assumeTrue(!configuredPath.isBlank(), "Set geoguide.test.minceturCsv to profile the supplied snapshot.");
        Path source = Path.of(configuredPath);
        var parsed = parser.parse(source.getFileName().toString(), Files.readAllBytes(source));
        var normalized = normalizer.normalize(parsed, manifest());

        assertThat(normalized.records()).hasSize(6341);
        assertThat(normalized.records()).filteredOn(record ->
                record.status() == RecordStatus.NORMALIZED_PENDING_REVIEW).hasSize(6331);
        assertThat(normalized.records()).filteredOn(record ->
                record.status() != RecordStatus.NORMALIZED_PENDING_REVIEW).hasSize(10);
        assertThat(normalized.records()).filteredOn(record ->
                record.sourceRecordId().equals("237")).singleElement().satisfies(record -> {
                    assertThat(record.normalizedLatitude()).isEqualByComparingTo("-14.087854051458200");
                    assertThat(record.normalizedLongitude()).isEqualByComparingTo("-75.76291501522060");
                    assertThat(record.rawFields().get("LATITUD")).isEqualTo("-7.576.291.501.522.060");
                    assertThat(record.rawFields().get("LONGITUD")).isEqualTo("-14.087.854.051.458.200");
                    assertThat(record.normalizationRule()).isEqualTo(
                            MinceturSnapshotCoordinateNormalizer.RULE_VERSION);
                    assertThat(record.validationEvidence()).contains("not geodetically verified or published");
                });
        assertThat(normalized.records()).filteredOn(record ->
                record.sourceRecordId().equals("14068")).singleElement().satisfies(record -> {
                    assertThat(record.normalizedLatitude()).isEqualByComparingTo("-11.4669625");
                    assertThat(record.normalizedLongitude()).isEqualByComparingTo("-76.6247746");
                });
        assertThat(normalized.records()).filteredOn(record ->
                java.util.Set.of("559", "3923", "6871", "6905", "14738", "14707", "14737", "11104", "14810", "14798")
                        .contains(record.sourceRecordId()))
                .hasSize(10).allSatisfy(record -> {
                    assertThat(record.status()).isNotEqualTo(RecordStatus.NORMALIZED_PENDING_REVIEW);
                    assertThat(record.normalizedLatitude()).isNull();
                    assertThat(record.normalizedLongitude()).isNull();
                });
    }

    @Test
    void doesNotApplySnapshotSpecificRuleToOtherSourceHash() throws IOException {
        String input = "REGIÓN;PROVINCIA;DISTRITO;CODIGO DEL RECURSO;NOMBRE DEL RECURSO;CATEGORÍA;TIPO DE CATEGORÍA;SUB TIPO CATEGORÍA;URL;LATITUD;LONGITUD;FECHA_DE_CORTE\r\n"
                + "Ica;Ica;ICA;237;Laguna De Huacachina;1. SITIOS NATURALES;g. Cuerpo de Agua;Lagunas;https://example.test;"
                + "-7.576.291.501.522.060;-14.087.854.051.458.200;20261110\r\n";
        var parsed = parser.parse("another-snapshot.csv", input.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        var normalized = normalizer.normalize(parsed, manifest());

        assertThat(normalized.records()).singleElement().satisfies(record -> {
            assertThat(record.status()).isEqualTo(RecordStatus.COORDINATE_FORMAT_AMBIGUOUS);
            assertThat(record.normalizedLatitude()).isNull();
            assertThat(record.normalizedLongitude()).isNull();
        });
    }

    @Test
    void failsClosedWhenManifestHasMalformedAcceptedCount() throws IOException {
        String input = "REGIÓN;PROVINCIA;DISTRITO;CODIGO DEL RECURSO;NOMBRE DEL RECURSO;CATEGORÍA;TIPO DE CATEGORÍA;SUB TIPO CATEGORÍA;URL;LATITUD;LONGITUD;FECHA_DE_CORTE\r\n"
                + "Ica;Ica;ICA;237;Lugar;1;g;Lagunas;https://example.test;-7.576.291.501.522.060;-14.087.854.051.458.200;20261110\r\n";
        var snapshot = parser.parse("mincetur.csv", input.getBytes(java.nio.charset.StandardCharsets.UTF_8));
        String malformedManifest = "{\"manifestVersion\":\"mincetur-local-20261110-coordinate-recovery-v1\",\"status\":\"SNAPSHOT_SPECIFIC_CROSSCHECKED_NOT_PUBLISHED\",\"localSnapshot\":{\"sha256\":\""
                + snapshot.sha256() + "\",\"cutoff\":\"2026-11-10\",\"encoding\":\"UTF-8\",\"delimiter\":\";\",\"recordCount\":1},\"comparison\":{\"acceptedRecords\":1},\"acceptedRecords\":[],\"quarantine\":[]}";
        assertThatThrownBy(() -> normalizer.normalize(snapshot, new java.io.ByteArrayInputStream(
                malformedManifest.getBytes(java.nio.charset.StandardCharsets.UTF_8))))
                .isInstanceOf(IOException.class).hasMessageContaining("inconsistent accepted/quarantine counts");
    }

    private static java.io.InputStream manifest() throws IOException {
        var stream = MinceturSnapshotCoordinateNormalizerTests.class.getResourceAsStream(
                "/data/destination-search/mincetur-20261110-coordinate-recovery-v1.json");
        if (stream == null) {
            throw new IOException("Coordinate recovery manifest test resource is missing.");
        }
        return stream;
    }
}
