package ai.geoguide.poi.infrastructure.persistence;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ai.geoguide.poi.domain.Category;
import ai.geoguide.poi.domain.GeoPoint;
import ai.geoguide.poi.domain.PoiId;
import ai.geoguide.poi.domain.PointOfInterest;
import ai.geoguide.poi.domain.SourceReference;
import ai.geoguide.poi.application.port.CategoryRepository;
import ai.geoguide.destination.application.port.DestinationRepository;
import ai.geoguide.destination.domain.Destination;
import ai.geoguide.destination.infrastructure.dataset.DestinationCatalogLoader;
import ai.geoguide.poi.infrastructure.dataset.P3DatasetLoader;
import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotCoordinateNormalizer;
import ai.geoguide.poi.infrastructure.dataset.mincetur.JdbcMinceturSnapshotStagingRepository;
import ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturSnapshotParser;
import ai.geoguide.admin.infrastructure.persistence.AdminEditorialRepository;
import ai.geoguide.admin.infrastructure.persistence.AdminImportReadRepository;
import ai.geoguide.admin.infrastructure.persistence.AdminDestinationRepository;
import ai.geoguide.admin.infrastructure.persistence.AdminDestinationPoiRelationshipRepository;
import ai.geoguide.discovery.domain.DiscoveryCriteria;
import ai.geoguide.discovery.infrastructure.persistence.JdbcRoutePoiCandidateQuery;
import ai.geoguide.routing.domain.RouteGeometry;
import ai.geoguide.routing.domain.RoutePoint;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.time.Instant;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.core.io.ClassPathResource;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.context.annotation.Import;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;
import org.junit.jupiter.api.extension.ExtendWith;
import org.junit.jupiter.api.extension.ConditionEvaluationResult;
import org.junit.jupiter.api.extension.ExecutionCondition;
import org.junit.jupiter.api.extension.ExtensionContext;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.DockerClientFactory;
import org.testcontainers.utility.DockerImageName;

@ExtendWith(PostgisIntegrationTests.PostgisEnvironmentCondition.class)
@SpringBootTest
@AutoConfigureMockMvc
@Import({JdbcPoiRepository.class, JdbcCategoryRepository.class, JdbcRoutePoiCandidateQuery.class,
        JdbcMinceturSnapshotStagingRepository.class})
class PostgisIntegrationTests {

    static final PostgreSQLContainer<?> POSTGIS = new PostgreSQLContainer<>(
            DockerImageName.parse("postgis/postgis:16-3.4")
                    .asCompatibleSubstituteFor("postgres"));

    static final String EXTERNAL_DATABASE_PROPERTY = "geoguide.test.postgis.external";

    public static final class PostgisEnvironmentCondition implements ExecutionCondition {
        @Override
        public ConditionEvaluationResult evaluateExecutionCondition(ExtensionContext context) {
            if (Boolean.getBoolean(EXTERNAL_DATABASE_PROPERTY)) {
                return ConditionEvaluationResult.enabled("Using explicitly configured isolated PostGIS database.");
            }
            return DockerClientFactory.instance().isDockerAvailable()
                    ? ConditionEvaluationResult.enabled("Docker is available for Testcontainers.")
                    : ConditionEvaluationResult.disabled("Docker is unavailable and no external PostGIS was configured.");
        }
    }

    @DynamicPropertySource
    static void databaseProperties(DynamicPropertyRegistry registry) {
        if (Boolean.getBoolean(EXTERNAL_DATABASE_PROPERTY)) {
            registry.add("spring.datasource.url", () -> requiredSystemProperty("geoguide.test.postgis.url"));
            registry.add("spring.datasource.username", () -> requiredSystemProperty("geoguide.test.postgis.username"));
            registry.add("spring.datasource.password", () -> requiredSystemProperty("geoguide.test.postgis.password"));
        } else {
            POSTGIS.start();
            registry.add("spring.datasource.url", POSTGIS::getJdbcUrl);
            registry.add("spring.datasource.username", POSTGIS::getUsername);
            registry.add("spring.datasource.password", POSTGIS::getPassword);
        }
    }

