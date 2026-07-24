package ai.zeroon.evidence;

import ai.zeroon.evidence.EvidenceCohortReport.Metric;
import ai.zeroon.evidence.EvidenceOperationsDtos.CountCell;
import ai.zeroon.evidence.EvidenceOperationsDtos.DistributionCell;
import ai.zeroon.evidence.EvidenceOperationsDtos.EvidenceOperationsResponse;
import ai.zeroon.evidence.EvidenceOperationsDtos.MetricCell;
import ai.zeroon.evidence.EvidenceOperationsDtos.ReliabilityView;
import ai.zeroon.evidence.EvidenceOperationsDtos.TrustControlsView;
import java.time.LocalDate;
import java.util.Map;
import java.util.TreeMap;
import org.springframework.stereotype.Service;

@Service
public class EvidenceOperationsService {

    static final String INTERPRETATION_NOTICE =
            "Retained-event loss, disabled collection, and incomplete maturity constrain interpretation.";

    private final EvidenceCohortService cohortService;

    public EvidenceOperationsService(EvidenceCohortService cohortService) {
        this.cohortService = cohortService;
    }

    public EvidenceOperationsResponse read(
            LocalDate cohortStart,
            LocalDate cohortEnd,
            LocalDate asOfDate) {
        EvidenceCohortReport report = cohortService.calculate(cohortStart, cohortEnd, asOfDate);
        if (report.authenticatedSubjects() < EvidenceOperationsDtos.MINIMUM_COHORT_SIZE) {
            return new EvidenceOperationsResponse(
                    cohortStart,
                    cohortEnd,
                    asOfDate,
                    EvidenceOperationsDtos.MINIMUM_COHORT_SIZE,
                    true,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    null,
                    INTERPRETATION_NOTICE);
        }

        var reliability = report.reliability();
        var trust = report.trustControls();
        return new EvidenceOperationsResponse(
                report.cohortStart(),
                report.cohortEnd(),
                report.asOfDate(),
                EvidenceOperationsDtos.MINIMUM_COHORT_SIZE,
                false,
                report.activationCoverage(),
                report.authenticatedSubjects(),
                metric(report.activation()),
                metric(report.dayOneRetention()),
                metric(report.daySevenRetention()),
                metric(report.dayThirtyRetention()),
                metric(report.weekTwoRecord()),
                metric(report.currentWeekContinuityReview()),
                metric(report.currentWeekChatOnly()),
                metric(report.recordFlowCompletion()),
                new ReliabilityView(
                        count(reliability.recordSaved(), reliability.recordSavedSubjects()),
                        count(reliability.recordSaveFailed(), reliability.recordSaveFailedSubjects()),
                        metric(reliability.recordSaveSuccess(), reliability.recordSaveSuccessSubjects()),
                        metric(reliability.recoveredRetry(), reliability.recoveredRetrySubjects()),
                        distributions(reliability.reflectionOutcomes()),
                        distributions(reliability.reflectionLatencyBuckets())),
                new TrustControlsView(
                        metric(trust.aiContextDisabledSubjects()),
                        metric(trust.memoryDeletionSubjects()),
                        metric(trust.dataExportDemand()),
                        metric(trust.accountDeletionDemand())),
                INTERPRETATION_NOTICE);
    }

    private static MetricCell metric(Metric metric) {
        return metric(metric, metric.denominator());
    }

    private static MetricCell metric(Metric metric, long distinctSubjectPopulation) {
        boolean suppressed = distinctSubjectPopulation < EvidenceOperationsDtos.MINIMUM_COHORT_SIZE
                || (metric.numerator() > 0
                        && metric.numerator() < EvidenceOperationsDtos.MINIMUM_COHORT_SIZE);
        return suppressed
                ? new MetricCell(true, null, null, null)
                : new MetricCell(false, metric.numerator(), metric.denominator(), metric.rate());
    }

    private static CountCell count(long events, long subjects) {
        boolean suppressed = subjects < EvidenceOperationsDtos.MINIMUM_COHORT_SIZE;
        return suppressed
                ? new CountCell(true, null, null)
                : new CountCell(false, events, subjects);
    }

    private static Map<String, DistributionCell> distributions(
            Map<String, EvidenceCohortReport.DistributionCell> source) {
        Map<String, DistributionCell> result = new TreeMap<>();
        source.forEach((name, cell) -> {
            boolean suppressed = cell.subjects() < EvidenceOperationsDtos.MINIMUM_COHORT_SIZE;
            result.put(
                    name,
                    suppressed
                            ? new DistributionCell(true, null, null)
                            : new DistributionCell(false, cell.events(), cell.subjects()));
        });
        return Map.copyOf(result);
    }
}
