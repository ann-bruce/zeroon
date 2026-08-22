package ai.zeroon.growth;

import java.time.Instant;
import java.time.LocalDate;

public final class GrowthDtos {

    private GrowthDtos() {
    }

    public record GrowthSummary(
            long preservedMoments,
            LocalDate firstRecordDate,
            long companionDays,
            String timezone,
            Instant calculatedAt) {
    }

    public record StatePatternSummary(
            int days,
            long sampleSize,
            String timezone,
            Instant calculatedAt) {
    }
}
