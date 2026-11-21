package ai.geoguide.poi.domain;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.ZoneId;
import java.util.HashSet;
import java.util.List;
import java.util.Objects;
import java.util.Set;
import java.util.UUID;

/** Current, editable operating information; it is independent of editorial approval. */
public record PoiOperationalInfo(
        String timeZone,
        List<DailyHours> weeklyHours,
        List<OperationalItem> items,
        long version) {

    public PoiOperationalInfo {
        if (timeZone == null || timeZone.isBlank()) throw new IllegalArgumentException("timeZone is required.");
        timeZone = timeZone.trim();
        try { ZoneId.of(timeZone); }
        catch (RuntimeException ex) { throw new IllegalArgumentException("timeZone must be a valid IANA time zone."); }
        weeklyHours = List.copyOf(Objects.requireNonNull(weeklyHours, "weeklyHours is required."));
        items = List.copyOf(Objects.requireNonNull(items, "items is required."));
        if (version < 0) throw new IllegalArgumentException("version cannot be negative.");
        Set<DayOfWeek> days = new HashSet<>();
        for (DailyHours day : weeklyHours) {
            if (!days.add(day.day())) throw new IllegalArgumentException("Each weekday can appear only once.");
        }
        if (weeklyHours.size() != DayOfWeek.values().length) throw new IllegalArgumentException("All seven weekdays are required.");
        if (items.size() > 50) throw new IllegalArgumentException("At most 50 operational items are allowed per POI.");
        Set<UUID> ids = new HashSet<>();
        for (OperationalItem item : items) {
            if (!ids.add(item.id())) throw new IllegalArgumentException("Operational item IDs must be unique.");
        }
    }

    public static PoiOperationalInfo empty(String timeZone, long version) {
        return new PoiOperationalInfo(timeZone, java.util.Arrays.stream(DayOfWeek.values())
                .map(day -> new DailyHours(day, List.of())).toList(), List.of(), version);
    }

    public record DailyHours(DayOfWeek day, List<TimeRange> periods) {
        public DailyHours {
            Objects.requireNonNull(day, "day is required.");
            periods = List.copyOf(Objects.requireNonNull(periods, "periods are required."));
            LocalTime priorClose = null;
            for (TimeRange period : periods) {
                if (priorClose != null && !period.opensAt().isAfter(priorClose))
                    throw new IllegalArgumentException("Opening periods must be ordered and must not overlap.");
                priorClose = period.closesAt();
            }
        }
    }

    public record TimeRange(LocalTime opensAt, LocalTime closesAt) {
        public TimeRange {
            Objects.requireNonNull(opensAt, "opensAt is required.");
            Objects.requireNonNull(closesAt, "closesAt is required.");
            if (!closesAt.isAfter(opensAt)) throw new IllegalArgumentException("Closing time must be after opening time.");
        }
    }

    public enum ItemType { PERFORMANCE, PROMOTION }

    public record OperationalItem(UUID id, ItemType type, String title, String description,
            String scheduleText, LocalDate validFrom, LocalDate validUntil, String terms, boolean active) {
        public OperationalItem {
            Objects.requireNonNull(id, "id is required.");
            Objects.requireNonNull(type, "type is required.");
            if (title == null || title.isBlank() || title.length() > 200)
                throw new IllegalArgumentException("A title of 1–200 characters is required.");
            title = title.trim();
            description = bounded(description, 2000, "description");
            scheduleText = bounded(scheduleText, 500, "scheduleText");
            terms = bounded(terms, 1000, "terms");
            if (validFrom != null && validUntil != null && validUntil.isBefore(validFrom))
                throw new IllegalArgumentException("validUntil cannot be before validFrom.");
        }

        private static String bounded(String value, int max, String name) {
            if (value == null || value.isBlank()) return null;
            String trimmed = value.trim();
            if (trimmed.length() > max) throw new IllegalArgumentException(name + " exceeds " + max + " characters.");
            return trimmed;
        }
    }
}
