package ai.zeroon.evidence;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

import ai.zeroon.evidence.EvidenceCohortReport.DistributionCell;
import ai.zeroon.evidence.EvidenceCohortReport.Metric;
import ai.zeroon.evidence.EvidenceCohortReport.Reliability;
import ai.zeroon.evidence.EvidenceCohortReport.TrustControls;
import java.time.LocalDate;
import java.util.Map;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;

class EvidenceOperationsServiceTest {

    private static final LocalDate DAY = LocalDate.of(2026, 7, 1);

    private final EvidenceCohortService cohortService = Mockito.mock(EvidenceCohortService.class);
    private final EvidenceOperationsService service = new EvidenceOperationsService(cohortService);

    @Test
    void suppressesTheWholeReportBelowFiveSubjects() {
        when(cohortService.calculate(DAY, DAY, DAY)).thenReturn(report(4));

        var response = service.read(DAY, DAY, DAY);

        assertThat(response.suppressed()).isTrue();
        assertThat(response.minimumCohortSize()).isEqualTo(5);
        assertThat(response.authenticatedSubjects()).isNull();
        assertThat(response.activation()).isNull();
        assertThat(response.reliability()).isNull();
    }

    @Test
    void suppressesSmallDerivedCellsWithoutHidingSafeZeros() {
        when(cohortService.calculate(DAY, DAY, DAY)).thenReturn(report(8));

        var response = service.read(DAY, DAY, DAY);

        assertThat(response.suppressed()).isFalse();
        assertThat(response.authenticatedSubjects()).isEqualTo(8);
        assertThat(response.activation().suppressed()).isTrue();
        assertThat(response.dayOneRetention().suppressed()).isFalse();
        assertThat(response.dayOneRetention().numerator()).isZero();
        assertThat(response.currentWeekContinuityReview().suppressed()).isTrue();
        assertThat(response.reliability().recordSaved().suppressed()).isFalse();
        assertThat(response.reliability().recordSaveFailed().suppressed()).isTrue();
        assertThat(response.reliability().reflectionOutcomes().get("SUCCESS").suppressed())
                .isFalse();
        assertThat(response.reliability().reflectionOutcomes().get("FALLBACK").suppressed())
                .isTrue();
        assertThat(response.trustControls().memoryDeletionSubjects().suppressed()).isTrue();
    }

    private EvidenceCohortReport report(int subjects) {
        Metric activation = EvidenceCohortCalculator.metric(3, subjects);
        Metric safeZero = EvidenceCohortCalculator.metric(0, subjects);
        Metric five = EvidenceCohortCalculator.metric(5, subjects);
        return new EvidenceCohortReport(
                DAY,
                DAY,
                DAY,
                EvidenceCohortCalculator.ACTIVATION_COVERAGE,
                subjects,
                activation,
                safeZero,
                five,
                five,
                five,
                EvidenceCohortCalculator.metric(3, 4),
                safeZero,
                five,
                new Reliability(
                        7,
                        5,
                        2,
                        2,
                        EvidenceCohortCalculator.metric(7, 9),
                        6,
                        EvidenceCohortCalculator.metric(2, 7),
                        2,
                        Map.of(
                                "SUCCESS", new DistributionCell(7, 5),
                                "FALLBACK", new DistributionCell(4, 4)),
                        Map.of("UNDER_500_MS", new DistributionCell(7, 5))),
                new TrustControls(
                        safeZero,
                        EvidenceCohortCalculator.metric(2, subjects),
                        five,
                        safeZero));
    }
}
