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
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(name = "geoguide.mincetur-import.enabled", havingValue = "true")
public class MinceturSnapshotImportRunner implements ApplicationRunner {
    private static final Logger LOGGER = LoggerFactory.getLogger(MinceturSnapshotImportRunner.class);
    private final JdbcMinceturSnapshotStagingRepository repository;
    private final String sourcePath;

    public MinceturSnapshotImportRunner(JdbcMinceturSnapshotStagingRepository repository,
            @Value("${geoguide.mincetur-import.source-path:}") String sourcePath) {
        this.repository = repository;
        this.sourcePath = sourcePath;
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
        var snapshot = parser.parse(source.getFileName().toString(), Files.readAllBytes(source));
        var batchId = repository.stage(snapshot);
        LOGGER.info("MINCETUR source snapshot staged: batchId={}, sha256={}, records={}, quarantined={}",
                batchId, snapshot.sha256(), snapshot.records().size(), snapshot.records().size());
    }
}