    @AfterAll
    static void stopPostgisContainer() {
        if (!Boolean.getBoolean(EXTERNAL_DATABASE_PROPERTY) && POSTGIS.isRunning()) {
            POSTGIS.stop();
        }
    }

    private static String requiredSystemProperty(String name) {
        String value = System.getProperty(name);
        if (value == null || value.isBlank()) throw new IllegalStateException(name + " is required.");
        return value;
    }

    @Autowired
    JdbcPoiRepository repository;

    @Autowired
    CategoryRepository categoryRepository;

    @Autowired
    JdbcTemplate jdbcTemplate;

    @Autowired
    DestinationRepository destinationRepository;

    @Autowired
    JdbcRoutePoiCandidateQuery discoveryQuery;

    @Autowired
    Flyway flyway;

    @Autowired
    ObjectMapper objectMapper;

    @Autowired
    JdbcMinceturSnapshotStagingRepository minceturStagingRepository;

    @Autowired
    AdminEditorialRepository adminEditorialRepository;

    @Autowired
    AdminImportReadRepository adminImportReadRepository;

    @Autowired
    AdminDestinationRepository adminDestinationRepository;

    @Autowired
    AdminDestinationPoiRelationshipRepository adminDestinationPoiRelationshipRepository;

    @Autowired
    MockMvc mockMvc;

    @BeforeEach
    void cleanP3Data() {
        jdbcTemplate.execute("TRUNCATE geo.mincetur_import_record, geo.mincetur_import_batch CASCADE");
        jdbcTemplate.execute("TRUNCATE geo.poi_provenance, geo.point_of_interest, geo.category CASCADE");
        jdbcTemplate.execute("TRUNCATE geo.destination_alias, geo.destination CASCADE");
    }

