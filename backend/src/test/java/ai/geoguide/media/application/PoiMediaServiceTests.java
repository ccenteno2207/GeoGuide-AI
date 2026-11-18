package ai.geoguide.media.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import ai.geoguide.media.application.port.ObjectStorageProvider;
import ai.geoguide.media.infrastructure.persistence.PoiMediaRepository;
import ai.geoguide.media.infrastructure.persistence.PoiMediaRepository.Asset;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.UUID;
import javax.imageio.ImageIO;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.mock.web.MockMultipartFile;

class PoiMediaServiceTests {
    private ObjectStorageProvider storage;
    private PoiMediaRepository repository;
    private PoiMediaService service;

    @BeforeEach
    void setUp() {
        storage=mock(ObjectStorageProvider.class);repository=mock(PoiMediaRepository.class);
        when(storage.storePrivate(any(),anyString(),anyLong(),any(InputStream.class))).thenAnswer(invocation->{
            var input=(InputStream)invocation.getArgument(3);byte[] bytes=input.readAllBytes();
            return new ObjectStorageProvider.StoredObject("private/opaque", "A".repeat(64), bytes.length, invocation.getArgument(1));
        });
        when(repository.create(any(Asset.class),anyString())).thenAnswer(invocation->invocation.getArgument(0));
        service=new PoiMediaService(storage,repository,1_000_000,100_000);
    }

    @Test
    void acceptsAndSanitizesSupportedPngBeforePrivateStorage() throws Exception {
        byte[] png=png(12,8);
        var uploaded=service.upload(UUID.randomUUID(),new MockMultipartFile("file","sample.png","text/plain",png),
                "synthetic fixture","fixture:poi-media-1","editor-test");
        assertThat(uploaded.contentType()).isEqualTo("image/png");
        assertThat(uploaded.objectKey()).startsWith("private/");
        verify(storage).storePrivate(any(),org.mockito.ArgumentMatchers.eq("image/png"),anyLong(),any(InputStream.class));
        verify(repository).create(any(Asset.class),org.mockito.ArgumentMatchers.eq("editor-test"));
    }

    @Test
    void rejectsSvgAndImagesExceedingPixelLimitBeforeStorage() throws Exception {
        assertThatThrownBy(()->service.upload(UUID.randomUUID(),new MockMultipartFile("file","x.svg","image/png",
                "<svg/>".getBytes()),"synthetic","fixture:x","editor"))
                .isInstanceOf(IllegalArgumentException.class).hasMessageContaining("Only JPEG and PNG");
        var onePixelService=new PoiMediaService(storage,repository,1_000_000,4);
        assertThatThrownBy(()->onePixelService.upload(UUID.randomUUID(),new MockMultipartFile("file","big.png","image/png",png(3,3)),
                "synthetic","fixture:y","editor"))
                .isInstanceOf(IllegalArgumentException.class).hasMessageContaining("pixel limit");
    }

    private static byte[] png(int width,int height)throws Exception{
        BufferedImage image=new BufferedImage(width,height,BufferedImage.TYPE_INT_RGB);
        ByteArrayOutputStream bytes=new ByteArrayOutputStream();ImageIO.write(image,"png",bytes);return bytes.toByteArray();
    }
}
