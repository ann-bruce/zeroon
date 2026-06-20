package ai.zeroon.growth;

import java.time.Instant;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import ai.zeroon.user.UserState;

public final class GrowthDtos {

    private GrowthDtos() {
    }

    public record GrowthSummary(
            int continuousResetDays,
            long cachedEntries,
            LocalDate firstRecordDate,
            long companionDays,
            String timezone,
            Instant calculatedAt) {
    }

    public record StatePatternSummary(
            int days,
            long sampleSize,
            UserState dominantState,
            Map<UserState, Long> distribution,
            String observation,
            List<String> dataSources,
            String timezone,
            Instant calculatedAt) {
    }
}
