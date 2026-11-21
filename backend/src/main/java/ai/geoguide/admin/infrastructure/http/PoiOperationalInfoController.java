package ai.geoguide.admin.infrastructure.http;

import ai.geoguide.admin.infrastructure.persistence.PoiOperationalInfoRepository;
import ai.geoguide.poi.domain.PoiOperationalInfo;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import jakarta.validation.constraints.Min;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.http.HttpStatus;
import org.springframework.http.CacheControl;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@ConditionalOnProperty(name = "spring.datasource.url")
public class PoiOperationalInfoController {
    private final PoiOperationalInfoRepository repository;

    public PoiOperationalInfoController(PoiOperationalInfoRepository repository) { this.repository = repository; }

    @GetMapping("/api/v1/admin/pois/{poiId}/operational-info")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR','REVIEWER')")
    public ResponseEntity<PoiOperationalInfo> getAdmin(@PathVariable UUID poiId) {
        try { return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(repository.getAdmin(poiId)); }
        catch (IllegalArgumentException ex) { throw new ResponseStatusException(HttpStatus.NOT_FOUND, "POI not found."); }
    }

    @PutMapping("/api/v1/admin/pois/{poiId}/operational-info")
    @PreAuthorize("hasAnyRole('ADMINISTRATOR','EDITOR')")
    public PoiOperationalInfo update(@PathVariable UUID poiId, @Valid @RequestBody UpdateRequest request, Authentication auth) {
        if (auth == null || auth.getName() == null || auth.getName().isBlank())
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Authenticated actor is required.");
        return repository.update(poiId, request.expectedVersion(), auth.getName(),
                new PoiOperationalInfo(request.timeZone(), request.weeklyHours().stream().map(day ->
                        new PoiOperationalInfo.DailyHours(day.day(), day.periods().stream().map(period ->
                                new PoiOperationalInfo.TimeRange(period.opensAt(), period.closesAt())).toList())).toList(),
                        request.items().stream().map(item -> new PoiOperationalInfo.OperationalItem(item.id(), item.type(),
                                item.title(), item.description(), item.scheduleText(), item.validFrom(), item.validUntil(),
                                item.terms(), item.active())).toList(), request.expectedVersion()));
    }

    @GetMapping("/api/v1/pois/{poiId}/operational-info")
    public ResponseEntity<PoiOperationalInfo> getPublic(@PathVariable UUID poiId) {
        try { return ResponseEntity.ok().cacheControl(CacheControl.noStore()).body(repository.getPublic(poiId)); }
        catch (IllegalArgumentException ex) { throw new ResponseStatusException(HttpStatus.NOT_FOUND, "POI not found."); }
    }

    public record UpdateRequest(@Min(0) long expectedVersion, @NotBlank @Size(max=80) String timeZone,
            @NotNull @Size(min=7, max=7) List<@Valid DayHoursRequest> weeklyHours,
            @NotNull @Size(max=50) List<@Valid ItemRequest> items) {}
    public record DayHoursRequest(@NotNull DayOfWeek day, @NotNull List<@Valid TimeRangeRequest> periods) {}
    public record TimeRangeRequest(@NotNull LocalTime opensAt, @NotNull LocalTime closesAt) {}
    public record ItemRequest(@NotNull UUID id, @NotNull PoiOperationalInfo.ItemType type,
            @NotBlank @Size(max=200) String title, @Size(max=2000) String description,
            @Size(max=500) String scheduleText, LocalDate validFrom, LocalDate validUntil,
            @Size(max=1000) String terms, boolean active) {}
}