    @Test
    void migrationsCreateApprovedPostgisBaseline() {
        flyway.validate();

        assertThat(jdbcTemplate.queryForObject("SELECT PostGIS_Version()", String.class)).isNotBlank();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM flyway_schema_history", Integer.class))
                .isEqualTo(9);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM information_schema.tables
                WHERE table_schema = 'geo'
                  AND table_name IN ('category', 'point_of_interest', 'poi_provenance')
                """, Integer.class)).isEqualTo(3);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM pg_indexes
                WHERE schemaname = 'geo' AND tablename = 'point_of_interest'
                  AND indexdef ILIKE '%USING gist (location)%'
                """, Integer.class)).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM pg_indexes
                WHERE schemaname = 'geo' AND tablename = 'destination'
                  AND indexdef ILIKE '%USING gist (location)%'
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
    void destinationPublicationRequiresIndependentGeoIdentityAndAccessReviewsAndDoesNotPublishPoi() {
        var draft = adminDestinationRepository.create(new AdminDestinationRepository.CreateDestination(
                "Recurso sintético Lima Canta", "REALIZACION_TECNICA", "Canta — Lima — Lima",
                new java.math.BigDecimal("-11.45"), new java.math.BigDecimal("-76.62"),
                "raw-lat", "raw-lon", "synthetic-test-rule", "synthetic map evidence",
                "https://example.invalid/test-source", "TEST_ONLY", "Synthetic fixture attribution", "test-dest-1"),
                "editor-1");

        var geo = adminDestinationRepository.reviewGeography(draft.id(), draft.version(), true,
                "reviewer-1", "synthetic coordinate verified");
        var identity = adminDestinationRepository.reviewIdentity(geo.id(), geo.version(), true,
                "reviewer-1", "synthetic unique fixture", "No matching destination in synthetic database.");
        assertThatThrownBy(() -> adminDestinationRepository.transition(identity.id(), identity.version(),
                "SUBMIT_FOR_REVIEW", "editor-1", "access review missing", "Synthetic test proves access review gate is incomplete."))
                .isInstanceOf(RuntimeException.class);
        var access = adminDestinationRepository.reviewAccess(identity.id(), identity.version(), true,
                "reviewer-1", "access checked in synthetic test map", "fixture route point is on test road segment");
        var pending = adminDestinationRepository.transition(access.id(), access.version(),
                "SUBMIT_FOR_REVIEW", "editor-1", "all independent reviews recorded", "All required synthetic review evidence is attached.");
        var published = adminDestinationRepository.transition(pending.id(), pending.version(),
                "APPROVE", "reviewer-1", "publish isolated synthetic destination", "Approved synthetic destination record.");

        assertThat(published.publishedDestinationId()).isEqualTo(published.id());
        assertThat(destinationRepository.search(Destination.normalize("Recurso sintético"), 10))
                .extracting(Destination::id).contains(published.id());
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest", Integer.class)).isZero();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM admin.destination_editorial_audit WHERE destination_editorial_id=?", Integer.class,
                published.id())).isEqualTo(6);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT details->>'evidence' FROM admin.destination_editorial_audit
                WHERE destination_editorial_id=? AND action='NO_DUPLICATE_CONFIRMED'
                """, String.class, published.id())).isEqualTo("No matching destination in synthetic database.");
        assertThat(jdbcTemplate.queryForObject("""
                SELECT details->>'evidence' FROM admin.destination_editorial_audit
                WHERE destination_editorial_id=? AND action='APPROVE'
                """, String.class, published.id())).isEqualTo("Approved synthetic destination record.");
    }

    @Test
    void destinationPoiRelationshipIsPendingAndAuditedWithoutChangingEitherGeometry() {
        UUID destinationId = UUID.randomUUID();
        UUID poiId = UUID.randomUUID();
        UUID categoryId = UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category(id,code,name,active) VALUES (?,?,?,true)", categoryId, "OTHER", "Other");
        jdbcTemplate.update("""
                INSERT INTO geo.destination(id,canonical_name,normalized_name,destination_type,administrative_context,
                    location,source_system,source_record_id,source_url,source_license,attribution,verified_at,catalog_version,active)
                VALUES (?,?,?,? ,?,ST_SetSRID(ST_MakePoint(?,?),4326),?,?,?,?,?,CURRENT_DATE,?,true)
                """, destinationId,"Destination test","destination test","TEST","Canta, Lima",-76.620000,-11.450000,
                "TEST","dest-link-1","https://example.invalid","TEST_ONLY","synthetic", "test-v1");
        jdbcTemplate.update("""
                INSERT INTO geo.point_of_interest(id,category_id,name,description,location,active,created_at,updated_at)
                VALUES (?,?,?,NULL,ST_SetSRID(ST_MakePoint(?,?),4326),true,now(),now())
                """, poiId,categoryId,"POI test",-76.619000,-11.451000);

        var pending = adminDestinationPoiRelationshipRepository.create(
                new AdminDestinationPoiRelationshipRepository.CreateRelationship(destinationId, poiId,
                        "RELATED_RESOURCE", "synthetic relationship review", "Fixture says these are related only."), "editor-1");
        assertThat(pending.status()).isEqualTo("PENDING");
        var approved = adminDestinationPoiRelationshipRepository.review(pending.id(), pending.version(), true,
                "reviewer-1", "relationship confirmed", "synthetic test evidence");
        assertThat(approved.status()).isEqualTo("APPROVED");
        assertThat(jdbcTemplate.queryForObject("SELECT ST_X(location) FROM geo.destination WHERE id=?", Double.class,
                destinationId)).isEqualTo(-76.62);
        assertThat(jdbcTemplate.queryForObject("SELECT ST_X(location) FROM geo.point_of_interest WHERE id=?", Double.class,
                poiId)).isEqualTo(-76.619);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM admin.destination_poi_relationship_audit WHERE relationship_id=?",
                Integer.class, pending.id())).isEqualTo(2);
    }

    @Test
    void stagingSnapshotIsIdempotentAndDoesNotPublishOrCreateGeometry() throws Exception {
        String csv = String.join("\r\n",
                "REGIÓN;PROVINCIA;DISTRITO;CODIGO DEL RECURSO;NOMBRE DEL RECURSO;CATEGORÍA;TIPO DE CATEGORÍA;SUB TIPO CATEGORÍA;URL;LATITUD;LONGITUD;FECHA_DE_CORTE",
                "Ica;Ica;ICA;237;Laguna De Huacachina;1. SITIOS NATURALES;g. Cuerpo de Agua;Lagunas;https://example.test/237;-7.576.291.501.522.060;-14.087.854.051.458.200;20261110",
                "");
        var snapshot = new MinceturSnapshotParser().parse("sample.csv", csv.getBytes(java.nio.charset.StandardCharsets.UTF_8));

        var firstBatchId = minceturStagingRepository.stage(snapshot);
        var secondBatchId = minceturStagingRepository.stage(snapshot);

        assertThat(secondBatchId).isEqualTo(firstBatchId);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.mincetur_import_batch", Integer.class))
                .isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.mincetur_import_record", Integer.class))
                .isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT record_status FROM geo.mincetur_import_record WHERE batch_id = ?
                """, String.class, firstBatchId)).isEqualTo("COORDINATE_FORMAT_AMBIGUOUS");
        assertThat(jdbcTemplate.queryForObject("""
                SELECT thematic_eligibility FROM geo.mincetur_import_record WHERE batch_id = ?
                """, String.class, firstBatchId)).isEqualTo("CLASSIFICATION_REVIEW_REQUIRED");
        assertThat(jdbcTemplate.queryForObject("""
                SELECT normalized_latitude IS NULL AND normalized_longitude IS NULL
                FROM geo.mincetur_import_record WHERE batch_id = ?
                """, Boolean.class, firstBatchId)).isTrue();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.destination", Integer.class)).isZero();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest", Integer.class)).isZero();
    }

    @Test
    void fullMinceturSnapshotStagesExpectedCountsIdempotentlyAndPreservesP3AndCuratedDestinations() throws Exception {
        String csvPath = System.getProperty("geoguide.test.minceturCsv");
        Assumptions.assumeTrue(csvPath != null && !csvPath.isBlank(),
                "Set geoguide.test.minceturCsv to stage the owner-provided source snapshot.");

        var p3 = new P3DatasetLoader(objectMapper, categoryRepository, repository,
                new ClassPathResource("data/p3/taxonomy-v1.json"),
                new ClassPathResource("data/p3/lima-obrajillo-v1.json")).load();
        int destinations = new DestinationCatalogLoader(objectMapper, destinationRepository,
                new ClassPathResource("data/destination-search/mincetur-pilot-v1.json")).load();
        assertThat(p3.poiCount()).isEqualTo(5);
        assertThat(destinations).isEqualTo(9);

        var p3Before = jdbcTemplate.queryForList("""
                SELECT id::text AS id, name, ST_AsText(location) AS geometry, active
                FROM geo.point_of_interest ORDER BY id
                """);
        var destinationsBefore = jdbcTemplate.queryForList("""
                SELECT id::text AS id, canonical_name, ST_AsText(location) AS geometry, active
                FROM geo.destination ORDER BY id
                """);

        byte[] source = Files.readAllBytes(Path.of(csvPath));
        var parsed = new MinceturSnapshotParser().parse(Path.of(csvPath).getFileName().toString(), source);
        var normalizer = new MinceturSnapshotCoordinateNormalizer(objectMapper);
        var manifest = new ClassPathResource(
                "data/destination-search/mincetur-20261110-coordinate-recovery-v1.json");
        var snapshot = normalizer.normalize(parsed, manifest.getInputStream());

        assertThat(snapshot.sha256()).isEqualToIgnoringCase(
                "29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66");
        assertThat(snapshot.records()).hasSize(6_341);
        assertThat(snapshot.records().stream().filter(r -> r.status()
                == MinceturSnapshotParser.RecordStatus.NORMALIZED_PENDING_REVIEW)).hasSize(6_331);
        assertThat(snapshot.records().stream().filter(r -> r.status()
                == MinceturSnapshotParser.RecordStatus.COORDINATE_FORMAT_AMBIGUOUS)).hasSize(10);

        var taxonomy = new ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturTaxonomyFilter()
                .classify(snapshot);
        assertThat(taxonomy.supportedSnapshot()).isTrue();
        assertThat(taxonomy.decisionsByRowNumber().values().stream()
                .filter(decision -> decision.eligibility() ==
                        ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturTaxonomyFilter.Eligibility
                                .EXCLUDED_FROM_NAVIGATION)).hasSize(1_768);
        assertThat(taxonomy.decisionsByRowNumber().values().stream()
                .filter(decision -> decision.eligibility() ==
                        ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturTaxonomyFilter.Eligibility
                                .ELIGIBLE_FOR_REVIEW)).hasSize(4_573);
        assertThat(taxonomy.decisionsByRowNumber().values().stream()
                .filter(decision -> decision.eligibility() ==
                        ai.geoguide.poi.infrastructure.dataset.mincetur.MinceturTaxonomyFilter.Eligibility
                                .CLASSIFICATION_REVIEW_REQUIRED)).isEmpty();

        UUID firstBatch = minceturStagingRepository.stage(snapshot);
        UUID secondBatch = minceturStagingRepository.stage(snapshot);

        assertThat(secondBatch).isEqualTo(firstBatch);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.mincetur_import_batch", Integer.class))
                .isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.mincetur_import_record", Integer.class))
                .isEqualTo(6_341);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT taxonomy_filter_version FROM geo.mincetur_import_batch WHERE id = ?
                """, String.class, firstBatch)).isEqualTo("MINCETUR-TAXONOMY-FILTER-v1");
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM geo.mincetur_import_record
                WHERE record_status='NORMALIZED_PENDING_REVIEW'
                """, Integer.class)).isEqualTo(6_331);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM geo.mincetur_import_record
                WHERE record_status='COORDINATE_FORMAT_AMBIGUOUS'
                """, Integer.class)).isEqualTo(10);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM geo.mincetur_import_record
                WHERE thematic_eligibility='EXCLUDED_FROM_NAVIGATION'
                """, Integer.class)).isEqualTo(1_768);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM geo.mincetur_import_record
                WHERE thematic_eligibility='ELIGIBLE_FOR_REVIEW'
                """, Integer.class)).isEqualTo(4_573);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM geo.mincetur_import_record
                WHERE thematic_eligibility='CLASSIFICATION_REVIEW_REQUIRED'
                """, Integer.class)).isZero();
        assertThat(jdbcTemplate.queryForObject("""
                SELECT raw_fields->>'LATITUD' FROM geo.mincetur_import_record
                WHERE batch_id = ? AND source_record_id = '237'
                """, String.class, firstBatch)).isEqualTo("-7.576.291.501.522.060");
        assertThat(jdbcTemplate.queryForList("""
                SELECT id::text AS id, name, ST_AsText(location) AS geometry, active
                FROM geo.point_of_interest ORDER BY id
                """)).isEqualTo(p3Before);
        assertThat(jdbcTemplate.queryForList("""
                SELECT id::text AS id, canonical_name, ST_AsText(location) AS geometry, active
                FROM geo.destination ORDER BY id
                """)).isEqualTo(destinationsBefore);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM admin.poi_editorial_record", Integer.class)).isZero();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM admin.destination_editorial_record", Integer.class)).isZero();
    }

    @Test
    void administrativeReadQueriesAcceptOmittedOptionalFilters() {
        assertThat(adminEditorialRepository.list(null, null, 0, 50)).isNotNull();

        UUID batchId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_batch(id,source_system,source_file_name,source_sha256,source_cutoff,
                    detected_encoding,delimiter,parser_version,record_count,quarantined_count,batch_status)
                VALUES (?, 'MINCETUR', 'filters.csv', ?, DATE '2026-11-10', 'UTF-8', ';', 'filters-test', 0, 0,
                    'STAGED_REQUIRES_REVIEW')
                """, batchId, UUID.randomUUID().toString().replace("-", "").repeat(2).toUpperCase(java.util.Locale.ROOT));

        assertThat(adminImportReadRepository.records(batchId, null, null, 0, 50).totalElements()).isZero();
        assertThat(adminImportReadRepository.records(batchId, "NORMALIZED_PENDING_REVIEW", "", 0, 50)
                .totalElements()).isZero();
    }

    @Test
    void editorialPublicationRequiresIndependentGeographicAndIdentityReviewAndPreservesExistingPoi() {
        UUID categoryId=UUID.randomUUID(), existingId=UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category(id,code,name,active) VALUES (?,?,?,true)",categoryId,"MONUMENT","Monument");
        jdbcTemplate.update("""
                INSERT INTO geo.point_of_interest(id,category_id,name,description,location,active,created_at,updated_at)
                VALUES (?,?,?, ?,ST_SetSRID(ST_MakePoint(-75,-14),4326),true,now(),now())
                """,existingId,categoryId,"Existing P3 record","Preserved");
        var candidate=adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(null,
                "Synthetic MINCETUR candidate","Candidate description","MONUMENT",
                new java.math.BigDecimal("-14.1"),new java.math.BigDecimal("-75.1"),
                "-14.1","-75.1","SYNTHETIC_TEST_COORDINATE","Synthetic fixture coordinates generated for this test",
                "Synthetic test terms","Synthetic fixture attribution"),"editor-test");

        assertThat(candidate.state()).isEqualTo("DRAFT");
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest",Integer.class)).isEqualTo(1);
        var geographic=adminEditorialRepository.reviewGeography(candidate.id(),0,true,"reviewer-test","Coordinates manually checked against isolated fixture evidence");
        var identity=adminEditorialRepository.reviewIdentity(candidate.id(),geographic.version(),true,"reviewer-test",
                "No matching P3 or destination entry in isolated fixture", "Synthetic identity comparison returned no exact match.");
        var submitted=adminEditorialRepository.transition(candidate.id(),identity.version(),"SUBMIT_FOR_REVIEW","editor-test","Ready for independent editorial review","Synthetic review packet is complete.");
        var published=adminEditorialRepository.transition(candidate.id(),submitted.version(),"APPROVE","reviewer-test","Approved synthetic fixture for local integration test","Synthetic publication evidence validated.");

        assertThat(published.state()).isEqualTo("PUBLISHED");
        assertThat(published.publishedPoiId()).isEqualTo(candidate.id());
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest",Integer.class)).isEqualTo(2);
        assertThat(jdbcTemplate.queryForObject("SELECT name FROM geo.point_of_interest WHERE id=?",String.class,existingId))
                .isEqualTo("Existing P3 record");
        assertThat(jdbcTemplate.queryForObject("SELECT ST_X(location) FROM geo.point_of_interest WHERE id=?",Double.class,existingId))
                .isEqualTo(-75.0);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.poi_provenance WHERE poi_id=?",Integer.class,candidate.id())).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM admin.poi_editorial_audit WHERE editorial_id=?",Integer.class,candidate.id())).isEqualTo(5);
        assertThat(jdbcTemplate.queryForObject("""
                SELECT details->>'evidence' FROM admin.poi_editorial_audit
                WHERE editorial_id=? AND action='NO_DUPLICATE_CONFIRMED'
                """, String.class, candidate.id())).isEqualTo("Synthetic identity comparison returned no exact match.");
        assertThat(jdbcTemplate.queryForObject("""
                SELECT details->>'decisionEvidence' FROM admin.poi_editorial_audit
                WHERE editorial_id=? AND action='APPROVE'
                """, String.class, candidate.id())).isEqualTo("Synthetic publication evidence validated.");
    }

    @Test
    void editorialDraftPreservesFullPrecisionOfStagedCoordinateCandidate() {
        UUID batchId = UUID.randomUUID();
        UUID importRecordId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_batch(id,source_system,source_file_name,source_sha256,source_cutoff,
                    detected_encoding,delimiter,parser_version,record_count,quarantined_count,batch_status)
                VALUES (?, 'MINCETUR', 'synthetic.csv', ?, DATE '2026-11-10', 'UTF-8', ';', 'precision-test', 1, 0,
                    'STAGED_REQUIRES_REVIEW')
                """, batchId, "A".repeat(64));
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_record(id,batch_id,row_number,source_record_id,raw_fields,
                    raw_latitude,raw_longitude,normalized_latitude,normalized_longitude,normalization_rule,
                    validation_evidence,record_status)
                VALUES (?,?,1,'237',?::jsonb,?,?,?,?,'synthetic-precision-rule',
                    'synthetic test evidence; candidate is not published', 'NORMALIZED_PENDING_REVIEW')
                """, importRecordId,
                batchId,
                "{\"NOMBRE DEL RECURSO\":\"Laguna de Huacachina\",\"URL\":\"https://example.test/237\"}",
                "-7.576.291.501.522.060", "-14.087.854.051.458.200",
                new java.math.BigDecimal("-14.087854051458200"),
                new java.math.BigDecimal("-75.76291501522060"));

        var draft = adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(
                importRecordId, null, null, "NATURAL_SITE", null, null, null, null, null, null, null, null), "editor-test");

        assertThat(draft.latitude()).isEqualByComparingTo("-14.087854051458200");
        assertThat(draft.longitude()).isEqualByComparingTo("-75.76291501522060");
        assertThat(draft.rawLatitude()).isEqualTo("-7.576.291.501.522.060");
        assertThat(draft.rawLongitude()).isEqualTo("-14.087.854.051.458.200");
        assertThat(draft.state()).isEqualTo("DRAFT");
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest", Integer.class)).isZero();
    }

    @Test
    void destinationCatalogSearchMatchesAccentInsensitiveNamesAndAliases() {
        UUID id = UUID.randomUUID();
        Destination destination = new Destination(id, "Plaza Mayor De Lima", null,
                "LANDMARK", "Lima, Lima, LIMA", -12.045947477780945, -77.03060082209015,
                "MINCETUR", "3348", "https://example.test/3348", "ODC-BY-1.0", "Fuente MINCETUR",
                List.of(new Destination.Alias(UUID.randomUUID(), "Plaza de Armas de Lima", null,
                        "Ficha MINCETUR 3348: también llamada Plaza de Armas")));
        destinationRepository.saveCatalogEntry(destination, "test-v1", java.time.LocalDate.of(2026, 11, 10));

        assertThat(destinationRepository.search("plaza de armas de lima", 10))
                .extracting(Destination::canonicalName)
                .containsExactly("Plaza Mayor De Lima");
        assertThat(destinationRepository.search(Destination.normalize("PLAZA DE ARMAS"), 1)).hasSize(1);
    }

    @Test
    void optInCatalogLoadsIdempotentlyAndSearchEndpointReturnsVerifiedCoordinate() throws Exception {
        var loader = new DestinationCatalogLoader(objectMapper, destinationRepository,
                new ClassPathResource("data/destination-search/mincetur-pilot-v1.json"));
        assertThat(loader.load()).isEqualTo(9);
        assertThat(loader.load()).isEqualTo(9);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.destination", Integer.class)).isEqualTo(9);

        mockMvc.perform(post("/api/v1/destinations/search")
                        .contentType("application/json")
                        .content("{\"query\":\"Plaza de Armas de Lima\",\"limit\":20}"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.results[0].name").value("Plaza Mayor De Lima"))
                .andExpect(jsonPath("$.results[0].latitude").value(-12.045947477780945))
                .andExpect(jsonPath("$.results[0].source").value("MINCETUR - Inventario Nacional de Recursos Turísticos"));
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
        PointOfInterest revised = new PointOfInterest(
                poi.id(), "Centro histórico actualizado", poi.description(), poi.category(),
                poi.location(), false, poi.createdAt(), poi.updatedAt().plusSeconds(60),
                poi.provenance());
        repository.save(revised);

        PointOfInterest restored = repository.findById(poiId).orElseThrow();
        assertThat(restored).usingRecursiveComparison().isEqualTo(revised);
        assertThat(restored.active()).isFalse();
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

    @Test
    void discoveryQueryUsesRouteCorridorActivePoisAndCategoryFilter() {
        UUID categoryId = UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category (id, code, name, active) VALUES (?, 'MUSEUM', 'Museum', true)", categoryId);
        jdbcTemplate.update("INSERT INTO geo.point_of_interest (id, category_id, name, location, active, created_at, updated_at) VALUES (?, ?, 'On route', ST_SetSRID(ST_MakePoint(-77.00, -12.00), 4326), true, now(), now())", UUID.randomUUID(), categoryId);
        jdbcTemplate.update("INSERT INTO geo.point_of_interest (id, category_id, name, location, active, created_at, updated_at) VALUES (?, ?, 'Inactive', ST_SetSRID(ST_MakePoint(-77.01, -12.00), 4326), false, now(), now())", UUID.randomUUID(), categoryId);
        jdbcTemplate.update("INSERT INTO geo.point_of_interest (id, category_id, name, location, active, created_at, updated_at) VALUES (?, ?, 'Far', ST_SetSRID(ST_MakePoint(-77.00, -11.80), 4326), true, now(), now())", UUID.randomUUID(), categoryId);

        var candidates = discoveryQuery.findAlong(new RouteGeometry(List.of(
                new RoutePoint(-12.00, -77.02), new RoutePoint(-12.00, -76.98))),
                new DiscoveryCriteria(java.util.Set.of("MUSEUM"), 1_000, 20));

        assertThat(candidates).extracting(candidate -> candidate.name()).containsExactly("On route");
        assertThat(candidates.getFirst().routeProgress()).isBetween(0.0, 1.0);
    }

    @Test
    void discoveryCorridorQueryCanUseTheInheritedGistIndex() {
        UUID categoryId = UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category (id, code, name, active) VALUES (?, 'INDEX_TEST', 'Index test', true)", categoryId);
        jdbcTemplate.update("INSERT INTO geo.point_of_interest (id, category_id, name, location, active, created_at, updated_at) VALUES (?, ?, 'Indexed POI', ST_SetSRID(ST_MakePoint(-77.00, -12.00), 4326), true, now(), now())", UUID.randomUUID(), categoryId);

        jdbcTemplate.execute("SET enable_seqscan = off");
        try {
            var plan = jdbcTemplate.queryForList("""
                    EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
                    WITH route AS (SELECT ST_SetSRID(ST_GeomFromGeoJSON(?), 4326) AS geometry)
                    SELECT p.id FROM geo.point_of_interest p CROSS JOIN route
                    WHERE p.location && ST_Expand(route.geometry, ? / 111320.0)
                      AND ST_DWithin(p.location::geography, route.geometry::geography, ?)
                    LIMIT ?
                    """, String.class,
                    "{\"type\":\"LineString\",\"coordinates\":[[-77.02,-12.0],[-76.98,-12.0]]}", 1_000, 1_000, 20);

            assertThat(plan).anyMatch(line -> line.contains("Index Scan"));
        } finally {
            jdbcTemplate.execute("RESET enable_seqscan");
        }
    }
}
