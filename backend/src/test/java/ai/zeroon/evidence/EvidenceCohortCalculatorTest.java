package ai.zeroon.evidence;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ai.zeroon.evidence.EvidenceCohortCalculator.Observation;
import ai.zeroon.evidence.EvidenceEnums.EventName;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import org.junit.jupiter.api.Test;

class EvidenceCohortCalculatorTest {

    private final EvidenceCohortCalculator calculator = new EvidenceCohortCalculator();

    @Test
    void calculatesActivationRetentionContinuityReliabilityAndTrustFromCalendarDays() {
        LocalDate januaryFirst = LocalDate.of(2026, 1, 1);
        LocalDate januarySecond = LocalDate.of(2026, 1, 2);
        LocalDate asOf = LocalDate.of(2026, 2, 15);
        List<Observation> events = new ArrayList<>();

        addActivated(events, 1, januaryFirst, "ZERO");
        addActivated(events, 2, januaryFirst, "ONE");
        addActivated(events, 4, januarySecond, "ZERO");
        addActivated(events, 5, januarySecond, "ZERO");
        addActivated(events, 6, januarySecond, "ZERO");
        events.add(event(3, EventName.AUTH_COMPLETED, januaryFirst));

        events.add(event(1, EventName.STATE_STARTED, januaryFirst.plusDays(1)));
        events.add(event(2, EventName.STATE_STARTED, januaryFirst.plusDays(1)));
        events.add(event(1, EventName.ARCHIVE_VIEWED, januaryFirst.plusDays(7)));
        events.add(event(1, EventName.ARCHIVE_VIEWED, januaryFirst.plusDays(30)));
        events.add(event(1, EventName.RECORD_SAVED, januaryFirst.plusDays(9)));
        events.add(event(2, EventName.RECORD_SAVE_FAILED, januaryFirst.plusDays(3)));

        events.add(event(1, EventName.ARCHIVE_VIEWED, asOf));
        events.add(observation(
                1, EventName.REFLECTION_COMPLETED, asOf, null,
                "UNDER_500_MS", null, "SUCCESS", null, null));
        events.add(observation(
                2, EventName.REFLECTION_REQUESTED, asOf, null,
                null, "COMPANION", null, null, null));
        events.add(observation(
                2, EventName.REFLECTION_COMPLETED, asOf, null,
                "FROM_500_TO_1499_MS", null, "FALLBACK", null, null));
        events.add(event(3, EventName.STATE_STARTED, asOf));

        events.add(observation(
                1, EventName.PROFILE_AI_CONTEXT_CHANGED, januaryFirst.plusDays(2),
                null, null, "PROFILE", null, null, false));
        events.add(observation(
                2, EventName.MEMORY_CONTROL_CHANGED, januaryFirst.plusDays(2),
                null, null, null, null, "DELETE", null));
        events.add(observation(
                3, EventName.DATA_EXPORT_REQUESTED, januaryFirst.plusDays(2),
                null, null, "DATA_CONTROL", "STARTED", null, null));
        events.add(observation(
                4, EventName.ACCOUNT_DELETE_REQUESTED, januarySecond.plusDays(2),
                null, null, "DATA_CONTROL", "STARTED", null, null));
        events.add(event(3, EventName.RESET_STARTED, januaryFirst.plusDays(2)));

        EvidenceCohortReport report = calculator.calculate(
                events, januaryFirst, januarySecond, asOf);

        assertThat(report.activationCoverage())
                .isEqualTo("FULL_REVIEWED_EVENT_COVERAGE");
        assertThat(report.authenticatedSubjects()).isEqualTo(6);
        assertMetric(report.activation(), 5, 6, "0.8333");
        assertMetric(report.dayOneRetention(), 2, 5, "0.4000");
        assertMetric(report.daySevenRetention(), 1, 5, "0.2000");
        assertMetric(report.dayThirtyRetention(), 1, 5, "0.2000");
        assertMetric(report.weekTwoRecord(), 1, 5, "0.2000");
        assertMetric(report.currentWeekContinuityReview(), 1, 3, "0.3333");
        assertMetric(report.currentWeekChatOnly(), 1, 3, "0.3333");
        assertMetric(report.recordFlowCompletion(), 5, 6, "0.8333");

        assertThat(report.reliability().recordSaved()).isEqualTo(6);
        assertThat(report.reliability().recordSavedSubjects()).isEqualTo(5);
        assertThat(report.reliability().recordSaveFailed()).isEqualTo(1);
        assertThat(report.reliability().recordSaveFailedSubjects()).isEqualTo(1);
        assertMetric(report.reliability().recordSaveSuccess(), 6, 7, "0.8571");
        assertThat(report.reliability().recordSaveSuccessSubjects()).isEqualTo(5);
        assertMetric(report.reliability().recoveredRetry(), 1, 6, "0.1667");
        assertThat(report.reliability().recoveredRetrySubjects()).isEqualTo(1);
        assertThat(report.reliability().reflectionOutcomes())
                .containsExactlyInAnyOrderEntriesOf(java.util.Map.of(
                        "SUCCESS", new EvidenceCohortReport.DistributionCell(1, 1),
                        "FALLBACK", new EvidenceCohortReport.DistributionCell(1, 1)));
        assertThat(report.reliability().reflectionLatencyBuckets())
                .containsExactlyInAnyOrderEntriesOf(java.util.Map.of(
                        "UNDER_500_MS", new EvidenceCohortReport.DistributionCell(1, 1),
                        "FROM_500_TO_1499_MS", new EvidenceCohortReport.DistributionCell(1, 1)));

        assertMetric(report.trustControls().aiContextDisabledSubjects(), 1, 6, "0.1667");
        assertMetric(report.trustControls().memoryDeletionSubjects(), 1, 6, "0.1667");
        assertMetric(report.trustControls().dataExportDemand(), 1, 6, "0.1667");
        assertMetric(report.trustControls().accountDeletionDemand(), 1, 6, "0.1667");
    }

