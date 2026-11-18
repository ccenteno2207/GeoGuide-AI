package ai.geoguide.media.infrastructure.http;

import ai.geoguide.media.application.PoiMediaService;
import ai.geoguide.media.application.port.ObjectStorageProvider;
import ai.geoguide.media.infrastructure.persistence.PoiMediaRepository;
import ai.geoguide.media.infrastructure.persistence.PoiMediaRepository.Asset;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import java.io.IOException;
import java.util.List;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.CacheControl;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

/** No MinIO object keys or direct bucket URLs leave the backend. */
@RestController
@ConditionalOnProperty(name="geoguide.media.storage.enabled",havingValue="true")
public class PoiMediaController {
    private final PoiMediaService service;
    private final PoiMediaRepository repository;
    private final ObjectStorageProvider storage;
    public PoiMediaController(PoiMediaService service,PoiMediaRepository repository,ObjectStorageProvider storage){this.service=service;this.repository=repository;this.storage=storage;}

    @GetMapping("/api/v1/pois/{poiId}/media/primary")
    public ResponseEntity<byte[]> primary(@PathVariable UUID poiId) throws IOException {
        Asset a=repository.primaryPublished(poiId).orElse(null);
        if(a==null)return ResponseEntity.notFound().build();
        try(var input=storage.readPrivate(a.objectKey())){
            byte[] bytes=input.readAllBytes();
            return ResponseEntity.ok().contentType(MediaType.parseMediaType(a.contentType())).contentLength(bytes.length)
                    .cacheControl(CacheControl.noStore()).header("X-Content-Type-Options","nosniff").body(bytes);
        }
    }

    @GetMapping("/api/v1/admin/pois/{poiId}/media")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public List<Asset> list(@PathVariable UUID poiId){return repository.byPoi(poiId);}

    @PostMapping(value="/api/v1/admin/pois/{poiId}/media",consumes=MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public Asset upload(@PathVariable UUID poiId,@RequestParam("file") MultipartFile file,
            @RequestParam String author,@RequestParam String sourceUrl,Authentication auth){
        return service.upload(poiId,file,author,sourceUrl,actor(auth));
    }

    @PatchMapping("/api/v1/admin/media/{id}/rights")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public Asset rights(@PathVariable UUID id,@Valid @RequestBody RightsRequest request,Authentication auth){
        return repository.updateRights(id,request.expectedVersion(),request.license(),request.attribution(),request.evidenceReference(),actor(auth),request.reason());
    }

    @PostMapping("/api/v1/admin/media/{id}/submit")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public Asset submit(@PathVariable UUID id,@Valid @RequestBody ActionRequest request,Authentication auth){return repository.action(id,request.expectedVersion(),"SUBMIT",actor(auth),request.reason(),false);}

    @PostMapping("/api/v1/admin/media/{id}/publish")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public Asset publish(@PathVariable UUID id,@Valid @RequestBody PublishRequest request,Authentication auth){return repository.action(id,request.expectedVersion(),"PUBLISH",actor(auth),request.reason(),request.makePrimary());}

    @PostMapping("/api/v1/admin/media/{id}/reject")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public Asset reject(@PathVariable UUID id,@Valid @RequestBody ActionRequest request,Authentication auth){return repository.action(id,request.expectedVersion(),"REJECT",actor(auth),request.reason(),false);}

    @PostMapping("/api/v1/admin/media/{id}/withdraw")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public Asset withdraw(@PathVariable UUID id,@Valid @RequestBody ActionRequest request,Authentication auth){return repository.action(id,request.expectedVersion(),"WITHDRAW",actor(auth),request.reason(),false);}

    private static String actor(Authentication auth){if(auth==null||auth.getName()==null||auth.getName().isBlank())throw new IllegalStateException("Authenticated actor is required.");return auth.getName();}
    public record RightsRequest(@PositiveOrZero long expectedVersion,@NotBlank String license,@NotBlank String attribution,
            @NotBlank String evidenceReference,@NotBlank String reason){}
    public record ActionRequest(@PositiveOrZero long expectedVersion,@NotBlank String reason){}
    public record PublishRequest(@PositiveOrZero long expectedVersion,@NotBlank String reason,@NotNull Boolean makePrimary){}
}
