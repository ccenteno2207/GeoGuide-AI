package ai.geoguide.admin.infrastructure.http;

import ai.geoguide.admin.infrastructure.persistence.AdminEditorialRepository;
import ai.geoguide.admin.infrastructure.persistence.AdminImportReadRepository;
import ai.geoguide.admin.infrastructure.persistence.AdminPoiInventoryRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
import java.util.List;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

/** Local administrative catalog APIs. The security chain is deny-by-default until OIDC is configured. */
@RestController
@ConditionalOnProperty(name = "spring.datasource.url")
@RequestMapping("/api/v1/admin")
public class AdminCatalogController {
    private final AdminEditorialRepository editorial;
    private final AdminImportReadRepository imports;
    private final AdminPoiInventoryRepository pois;

    public AdminCatalogController(AdminEditorialRepository editorial, AdminImportReadRepository imports, AdminPoiInventoryRepository pois) {
        this.editorial = editorial;
        this.imports = imports;
        this.pois = pois;
    }

    @GetMapping("/pois")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public AdminPoiInventoryRepository.Page pois(@RequestParam(required=false) String q,
            @RequestParam(required=false) String category, @RequestParam(required=false) Boolean active,
            @RequestParam(defaultValue="0") int page,@RequestParam(defaultValue="50") int size) {
        return pois.list(q, category, active, page, size);
    }

    @GetMapping("/pois/{id}/activation-history")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public List<AdminPoiInventoryRepository.ActivationAudit> poiActivationHistory(@PathVariable UUID id) { return pois.audit(id); }

    @PostMapping("/pois/{id}/activation")
    @PreAuthorize("hasRole('ADMINISTRATOR')")
    public AdminPoiInventoryRepository.PoiView setPoiActivation(@PathVariable UUID id,
            @Valid @RequestBody ExistingPoiActivationRequest request, Authentication auth) {
        return pois.setActive(id, request.expectedUpdatedAt(), request.active(), actor(auth), request.reason(), request.evidence());
    }

    @PostMapping("/records/change-requests/{poiId}")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public AdminEditorialRepository.EditorialView createChangeRequest(@PathVariable UUID poiId, Authentication auth) {
        return editorial.createChangeRequest(poiId, actor(auth));
    }

    @GetMapping("/imports")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public List<AdminImportReadRepository.BatchView> batches() { return imports.batches(); }

    @GetMapping("/imports/{batchId}/records")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public AdminImportReadRepository.Page<AdminImportReadRepository.ImportRecordView> importRecords(@PathVariable UUID batchId,
            @RequestParam(required = false) String status, @RequestParam(required = false) String q,
            @RequestParam(required = false) String locality, @RequestParam(required = false) String category,
            @RequestParam(defaultValue="0") int page,@RequestParam(defaultValue="100") int size) {
        return imports.records(batchId, status, q, locality, category, page, size);
    }

    @GetMapping("/records")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public AdminEditorialRepository.Page<AdminEditorialRepository.EditorialView> records(@RequestParam(required = false) String state,
            @RequestParam(required = false) String q, @RequestParam(required = false) String locality,
            @RequestParam(required = false) String category, @RequestParam(defaultValue="0") int page,
            @RequestParam(defaultValue="50") int size) { return editorial.list(state, q, locality, category, page, size); }

    @GetMapping("/records/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public AdminEditorialRepository.EditorialView record(@PathVariable UUID id) {
        return editorial.find(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Editorial record not found."));
    }

    @PostMapping("/records")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public AdminEditorialRepository.EditorialView create(@Valid @RequestBody CreateRequest request, Authentication auth) {
        if (request.importRecordId() == null && (request.name() == null || request.name().isBlank())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "A manual POI draft requires a non-blank name.");
        }
        return editorial.create(new AdminEditorialRepository.CreateEditorial(request.importRecordId(), request.name(),
                request.description(), request.categoryCode(), request.latitude(), request.longitude(),
                request.rawLatitude(),request.rawLongitude(),request.normalizationRule(),request.coordinateEvidence(),
                request.sourceLicense(), request.sourceAttribution(), request.administrativeContext()), actor(auth));
    }

    @PutMapping("/records/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public AdminEditorialRepository.EditorialView update(@PathVariable UUID id, @Valid @RequestBody UpdateRequest request,
            Authentication auth) {
        return editorial.update(id, request.expectedVersion(), new AdminEditorialRepository.UpdateEditorial(request.name(),
                request.description(), request.categoryCode(), request.latitude(), request.longitude(),
                request.normalizationRule(),request.coordinateEvidence(),request.sourceLicense(), request.sourceAttribution(),
                request.administrativeContext()), actor(auth), request.reason());
    }

    @PostMapping("/records/{id}/geographic-review")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminEditorialRepository.EditorialView geographicReview(@PathVariable UUID id,
            @Valid @RequestBody GeographicReviewRequest request, Authentication auth) {
        return editorial.reviewGeography(id, request.expectedVersion(), request.approve(), actor(auth), request.reason());
    }

