package ai.geoguide.admin.infrastructure.http;

import ai.geoguide.admin.infrastructure.persistence.AdminDestinationPoiRelationshipRepository;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@RestController
@ConditionalOnProperty(name = "spring.datasource.url")
@RequestMapping("/api/v1/admin/destination-poi-relationships")
public class AdminDestinationPoiRelationshipController {
    private final AdminDestinationPoiRelationshipRepository relationships;

    public AdminDestinationPoiRelationshipController(AdminDestinationPoiRelationshipRepository relationships) {
        this.relationships = relationships;
    }

    @GetMapping
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public AdminDestinationPoiRelationshipRepository.Page<AdminDestinationPoiRelationshipRepository.RelationshipView> list(
            @RequestParam(required = false) String status, @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "50") int size) {
        return relationships.list(status, page, size);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public AdminDestinationPoiRelationshipRepository.RelationshipView create(
            @Valid @RequestBody CreateRequest request, Authentication auth) {
        return relationships.create(new AdminDestinationPoiRelationshipRepository.CreateRelationship(
                request.destinationId(), request.poiId(), request.relationshipType(), request.reason(),
                request.evidence()), actor(auth));
    }

    @PostMapping("/{id}/approve")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminDestinationPoiRelationshipRepository.RelationshipView approve(@PathVariable UUID id,
            @Valid @RequestBody ReviewRequest request, Authentication auth) {
        return relationships.review(id, request.expectedVersion(), true, actor(auth), request.reason(), request.evidence());
    }

    @PostMapping("/{id}/reject")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','REVIEWER')")
    public AdminDestinationPoiRelationshipRepository.RelationshipView reject(@PathVariable UUID id,
            @Valid @RequestBody ReviewRequest request, Authentication auth) {
        return relationships.review(id, request.expectedVersion(), false, actor(auth), request.reason(), request.evidence());
    }

    private static String actor(Authentication authentication) {
        if (authentication == null || authentication.getName() == null || authentication.getName().isBlank()) {
            throw new IllegalStateException("Authenticated actor identity is required.");
        }
        return authentication.getName();
    }

    public record CreateRequest(UUID destinationId, UUID poiId, @NotBlank String relationshipType,
            @NotBlank String reason, @NotBlank String evidence) {}
    public record ReviewRequest(long expectedVersion, @NotBlank String reason, @NotBlank String evidence) {}
}
