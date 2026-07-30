package ai.zeroon.record;

import ai.zeroon.record.RecordDtos.ContinuityCue;
import ai.zeroon.record.RecordDtos.ContinuityCueResponse;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.Objects;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Finds one optional, older Record for the authenticated owner's Now surface.
 *
 * <p>The selection is deliberately content-blind: it uses only owner id, creation time, and
 * the caller's local calendar day. It does not call AI, mutate records or memory, or emit
 * evidence.</p>
 */
@Service
public class ContinuityCueService {

    static final Duration MINIMUM_RECORD_AGE = Duration.ofHours(72);
    static final int MAXIMUM_PREVIEW_CODE_POINTS = 160;

    private final ZeroRecordRepository zeroRecordRepository;
    private final Clock clock;

    public ContinuityCueService(ZeroRecordRepository zeroRecordRepository, Clock clock) {
        this.zeroRecordRepository = zeroRecordRepository;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public ContinuityCueResponse findFor(Long userId, ZoneId timezone) {
        Instant now = Instant.now(clock);
        LocalDate localDay = now.atZone(timezone).toLocalDate();
        Instant eligibilityCutoff = localDay
                .atStartOfDay(timezone)
                .toInstant()
                .minus(MINIMUM_RECORD_AGE);
        long eligibleCount = zeroRecordRepository
                .countByUserIdAndCreatedAtLessThanEqual(userId, eligibilityCutoff);
        if (eligibleCount == 0) {
            return new ContinuityCueResponse(null);
        }

        int selectedIndex = Math.floorMod(
                Objects.hash(userId, localDay),
                Math.toIntExact(eligibleCount));
        ZeroRecordEntity record = zeroRecordRepository
                .findByUserIdAndCreatedAtLessThanEqualOrderByCreatedAtAscIdAsc(
                        userId,
                        eligibilityCutoff,
                        PageRequest.of(selectedIndex, 1))
                .getContent()
                .stream()
                .findFirst()
                .orElseThrow(() -> new IllegalStateException("Eligible continuity cue disappeared"));
        return new ContinuityCueResponse(new ContinuityCue(
                record.getId(),
                record.getState(),
                preview(record),
                record.getCreatedAt()));
    }

    private String preview(ZeroRecordEntity record) {
        String source = hasText(record.getContent())
                ? record.getContent().trim()
                : hasText(record.getGoal())
                        ? record.getGoal().trim()
                        : record.getState().name();
        int codePointCount = source.codePointCount(0, source.length());
        if (codePointCount <= MAXIMUM_PREVIEW_CODE_POINTS) {
            return source;
        }
        int endIndex = source.offsetByCodePoints(0, MAXIMUM_PREVIEW_CODE_POINTS);
        return source.substring(0, endIndex);
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }
}
