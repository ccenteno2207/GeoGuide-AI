package ai.geoguide.media.infrastructure.minio;

import ai.geoguide.media.application.port.ObjectStorageProvider;
import io.minio.BucketExistsArgs;
import io.minio.GetObjectArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import io.minio.PutObjectArgs;
import io.minio.RemoveObjectArgs;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Component;

/** Private MinIO objects; this adapter never creates public bucket policies or presigned URLs. */
@Component
@ConditionalOnProperty(name = "geoguide.media.storage.enabled", havingValue = "true")
public class MinioObjectStorageAdapter implements ObjectStorageProvider {
    private final MinioClient client;
    private final String bucket;

    public MinioObjectStorageAdapter(MinioClient client,
            @Value("${geoguide.media.storage.bucket}") String bucket) {
        if (bucket == null || !bucket.matches("[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]")) {
            throw new IllegalArgumentException("A valid private MinIO bucket name is required.");
        }
        this.client = client;
        this.bucket = bucket;
    }

    @Override
    public StoredObject storePrivate(UUID mediaId, String contentType, long sizeBytes, InputStream content) {
        try {
            byte[] bytes = content.readAllBytes();
            if (bytes.length == 0 || bytes.length != sizeBytes) throw new IllegalArgumentException("Media stream size mismatch.");
            String hash = HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256").digest(bytes));
            if (!client.bucketExists(BucketExistsArgs.builder().bucket(bucket).build())) {
                client.makeBucket(MakeBucketArgs.builder().bucket(bucket).build());
            }
            String key = "poi/" + mediaId + "/" + UUID.randomUUID();
            client.putObject(PutObjectArgs.builder().bucket(bucket).object(key).stream(
                    new ByteArrayInputStream(bytes), bytes.length, -1).contentType(contentType).build());
            return new StoredObject(key, hash, bytes.length, contentType);
        } catch (Exception exception) {
            throw new IllegalStateException("Private media object could not be stored.", exception);
        }
    }

    @Override
    public InputStream readPrivate(String opaqueObjectKey) {
        try { return client.getObject(GetObjectArgs.builder().bucket(bucket).object(opaqueObjectKey).build()); }
        catch (Exception exception) { throw new IllegalStateException("Private media object could not be read.", exception); }
    }

    @Override
    public void deletePrivate(String opaqueObjectKey) {
        try { client.removeObject(RemoveObjectArgs.builder().bucket(bucket).object(opaqueObjectKey).build()); }
        catch (Exception exception) { throw new IllegalStateException("Private media object could not be deleted.", exception); }
    }
}
