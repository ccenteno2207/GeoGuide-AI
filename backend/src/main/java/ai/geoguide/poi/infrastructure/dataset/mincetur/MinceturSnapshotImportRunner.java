package ai.geoguide.poi.infrastructure.dataset.mincetur;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(name = "geoguide.mincetur-import.enabled", havingValue = "true")
public class MinceturSnapshotImportRunner implements ApplicationRunner {
    private static final Logger LOGGER = LoggerFactory.getLogger(MinceturSnapshotImportRunner.class);
    private final JdbcMinceturSnapshotStagingRepository repository;
    private final MinceturSnapshotCoordinateNormalizer normalizer;
    private final String sourcePath;
    private final Resource coordinateManifest;

    public MinceturSnapshotImportRunner(JdbcMinceturSnapshotStagingRepository repository,
            MinceturSnapshotCoordinateNormalizer normalizer,
            @Value("${geoguide.mincetur-import.source-path:}") String sourcePath,
            @Value("${geoguide.mincetur-import.coordinate-manifest:classpath:data/destination-search/mincetur-20261110-coordinate-recovery-v1.json}") Resource coordinateManifest) {
        this.repository = repository;
        this.normalizer = normalizer;
        this.sourcePath = sourcePath;
        this.coordinateManifest = coordinateManifest;
    }

    @Override
    public void run(ApplicationArguments args) throws IOException {
        if (sourcePath.isBlank()) {
            throw new IllegalStateException("A source path is required when MINCETUR staging import is enabled.");
        }
        Path source = Path.of(sourcePath);
        if (!Files.isRegularFile(source) || !Files.isReadable(source)) {
            throw new IOException("Configured MINCETUR source is not a readable regular file.");
        }
        MinceturSnapshotParser parser = new MinceturSnapshotParser();
        var parsed = parser.parse(source.getFileName().toString(), Files.readAllBytes(source));
        var snapshot = normalizer.normalize(parsed, coordinateManifest.getInputStream());
        var batchId = repository.stage(snapshot);
        LOGGER.info("MINCETUR source snapshot staged: batchId={}, sha256={}, records={}, quarantined={}",
                batchId, snapshot.sha256(), snapshot.records().size(), snapshot.records().stream()
                        .filter(record -> record.status() != MinceturSnapshotParser.RecordStatus.NORMALIZED_PENDING_REVIEW)
                        .count());
    }
}
