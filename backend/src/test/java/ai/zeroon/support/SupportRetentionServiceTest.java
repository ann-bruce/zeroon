package ai.zeroon.support;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;

class SupportRetentionServiceTest {

    private static final Instant NOW = Instant.parse("2026-07-23T12:00:00Z");

    @Test
    void rejectsRetentionBelowOneDay() {
        SupportRequestRepository repository = mock(SupportRequestRepository.class);

        assertThatThrownBy(() -> new SupportRetentionService(
                repository,
                Clock.fixed(NOW, ZoneOffset.UTC),
                0))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("at least one day");
    }

    @Test
    void purgesAgainstTheConfiguredClosedAtCutoffWithoutReadingContent() {
        SupportRequestRepository repository = mock(SupportRequestRepository.class);
        Instant cutoff = NOW.minus(Duration.ofDays(180));
        when(repository.deleteExpiredClosedRequests(cutoff)).thenReturn(3);
        SupportRetentionService service = new SupportRetentionService(
                repository,
                Clock.fixed(NOW, ZoneOffset.UTC),
                180);

        assertThat(service.purgeExpiredClosedRequests()).isEqualTo(3);
        verify(repository).deleteExpiredClosedRequests(cutoff);
    }
}
