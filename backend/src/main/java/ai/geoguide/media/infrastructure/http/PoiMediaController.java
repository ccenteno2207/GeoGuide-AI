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
import org.springframework.web.bind.annotation.PutMapping;
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

    @GetMapping("/api/v1/pois/{poiId}/media")
    public ResponseEntity<List<PublicMediaResponse>> publicGallery(@PathVariable UUID poiId) {
        List<PublicMediaResponse> photos = repository.publishedPhotos(poiId).stream().map(a -> new PublicMediaResponse(a.id(),
                "/api/v1/pois/" + poiId + "/media/" + a.id() + "/content", a.altText(), a.primary(),
                a.displayOrder(), a.author(), a.attribution(), a.license())).toList();
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(photos);
    }

    @GetMapping("/api/v1/pois/{poiId}/media/{assetId}/content")
    public ResponseEntity<byte[]> publicPhoto(@PathVariable UUID poiId, @PathVariable UUID assetId) throws IOException {
        Asset a = repository.publishedPhoto(poiId, assetId).orElse(null);
        return photoBytes(a);
    }

    @GetMapping("/api/v1/admin/media/{id}/content")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public ResponseEntity<byte[]> privatePhoto(@PathVariable UUID id) throws IOException {
        Asset a = repository.find(id).orElse(null);
        return photoBytes(a);
    }

    @GetMapping("/api/v1/admin/pois/{poiId}/media")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public ResponseEntity<List<MediaAssetResponse>> list(@PathVariable UUID poiId){
        List<MediaAssetResponse> assets = repository.byPoi(poiId).stream().map(PoiMediaController::toResponse).toList();
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(assets);
    }

    @GetMapping("/api/v1/admin/media/{id}/history")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public ResponseEntity<List<PoiMediaRepository.AuditEvent>> history(@PathVariable UUID id) {
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(repository.history(id));
    }

    @PostMapping(value="/api/v1/admin/pois/{poiId}/media",consumes=MediaType.MULTIPART_FORM_DATA_VALUE)
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public MediaAssetResponse upload(@PathVariable UUID poiId,@RequestParam("file") MultipartFile file,
            @RequestParam String author,@RequestParam(required=false) String sourceUrl,
            @RequestParam(defaultValue = "") String altText,
            @RequestParam(defaultValue = "EXTERNAL_SOURCE") String sourceType,
            @RequestParam(defaultValue = "false") boolean authorDeclarationAccepted,
            @RequestParam(defaultValue = "") String captureDate,
            @RequestParam(defaultValue = "") String capturePlace,
            @RequestParam(defaultValue = "") String license,
            @RequestParam(defaultValue = "") String attribution,
            @RequestParam(defaultValue = "") String rightsEvidenceReference,Authentication auth){
        return toResponse(service.upload(poiId,file,author,sourceUrl,altText,actor(auth),sourceType,
                authorDeclarationAccepted,captureDate,capturePlace,license,attribution,rightsEvidenceReference));
    }

    @PatchMapping("/api/v1/admin/media/{id}/presentation")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public MediaAssetResponse presentation(@PathVariable UUID id,@Valid @RequestBody PresentationRequest request,Authentication auth){
        return toResponse(repository.updatePresentation(id,request.expectedVersion(),request.altText(),request.displayOrder(),actor(auth),request.reason()));
    }

    @PutMapping("/api/v1/admin/pois/{poiId}/media/order")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public List<MediaAssetResponse> reorder(@PathVariable UUID poiId,@Valid @RequestBody ReorderRequest request,Authentication auth){
        return repository.reorder(poiId,request.items().stream().map(item -> new PoiMediaRepository.PresentationOrder(
                item.id(),item.expectedVersion(),item.displayOrder())).toList(),actor(auth),request.reason())
                .stream().map(PoiMediaController::toResponse).toList();
    }

    @PatchMapping("/api/v1/admin/media/{id}/rights")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public MediaAssetResponse rights(@PathVariable UUID id,@Valid @RequestBody RightsRequest request,Authentication auth){
        return toResponse(repository.updateRights(id,request.expectedVersion(),request.license(),request.attribution(),request.evidenceReference(),actor(auth),request.reason()));
    }

    @PostMapping("/api/v1/admin/media/{id}/submit")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public MediaAssetResponse submit(@PathVariable UUID id,@Valid @RequestBody ActionRequest request,Authentication auth){return toResponse(repository.action(id,request.expectedVersion(),"SUBMIT",actor(auth),request.reason(),false));}

    @PostMapping("/api/v1/admin/media/{id}/publish")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public MediaAssetResponse publish(@PathVariable UUID id,@Valid @RequestBody PublishRequest request,Authentication auth){return toResponse(repository.action(id,request.expectedVersion(),"PUBLISH",actor(auth),request.reason(),request.makePrimary()));}

    @PostMapping("/api/v1/admin/media/{id}/reject")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public MediaAssetResponse reject(@PathVariable UUID id,@Valid @RequestBody ActionRequest request,Authentication auth){return toResponse(repository.action(id,request.expectedVersion(),"REJECT",actor(auth),request.reason(),false));}

    @PostMapping("/api/v1/admin/media/{id}/withdraw")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public MediaAssetResponse withdraw(@PathVariable UUID id,@Valid @RequestBody ActionRequest request,Authentication auth){return toResponse(repository.action(id,request.expectedVersion(),"WITHDRAW",actor(auth),request.reason(),false));}

    private static String actor(Authentication auth){if(auth==null||auth.getName()==null||auth.getName().isBlank())throw new IllegalStateException("Authenticated actor is required.");return auth.getName();}
    private ResponseEntity<byte[]> photoBytes(Asset a) throws IOException {
        if(a==null)return ResponseEntity.notFound().build();
        try(var input=storage.readPrivate(a.objectKey())){
            byte[] bytes=input.readAllBytes();
            return ResponseEntity.ok().contentType(MediaType.parseMediaType(a.contentType())).contentLength(bytes.length)
                    .cacheControl(CacheControl.noStore()).header("X-Content-Type-Options","nosniff").body(bytes);
        }
    }
    static MediaAssetResponse toResponse(Asset asset){return new MediaAssetResponse(asset.id(),asset.poiId(),asset.contentType(),asset.sha256(),asset.sizeBytes(),asset.width(),asset.height(),asset.author(),asset.sourceUrl(),asset.license(),asset.attribution(),asset.rightsEvidence(),asset.rightsStatus(),asset.state(),asset.primary(),asset.version(),asset.altText(),asset.displayOrder(),asset.sourceType(),asset.captureDate(),asset.capturePlace(),asset.authorDeclarationAccepted(),asset.authorDeclarationVersion(),asset.authorDeclarationBy(),asset.authorDeclarationAt(),asset.authorDeclarationText());}
    public record MediaAssetResponse(UUID id,UUID poiId,String contentType,String sha256,long sizeBytes,int width,int height,
            String author,String sourceUrl,String license,String attribution,String evidenceReference,String rightsStatus,
            String state,boolean primary,long version,String altText,int displayOrder,String sourceType,
            java.time.LocalDate captureDate,String capturePlace,boolean authorDeclarationAccepted,
            String authorDeclarationVersion,String authorDeclarationBy,java.time.Instant authorDeclarationAt,
            String authorDeclarationText){}
    public record PublicMediaResponse(UUID id,String path,String altText,boolean primary,int displayOrder,String author,String attribution,String license){}
    public record RightsRequest(@PositiveOrZero long expectedVersion,@NotBlank String license,@NotBlank String attribution,
            @NotBlank String evidenceReference,@NotBlank String reason){}
    public record ActionRequest(@PositiveOrZero long expectedVersion,@NotBlank String reason){}
    public record PublishRequest(@PositiveOrZero long expectedVersion,@NotBlank String reason,@NotNull Boolean makePrimary){}
    public record PresentationRequest(@PositiveOrZero long expectedVersion,@NotBlank @jakarta.validation.constraints.Size(max=500) String altText,
            @PositiveOrZero int displayOrder,@NotBlank String reason){}
    public record ReorderItem(@NotNull UUID id,@PositiveOrZero long expectedVersion,@PositiveOrZero int displayOrder){}
    public record ReorderRequest(@NotNull @jakarta.validation.constraints.Size(max=100) List<@Valid ReorderItem> items,@NotBlank String reason){}
}
