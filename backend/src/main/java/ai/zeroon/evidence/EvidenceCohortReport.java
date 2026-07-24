package ai.zeroon.evidence;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

public record EvidenceCohortReport(
        LocalDate cohortStart,
        LocalDate cohortEnd,
        LocalDate asOfDate,
        String activationCoverage,
        int authenticatedSubjects,
        Metric activation,
        Metric dayOneRetention,
        Metric daySevenRetention,
        Metric dayThirtyRetention,
        Metric weekTwoRecord,
        Metric currentWeekContinuityReview,
        Metric currentWeekChatOnly,
        Metric recordFlowCompletion,
        Reliability reliability,
        TrustControls trustControls) {

    public record Metric(
            long numerator,
            long denominator,
            BigDecimal rate) {
    }

    public record Reliability(
            long recordSaved,
            long recordSavedSubjects,
            long recordSaveFailed,
            long recordSaveFailedSubjects,
            Metric recordSaveSuccess,
            long recordSaveSuccessSubjects,
            Metric recoveredRetry,
            long recoveredRetrySubjects,
            Map<String, DistributionCell> reflectionOutcomes,
            Map<String, DistributionCell> reflectionLatencyBuckets) {
    }

    public record DistributionCell(
            long events,
            long subjects) {
    }

    public record TrustControls(
            Metric aiContextDisabledSubjects,
            Metric memoryDeletionSubjects,
            Metric dataExportDemand,
            Metric accountDeletionDemand) {
    }
}
