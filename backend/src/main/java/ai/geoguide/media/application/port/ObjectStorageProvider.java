package ai.geoguide.media.application.port;

import java.io.InputStream;
import java.util.UUID;

/** Private-object storage boundary; implementation must keep keys opaque and buckets non-public. */
public interface ObjectStorageProvider {
    StoredObject storePrivate(UUID mediaId, String contentType, long sizeBytes, InputStream content);
    InputStream readPrivate(String opaqueObjectKey);
    void deletePrivate(String opaqueObjectKey);

    record StoredObject(String opaqueObjectKey, String sha256, long sizeBytes, String contentType) {}
}
