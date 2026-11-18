package ai.geoguide.admin.infrastructure.http;

import ai.geoguide.admin.infrastructure.persistence.AdminDestinationRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import java.math.BigDecimal;
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

/** Destination publication is independent from editorial POI publication and Route Discovery. */
@RestController
@ConditionalOnProperty(name = "spring.datasource.url")
@RequestMapping("/api/v1/admin/destination-records")
public class AdminDestinationController {
    private final AdminDestinationRepository destinations;

    public AdminDestinationController(AdminDestinationRepository destinations) { this.destinations = destinations; }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public AdminDestinationRepository.Page<AdminDestinationRepository.DestinationEditorialView> list(
            @RequestParam(required = false) String state, @RequestParam(required = false) String q,
            @RequestParam(defaultValue = "0") int page, @RequestParam(defaultValue = "50") int size) {
        return destinations.list(state, q, page, size);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public AdminDestinationRepository.DestinationEditorialView get(@PathVariable UUID id) {
        return destinations.find(id).orElseThrow(() ->
                new ResponseStatusException(HttpStatus.NOT_FOUND, "Destination candidate not found."));
    }

    @PostMapping("/from-import")
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public AdminDestinationRepository.DestinationEditorialView createFromImport(
            @Valid @RequestBody ImportDestinationRequest request, Authentication auth) {
        return destinations.createFromImport(request.importRecordId(), request.destinationType(),
                request.sourceLicense(), request.sourceAttribution(), actor(auth));
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public AdminDestinationRepository.DestinationEditorialView create(
            @Valid @RequestBody CreateDestinationRequest request, Authentication auth) {
        return destinations.create(new AdminDestinationRepository.CreateDestination(request.canonicalName(),
                request.destinationType(), request.administrativeContext(), request.latitude(), request.longitude(),
                request.rawLatitude(), request.rawLongitude(), request.normalizationRule(), request.coordinateEvidence(),
                request.sourceUrl(), request.sourceLicense(), request.sourceAttribution(), request.sourceRecordId()), actor(auth));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public AdminDestinationRepository.DestinationEditorialView update(@PathVariable UUID id,
            @Valid @RequestBody UpdateDestinationRequest request, Authentication auth) {
        return destinations.update(id, request.expectedVersion(), new AdminDestinationRepository.UpdateDestination(
                request.canonicalName(), request.destinationType(), request.administrativeContext(), request.latitude(),
                request.longitude(), request.normalizationRule(), request.coordinateEvidence(), request.sourceUrl(),
                request.sourceLicense(), request.sourceAttribution()), actor(auth), request.reason());
    }

    @PostMapping("/{id}/geographic-review")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminDestinationRepository.DestinationEditorialView geographicReview(@PathVariable UUID id,
            @Valid @RequestBody ReviewRequest request, Authentication auth) {
        return destinations.reviewGeography(id, request.expectedVersion(), request.approve(), actor(auth), request.reason());
    }

    @PostMapping("/{id}/identity-review")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminDestinationRepository.DestinationEditorialView identityReview(@PathVariable UUID id,
            @Valid @RequestBody IdentityReviewRequest request, Authentication auth) {
        return destinations.reviewIdentity(id, request.expectedVersion(), request.noDuplicate(), actor(auth),
                request.reason(), request.evidence());
    }

    @PostMapping("/{id}/access-review")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminDestinationRepository.DestinationEditorialView accessReview(@PathVariable UUID id,
            @Valid @RequestBody AccessReviewRequest request, Authentication auth) {
        return destinations.reviewAccess(id, request.expectedVersion(), request.approve(), actor(auth),
                request.reason(), request.evidence());
    }

    @GetMapping("/{id}/duplicates")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public java.util.List<AdminDestinationRepository.DuplicateCandidate> duplicates(@PathVariable UUID id) {
        return destinations.duplicates(id);
    }

    @PostMapping("/{id}/submit")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public AdminDestinationRepository.DestinationEditorialView submit(@PathVariable UUID id,
            @Valid @RequestBody VersionedAction request, Authentication auth) {
        return destinations.transition(id, request.expectedVersion(), "SUBMIT_FOR_REVIEW", actor(auth),
                request.reason(), request.evidence());
    }

    @PostMapping("/{id}/approve")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminDestinationRepository.DestinationEditorialView approve(@PathVariable UUID id,
            @Valid @RequestBody VersionedAction request, Authentication auth) {
        return destinations.transition(id, request.expectedVersion(), "APPROVE", actor(auth), request.reason(), request.evidence());
    }

    @PostMapping("/{id}/reject")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminDestinationRepository.DestinationEditorialView reject(@PathVariable UUID id,
            @Valid @RequestBody VersionedAction request, Authentication auth) {
        return destinations.transition(id, request.expectedVersion(), "REJECT", actor(auth), request.reason(), request.evidence());
    }

    @PostMapping("/{id}/archive")
    @PreAuthorize("hasRole('ADMINISTRATOR')")
    public AdminDestinationRepository.DestinationEditorialView archive(@PathVariable UUID id,
            @Valid @RequestBody VersionedAction request, Authentication auth) {
        return destinations.transition(id, request.expectedVersion(), "ARCHIVE", actor(auth), request.reason(), request.evidence());
    }

    private static String actor(Authentication authentication) {
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            throw new IllegalStateException("Authenticated actor identity is required.");
        }
        return authentication.getName();
    }

    public record ImportDestinationRequest(@NotNull UUID importRecordId, @NotBlank String destinationType,
            String sourceLicense, String sourceAttribution) {}
    public record CreateDestinationRequest(@NotBlank String canonicalName, @NotBlank String destinationType,
            @NotBlank String administrativeContext, BigDecimal latitude, BigDecimal longitude, String rawLatitude,
            String rawLongitude, String normalizationRule, String coordinateEvidence, @NotBlank String sourceUrl,
            @NotBlank String sourceLicense, @NotBlank String sourceAttribution, String sourceRecordId) {}
    public record UpdateDestinationRequest(long expectedVersion, @NotBlank String reason,
            @NotBlank String canonicalName, @NotBlank String destinationType,
            @NotBlank String administrativeContext, BigDecimal latitude, BigDecimal longitude,
            String normalizationRule, String coordinateEvidence, @NotBlank String sourceUrl,
            @NotBlank String sourceLicense, @NotBlank String sourceAttribution) {}
    public record ReviewRequest(long expectedVersion, boolean approve, @NotBlank String reason) {}
    public record IdentityReviewRequest(long expectedVersion, boolean noDuplicate, @NotBlank String reason,
            @NotBlank String evidence) {}
    public record AccessReviewRequest(long expectedVersion, boolean approve, @NotBlank String reason,
            @NotBlank String evidence) {}
    public record VersionedAction(long expectedVersion, @NotBlank String reason, @NotBlank String evidence) {}
}
