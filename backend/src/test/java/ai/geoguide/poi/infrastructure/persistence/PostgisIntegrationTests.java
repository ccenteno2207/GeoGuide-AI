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
import ai.geoguide.admin.infrastructure.persistence.AdminPoiInventoryRepository;
import ai.geoguide.admin.infrastructure.persistence.PoiOperationalInfoRepository;
import ai.geoguide.poi.domain.PoiOperationalInfo;
import ai.geoguide.admin.domain.EditorialWorkflowConflictException;
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
    AdminPoiInventoryRepository adminPoiInventoryRepository;

    @Autowired
    PoiOperationalInfoRepository poiOperationalInfoRepository;

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
        jdbcTemplate.execute("TRUNCATE admin.poi_editorial_record, admin.destination_editorial_record, " +
                "admin.destination_poi_relationship, media.poi_asset CASCADE");
    }

    @Test
    void reopenedUnpublishedMinceturArchiveKeepsIdentityAndResetsReviewsWithoutPublishing() throws Exception {
        UUID importRecordId = insertSyntheticMinceturCandidate("1851", "Sitio Arqueológico Cantamarca sintético");
        var draft = adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(importRecordId,
                null, null, "ARCHAEOLOGICAL_SITE", null, null, null, null, null, null,
                "Synthetic license", "Synthetic attribution"), "editor-test");
        var archived = adminEditorialRepository.transition(draft.id(), draft.version(), "ARCHIVE", "administrator-test",
                "Archive fixture before review.", "Synthetic archive evidence.");

        var reopened = adminEditorialRepository.reopen(archived.id(), archived.version(), "administrator-test",
                "Reopen the synthetic archived candidate for editorial review.");

        assertThat(reopened.id()).isEqualTo(archived.id());
        assertThat(reopened.importRecordId()).isEqualTo(importRecordId);
        assertThat(reopened.sourceRecordId()).isEqualTo("1851");
        assertThat(reopened.state()).isEqualTo("DRAFT");
        assertThat(reopened.version()).isEqualTo(archived.version() + 1);
        assertThat(reopened.active()).isFalse();
        assertThat(reopened.publishedPoiId()).isNull();
        assertThat(reopened.targetPoiId()).isNull();
        assertThat(reopened.geographicReviewStatus()).isEqualTo("PENDING");
        assertThat(reopened.identityReviewStatus()).isEqualTo("PENDING");
        assertThat(reopened.identityReviewEvidence()).isNull();
        assertThat(reopened.rawLatitude()).isEqualTo("-11.438714");
        assertThat(reopened.rawLongitude()).isEqualTo("-76.591777");
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.point_of_interest", Integer.class)).isZero();
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM admin.poi_editorial_record WHERE import_record_id=?", Integer.class,
                importRecordId)).isEqualTo(1);
        assertThat(jdbcTemplate.queryForMap("""
                SELECT actor_id, action, reason, previous_state, next_state, version
                FROM admin.poi_editorial_audit WHERE editorial_id=? ORDER BY version DESC LIMIT 1
                """, reopened.id())).containsEntry("actor_id", "administrator-test")
                .containsEntry("action", "REOPEN")
                .containsEntry("reason", "Reopen the synthetic archived candidate for editorial review.")
                .containsEntry("previous_state", "ARCHIVED")
                .containsEntry("next_state", "DRAFT")
                .containsEntry("version", reopened.version());
        assertThatThrownBy(() -> adminEditorialRepository.reopen(reopened.id(), archived.version(), "administrator-test", "stale reopen"))
                .isInstanceOf(EditorialWorkflowConflictException.class)
                .hasMessageContaining("version is stale");
        assertThatThrownBy(() -> adminEditorialRepository.reopen(reopened.id(), reopened.version(), "administrator-test", "duplicate reopen"))
                .isInstanceOf(EditorialWorkflowConflictException.class)
                .hasMessageContaining("Only archived");
    }

    @Test
    void observedRecordCanBeReviewedAgainAndPublishedArchiveReopensAsSameInactivePoiChangeRequest() throws Exception {
        jdbcTemplate.update("INSERT INTO geo.category(id,code,name,active) VALUES (?,?,?,true)",
                UUID.randomUUID(), "ARCHAEOLOGICAL_SITE", "Archaeological site");
        UUID importRecordId = insertSyntheticMinceturCandidate("1851", "Sitio Arqueológico Cantamarca sintético");
        var draft = adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(importRecordId,
                null, null, "ARCHAEOLOGICAL_SITE", null, null, null, null, null, null,
                "Synthetic license", "Synthetic attribution"), "editor-test");
        var geographic = adminEditorialRepository.reviewGeography(draft.id(), draft.version(), true,
                "reviewer-test", "Initial synthetic coordinate review.");
        var identity = adminEditorialRepository.reviewIdentity(draft.id(), geographic.version(), true,
                "reviewer-test", "Initial synthetic identity review.", "No duplicate found in synthetic catalog.");
        var submitted = adminEditorialRepository.transition(identity.id(), identity.version(), "SUBMIT_FOR_REVIEW",
                "editor-test", "Submit synthetic candidate.", "Initial review evidence.");
        var observed = adminEditorialRepository.transition(submitted.id(), submitted.version(), "OBSERVE",
                "reviewer-test", "Request a synthetic correction.", "Correct the validated description.");
        var edited = adminEditorialRepository.update(observed.id(), observed.version(),
                new AdminEditorialRepository.UpdateEditorial(observed.name(), "Corrected synthetic description.",
                        observed.categoryCode(), observed.latitude(), observed.longitude(), observed.normalizationRule(),
                        observed.coordinateEvidence(), observed.sourceLicense(), observed.sourceAttribution(),
                        observed.administrativeContext()), "editor-test", "Apply the requested synthetic correction.");
        var observedGeography = adminEditorialRepository.reviewGeography(edited.id(), edited.version(), true,
                "reviewer-test", "Recheck coordinates after the observed edit.");
        var observedIdentity = adminEditorialRepository.reviewIdentity(observedGeography.id(), observedGeography.version(), true,
                "reviewer-test", "Recheck identity after the observed edit.", "No duplicate found after the edit.");
        var resubmitted = adminEditorialRepository.transition(observedIdentity.id(), observedIdentity.version(), "SUBMIT_FOR_REVIEW",
                "editor-test", "Resubmit corrected candidate.", "Both reviews were repeated.");
        var approved = adminEditorialRepository.transition(resubmitted.id(), resubmitted.version(), "APPROVE",
                "reviewer-test", "Approve synthetic candidate, leave disabled.", "Required checks passed.");
        UUID poiId = approved.publishedPoiId();
        assertThat(approved.state()).isEqualTo("APPROVED");
        assertThat(approved.active()).isFalse();
        var activated = adminEditorialRepository.setActivation(approved.id(), approved.version(), true,
                "administrator-test", "Explicit synthetic activation.", "Synthetic activation evidence.");
        var archived = adminEditorialRepository.transition(activated.id(), activated.version(), "ARCHIVE", "administrator-test",
                "Archive synthetic published record.", "Synthetic archive evidence.");
        assertThat(jdbcTemplate.queryForObject("SELECT active FROM geo.point_of_interest WHERE id=?", Boolean.class, poiId)).isFalse();

        var reopened = adminEditorialRepository.reopen(archived.id(), archived.version(), "administrator-test",
                "Reopen the same synthetic record for another review.");

        assertThat(reopened.id()).isEqualTo(archived.id());
        assertThat(reopened.state()).isEqualTo("DRAFT");
        assertThat(reopened.publishedPoiId()).isNull();
        assertThat(reopened.targetPoiId()).isEqualTo(poiId);
        assertThat(reopened.active()).isFalse();
        assertThat(reopened.geographicReviewStatus()).isEqualTo("PENDING");
        assertThat(reopened.identityReviewStatus()).isEqualTo("PENDING");
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.point_of_interest", Integer.class)).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("SELECT active FROM geo.point_of_interest WHERE id=?", Boolean.class, poiId)).isFalse();
        assertThat(jdbcTemplate.queryForObject("SELECT source_record_id FROM geo.poi_provenance WHERE poi_id=?", String.class, poiId))
                .isEqualTo("1851");

        var reopenedGeography = adminEditorialRepository.reviewGeography(reopened.id(), reopened.version(), true,
                "reviewer-test", "Repeat geographic review after reopening.");
        var reopenedIdentity = adminEditorialRepository.reviewIdentity(reopened.id(), reopenedGeography.version(), true,
                "reviewer-test", "Repeat identity review after reopening.", "No duplicate found.");
        var finalSubmission = adminEditorialRepository.transition(reopenedIdentity.id(), reopenedIdentity.version(), "SUBMIT_FOR_REVIEW",
                "editor-test", "Submit the reopened candidate.", "Fresh reviews recorded.");
        var secondApproval = adminEditorialRepository.transition(finalSubmission.id(), finalSubmission.version(), "APPROVE",
                "reviewer-test", "Approve without activating.", "Fresh checks passed.");
        assertThat(secondApproval.publishedPoiId()).isEqualTo(poiId);
        assertThat(secondApproval.active()).isFalse();
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.point_of_interest", Integer.class)).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("SELECT active FROM geo.point_of_interest WHERE id=?", Boolean.class, poiId)).isFalse();
    }

    @Test
    void reopeningIsRejectedWhenAnotherRecordAlreadyUsesTheMinceturSourceCode() {
        UUID first = UUID.randomUUID();
        UUID second = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO admin.poi_editorial_record(id, source_record_id, name, category_code, editorial_state, created_by)
                VALUES (?, '1851', 'Synthetic Cantamarca one', 'ARCHAEOLOGICAL_SITE', 'ARCHIVED', 'fixture')
                """, first);
        jdbcTemplate.update("""
                INSERT INTO admin.poi_editorial_record(id, source_record_id, name, category_code, editorial_state, created_by)
                VALUES (?, '1851', 'Synthetic Cantamarca two', 'ARCHAEOLOGICAL_SITE', 'ARCHIVED', 'fixture')
                """, second);

        assertThatThrownBy(() -> adminEditorialRepository.reopen(first, 0, "administrator-test", "Check duplicate guard."))
                .isInstanceOf(EditorialWorkflowConflictException.class)
                .hasMessageContaining("already uses this MINCETUR source code");
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM admin.poi_editorial_record WHERE source_record_id='1851'", Integer.class))
                .isEqualTo(2);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM admin.poi_editorial_record WHERE editorial_state='DRAFT'", Integer.class))
                .isZero();
    }

    private UUID insertSyntheticMinceturCandidate(String sourceId, String name) throws Exception {
        UUID batchId = UUID.randomUUID();
        UUID importRecordId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_batch(id,source_system,source_file_name,source_sha256,source_cutoff,
                    detected_encoding,delimiter,parser_version,record_count,quarantined_count,batch_status,taxonomy_filter_version)
                VALUES (?, 'MINCETUR', 'synthetic-reopen.csv', ?, DATE '2026-11-19', 'UTF-8', ';', 'reopen-test', 1, 0,
                    'STAGED_REQUIRES_REVIEW', 'MINCETUR-TAXONOMY-FILTER-v1')
                """, batchId, "A".repeat(64));
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_record(id,batch_id,row_number,source_record_id,raw_fields,
                    raw_latitude,raw_longitude,normalized_latitude,normalized_longitude,normalization_rule,
                    validation_evidence,record_status,thematic_eligibility,thematic_rule_code,thematic_reason)
                VALUES (?,?,1,?,?::jsonb,'-11.438714','-76.591777',-11.438714,-76.591777,
                    'synthetic-normalizer','Synthetic coordinate evidence.', 'NORMALIZED_PENDING_REVIEW',
                    'ELIGIBLE_FOR_REVIEW','TEST_ELIGIBLE','Synthetic eligible record')
                """, importRecordId, batchId, sourceId,
                objectMapper.writeValueAsString(Map.of("NOMBRE DEL RECURSO", name, "URL", "https://example.test/" + sourceId)));
        return importRecordId;
    }

    @Test
    void migrationsCreateApprovedPostgisBaseline() {
        flyway.validate();

        assertThat(jdbcTemplate.queryForObject("SELECT PostGIS_Version()", String.class)).isNotBlank();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM flyway_schema_history", Integer.class))
                .isEqualTo(12);
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
        var manual = adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(null,
                "Synthetic manual draft", null, "MONUMENT", null, null, null, null, null, null,
                null, null, "Canta — Lima"), "editor-test");
        assertThat(manual.state()).isEqualTo("DRAFT");
        assertThat(manual.latitude()).isNull();
        assertThat(manual.longitude()).isNull();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest", Integer.class)).isZero();
        assertThat(adminEditorialRepository.list(null, null, null, null, 0, 50).totalElements()).isEqualTo(1);
        assertThat(adminEditorialRepository.list(null, null, "Canta", "MONUMENT", 0, 50).totalElements()).isEqualTo(1);
        assertThat(adminEditorialRepository.list(null, null, "Arequipa", "MONUMENT", 0, 50).totalElements()).isZero();
        assertThat(adminEditorialRepository.list(null, null, "Canta", "MUSEUM", 0, 50).totalElements()).isZero();

        UUID batchId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_batch(id,source_system,source_file_name,source_sha256,source_cutoff,
                    detected_encoding,delimiter,parser_version,record_count,quarantined_count,batch_status)
                VALUES (?, 'MINCETUR', 'filters.csv', ?, DATE '2026-11-10', 'UTF-8', ';', 'filters-test', 0, 0,
                    'STAGED_REQUIRES_REVIEW')
                """, batchId, UUID.randomUUID().toString().replace("-", "").repeat(2).toUpperCase(java.util.Locale.ROOT));

        assertThat(adminImportReadRepository.records(batchId, null, null, null, null, 0, 50).totalElements()).isZero();
        assertThat(adminImportReadRepository.records(batchId, "NORMALIZED_PENDING_REVIEW", "", null, null, 0, 50)
                .totalElements()).isZero();
        UUID importId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_record(id,batch_id,row_number,source_record_id,raw_fields,record_status)
                VALUES (?,?,1,'synthetic-1',?::jsonb,'MALFORMED_ROW')
                """, importId, batchId,
                "{\"NOMBRE DEL RECURSO\":\"Synthetic place\",\"DISTRITO\":\"Obrajillo\",\"PROVINCIA\":\"Canta\",\"REGIÓN\":\"Lima\",\"CATEGORÍA\":\"Natural\"}");
        assertThat(adminImportReadRepository.records(batchId, null, null, "Canta", "Natural", 0, 50)
                .totalElements()).isEqualTo(1);
        assertThat(adminImportReadRepository.records(batchId, null, null, "Canta", "natural", 0, 50)
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

        assertThat(published.state()).isEqualTo("APPROVED");
        assertThat(published.publishedPoiId()).isEqualTo(candidate.id());
        assertThat(published.active()).isFalse();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest",Integer.class)).isEqualTo(2);
        assertThat(jdbcTemplate.queryForObject("SELECT active FROM geo.point_of_interest WHERE id=?",Boolean.class,candidate.id())).isFalse();
        var syntheticRoute = new RouteGeometry(List.of(new RoutePoint(-14.1, -75.11), new RoutePoint(-14.1, -75.09)));
        assertThat(discoveryQuery.findAlong(syntheticRoute, new DiscoveryCriteria(java.util.Set.of("MONUMENT"), 2_000, 20)))
                .extracting(item -> item.poiId().value()).doesNotContain(candidate.id());
        var activePoi = adminEditorialRepository.setActivation(published.id(), published.version(), true,
                "administrator-test", "Activate after separate approval", "Synthetic administrator activation evidence.");
        assertThat(activePoi.active()).isTrue();
        assertThat(discoveryQuery.findAlong(syntheticRoute, new DiscoveryCriteria(java.util.Set.of("MONUMENT"), 2_000, 20)))
                .extracting(item -> item.poiId().value()).contains(candidate.id());
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM admin.poi_editorial_audit WHERE editorial_id=? AND action='ACTIVATE'", Integer.class, candidate.id())).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("SELECT name FROM geo.point_of_interest WHERE id=?",String.class,existingId))
                .isEqualTo("Existing P3 record");
        assertThat(jdbcTemplate.queryForObject("SELECT ST_X(location) FROM geo.point_of_interest WHERE id=?",Double.class,existingId))
                .isEqualTo(-75.0);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.poi_provenance WHERE poi_id=?",Integer.class,candidate.id())).isEqualTo(1);
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM admin.poi_editorial_audit WHERE editorial_id=?",Integer.class,candidate.id())).isEqualTo(6);
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
    void existingPoiDeactivationIsAuditedAndReactivationRequiresEditorialApproval() {
        UUID categoryId = UUID.randomUUID();
        UUID poiId = UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category(id,code,name,active) VALUES (?,?,?,true)", categoryId, "MONUMENT", "Monument");
        jdbcTemplate.update("INSERT INTO geo.point_of_interest(id,category_id,name,location,active,created_at,updated_at) "
                + "VALUES (?,?,?,ST_SetSRID(ST_MakePoint(-75,-14),4326),true,now(),now())", poiId, categoryId, "Existing synthetic POI");
        var before = adminPoiInventoryRepository.list("synthetic", "MONUMENT", true, 0, 20).content().getFirst();
        assertThatThrownBy(() -> adminPoiInventoryRepository.setActive(poiId, before.updatedAt(), true, "admin-test",
                "Direct activation", "Synthetic evidence."))
                .hasMessageContaining("approved editorial change request");
        var deactivated = adminPoiInventoryRepository.setActive(poiId, before.updatedAt(), false, "admin-test",
                "Explicit deactivation for test", "Synthetic deactivation evidence.");
        assertThat(deactivated.active()).isFalse();
        assertThat(adminPoiInventoryRepository.audit(poiId)).hasSize(1);
        assertThatThrownBy(() -> adminPoiInventoryRepository.setActive(poiId, before.updatedAt(), false, "admin-test",
                "Stale activation", "Synthetic stale evidence.")).hasMessageContaining("stale");
    }

    @Test
    void operationalInformationCanBeUpdatedOnAnActivePoiWithoutEditorialTransition() {
        UUID categoryId = UUID.randomUUID();
        UUID poiId = UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category(id,code,name,active) VALUES (?,?,?,true)", categoryId, "MUSEUM", "Museum");
        jdbcTemplate.update("INSERT INTO geo.point_of_interest(id,category_id,name,location,active,created_at,updated_at) "
                + "VALUES (?,?,?,ST_SetSRID(ST_MakePoint(-75,-14),4326),true,now(),now())", poiId, categoryId, "Operational synthetic museum");

        var before = poiOperationalInfoRepository.getAdmin(poiId);
        var hours = java.util.Arrays.stream(java.time.DayOfWeek.values())
                .map(day -> new PoiOperationalInfo.DailyHours(day, day == java.time.DayOfWeek.SATURDAY
                        ? List.of(new PoiOperationalInfo.TimeRange(java.time.LocalTime.of(10, 0), java.time.LocalTime.of(16, 0)))
                        : List.of())).toList();
        var item = new PoiOperationalInfo.OperationalItem(UUID.randomUUID(), PoiOperationalInfo.ItemType.PERFORMANCE,
                "Función sintética", "Actividad de prueba", "Sábados 14:00", null, null, null, true);
        var inactiveItem = new PoiOperationalInfo.OperationalItem(UUID.randomUUID(), PoiOperationalInfo.ItemType.PROMOTION,
                "Promoción retirada", null, null, null, null, null, false);
        var saved = poiOperationalInfoRepository.update(poiId, before.version(), "editor-test",
                new PoiOperationalInfo("America/Lima", hours, List.of(item, inactiveItem), before.version()));

        assertThat(saved.version()).isEqualTo(1);
        assertThat(saved.items()).hasSize(2);
        assertThat(poiOperationalInfoRepository.getPublic(poiId).items()).containsExactly(item);
        assertThat(jdbcTemplate.queryForObject("SELECT active FROM geo.point_of_interest WHERE id=?", Boolean.class, poiId)).isTrue();
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM admin.poi_operational_info_audit WHERE poi_id=?", Integer.class, poiId)).isEqualTo(1);
        assertThatThrownBy(() -> poiOperationalInfoRepository.update(poiId, 0, "editor-test", saved))
                .isInstanceOf(PoiOperationalInfoRepository.OperationalInfoConflictException.class);
        assertThatThrownBy(() -> poiOperationalInfoRepository.getPublic(UUID.randomUUID()))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void existingPoiReactivationUsesSameUuidAndRequiresApprovedChangeRequest() {
        UUID categoryId = UUID.randomUUID();
        UUID poiId = UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category(id,code,name,active) VALUES (?,?,?,true)", categoryId, "MONUMENT", "Monument");
        jdbcTemplate.update("INSERT INTO geo.point_of_interest(id,category_id,name,description,location,active,created_at,updated_at) "
                + "VALUES (?,?,?, ?,ST_SetSRID(ST_MakePoint(-75,-14),4326),false,now(),now())",
                poiId, categoryId, "Existing curated POI", "Original description");
        jdbcTemplate.update("INSERT INTO geo.poi_provenance(id,poi_id,source_system,source_record_id,retrieved_at,license,attribution,incorporation_method,logical_key) "
                + "VALUES (?,?, 'P3', 'fixture-42', now(), 'Synthetic test license', 'Synthetic test attribution', 'fixture', 'fixture-42')",
                UUID.randomUUID(), poiId);

        var draft = adminEditorialRepository.createChangeRequest(poiId, "editor-test");
        assertThat(draft.targetPoiId()).isEqualTo(poiId);
        var updated = adminEditorialRepository.update(draft.id(), draft.version(), new AdminEditorialRepository.UpdateEditorial(
                "Updated curated POI", "Updated description", "MONUMENT", new java.math.BigDecimal("-14.01"),
                new java.math.BigDecimal("-75.01"), "Synthetic test coordinate", "Synthetic independent confirmation",
                "Synthetic test license", "Synthetic test attribution", "Canta"), "editor-test", "Update reviewed fixture.");
        var geographic = adminEditorialRepository.reviewGeography(updated.id(), updated.version(), true, "reviewer-test", "Synthetic geography checked.");
        var identity = adminEditorialRepository.reviewIdentity(geographic.id(), geographic.version(), true, "reviewer-test",
                "Synthetic no duplicate check.", "Compared with the isolated fixture catalog.");
        var submitted = adminEditorialRepository.transition(identity.id(), identity.version(), "SUBMIT_FOR_REVIEW", "editor-test",
                "Submit approved change request.", "Synthetic change packet complete.");
        var approved = adminEditorialRepository.transition(submitted.id(), submitted.version(), "APPROVE", "reviewer-test",
                "Approve existing POI edits while keeping it hidden.", "Synthetic editorial approval.");

        assertThat(approved.state()).isEqualTo("APPROVED");
        assertThat(approved.publishedPoiId()).isEqualTo(poiId);
        assertThat(approved.active()).isFalse();
        assertThat(jdbcTemplate.queryForObject("SELECT active FROM geo.point_of_interest WHERE id=?", Boolean.class, poiId)).isFalse();
        assertThat(jdbcTemplate.queryForObject("SELECT source_record_id FROM geo.poi_provenance WHERE poi_id=?", String.class, poiId))
                .isEqualTo("fixture-42");

        var active = adminEditorialRepository.setActivation(approved.id(), approved.version(), true, "administrator-test",
                "Reactivate only after editorial approval.", "Synthetic activation evidence.");
        assertThat(active.active()).isTrue();
        assertThat(jdbcTemplate.queryForObject("SELECT id FROM geo.point_of_interest WHERE name='Updated curated POI' AND active", UUID.class))
                .isEqualTo(poiId);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM admin.poi_activation_audit WHERE poi_id=? AND action='ACTIVATE'", Integer.class, poiId))
                .isEqualTo(1);
    }

    @Test
    void manualPublicationCannotBypassMinceturThematicExclusion() {
        UUID categoryId = UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category(id,code,name,active) VALUES (?,?,?,true)",
                categoryId, "MONUMENT", "Monument");
        String excludedName = "Fiesta de la Vendimia";
        var draft = adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(null,
                excludedName, "Synthetic draft", "MONUMENT", new java.math.BigDecimal("-14.1"),
                new java.math.BigDecimal("-75.1"), null, null, null,
                "Synthetic geographic evidence", "Synthetic license", "Synthetic attribution", "Canta"),
                "editor-test");
        var geography = adminEditorialRepository.reviewGeography(draft.id(), draft.version(), true,
                "reviewer-test", "Synthetic location review");
        var identity = adminEditorialRepository.reviewIdentity(draft.id(), geography.version(), true,
                "reviewer-test", "Synthetic identity review", "No published duplicate found.");
        var submitted = adminEditorialRepository.transition(draft.id(), identity.version(), "SUBMIT_FOR_REVIEW",
                "editor-test", "Synthetic submission", "Review packet complete.");

        UUID batchId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_batch(id,source_system,source_file_name,source_sha256,source_cutoff,
                    detected_encoding,delimiter,parser_version,record_count,quarantined_count,batch_status)
                VALUES (?, 'MINCETUR', 'excluded.csv', ?, DATE '2026-11-10', 'UTF-8', ';', 'exclusion-test', 1, 0,
                    'STAGED_REQUIRES_REVIEW')
                """, batchId, "A".repeat(64));
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_record(id,batch_id,row_number,raw_fields,record_status,
                    thematic_eligibility,thematic_rule_code,thematic_reason)
                VALUES (?,?,1,?::jsonb,'MALFORMED_ROW','EXCLUDED_FROM_NAVIGATION','TEST_EXCLUSION','Synthetic excluded row')
                """, UUID.randomUUID(), batchId,
                "{\"NOMBRE DEL RECURSO\":\"fiesta   de la vendimia\"}");

        assertThatThrownBy(() -> adminEditorialRepository.transition(draft.id(), submitted.version(), "APPROVE",
                "reviewer-test", "Should remain unpublished", "Synthetic excluded identity match"))
                .isInstanceOf(EditorialWorkflowConflictException.class)
                .hasMessageContaining("excluded from navigation");
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest", Integer.class)).isZero();
        assertThat(adminEditorialRepository.find(draft.id()).orElseThrow().state()).isEqualTo("PENDING_REVIEW");
    }

    @Test
    void editorialDraftPreservesFullPrecisionOfStagedCoordinateCandidate() {
        UUID batchId = UUID.randomUUID();
        UUID importRecordId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_batch(id,source_system,source_file_name,source_sha256,source_cutoff,
                    detected_encoding,delimiter,parser_version,record_count,quarantined_count,batch_status,taxonomy_filter_version)
                VALUES (?, 'MINCETUR', 'synthetic.csv', ?, DATE '2026-11-10', 'UTF-8', ';', 'precision-test', 1, 0,
                    'STAGED_REQUIRES_REVIEW', 'MINCETUR-TAXONOMY-FILTER-v1')
                """, batchId, "A".repeat(64));
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_record(id,batch_id,row_number,source_record_id,raw_fields,
                    raw_latitude,raw_longitude,normalized_latitude,normalized_longitude,normalization_rule,
                    validation_evidence,record_status,thematic_eligibility,thematic_rule_code,thematic_reason)
                VALUES (?,?,1,'237',?::jsonb,?,?,?,?,'synthetic-precision-rule',
                    'synthetic test evidence; candidate is not published', 'NORMALIZED_PENDING_REVIEW',
                    'ELIGIBLE_FOR_REVIEW','TEST_ELIGIBLE','Synthetic eligible fixture')
                """, importRecordId,
                batchId,
                "{\"NOMBRE DEL RECURSO\":\"Laguna de Huacachina\",\"URL\":\"https://example.test/237\"}",
                "-7.576.291.501.522.060", "-14.087.854.051.458.200",
                new java.math.BigDecimal("-14.087854051458200"),
                new java.math.BigDecimal("-75.76291501522060"));

        var draft = adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(
                importRecordId, null, null, "NATURAL_SITE", null, null, null, null, null, null,
                "ODC-BY-1.0", "MINCETUR Open Data catalog; test attribution"), "editor-test");

        assertThat(draft.latitude()).isEqualByComparingTo("-14.087854051458200");
        assertThat(draft.longitude()).isEqualByComparingTo("-75.76291501522060");
        assertThat(draft.rawLatitude()).isEqualTo("-7.576.291.501.522.060");
        assertThat(draft.rawLongitude()).isEqualTo("-14.087.854.051.458.200");
        assertThat(draft.sourceLicense()).isEqualTo("ODC-BY-1.0");
        assertThat(draft.sourceAttribution()).isEqualTo("MINCETUR Open Data catalog; test attribution");
        assertThat(draft.state()).isEqualTo("DRAFT");
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest", Integer.class)).isZero();
    }

    @Test
    void minceturEditorialApprovalPersistsLicenseWithinEditorialLimitAndStaysInactive() {
        UUID batchId = UUID.randomUUID();
        UUID importRecordId = UUID.randomUUID();
        UUID categoryId = UUID.randomUUID();
        jdbcTemplate.update("INSERT INTO geo.category(id,code,name,active) VALUES (?,?,?,true)",
                categoryId, "ARCHAEOLOGICAL_SITE", "Sitio arqueológico");
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_batch(id,source_system,source_file_name,source_sha256,source_cutoff,
                    detected_encoding,delimiter,parser_version,record_count,quarantined_count,batch_status,taxonomy_filter_version)
                VALUES (?, 'MINCETUR', 'synthetic-1851.csv', ?, DATE '2026-11-10', 'UTF-8', ';', 'approval-409-test', 1, 0,
                    'STAGED_REQUIRES_REVIEW', 'MINCETUR-TAXONOMY-FILTER-v1')
                """, batchId, "C".repeat(64));
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_record(id,batch_id,row_number,source_record_id,raw_fields,
                    raw_latitude,raw_longitude,normalized_latitude,normalized_longitude,normalization_rule,
                    validation_evidence,record_status,thematic_eligibility,thematic_rule_code,thematic_reason)
                VALUES (?,?,1,'1851',?::jsonb,'-11.4','-76.5',-11.4,-76.5,'synthetic-approved-candidate',
                    'Synthetic coordinate validation evidence', 'NORMALIZED_PENDING_REVIEW',
                    'ELIGIBLE_FOR_REVIEW','TEST_ELIGIBLE','Synthetic eligible fixture')
                """, importRecordId, batchId,
                "{\"NOMBRE DEL RECURSO\":\"Sitio Arqueológico Cantamarca (synthetic)\",\"CATEGORÍA\":\"2. MANIFESTACIONES CULTURALES\",\"TIPO DE CATEGORÍA\":\"Sitios Arqueológicos\"}");

        String license = "MINCETUR — condiciones de reutilización de la ficha y datos pendientes de verificación. "
                + "No se presume licencia abierta para fotografías ni contenidos de terceros.";
        String attribution = "MINCETUR — Inventario Nacional de Recursos Turísticos. "
                + "Ficha sintética de prueba; no constituye aprobación ni publicación del expediente real.";
        assertThat(license).hasSize(162);
        assertThat(attribution.length()).isLessThanOrEqualTo(240);

        assertThat(adminImportReadRepository.records(batchId, null, null, null, null, 0, 10).content().getFirst()
                .suggestedPoiCategoryCode()).isEqualTo("ARCHAEOLOGICAL_SITE");
        assertThatThrownBy(() -> adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(
                importRecordId, null, null, "WATERFALL", null, null, null, null, null, null,
                license, attribution), "synthetic-editor"))
                .isInstanceOf(ai.geoguide.admin.domain.EditorialCategoryMismatchException.class)
                .hasMessageContaining("ARCHAEOLOGICAL_SITE");
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM admin.poi_editorial_record", Integer.class)).isZero();

        var draft = adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(
                importRecordId, null, null, "ARCHAEOLOGICAL_SITE", null, null, null, null, null, null,
                license, attribution), "synthetic-editor");
        var geographic = adminEditorialRepository.reviewGeography(draft.id(), draft.version(), true,
                "synthetic-reviewer", "Synthetic geographic review.");
        var identity = adminEditorialRepository.reviewIdentity(geographic.id(), geographic.version(), true,
                "synthetic-reviewer", "Synthetic identity review.", "Synthetic no-duplicate evidence.");
        var pending = adminEditorialRepository.transition(identity.id(), identity.version(), "SUBMIT_FOR_REVIEW",
                "synthetic-editor", "Submit synthetic MINCETUR record.", "Synthetic submission evidence.");

        assertThatThrownBy(() -> adminEditorialRepository.transition(pending.id(), pending.version() - 1,
                "APPROVE", "synthetic-reviewer", "Stale optimistic version.", "Synthetic decision evidence."))
                .isInstanceOf(EditorialWorkflowConflictException.class).hasMessageContaining("version is stale");
        assertThat(adminEditorialRepository.find(pending.id()).orElseThrow().state()).isEqualTo("PENDING_REVIEW");
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.point_of_interest", Integer.class)).isZero();

        // Simulate a legacy editorial row created before the category mapping existed.
        jdbcTemplate.update("UPDATE admin.poi_editorial_record SET category_code='WATERFALL' WHERE id=?", pending.id());
        assertThatThrownBy(() -> adminEditorialRepository.transition(pending.id(), pending.version(), "APPROVE",
                "synthetic-reviewer", "Reject legacy mismapped category.", "Synthetic mismatch evidence."))
                .isInstanceOf(ai.geoguide.admin.domain.EditorialCategoryMismatchException.class)
                .hasMessageContaining("ARCHAEOLOGICAL_SITE");
        assertThat(adminEditorialRepository.find(pending.id()).orElseThrow().state()).isEqualTo("PENDING_REVIEW");
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.point_of_interest", Integer.class)).isZero();
        jdbcTemplate.update("UPDATE admin.poi_editorial_record SET category_code='ARCHAEOLOGICAL_SITE' WHERE id=?", pending.id());

        var approved = adminEditorialRepository.transition(pending.id(), pending.version(), "APPROVE",
                "synthetic-reviewer", "Approve synthetic record while remaining inactive.", "Synthetic approval evidence.");
        assertThat(approved.state()).isEqualTo("APPROVED");
        assertThat(approved.active()).isFalse();
        assertThat(approved.categoryCode()).isEqualTo("ARCHAEOLOGICAL_SITE");
        assertThat(jdbcTemplate.queryForObject("SELECT active FROM geo.point_of_interest WHERE id=?", Boolean.class,
                approved.id())).isFalse();
        assertThat(jdbcTemplate.queryForObject("SELECT c.code FROM geo.point_of_interest p JOIN geo.category c ON c.id=p.category_id WHERE p.id=?",
                String.class, approved.id())).isEqualTo("ARCHAEOLOGICAL_SITE");
        assertThat(jdbcTemplate.queryForObject("SELECT license FROM geo.poi_provenance WHERE poi_id=?", String.class,
                approved.id())).isEqualTo(license);
        assertThat(jdbcTemplate.queryForObject("SELECT attribution FROM geo.poi_provenance WHERE poi_id=?", String.class,
                approved.id())).isEqualTo(attribution);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM admin.poi_editorial_audit WHERE editorial_id=? AND action='APPROVE'",
                Integer.class, approved.id())).isEqualTo(1);
    }

    @Test
    void editorialDraftCannotBeCreatedFromThematicallyExcludedImportRecord() {
        UUID batchId = UUID.randomUUID();
        UUID importRecordId = UUID.randomUUID();
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_batch(id,source_system,source_file_name,source_sha256,source_cutoff,
                    detected_encoding,delimiter,parser_version,record_count,quarantined_count,batch_status,taxonomy_filter_version)
                VALUES (?, 'MINCETUR', 'excluded.csv', ?, DATE '2026-11-10', 'UTF-8', ';', 'taxonomy-test', 1, 0,
                    'STAGED_REQUIRES_REVIEW', 'MINCETUR-TAXONOMY-FILTER-v1')
                """, batchId, "B".repeat(64));
        jdbcTemplate.update("""
                INSERT INTO geo.mincetur_import_record(id,batch_id,row_number,source_record_id,raw_fields,
                    raw_latitude,raw_longitude,normalized_latitude,normalized_longitude,normalization_rule,
                    validation_evidence,record_status,thematic_eligibility,thematic_rule_code,thematic_reason)
                VALUES (?,?,1,'excluded-1',?::jsonb,'-76.6','-11.4',-11.4,-76.6,'test-rule',
                    'synthetic test evidence','NORMALIZED_PENDING_REVIEW','EXCLUDED_FROM_NAVIGATION',
                    'TD-EX-01','Synthetic excluded fixture')
                """, importRecordId, batchId, "{\"NOMBRE DEL RECURSO\":\"Excluded cultural event\"}");

        assertThatThrownBy(() -> adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(
                importRecordId, null, null, "MONUMENT", null, null, null, null, null, null,
                "ODC-BY-1.0", "MINCETUR attribution"), "editor-test"))
                .isInstanceOf(ai.geoguide.admin.domain.EditorialWorkflowConflictException.class)
                .hasMessageContaining("thematically excluded");
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM admin.poi_editorial_record", Integer.class)).isZero();
        assertThat(jdbcTemplate.queryForObject("SELECT COUNT(*) FROM geo.point_of_interest", Integer.class)).isZero();
    }

    @Test
    void cantaPilotPublishesOnlyIndependentlyReviewedPoiCandidates() throws Exception {
        String csvPath = System.getProperty("geoguide.test.minceturCsv");
        Assumptions.assumeTrue(csvPath != null && !csvPath.isBlank(),
                "Set geoguide.test.minceturCsv to publish the owner-provided snapshot into an isolated pilot database.");

        var p3 = new P3DatasetLoader(objectMapper, categoryRepository, repository,
                new ClassPathResource("data/p3/taxonomy-v1.json"),
                new ClassPathResource("data/p3/lima-obrajillo-v1.json")).load();
        var curatedDestinations = new DestinationCatalogLoader(objectMapper, destinationRepository,
                new ClassPathResource("data/destination-search/mincetur-pilot-v1.json")).load();
        assertThat(p3.poiCount()).isEqualTo(5);
        assertThat(curatedDestinations).isEqualTo(9);

        byte[] sourceBytes = Files.readAllBytes(Path.of(csvPath));
        var snapshot = new MinceturSnapshotCoordinateNormalizer(objectMapper).normalize(
                new MinceturSnapshotParser().parse(Path.of(csvPath).getFileName().toString(), sourceBytes),
                new ClassPathResource("data/destination-search/mincetur-20261110-coordinate-recovery-v1.json")
                        .getInputStream());
        assertThat(snapshot.sha256()).isEqualToIgnoringCase(
                "29351B0BAEA9E68AC1D50CFA2B5BF6273594FEC4A8CE112D2E63271F2D08FD66");
        UUID batchId = minceturStagingRepository.stage(snapshot);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.mincetur_import_record WHERE batch_id=?",
                Integer.class, batchId)).isEqualTo(6_341);

        record ReviewedPoi(String sourceId, String category, String latitude, String longitude,
                String coordinateEvidence) {}
        List<ReviewedPoi> reviewed = List.of(
                new ReviewedPoi("1851", "ARCHAEOLOGICAL_SITE", "-11.43885", "-76.59179",
                        "MINCETUR ficha 1851 identifies the archaeological site in Canta; OSM node 1649971847 " +
                                "(https://www.openstreetmap.org/node/1649971847) places Ciudadela de Cantamarca at " +
                                "-11.43885,-76.59179. The staged candidate differs by approximately 15 m. " +
                                "Independent identity context: https://target2.promperu.gob.pe/destinos/lima/canta/sitio-arqueologico-de-cantamarca"),
                new ReviewedPoi("12185", "HISTORIC_CHURCH", "-11.48941", "-76.66162",
                        "MINCETUR ficha 12185 identifies the colonial church in San Buenaventura; OSM way 450034994 " +
                                "(https://www.openstreetmap.org/way/450034994) maps Iglesia de San Buenaventura at " +
                                "-11.48941,-76.66162. The staged candidate differs by approximately 19 m."),
                new ReviewedPoi("14041", "WATERFALL", "-11.46317", "-76.63708",
                        "MINCETUR ficha 14041 identifies Cascada Huamanmayo in San Buenaventura and documents its " +
                                "community land/access terms; OSM node 1651111731 " +
                                "(https://www.openstreetmap.org/node/1651111731) maps Cascadas de Huamanmayo at " +
                                "-11.46317,-76.63708. The staged candidate differs by approximately 28 m. " +
                                "Publication is POI-only; no route-access destination is created."));

        String combinedLicense = "ODC-BY-1.0 (MINCETUR inventory); ODbL-1.0 (OSM coordinate source)";
        String combinedAttribution = "MINCETUR — Inventario Nacional de Recursos Turísticos; " +
                "© OpenStreetMap contributors";
        String reviewer = "poi-data-3-automated-review";
        for (ReviewedPoi item : reviewed) {
            UUID importId = jdbcTemplate.queryForObject("""
                    SELECT id FROM geo.mincetur_import_record
                    WHERE batch_id=? AND source_record_id=? AND thematic_eligibility='ELIGIBLE_FOR_REVIEW'
                      AND record_status='NORMALIZED_PENDING_REVIEW'
                    """, (rs, row) -> rs.getObject(1, UUID.class), batchId, item.sourceId());
            var draft = adminEditorialRepository.create(new AdminEditorialRepository.CreateEditorial(
                    importId, null, null, item.category(), null, null, null, null, null, null,
                    combinedLicense, combinedAttribution), reviewer);
            var positioned = adminEditorialRepository.update(draft.id(), draft.version(),
                    new AdminEditorialRepository.UpdateEditorial(draft.name(), null, item.category(),
                            new java.math.BigDecimal(item.latitude()), new java.math.BigDecimal(item.longitude()),
                            "MINCETUR-TAXONOMY-FILTER-v1 + independently matched OSM feature",
                            item.coordinateEvidence(), combinedLicense, combinedAttribution),
                    reviewer, "Apply independently corroborated pilot coordinate and provenance.");
            var geographic = adminEditorialRepository.reviewGeography(positioned.id(), positioned.version(), true,
                    reviewer, "Independent point match, source context and administrative location verified.");
            assertThat(adminEditorialRepository.duplicates(geographic.id())).as("duplicate candidates for MINCETUR %s", item.sourceId())
                    .isEmpty();
            var identity = adminEditorialRepository.reviewIdentity(geographic.id(), geographic.version(), true,
                    reviewer, "Compared by source ID, exact identity and active POI/destination proximity.",
                    "No duplicate in the loaded five P3 POIs or nine curated destinations; see coordinate evidence.");
            var submitted = adminEditorialRepository.transition(identity.id(), identity.version(), "SUBMIT_FOR_REVIEW",
                    reviewer, "Qualification gates satisfied for isolated Canta pilot.", item.coordinateEvidence());
            var published = adminEditorialRepository.transition(submitted.id(), submitted.version(), "APPROVE",
                    reviewer, "Publish independently qualified POI to isolated development pilot only.",
                    "POI-only pilot publication; no production release or route destination access assertion.");
            assertThat(published.state()).isEqualTo("APPROVED");
            assertThat(published.publishedPoiId()).isEqualTo(published.id());
            assertThat(jdbcTemplate.queryForObject("SELECT active FROM geo.point_of_interest WHERE id=?", Boolean.class, published.id())).isFalse();
            var activated = adminEditorialRepository.setActivation(published.id(), published.version(), true,
                    reviewer, "Explicitly activate validated isolated pilot POI.", "Synthetic activation evidence.");
            assertThat(activated.active()).isTrue();
            assertThat(jdbcTemplate.queryForObject("""
                    SELECT ST_SRID(location)=4326 AND ST_X(location)=? AND ST_Y(location)=?
                    FROM geo.point_of_interest WHERE id=? AND active
                    """, Boolean.class, Double.parseDouble(item.longitude()), Double.parseDouble(item.latitude()),
                    published.id())).isTrue();
            var route = new RouteGeometry(List.of(
                    new RoutePoint(Double.parseDouble(item.latitude()), Double.parseDouble(item.longitude()) - 0.01),
                    new RoutePoint(Double.parseDouble(item.latitude()), Double.parseDouble(item.longitude()) + 0.01)));
            assertThat(discoveryQuery.findAlong(route,
                    new DiscoveryCriteria(java.util.Set.of(item.category()), 1_000, 20)))
                    .extracting(candidate -> candidate.name()).contains(item.sourceId().equals("1851")
                            ? "Sitio Arqueológico Cantamarca"
                            : item.sourceId().equals("12185") ? "Iglesia Colonial De San Buenaventura"
                                    : "Cascada De Huamanmayo");
        }

        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.point_of_interest WHERE active", Integer.class))
                .isEqualTo(8);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.destination WHERE active", Integer.class))
                .isEqualTo(9);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM admin.poi_editorial_record WHERE editorial_state='APPROVED' AND active",
                Integer.class)).isEqualTo(3);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.point_of_interest WHERE id IN ("
                + "SELECT published_poi_id FROM admin.poi_editorial_record)", Integer.class)).isEqualTo(3);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.mincetur_import_record " +
                "WHERE thematic_eligibility='EXCLUDED_FROM_NAVIGATION'", Integer.class)).isEqualTo(1_768);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.mincetur_import_record " +
                "WHERE thematic_eligibility='ELIGIBLE_FOR_REVIEW'", Integer.class)).isEqualTo(4_573);
        assertThat(jdbcTemplate.queryForObject("SELECT count(*) FROM geo.mincetur_import_record " +
                "WHERE record_status='COORDINATE_FORMAT_AMBIGUOUS'", Integer.class)).isEqualTo(10);
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
