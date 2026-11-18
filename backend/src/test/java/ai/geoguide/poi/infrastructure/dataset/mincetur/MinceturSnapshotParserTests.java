package ai.geoguide.poi.infrastructure.dataset.mincetur;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser.RecordStatus;
import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assumptions.assumeTrue;

class MinceturSnapshotParserTests {
    private static final String HEADER = String.join(";", "REGIÓN", "PROVINCIA", "DISTRITO",
            "CODIGO DEL RECURSO", "NOMBRE DEL RECURSO", "CATEGORÍA", "TIPO DE CATEGORÍA",
            "SUB TIPO CATEGORÍA", "URL", "LATITUD", "LONGITUD", "FECHA_DE_CORTE");

    private final MinceturSnapshotParser parser = new MinceturSnapshotParser();

    @Test
    void preservesGroupedCoordinateTokensAndQuarantinesWithoutInventingDecimalPlacement() throws IOException {
        var snapshot = parse(row("237", "Laguna De Huacachina", "-7.576.291.501.522.060",
                "-14.087.854.051.458.200"));

        assertThat(snapshot.cutoff()).hasToString("2026-11-10");
        assertThat(snapshot.records()).singleElement().satisfies(record -> {
            assertThat(record.status()).isEqualTo(RecordStatus.COORDINATE_FORMAT_AMBIGUOUS);
            assertThat(record.rawFields().get("LATITUD")).isEqualTo("-7.576.291.501.522.060");
            assertThat(record.rawFields().get("LONGITUD")).isEqualTo("-14.087.854.051.458.200");
            assertThat(record.normalizedLatitude()).isNull();
            assertThat(record.normalizedLongitude()).isNull();
            assertThat(record.normalizationRule()).isNull();
        });
    }

    @Test
    void syntacticallyDecimalCoordinatesStillRequireSnapshotMappingEvidence() throws IOException {
        var snapshot = parse(row("14068", "Plaza De Armas De Canta", "-76.6247746", "-11.4669625"));

        assertThat(snapshot.records()).singleElement().satisfies(record -> {
            assertThat(record.status()).isEqualTo(RecordStatus.COORDINATE_MAPPING_UNVERIFIED);
            assertThat(record.normalizedLatitude()).isNull();
            assertThat(record.normalizedLongitude()).isNull();
        });
    }

    @Test
    void detectsDuplicateSourceCodesAndRetainsBothRawRows() throws IOException {
        String text = HEADER + "\r\n" + row("42", "Lugar A", "-76.0", "-11.0") + "\r\n"
                + row("42", "Lugar B", "-76.1", "-11.1") + "\r\n";
        var snapshot = parser.parse("duplicates.csv", text.getBytes(StandardCharsets.UTF_8));

        assertThat(snapshot.records()).hasSize(2)
                .allSatisfy(record -> assertThat(record.status()).isEqualTo(RecordStatus.DUPLICATE_SOURCE_ID));
    }

    @Test
    void detectsWindows1252AndKeepsQuotedSemicolonsInsideFields() throws IOException {
        String text = HEADER + "\r\n" + row("9", "Iglesia de San José", "-76.0", "-11.0", "texto; adicional") + "\r\n";
        var snapshot = parser.parse("mincetur.csv", text.getBytes(Charset.forName("windows-1252")));

        assertThat(snapshot.encoding()).isEqualTo("windows-1252");
        assertThat(snapshot.records()).singleElement().satisfies(record -> {
            assertThat(record.rawFields().get("NOMBRE DEL RECURSO")).isEqualTo("Iglesia de San José");
            assertThat(record.rawFields().get("SUB TIPO CATEGORÍA")).isEqualTo("texto; adicional");
        });
    }

    @Test
    void refusesUnexpectedHeadersAndUnclosedQuotedFields() {
        assertThatThrownBy(() -> parser.parse("wrong.csv",
                ("OTHER;HEADER\r\n" + row("1", "Lugar", "1", "1") + "\r\n").getBytes(StandardCharsets.UTF_8)))
                .isInstanceOf(IOException.class).hasMessageContaining("Unexpected MINCETUR CSV header");

        assertThatThrownBy(() -> parser.parse("broken.csv",
                (HEADER + "\r\n\"unclosed").getBytes(StandardCharsets.UTF_8)))
                .isInstanceOf(IOException.class).hasMessageContaining("Unclosed quoted field");
    }

    @Test
    void profilesOwnerProvidedSnapshotWhenPathIsSupplied() throws IOException {
        String configuredPath = System.getProperty("geoguide.test.minceturCsv", "");
        assumeTrue(!configuredPath.isBlank(), "Set geoguide.test.minceturCsv to profile the supplied source snapshot.");

        var snapshot = parser.parse(Path.of(configuredPath).getFileName().toString(),
                Files.readAllBytes(Path.of(configuredPath)));

        assertThat(snapshot.records()).hasSize(6341);
        assertThat(snapshot.encoding()).isEqualTo("windows-1252");
        assertThat(snapshot.cutoff()).hasToString("2026-11-10");
        assertThat(snapshot.records()).allSatisfy(record -> {
            assertThat(record.status()).isIn(RecordStatus.COORDINATE_FORMAT_AMBIGUOUS,
                    RecordStatus.COORDINATE_MAPPING_UNVERIFIED);
            assertThat(record.normalizedLatitude()).isNull();
            assertThat(record.normalizedLongitude()).isNull();
        });
        assertThat(snapshot.records()).anySatisfy(record -> {
            assertThat(record.sourceRecordId()).isEqualTo("237");
            assertThat(record.rawFields().get("LATITUD")).isEqualTo("-7.576.291.501.522.060");
            assertThat(record.rawFields().get("LONGITUD")).isEqualTo("-14.087.854.051.458.200");
        });
    }

    private MinceturSnapshotParser.Snapshot parse(String dataRow) throws IOException {
        String text = HEADER + "\r\n" + dataRow + "\r\n";
        return parser.parse("mincetur.csv", text.getBytes(StandardCharsets.UTF_8));
    }

    private static String row(String id, String name, String lat, String lon) {
        return row(id, name, lat, lon, "Lagunas");
    }

    private static String row(String id, String name, String lat, String lon, String subType) {
        return String.join(";", "Ica", "Ica", "ICA", id, name, "1. SITIOS NATURALES", "g. Cuerpo de Agua",
                quote(subType), "https://example.test/ficha", lat, lon, "20261110");
    }

    private static String quote(String value) {
        return "\"" + value.replace("\"", "\"\"") + "\"";
    }
}
