package ai.zeroon.evidence;

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
public class EvidenceRetentionService {

    private static final Logger LOGGER = LoggerFactory.getLogger(EvidenceRetentionService.class);

    private final EvidenceEventRepository eventRepository;
    private final EvidenceSubjectRepository subjectRepository;
    private final Clock clock;
    private final Duration retention;

    public EvidenceRetentionService(
            EvidenceEventRepository eventRepository,
            EvidenceSubjectRepository subjectRepository,
            Clock clock,
            @Value("${zeroon.evidence.retention-days:180}") long retentionDays) {
        if (retentionDays < 1 || retentionDays > 180) {
            throw new IllegalArgumentException(
                    "Evidence retention must be between one and 180 days");
        }
        this.eventRepository = eventRepository;
        this.subjectRepository = subjectRepository;
        this.clock = clock;
        this.retention = Duration.ofDays(retentionDays);
    }

    @Scheduled(
            cron = "${zeroon.evidence.retention-cron:0 29 * * * *}",
            zone = "UTC")
    @Transactional
    public PurgeResult purgeExpiredEvidence() {
        Instant cutoff = clock.instant().minus(retention);
        int events = eventRepository.deleteReceivedBefore(cutoff);
        int subjects = subjectRepository.deleteStaleWithoutEvents(cutoff);
        if (events > 0 || subjects > 0) {
            LOGGER.info(
                    "Purged {} expired evidence events and {} stale evidence subjects",
                    events,
                    subjects);
        }
        return new PurgeResult(events, subjects);
    }

    public record PurgeResult(int events, int subjects) {
    }
}
