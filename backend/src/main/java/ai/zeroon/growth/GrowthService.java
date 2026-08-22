package ai.zeroon.growth;

import ai.zeroon.growth.GrowthDtos.GrowthSummary;
import ai.zeroon.growth.GrowthDtos.StatePatternSummary;
import ai.zeroon.record.ZeroRecordRepository;
import ai.zeroon.state.StateHistoryRepository;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.time.Clock;
import java.time.DateTimeException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.temporal.ChronoUnit;
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
        long preservedMoments = zeroRecordRepository.countByUserId(userId);
        LocalDate firstRecordDate = zeroRecordRepository
                .findFirstByUserIdOrderByCreatedAtAsc(userId)
                .map(record -> LocalDate.ofInstant(record.getCreatedAt(), zoneId))
                .orElse(null);

        return new GrowthSummary(
                preservedMoments,
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
        long sampleSize = stateHistoryRepository
                .findByUserIdAndCreatedAtGreaterThanEqualOrderByCreatedAtDesc(userId, since)
                .size();
        return new StatePatternSummary(safeDays, sampleSize, zoneId.getId(), now);
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
}
