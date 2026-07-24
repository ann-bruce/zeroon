package ai.zeroon.evidence;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Map;

public final class EvidenceOperationsDtos {

    public static final int MINIMUM_COHORT_SIZE = 5;

    private EvidenceOperationsDtos() {
    }

    public record EvidenceOperationsResponse(
            LocalDate cohortStart,
            LocalDate cohortEnd,
            LocalDate asOfDate,
            int minimumCohortSize,
            boolean suppressed,
            String activationCoverage,
            Integer authenticatedSubjects,
            MetricCell activation,
            MetricCell dayOneRetention,
            MetricCell daySevenRetention,
            MetricCell dayThirtyRetention,
            MetricCell weekTwoRecord,
            MetricCell currentWeekContinuityReview,
            MetricCell currentWeekChatOnly,
            MetricCell recordFlowCompletion,
            ReliabilityView reliability,
            TrustControlsView trustControls,
            String interpretationNotice) {
    }

    public record MetricCell(
            boolean suppressed,
            Long numerator,
            Long denominator,
            BigDecimal rate) {
    }

    public record CountCell(
            boolean suppressed,
            Long events,
            Long subjects) {
    }

    public record DistributionCell(
            boolean suppressed,
            Long events,
            Long subjects) {
    }

    public record ReliabilityView(
            CountCell recordSaved,
            CountCell recordSaveFailed,
            MetricCell recordSaveSuccess,
            MetricCell recoveredRetry,
            Map<String, DistributionCell> reflectionOutcomes,
            Map<String, DistributionCell> reflectionLatencyBuckets) {
    }

    public record TrustControlsView(
            MetricCell aiContextDisabledSubjects,
            MetricCell memoryDeletionSubjects,
            MetricCell dataExportDemand,
            MetricCell accountDeletionDemand) {
    }
}
