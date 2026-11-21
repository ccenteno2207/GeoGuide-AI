package ai.geoguide.admin.infrastructure.http;

import ai.geoguide.admin.domain.PoiTourismContent;
import ai.geoguide.admin.infrastructure.persistence.PoiTourismContentRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.PositiveOrZero;
import jakarta.validation.constraints.Size;
import java.util.List;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@ConditionalOnProperty(name = "spring.datasource.url")
public class PoiTourismContentController {
    private final PoiTourismContentRepository repository;

    public PoiTourismContentController(PoiTourismContentRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/api/v1/admin/pois/{poiId}/content")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public ResponseEntity<PoiTourismContentRepository.AdminContent> admin(@PathVariable UUID poiId) {
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(repository.getAdmin(poiId));
    }

    @PutMapping("/api/v1/admin/pois/{poiId}/content/draft")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public PoiTourismContentRepository.AdminContent save(@PathVariable UUID poiId,
            @Valid @RequestBody SaveDraftRequest request, Authentication auth) {
        return repository.saveDraft(poiId, request.expectedVersion(), request.content(), actor(auth), request.reason());
    }

    @PostMapping("/api/v1/admin/pois/{poiId}/content/submit")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public PoiTourismContentRepository.AdminContent submit(@PathVariable UUID poiId,
            @Valid @RequestBody ActionRequest request, Authentication auth) {
        return repository.submit(poiId, request.expectedVersion(), actor(auth), request.reason());
    }

    @PostMapping("/api/v1/admin/pois/{poiId}/content/publish")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public PoiTourismContentRepository.AdminContent publish(@PathVariable UUID poiId,
            @Valid @RequestBody ActionRequest request, Authentication auth) {
        return repository.publish(poiId, request.expectedVersion(), actor(auth), request.reason());
    }

    @PostMapping("/api/v1/admin/pois/{poiId}/content/revert")
    @PreAuthorize("hasRole('ADMINISTRATOR')")
    public PoiTourismContentRepository.AdminContent revert(@PathVariable UUID poiId,
            @Valid @RequestBody RevertRequest request, Authentication auth) {
        return repository.revertTo(poiId, request.revisionId(), request.expectedVersion(), actor(auth), request.reason());
    }

    @GetMapping("/api/v1/pois/{poiId}/content")
    public ResponseEntity<PoiTourismContentRepository.PublicContent> publicContent(@PathVariable UUID poiId) {
        return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(repository.getPublic(poiId));
    }

    private static String actor(Authentication auth) {
        if (auth == null || auth.getName() == null || auth.getName().isBlank()) {
            throw new IllegalArgumentException("Authenticated actor is required.");
        }
        return auth.getName();
    }

    public record SaveDraftRequest(@PositiveOrZero long expectedVersion, @NotNull @Valid PoiTourismContent content,
            @NotBlank @Size(max = 1000) String reason) { }
    public record ActionRequest(@PositiveOrZero long expectedVersion, @NotBlank @Size(max = 1000) String reason) { }
    public record RevertRequest(@NotNull UUID revisionId, @PositiveOrZero long expectedVersion,
            @NotBlank @Size(max = 1000) String reason) { }
}
