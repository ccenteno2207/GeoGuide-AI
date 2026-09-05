package ai.geoguide.poi.infrastructure.persistence;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ai.geoguide.poi.domain.Category;
import ai.geoguide.poi.domain.GeoPoint;
import ai.geoguide.poi.domain.PoiId;
import ai.geoguide.poi.domain.PointOfInterest;
import ai.geoguide.poi.domain.SourceReference;
import ai.geoguide.poi.infrastructure.dataset.P3DatasetLoader;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Instant;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.core.io.ClassPathResource;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.context.annotation.Import;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.DockerImageName;

@Testcontainers(disabledWithoutDocker = true)
@SpringBootTest
@Import({JdbcPoiRepository.class, JdbcCategoryRepository.class})
class PostgisIntegrationTests {

    @Container
    static final PostgreSQLContainer<?> POSTGIS = new PostgreSQLContainer<>(
            DockerImageName.parse("postgis/postgis:16-3.4")
                    .asCompatibleSubstituteFor("postgres"));

    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGIS::getJdbcUrl);
        registry.add("spring.datasource.username", POSTGIS::getUsername);
        registry.add("spring.datasource.password", POSTGIS::getPassword);
    }

    @Autowired
    JdbcPoiRepository repository;

    @Autowired
    JdbcTemplate jdbcTemplate;

    @Autowired
    Flyway flyway;

    @Autowired
    ObjectMapper objectMapper;

    @BeforeEach
    void cleanP3Data() {
        jdbcTemplate.execute("TRUNCATE geo.poi_provenance, geo.point_of_interest, geo.category CASCADE");
    }

    @Test
    void migrationsCreateApprovedPostgisBaseline() {
        flyway.validate();

        assertThat(jdbcTemplate.queryForObject("SELECT PostGIS_Version()", String.class)).isNotBlank();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM flyway_schema_history", Integer.class))
                .isEqualTo(4);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM information_schema.tables
                WHERE table_schema = 'geo'
                  AND table_name IN ('category', 'point_of_interest', 'poi_provenance')
                """, Integer.class)).isEqualTo(3);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM pg_indexes
                WHERE schemaname = 'geo' AND indexdef ILIKE '%USING gist (location)%'
                """, Integer.class)).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT udt_name FROM information_schema.columns
                WHERE table_schema = 'geo' AND table_name = 'point_of_interest' AND column_name = 'location'
                """, String.class)).isEqualTo("geometry");
        assertThat(jdbcTemplate.queryForObject("""
                SELECT data_type FROM information_schema.columns
                WHERE table_schema = 'geo' AND table_name = 'point_of_interest' AND column_name = 'created_at'
                """, String.class)).isEqualTo("timestamp with time zone");
    }

    @Test
    void repositoryRoundTripsDomainAndRemainsIdempotent() {
        UUID categoryId = UUID.fromString("10000000-0000-0000-0000-000000000001");
        PoiId poiId = new PoiId(UUID.fromString("20000000-0000-0000-0000-000000000001"));
        UUID provenanceId = UUID.fromString("30000000-0000-0000-0000-000000000001");
        Instant created = Instant.parse("2026-01-01T12:00:00Z");
        PointOfInterest poi = new PointOfInterest(
                poiId,
                "Centro histórico",
                "Descripción factual",
                new Category(categoryId, "HISTORIC_SITE", "Sitio histórico", true),
                new GeoPoint(-11.8765, -76.9456),
                true,
                created,
                created.plusSeconds(60),
                List.of(new SourceReference(
                        provenanceId, "official-test", "record-1", "https://example.test/record-1",
                        created, "TEST-TERMS", "Test source", "CURATED", "official-test:record-1")));

        repository.save(poi);
        repository.save(poi);

        PointOfInterest restored = repository.findById(poiId).orElseThrow();
        assertThat(restored).usingRecursiveComparison().isEqualTo(poi);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.category", Integer.class)).isOne();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest", Integer.class)).isOne();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.poi_provenance", Integer.class)).isOne();
        assertThat(jdbcTemplate.queryForMap("""
                SELECT ST_SRID(location) AS srid, ST_X(location) AS longitude, ST_Y(location) AS latitude
                FROM geo.point_of_interest WHERE id = ?
                """, poiId.value())).containsAllEntriesOf(Map.of(
                        "srid", 4326,
                        "longitude", -76.9456,
                        "latitude", -11.8765));
    }

    @Test
    void databaseRejectsMissingCategoryAndInvalidSrid() {
        assertThatThrownBy(() -> jdbcTemplate.update("""
                INSERT INTO geo.point_of_interest
                    (id, category_id, name, location, active, created_at, updated_at)
                VALUES (?, ?, 'Orphan', ST_SetSRID(ST_MakePoint(0, 0), 4326), true, now(), now())
                """, UUID.randomUUID(), UUID.randomUUID())).isInstanceOf(Exception.class);

        UUID categoryId = UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category (id, code, name, active) VALUES (?, ?, ?, true)",
                categoryId, "SRID_TEST", "SRID test");
        assertThatThrownBy(() -> jdbcTemplate.update("""
                INSERT INTO geo.point_of_interest
                    (id, category_id, name, location, active, created_at, updated_at)
                VALUES (?, ?, 'Wrong SRID', ST_SetSRID(ST_MakePoint(0, 0), 3857), true, now(), now())
                """, UUID.randomUUID(), categoryId)).isInstanceOf(Exception.class);
    }

    @Test
    void versionedP3DatasetLoadsIdempotently() throws Exception {
        P3DatasetLoader loader = new P3DatasetLoader(
                objectMapper,
                new JdbcCategoryRepository(jdbcTemplate),
                repository,
                new ClassPathResource("data/p3/taxonomy-v1.json"),
                new ClassPathResource("data/p3/lima-obrajillo-v1.json"));

        P3DatasetLoader.LoadResult first = loader.load();
        P3DatasetLoader.LoadResult second = loader.load();

        assertThat(first).isEqualTo(second);
        assertThat(first.categoryCount()).isEqualTo(15);
        assertThat(first.poiCount()).isEqualTo(5);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.category", Integer.class)).isEqualTo(15);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest", Integer.class)).isEqualTo(5);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.poi_provenance", Integer.class)).isEqualTo(10);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM geo.point_of_interest p
                LEFT JOIN geo.poi_provenance pp ON pp.poi_id = p.id
                WHERE pp.id IS NULL
                """, Integer.class)).isZero();
    }
}
