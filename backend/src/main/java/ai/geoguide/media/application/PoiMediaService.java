package ai.geoguide.media.application;

import ai.geoguide.media.application.port.ObjectStorageProvider;
import ai.geoguide.media.infrastructure.persistence.PoiMediaRepository;
import ai.geoguide.media.infrastructure.persistence.PoiMediaRepository.Asset;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Iterator;
import java.util.UUID;
import javax.imageio.IIOImage;
import javax.imageio.ImageIO;
import javax.imageio.ImageReader;
import javax.imageio.ImageWriteParam;
import javax.imageio.ImageWriter;
import javax.imageio.stream.ImageOutputStream;
import javax.imageio.stream.ImageInputStream;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

/** Validate bytes independently from browser MIME claims and re-encode to strip EXIF/GPS metadata. */
@Service
@ConditionalOnProperty(name = "geoguide.media.storage.enabled", havingValue = "true")
public class PoiMediaService {
    private final ObjectStorageProvider storage;
    private final PoiMediaRepository repository;
    private final long maxBytes;
    private final long maxPixels;

    public PoiMediaService(ObjectStorageProvider storage, PoiMediaRepository repository,
            @Value("${geoguide.media.max-bytes:10485760}") long maxBytes,
            @Value("${geoguide.media.max-pixels:40000000}") long maxPixels) {
        if (maxBytes < 1024 || maxPixels < 1) throw new IllegalArgumentException("Media limits must be positive and reasonable.");
        this.storage = storage; this.repository = repository; this.maxBytes = maxBytes; this.maxPixels = maxPixels;
    }

    public Asset upload(UUID poiId, MultipartFile file, String author, String sourceUrl, String actor) {
        if (file == null || file.isEmpty() || file.getSize() > maxBytes) throw new IllegalArgumentException("Image is empty or exceeds the configured size limit.");
        if (blank(author) || blank(sourceUrl)) throw new IllegalArgumentException("Image author and source reference are required.");
        try {
            byte[] input = file.getBytes();
            String mime = detectMime(input);
            BufferedImage image = decodeWithinLimits(input);
            if (image == null) {
                throw new IllegalArgumentException("Image bytes are invalid or exceed the configured pixel limit.");
            }
            byte[] safeBytes = reencode(image, mime);
            if (safeBytes.length > maxBytes) throw new IllegalArgumentException("Sanitized image exceeds the configured size limit.");
            UUID id = UUID.randomUUID();
            ObjectStorageProvider.StoredObject stored = storage.storePrivate(id, mime, safeBytes.length, new ByteArrayInputStream(safeBytes));
            try {
                return repository.create(new Asset(id,poiId,stored.opaqueObjectKey(),mime,stored.sha256(),stored.sizeBytes(),
                        image.getWidth(),image.getHeight(),author.trim(),sourceUrl.trim(),null,null,null,"UNVERIFIED","DRAFT",false,0),actor);
            } catch (RuntimeException exception) {
                storage.deletePrivate(stored.opaqueObjectKey());
                throw exception;
            }
        } catch (IOException exception) { throw new IllegalArgumentException("Image could not be decoded safely.",exception); }
    }

    private BufferedImage decodeWithinLimits(byte[] bytes) throws IOException {
        try (ImageInputStream input = ImageIO.createImageInputStream(new ByteArrayInputStream(bytes))) {
            if (input == null) return null;
            Iterator<ImageReader> readers = ImageIO.getImageReaders(input);
            if (!readers.hasNext()) return null;
            ImageReader reader = readers.next();
            try {
                reader.setInput(input, true, true);
                int width = reader.getWidth(0), height = reader.getHeight(0);
                if (width < 1 || height < 1 || (long) width * height > maxPixels) return null;
                return reader.read(0);
            } finally { reader.dispose(); }
        }
    }

    private static String detectMime(byte[] b) {
        if (b.length >= 8 && (b[0]&255)==0x89 && b[1]==0x50 && b[2]==0x4e && b[3]==0x47 && b[4]==0x0d && b[5]==0x0a && b[6]==0x1a && b[7]==0x0a) return "image/png";
        if (b.length >= 3 && (b[0]&255)==0xff && (b[1]&255)==0xd8 && (b[2]&255)==0xff) return "image/jpeg";
        throw new IllegalArgumentException("Only JPEG and PNG images are accepted.");
    }

    private static byte[] reencode(BufferedImage image,String mime)throws IOException {
        Iterator<ImageWriter> writers=ImageIO.getImageWritersByMIMEType(mime);
        if(!writers.hasNext()) throw new IllegalStateException("No safe image encoder is available.");
        ImageWriter writer=writers.next();
        try(ByteArrayOutputStream bytes=new ByteArrayOutputStream();ImageOutputStream output=ImageIO.createImageOutputStream(bytes)){
            writer.setOutput(output);ImageWriteParam param=writer.getDefaultWriteParam();
            if("image/jpeg".equals(mime)&&param.canWriteCompressed()){param.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);param.setCompressionQuality(0.9f);}
            writer.write(null,new IIOImage(image,null,null),param);output.flush();return bytes.toByteArray();
        }finally{writer.dispose();}
    }
    private static boolean blank(String s){return s==null||s.isBlank();}
}
