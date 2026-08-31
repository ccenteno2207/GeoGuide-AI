package ai.geoguide;

import static org.assertj.core.api.Assertions.assertThat;

import java.io.IOException;
import java.nio.charset.StandardCharsets;
import org.junit.jupiter.api.Test;
import org.springframework.core.io.ClassPathResource;

class FlywayMigrationTests {

    @Test
    void initialMigrationOnlyEnablesPostgis() throws IOException {
        var migration = new ClassPathResource("db/migration/V001__enable_postgis.sql");

        assertThat(migration.exists()).isTrue();
        assertThat(migration.getContentAsString(StandardCharsets.UTF_8).trim())
                .isEqualTo("CREATE EXTENSION IF NOT EXISTS postgis;");
    }
}
