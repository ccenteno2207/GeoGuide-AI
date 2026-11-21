package ai.geoguide.media.infrastructure.minio;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import io.minio.BucketExistsArgs;
import io.minio.MakeBucketArgs;
import io.minio.MinioClient;
import java.io.ByteArrayInputStream;
import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

@ExtendWith(MockitoExtension.class)
class MinioObjectStorageAdapterTests {
    @Mock
    private MinioClient client;

    @Test
    void refusesToProvisionBucketUsingRuntimeApplicationCredentials() throws Exception {
        when(client.bucketExists(any(BucketExistsArgs.class))).thenReturn(false);
        var adapter = new MinioObjectStorageAdapter(client, "geoguide-poi-media-private");

        assertThatThrownBy(() -> adapter.storePrivate(UUID.randomUUID(), "image/png", 1,
                new ByteArrayInputStream(new byte[] {1})))
                .isInstanceOf(IllegalStateException.class)
                .hasMessage("Private media object could not be stored.");

        verify(client).bucketExists(any(BucketExistsArgs.class));
        verify(client, never()).makeBucket(any(MakeBucketArgs.class));
    }
}
