package ai.zeroon.growth;

import ai.zeroon.growth.GrowthDtos.GrowthSummary;
import ai.zeroon.growth.GrowthDtos.StatePatternSummary;
import ai.zeroon.record.ZeroRecordEntity;
import ai.zeroon.record.ZeroRecordRepository;
import ai.zeroon.state.StateHistoryEntity;
import ai.zeroon.state.StateHistoryRepository;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserState;
import jakarta.persistence.EntityNotFoundException;
import java.time.Clock;
import java.time.Instant;
import java.time.DateTimeException;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.EnumMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import org.springframework.stereotype.Service;

@Service
public class GrowthService {

    private final UserRepository userRepository;
    private final ZeroRecordRepository zeroRecordRepository;
    private final StateHistoryRepository stateHistoryRepository;
    private final Clock clock;

    public GrowthService(
            UserRepository userRepository,
            ZeroRecordRepository zeroRecordRepository,
            StateHistoryRepository stateHistoryRepository,
            Clock clock) {
        this.userRepository = userRepository;
        this.zeroRecordRepository = zeroRecordRepository;
        this.stateHistoryRepository = stateHistoryRepository;
        this.clock = clock;
    }

    public GrowthSummary summary(Long userId, String timezone) {
        ZoneId zoneId = parseZone(timezone);
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        Instant now = clock.instant();
        LocalDate today = LocalDate.ofInstant(now, zoneId);
        long cachedEntries = zeroRecordRepository.countByUserId(userId);
        LocalDate firstRecordDate = zeroRecordRepository
                .findFirstByUserIdOrderByCreatedAtAsc(userId)
                .map(record -> LocalDate.ofInstant(record.getCreatedAt(), zoneId))
                .orElse(null);

        return new GrowthSummary(
                continuousResetDays(userId, today, zoneId),
                cachedEntries,
                firstRecordDate,
                companionDays(user.getCreatedAt(), today, zoneId),
                zoneId.getId(),
                now);
    }

    public StatePatternSummary statePattern(Long userId, String timezone, int days) {
        ZoneId zoneId = parseZone(timezone);
        userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        int safeDays = Math.min(Math.max(days, 1), 90);
        Instant now = clock.instant();
        Instant since = LocalDate.ofInstant(now, zoneId)
                .minusDays(safeDays - 1L)
                .atStartOfDay(zoneId)
                .toInstant();
        List<StateHistoryEntity> histories =
                stateHistoryRepository.findByUserIdAndCreatedAtGreaterThanEqualOrderByCreatedAtDesc(userId, since);
        Map<UserState, Long> distribution = distribution(histories);
        UserState dominantState = dominantState(distribution);
        return new StatePatternSummary(
                safeDays,
                histories.size(),
                dominantState,
                distribution,
                observation(dominantState, histories.size(), safeDays),
                List.of("state_history.current_state", "state_history.created_at"),
                zoneId.getId(),
                now);
    }

    private ZoneId parseZone(String timezone) {
        if (timezone == null || timezone.isBlank()) {
            throw new IllegalArgumentException("timezone is required");
        }
        try {
            return ZoneId.of(timezone);
        } catch (DateTimeException ex) {
            throw new IllegalArgumentException("timezone must be a valid IANA timezone", ex);
        }
    }

    private long companionDays(Instant registeredAt, LocalDate today, ZoneId zoneId) {
        LocalDate registrationDate = LocalDate.ofInstant(registeredAt, zoneId);
        long days = ChronoUnit.DAYS.between(registrationDate, today) + 1;
        return Math.max(days, 1);
    }

    private int continuousResetDays(Long userId, LocalDate today, ZoneId zoneId) {
        Set<LocalDate> recordDates = new HashSet<>();
        for (ZeroRecordEntity record : zeroRecordRepository.findByUserIdOrderByCreatedAtDesc(userId)) {
            recordDates.add(LocalDate.ofInstant(record.getCreatedAt(), zoneId));
        }

        LocalDate cursor;
        if (recordDates.contains(today)) {
            cursor = today;
        } else if (recordDates.contains(today.minusDays(1))) {
            cursor = today.minusDays(1);
        } else {
            return 0;
        }

        int count = 0;
        while (recordDates.contains(cursor)) {
            count++;
            cursor = cursor.minusDays(1);
        }
        return count;
    }

    private Map<UserState, Long> distribution(List<StateHistoryEntity> histories) {
        Map<UserState, Long> distribution = new EnumMap<>(UserState.class);
        for (UserState state : UserState.values()) {
            distribution.put(state, 0L);
        }
        for (StateHistoryEntity history : histories) {
            distribution.compute(history.getCurrentState(), (state, count) -> count == null ? 1L : count + 1);
        }
        return distribution;
    }

    private UserState dominantState(Map<UserState, Long> distribution) {
        UserState dominant = null;
        long max = 0;
        for (Map.Entry<UserState, Long> entry : distribution.entrySet()) {
            if (entry.getValue() > max) {
                dominant = entry.getKey();
                max = entry.getValue();
            }
        }
        return dominant;
    }

    private String observation(UserState dominantState, long sampleSize, int days) {
        if (sampleSize == 0) {
            return "最近还没有足够的状态记录。ZEROON 会先安静保存你之后确认过的状态变化。";
        }
        List<String> parts = new ArrayList<>();
        parts.add("最近 " + days + " 天，你确认过 " + sampleSize + " 次状态变化。");
        if (dominantState != null) {
            parts.add("出现最多的是 " + dominantState.name() + "。这只是近期记录的分布，不代表固定标签。");
        }
        parts.add("这个观察只来自你可见的状态历史。");
        return String.join(" ", parts);
    }
}
