package ai.geoguide.poi.domain;

import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.assertj.core.api.Assertions.assertThat;

import java.time.DayOfWeek;
import java.time.LocalTime;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class PoiOperationalInfoTests {
    @Test
    void acceptsAWeeklyScheduleAndOperationalOfferWithoutEditorialState() {
        var days = Arrays.stream(DayOfWeek.values())
                .map(day -> new PoiOperationalInfo.DailyHours(day, day == DayOfWeek.SATURDAY
                        ? List.of(new PoiOperationalInfo.TimeRange(LocalTime.of(10, 0), LocalTime.of(16, 0)))
                        : List.of()))
                .toList();
        var offer = new PoiOperationalInfo.OperationalItem(UUID.randomUUID(), PoiOperationalInfo.ItemType.PROMOTION,
                "Oferta sintética", "Sin derechos ni datos reales", "Sábados", null, null, null, true);

        var info = new PoiOperationalInfo("America/Lima", days, List.of(offer), 0);

        assertThat(info.weeklyHours()).hasSize(7);
        assertThat(info.items()).containsExactly(offer);
        assertThat(info.version()).isZero();
    }

    @Test
    void rejectsMissingDaysAndOverlappingOpeningPeriods() {
        assertThatThrownBy(() -> new PoiOperationalInfo("America/Lima",
                List.of(new PoiOperationalInfo.DailyHours(DayOfWeek.MONDAY, List.of())), List.of(), 0))
                .hasMessageContaining("All seven weekdays");

        assertThatThrownBy(() -> new PoiOperationalInfo.DailyHours(DayOfWeek.MONDAY, List.of(
                new PoiOperationalInfo.TimeRange(LocalTime.of(9, 0), LocalTime.of(13, 0)),
                new PoiOperationalInfo.TimeRange(LocalTime.of(12, 30), LocalTime.of(17, 0)))))
                .hasMessageContaining("must not overlap");
    }

    @Test
    void rejectsUnknownTimeZoneAndInvalidPromotionDates() {
        var days = PoiOperationalInfo.empty("America/Lima", 0).weeklyHours();
        assertThatThrownBy(() -> new PoiOperationalInfo("Unknown/Place", days, List.of(), 0))
                .hasMessageContaining("valid IANA time zone");
        assertThatThrownBy(() -> new PoiOperationalInfo.OperationalItem(UUID.randomUUID(), PoiOperationalInfo.ItemType.PERFORMANCE,
                "Función", null, null, java.time.LocalDate.parse("2026-12-02"), java.time.LocalDate.parse("2026-12-01"), null, true))
                .hasMessageContaining("cannot be before");
    }
}