    @PostMapping("/records/{id}/identity-review")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminEditorialRepository.EditorialView identityReview(@PathVariable UUID id,
            @Valid @RequestBody IdentityReviewRequest request, Authentication auth) {
        return editorial.reviewIdentity(id, request.expectedVersion(), request.noDuplicate(), actor(auth),
                request.reason(), request.evidence());
    }

    @PostMapping("/records/{id}/submit")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public AdminEditorialRepository.EditorialView submit(@PathVariable UUID id, @Valid @RequestBody VersionedAction request,
            Authentication auth) { return editorial.transition(id, request.expectedVersion(), "SUBMIT_FOR_REVIEW",
                    actor(auth), request.reason(), request.evidence()); }

    @PostMapping("/records/{id}/approve")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminEditorialRepository.EditorialView approve(@PathVariable UUID id, @Valid @RequestBody VersionedAction request,
            Authentication auth) { return editorial.transition(id, request.expectedVersion(), "APPROVE",
                    actor(auth), request.reason(), request.evidence()); }

    @PostMapping("/records/{id}/observe")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminEditorialRepository.EditorialView observe(@PathVariable UUID id, @Valid @RequestBody VersionedAction request,
            Authentication auth) { return editorial.transition(id, request.expectedVersion(), "OBSERVE",
                    actor(auth), request.reason(), request.evidence()); }

    @PostMapping("/records/{id}/suspend")
    @PreAuthorize("hasRole('ADMINISTRATOR')")
    public AdminEditorialRepository.EditorialView suspend(@PathVariable UUID id, @Valid @RequestBody VersionedAction request,
            Authentication auth) { return editorial.transition(id, request.expectedVersion(), "SUSPEND",
                    actor(auth), request.reason(), request.evidence()); }

    @PostMapping("/records/{id}/restore-approval")
    @PreAuthorize("hasRole('ADMINISTRATOR')")
    public AdminEditorialRepository.EditorialView restoreApproval(@PathVariable UUID id, @Valid @RequestBody VersionedAction request,
            Authentication auth) { return editorial.transition(id, request.expectedVersion(), "RESTORE_APPROVAL",
                    actor(auth), request.reason(), request.evidence()); }

    @PostMapping("/records/{id}/activation")
    @PreAuthorize("hasRole('ADMINISTRATOR')")
    public AdminEditorialRepository.EditorialView activation(@PathVariable UUID id, @Valid @RequestBody ActivationRequest request,
            Authentication auth) { return editorial.setActivation(id, request.expectedVersion(), request.active(), actor(auth),
                    request.reason(), request.evidence()); }

    @PostMapping("/records/{id}/reject")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminEditorialRepository.EditorialView reject(@PathVariable UUID id, @Valid @RequestBody VersionedAction request,
            Authentication auth) { return editorial.transition(id, request.expectedVersion(), "REJECT",
                    actor(auth), request.reason(), request.evidence()); }

    @PostMapping("/records/{id}/archive")
    @PreAuthorize("hasRole('ADMINISTRATOR')")
    public AdminEditorialRepository.EditorialView archive(@PathVariable UUID id, @Valid @RequestBody VersionedAction request,
            Authentication auth) { return editorial.transition(id, request.expectedVersion(), "ARCHIVE",
                    actor(auth), request.reason(), request.evidence()); }

    @GetMapping("/records/{id}/duplicates")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public List<AdminEditorialRepository.DuplicateCandidate> duplicates(@PathVariable UUID id) { return editorial.duplicates(id); }

    private static String actor(Authentication authentication) {
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            throw new IllegalStateException("Authenticated actor identity is required.");
        }
        return authentication.getName();
    }

    public record CreateRequest(UUID importRecordId, String name, String description, String administrativeContext,
            @NotBlank String categoryCode, BigDecimal latitude, BigDecimal longitude,
            String rawLatitude,String rawLongitude,String normalizationRule,String coordinateEvidence,
            @Size(max = 240) String sourceLicense, String sourceAttribution) {}
    public record UpdateRequest(long expectedVersion, @NotBlank String reason, @NotBlank String name,
            String description, @NotBlank String categoryCode, BigDecimal latitude, BigDecimal longitude,
            String normalizationRule,String coordinateEvidence,@Size(max = 240) String sourceLicense, String sourceAttribution,
            String administrativeContext) {}
    public record GeographicReviewRequest(long expectedVersion, boolean approve, @NotBlank String reason) {}
    public record IdentityReviewRequest(long expectedVersion, boolean noDuplicate, @NotBlank String reason,
            @NotBlank String evidence) {}
    public record VersionedAction(long expectedVersion, @NotBlank String reason, @NotBlank String evidence) {}
    public record ActivationRequest(long expectedVersion, boolean active, @NotBlank String reason, @NotBlank String evidence) {}
    public record ExistingPoiActivationRequest(@NotNull java.time.Instant expectedUpdatedAt, boolean active,
            @NotBlank String reason, @NotBlank String evidence) {}
}
