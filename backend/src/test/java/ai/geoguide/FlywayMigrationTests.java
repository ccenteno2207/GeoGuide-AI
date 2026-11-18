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

    @Test
    void v007DefinesSeparateEditorialAndPrivateMediaLedgersWithoutPublishingImportedRows() throws IOException {
        var migration = new ClassPathResource("db/migration/V007__admin_editorial_and_media.sql");
        assertThat(migration.exists()).isTrue();
        String sql = migration.getContentAsString(StandardCharsets.UTF_8);
        assertThat(sql).contains("CREATE TABLE admin.poi_editorial_record")
                .contains("CREATE TABLE admin.poi_editorial_audit")
                .contains("CREATE TABLE media.poi_asset")
                .contains("CREATE TABLE media.poi_asset_audit")
                .contains("BEFORE UPDATE OR DELETE ON admin.poi_editorial_audit")
                .contains("BEFORE UPDATE OR DELETE ON media.poi_asset_audit")
                .contains("admin_editorial_geo_approval_evidence")
                .contains("admin_editorial_identity_evidence")
                .contains("latitude NUMERIC,")
                .contains("longitude NUMERIC,")
                .doesNotContain("latitude NUMERIC(10,7)")
                .doesNotContain("longitude NUMERIC(10,7)")
                .doesNotContain("UPDATE geo.point_of_interest SET location")
                .doesNotContain("UPDATE geo.destination SET location");
    }

    @Test
    void v008AddsIndependentDestinationReviewAndAuditableCrossDomainLinks() throws IOException {
        var migration = new ClassPathResource("db/migration/V008__poi_catalog_destination_review_and_links.sql");
        assertThat(migration.exists()).isTrue();
        String sql = migration.getContentAsString(StandardCharsets.UTF_8);
        assertThat(sql).contains("CREATE TABLE admin.destination_editorial_record")
                .contains("ALTER TABLE admin.poi_editorial_record")
                .contains("identity_review_evidence")
                .contains("access_review_status")
                .contains("published_destination_id UUID UNIQUE REFERENCES geo.destination(id)")
                .contains("CREATE TABLE admin.destination_poi_relationship")
                .contains("SAME_RESOURCE")
                .contains("RELATED_RESOURCE")
                .contains("relationship_status IN ('PENDING','APPROVED','REJECTED')")
                .contains("CREATE TABLE admin.destination_poi_relationship_audit")
                .contains("BEFORE UPDATE OR DELETE ON admin.destination_editorial_audit")
                .contains("BEFORE UPDATE OR DELETE ON admin.destination_poi_relationship_audit")
                .doesNotContain("UPDATE geo.destination SET location")
                .doesNotContain("UPDATE geo.point_of_interest SET location");
    }
}
