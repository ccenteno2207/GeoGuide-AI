package ai.geoguide.media.application;

import ai.geoguide.media.application.port.ObjectStorageProvider;
import ai.geoguide.media.domain.PoiMediaValidationException;
import ai.geoguide.media.infrastructure.persistence.PoiMediaRepository;
import ai.geoguide.media.infrastructure.persistence.PoiMediaRepository.Asset;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.net.URI;
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
        return upload(poiId, file, author, sourceUrl, "", actor);
    }

    public Asset upload(UUID poiId, MultipartFile file, String author, String sourceUrl, String altText, String actor) {
        if (file == null || file.isEmpty()) throw invalid("FILE_REQUIRED", "file", "FILE_REQUIRED", "Selecciona un archivo JPEG o PNG válido.");
        if (file.getSize() > maxBytes) throw tooLarge("El archivo supera el tamaño máximo permitido.");
        if (blank(author)) throw invalid("AUTHOR_REQUIRED", "author", "AUTHOR_REQUIRED", "Indica el autor o titular de derechos.");
        if (author.length() > 200) throw invalid("AUTHOR_TOO_LONG", "author", "MAX_LENGTH", "El autor no debe superar 200 caracteres.");
        if (blank(sourceUrl)) throw invalid("SOURCE_REQUIRED", "sourceUrl", "SOURCE_REQUIRED", "Indica una URL HTTPS o una referencia de fuente de prueba válida.");
        if (sourceUrl.length() > 2048 || !validSourceReference(sourceUrl.trim())) throw invalid("SOURCE_FORMAT_INVALID", "sourceUrl", "INVALID_FORMAT", "La referencia debe ser una URL HTTPS con dominio o una referencia fixture: válida.");
        if (altText != null && altText.length() > 500) throw invalid("ALT_TEXT_TOO_LONG", "altText", "MAX_LENGTH", "El texto alternativo no debe superar 500 caracteres.");
        try {
            byte[] input = file.getBytes();
            String mime;
            try { mime = detectMime(input); }
            catch (IllegalArgumentException invalidType) { throw invalid("FILE_TYPE_INVALID", "file", "UNSUPPORTED_MEDIA_TYPE", "Selecciona un archivo JPEG o PNG válido."); }
            BufferedImage image = decodeWithinLimits(input);
            if (image == null) {
                throw invalid("FILE_CONTENT_INVALID", "file", "INVALID_IMAGE_CONTENT", "El archivo no contiene una imagen JPEG o PNG decodificable o supera el límite de dimensiones.");
            }
            byte[] safeBytes = reencode(image, mime);
            if (safeBytes.length > maxBytes) throw tooLarge("La imagen optimizada supera el tamaño máximo permitido.");
            UUID id = UUID.randomUUID();
            ObjectStorageProvider.StoredObject stored = storage.storePrivate(id, mime, safeBytes.length, new ByteArrayInputStream(safeBytes));
            try {
                return repository.create(new Asset(id,poiId,stored.opaqueObjectKey(),mime,stored.sha256(),stored.sizeBytes(),
                        image.getWidth(),image.getHeight(),author.trim(),sourceUrl.trim(),null,null,null,"UNVERIFIED","DRAFT",false,0,
                        altText == null ? "" : altText.strip(),0),actor);
            } catch (RuntimeException exception) {
                storage.deletePrivate(stored.opaqueObjectKey());
                throw exception;
            }
        } catch (PoiMediaValidationException exception) { throw exception; }
        catch (IOException exception) { throw invalid("FILE_DECODE_FAILED", "file", "INVALID_IMAGE_CONTENT", "No se pudo validar la imagen. Selecciona un JPEG o PNG válido."); }
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
    private static PoiMediaValidationException invalid(String code,String field,String fieldCode,String message){return new PoiMediaValidationException(400,code,field,fieldCode,message);}
    private static PoiMediaValidationException tooLarge(String message){return new PoiMediaValidationException(413,"MEDIA_FILE_TOO_LARGE","file","FILE_TOO_LARGE",message);}
    private static boolean validSourceReference(String value){
        if(value.matches("(?i)^fixture:[a-z0-9][a-z0-9._/-]{0,199}$")) return true;
        try { URI uri=URI.create(value); return "https".equalsIgnoreCase(uri.getScheme()) && uri.getHost()!=null && !uri.getHost().isBlank(); }
        catch (IllegalArgumentException ignored) { return false; }
    }
}
