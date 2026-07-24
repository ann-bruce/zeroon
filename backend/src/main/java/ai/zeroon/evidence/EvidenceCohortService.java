package ai.zeroon.evidence;

import ai.zeroon.evidence.EvidenceCohortCalculator.Observation;
import java.time.LocalDate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EvidenceCohortService {

    private final EvidenceEventRepository eventRepository;
    private final EvidenceCohortCalculator calculator = new EvidenceCohortCalculator();

    public EvidenceCohortService(EvidenceEventRepository eventRepository) {
        this.eventRepository = eventRepository;
    }

    @Transactional(readOnly = true)
    public EvidenceCohortReport calculate(
            LocalDate cohortStart,
            LocalDate cohortEnd,
            LocalDate asOfDate) {
        var observations = eventRepository
                .findByOccurredDateLessThanEqualOrderByOccurredDateAscReceivedAtAsc(asOfDate)
                .stream()
                .map(event -> new Observation(
                        event.getSubjectId(),
                        event.getEventName(),
                        event.getOccurredDate(),
                        event.getRetryCountBucket(),
                        event.getLatencyBucket(),
                        event.getSurface(),
                        event.getOutcome(),
                        event.getAction(),
                        event.getEnabled()))
                .toList();
        return calculator.calculate(observations, cohortStart, cohortEnd, asOfDate);
    }
}
