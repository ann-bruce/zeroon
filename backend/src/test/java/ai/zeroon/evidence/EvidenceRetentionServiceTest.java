package ai.zeroon.evidence;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.inOrder;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import ai.zeroon.evidence.EvidenceRetentionService.PurgeResult;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;
import org.mockito.InOrder;

class EvidenceRetentionServiceTest {

    private static final Instant NOW = Instant.parse("2026-07-23T12:00:00Z");

    @Test
    void rejectsRetentionOutsideTheApprovedBoundary() {
        EvidenceEventRepository eventRepository = mock(EvidenceEventRepository.class);
        EvidenceSubjectRepository subjectRepository = mock(EvidenceSubjectRepository.class);
        Clock clock = Clock.fixed(NOW, ZoneOffset.UTC);

        assertThatThrownBy(() -> new EvidenceRetentionService(
                eventRepository, subjectRepository, clock, 0))
                .isInstanceOf(IllegalArgumentException.class);
        assertThatThrownBy(() -> new EvidenceRetentionService(
                eventRepository, subjectRepository, clock, 181))
                .isInstanceOf(IllegalArgumentException.class);
    }

    @Test
    void purgesEventsBeforeStaleSubjectsUsingTheSameCutoff() {
        EvidenceEventRepository eventRepository = mock(EvidenceEventRepository.class);
        EvidenceSubjectRepository subjectRepository = mock(EvidenceSubjectRepository.class);
        Instant cutoff = NOW.minus(Duration.ofDays(180));
        when(eventRepository.deleteReceivedBefore(cutoff)).thenReturn(4);
        when(subjectRepository.deleteStaleWithoutEvents(cutoff)).thenReturn(2);
        EvidenceRetentionService service = new EvidenceRetentionService(
                eventRepository,
                subjectRepository,
                Clock.fixed(NOW, ZoneOffset.UTC),
                180);

        PurgeResult result = service.purgeExpiredEvidence();

        assertThat(result.events()).isEqualTo(4);
        assertThat(result.subjects()).isEqualTo(2);
        InOrder order = inOrder(eventRepository, subjectRepository);
        order.verify(eventRepository).deleteReceivedBefore(cutoff);
        order.verify(subjectRepository).deleteStaleWithoutEvents(cutoff);
    }
}
