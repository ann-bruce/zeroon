package ai.zeroon.support;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SupportRetentionService {

    private static final Logger LOGGER = LoggerFactory.getLogger(SupportRetentionService.class);

    private final SupportRequestRepository requestRepository;
    private final Clock clock;
    private final Duration closedRetention;

    public SupportRetentionService(
            SupportRequestRepository requestRepository,
            Clock clock,
            @Value("${zeroon.support.closed-retention-days:180}") long closedRetentionDays) {
        if (closedRetentionDays < 1) {
            throw new IllegalArgumentException("Support closed retention must be at least one day");
        }
        this.requestRepository = requestRepository;
        this.clock = clock;
        this.closedRetention = Duration.ofDays(closedRetentionDays);
    }

    @Scheduled(
            cron = "${zeroon.support.retention-cron:0 17 * * * *}",
            zone = "UTC")
    @Transactional
    public int purgeExpiredClosedRequests() {
        Instant cutoff = clock.instant().minus(closedRetention);
        int deleted = requestRepository.deleteExpiredClosedRequests(cutoff);
        if (deleted > 0) {
            LOGGER.info("Purged {} expired closed support requests", deleted);
        }
        return deleted;
    }
}