    @Test
    void doesNotPretendAControlChangeProvesTheControlWasViewed() {
        LocalDate day = LocalDate.of(2026, 1, 1);
        List<Observation> events = new ArrayList<>();
        events.add(event(1, EventName.AUTH_COMPLETED, day));
        events.add(event(1, EventName.ZEROON_ENCOUNTER_COMPLETED, day));
        events.add(event(1, EventName.STATE_STARTED, day));
        events.add(event(1, EventName.RECORD_SAVED, day));
        events.add(event(1, EventName.RECORD_DETAIL_VIEWED, day));
        events.add(observation(
                1, EventName.PROFILE_AI_CONTEXT_CHANGED, day, null,
                null, "PROFILE", null, null, true));

        EvidenceCohortReport report = calculator.calculate(events, day, day, day);

        assertMetric(report.activation(), 0, 1, "0");
    }

    @Test
    void leavesRateUndefinedWhenNoSubjectHasMatured() {
        LocalDate day = LocalDate.of(2026, 1, 1);
        List<Observation> events = new ArrayList<>();
        addActivated(events, 1, day, "ZERO");

        EvidenceCohortReport report = calculator.calculate(events, day, day, day);

        assertThat(report.dayOneRetention().numerator()).isZero();
        assertThat(report.dayOneRetention().denominator()).isZero();
        assertThat(report.dayOneRetention().rate()).isNull();
    }

    @Test
    void rejectsAnInvalidCalendarWindow() {
        LocalDate day = LocalDate.of(2026, 1, 1);

        assertThatThrownBy(() -> calculator.calculate(
                List.of(), day.plusDays(1), day, day))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Cohort window is invalid");
    }

    private void addActivated(
            List<Observation> events,
            long subjectId,
            LocalDate day,
            String retryBucket) {
        events.add(event(subjectId, EventName.AUTH_COMPLETED, day));
        events.add(event(subjectId, EventName.ZEROON_ENCOUNTER_COMPLETED, day));
        events.add(event(subjectId, EventName.STATE_STARTED, day));
        events.add(event(subjectId, EventName.RESET_STARTED, day));
        events.add(observation(
                subjectId, EventName.RECORD_SAVED, day, retryBucket,
                "UNDER_500_MS", null, null, null, null));
        events.add(event(subjectId, EventName.ARCHIVE_VIEWED, day));
        events.add(observation(
                subjectId, EventName.PROFILE_AI_CONTEXT_CHANGED, day, null,
                null, "PROFILE", null, null, true));
        events.add(observation(
                subjectId, EventName.PROFILE_AI_CONTEXT_CONTROL_VIEWED, day, null,
                null, "PROFILE", null, null, true));
    }

    private Observation event(long subjectId, EventName eventName, LocalDate day) {
        return observation(subjectId, eventName, day, null, null, null, null, null, null);
    }

    private Observation observation(
            long subjectId,
            EventName eventName,
            LocalDate day,
            String retryCountBucket,
            String latencyBucket,
            String surface,
            String outcome,
            String action,
            Boolean enabled) {
        return new Observation(
                subjectId,
                eventName,
                day,
                retryCountBucket,
                latencyBucket,
                surface,
                outcome,
                action,
                enabled);
    }

    private void assertMetric(
            EvidenceCohortReport.Metric metric,
            long numerator,
            long denominator,
            String rate) {
        assertThat(metric.numerator()).isEqualTo(numerator);
        assertThat(metric.denominator()).isEqualTo(denominator);
        if (denominator == 0) {
            assertThat(metric.rate()).isNull();
        } else {
            assertThat(metric.rate()).isEqualByComparingTo(new BigDecimal(rate));
        }
    }
}
