package ai.zeroon.evidence;

import ai.zeroon.evidence.EvidenceCohortReport.Metric;
import ai.zeroon.evidence.EvidenceCohortReport.Reliability;
import ai.zeroon.evidence.EvidenceCohortReport.TrustControls;
import ai.zeroon.evidence.EvidenceCohortReport.DistributionCell;
import ai.zeroon.evidence.EvidenceEnums.EventName;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.function.Predicate;
import java.util.stream.Collectors;

final class EvidenceCohortCalculator {

    static final String ACTIVATION_COVERAGE = "FULL_REVIEWED_EVENT_COVERAGE";

    private static final Set<EventName> RETURN_ACTIVITY = EnumSet.of(
            EventName.STATE_STARTED,
            EventName.RESET_STARTED,
            EventName.RECORD_SAVED,
            EventName.RECORD_SAVE_FAILED,
            EventName.ARCHIVE_VIEWED,
            EventName.RECORD_DETAIL_VIEWED,
            EventName.REFLECTION_REQUESTED,
            EventName.REFLECTION_COMPLETED,
            EventName.MEMORY_CONTROL_CHANGED,
            EventName.PROFILE_AI_CONTEXT_CHANGED,
            EventName.PROFILE_AI_CONTEXT_CONTROL_VIEWED);

    EvidenceCohortReport calculate(
            List<Observation> observations,
            LocalDate cohortStart,
            LocalDate cohortEnd,
            LocalDate asOfDate) {
        validateWindow(cohortStart, cohortEnd, asOfDate);
        Map<Long, List<Observation>> bySubject = observations.stream()
                .filter(observation -> !observation.occurredDate().isAfter(asOfDate))
                .collect(Collectors.groupingBy(
                        Observation::subjectId,
                        HashMap::new,
                        Collectors.toCollection(ArrayList::new)));
        bySubject.values().forEach(events ->
                events.sort(java.util.Comparator.comparing(Observation::occurredDate)));

        Map<Long, SubjectEvidence> cohort = new LinkedHashMap<>();
        bySubject.forEach((subjectId, events) -> {
            LocalDate firstAuth = firstDate(events, EventName.AUTH_COMPLETED);
            if (firstAuth != null
                    && !firstAuth.isBefore(cohortStart)
                    && !firstAuth.isAfter(cohortEnd)) {
                cohort.put(subjectId, new SubjectEvidence(events, activationDate(events)));
            }
        });

        List<SubjectEvidence> activated = cohort.values().stream()
                .filter(subject -> subject.activationDate() != null)
                .toList();
        Metric activation = metric(activated.size(), cohort.size());
        Metric d1 = retention(activated, asOfDate, 1);
        Metric d7 = retention(activated, asOfDate, 7);
        Metric d30 = retention(activated, asOfDate, 30);
        Metric weekTwo = weekTwoRecord(activated, asOfDate);

        LocalDate weekStart = asOfDate.minusDays(6);
        List<SubjectEvidence> weeklyActive = cohort.values().stream()
                .filter(subject -> subject.hasEventBetween(
                        weekStart, asOfDate, event -> RETURN_ACTIVITY.contains(event.eventName())))
                .toList();
        Metric continuity = metric(
                weeklyActive.stream().filter(subject -> subject.hasEventBetween(
                        weekStart, asOfDate, EvidenceCohortCalculator::isContinuityReview)).count(),
                weeklyActive.size());
        Metric chatOnly = metric(
                weeklyActive.stream().filter(subject -> isChatOnly(subject, weekStart, asOfDate)).count(),
                weeklyActive.size());

        long resetSubjects = cohort.values().stream()
                .filter(subject -> subject.hasEvent(EventName.RESET_STARTED))
                .count();
        long savedSubjects = cohort.values().stream()
                .filter(subject -> subject.hasEvent(EventName.RESET_STARTED)
                        && subject.hasEvent(EventName.RECORD_SAVED))
                .count();

        List<Observation> cohortEvents = cohort.values().stream()
                .flatMap(subject -> subject.events().stream())
                .toList();
        long saved = count(cohortEvents, event -> event.eventName() == EventName.RECORD_SAVED);
        long failed = count(cohortEvents, event -> event.eventName() == EventName.RECORD_SAVE_FAILED);
        long recovered = count(cohortEvents, event -> event.eventName() == EventName.RECORD_SAVED
                && event.retryCountBucket() != null
                && !"ZERO".equals(event.retryCountBucket()));
        long savedEventSubjects = distinctSubjects(
                cohortEvents, event -> event.eventName() == EventName.RECORD_SAVED);
        long failedEventSubjects = distinctSubjects(
                cohortEvents, event -> event.eventName() == EventName.RECORD_SAVE_FAILED);
        long saveAttemptSubjects = distinctSubjects(
                cohortEvents,
                event -> event.eventName() == EventName.RECORD_SAVED
                        || event.eventName() == EventName.RECORD_SAVE_FAILED);
        long recoveredSubjects = distinctSubjects(
                cohortEvents,
                event -> event.eventName() == EventName.RECORD_SAVED
                        && event.retryCountBucket() != null
                        && !"ZERO".equals(event.retryCountBucket()));

        Reliability reliability = new Reliability(
                saved,
                savedEventSubjects,
                failed,
                failedEventSubjects,
                metric(saved, saved + failed),
                saveAttemptSubjects,
                metric(recovered, saved),
                recoveredSubjects,
                distribution(cohortEvents, EventName.REFLECTION_COMPLETED, Observation::outcome),
                distribution(cohortEvents, EventName.REFLECTION_COMPLETED, Observation::latencyBucket));
        TrustControls trustControls = new TrustControls(
                subjectMetric(cohort, EvidenceCohortCalculator::disabledAiContext),
                subjectMetric(cohort, event -> event.eventName() == EventName.MEMORY_CONTROL_CHANGED
                        && "DELETE".equals(event.action())),
                subjectMetric(cohort, event -> event.eventName() == EventName.DATA_EXPORT_REQUESTED
                        && "STARTED".equals(event.outcome())),
                subjectMetric(cohort, event -> event.eventName() == EventName.ACCOUNT_DELETE_REQUESTED
                        && "STARTED".equals(event.outcome())));

        return new EvidenceCohortReport(
                cohortStart,
                cohortEnd,
                asOfDate,
                ACTIVATION_COVERAGE,
                cohort.size(),
                activation,
                d1,
                d7,
                d30,
                weekTwo,
                continuity,
                chatOnly,
                metric(savedSubjects, resetSubjects),
                reliability,
                trustControls);
    }

    private Metric retention(List<SubjectEvidence> activated, LocalDate asOfDate, int day) {
        List<SubjectEvidence> matured = activated.stream()
                .filter(subject -> !subject.activationDate().plusDays(day).isAfter(asOfDate))
                .toList();
        long returned = matured.stream()
                .filter(subject -> subject.hasEventOn(
                        subject.activationDate().plusDays(day),
                        event -> RETURN_ACTIVITY.contains(event.eventName())))
                .count();
        return metric(returned, matured.size());
    }

    private Metric weekTwoRecord(List<SubjectEvidence> activated, LocalDate asOfDate) {
        List<SubjectEvidence> matured = activated.stream()
                .filter(subject -> !subject.activationDate().plusDays(13).isAfter(asOfDate))
                .toList();
        long recorded = matured.stream()
                .filter(subject -> subject.hasEventBetween(
                        subject.activationDate().plusDays(7),
                        subject.activationDate().plusDays(13),
                        event -> event.eventName() == EventName.RECORD_SAVED))
                .count();
        return metric(recorded, matured.size());
    }

    private Metric subjectMetric(
            Map<Long, SubjectEvidence> cohort,
            Predicate<Observation> predicate) {
        long subjects = cohort.values().stream()
                .filter(subject -> subject.events().stream().anyMatch(predicate))
                .count();
        return metric(subjects, cohort.size());
    }

    private static boolean disabledAiContext(Observation event) {
        return (event.eventName() == EventName.PROFILE_AI_CONTEXT_CHANGED
                        && Boolean.FALSE.equals(event.enabled()))
                || (event.eventName() == EventName.MEMORY_CONTROL_CHANGED
                        && Set.of("DISABLE", "DISALLOW_AI").contains(event.action()));
    }

    private static boolean isContinuityReview(Observation event) {
        return event.eventName() == EventName.ARCHIVE_VIEWED
                || event.eventName() == EventName.RECORD_DETAIL_VIEWED
                || (event.eventName() == EventName.REFLECTION_REQUESTED
                        && Set.of("ARCHIVE", "RECORD_DETAIL").contains(event.surface()));
    }

    private static boolean isChatOnly(
            SubjectEvidence subject,
            LocalDate from,
            LocalDate to) {
        boolean chat = subject.hasEventBetween(
                from,
                to,
                event -> event.eventName() == EventName.REFLECTION_REQUESTED
                        && "COMPANION".equals(event.surface()));
        boolean core = subject.hasEventBetween(from, to, event ->
                Set.of(
                                EventName.STATE_STARTED,
                                EventName.RESET_STARTED,
                                EventName.RECORD_SAVED,
                                EventName.ARCHIVE_VIEWED,
                                EventName.RECORD_DETAIL_VIEWED)
                        .contains(event.eventName())
                        || isContinuityReview(event));
        return chat && !core;
    }

    private static LocalDate activationDate(List<Observation> events) {
        List<LocalDate> milestones = java.util.Arrays.asList(
                firstDate(events, EventName.AUTH_COMPLETED),
                firstDate(events, EventName.ZEROON_ENCOUNTER_COMPLETED),
                firstDate(events, EventName.STATE_STARTED),
                firstDate(events, EventName.RECORD_SAVED),
                firstDate(events, event -> event.eventName() == EventName.ARCHIVE_VIEWED
                        || event.eventName() == EventName.RECORD_DETAIL_VIEWED),
                firstDate(events, EventName.PROFILE_AI_CONTEXT_CONTROL_VIEWED));
        if (milestones.stream().anyMatch(java.util.Objects::isNull)) {
            return null;
        }
        return milestones.stream().max(LocalDate::compareTo).orElseThrow();
    }

    private static LocalDate firstDate(List<Observation> events, EventName eventName) {
        return firstDate(events, event -> event.eventName() == eventName);
    }

    private static LocalDate firstDate(
            List<Observation> events,
            Predicate<Observation> predicate) {
        return events.stream()
                .filter(predicate)
                .map(Observation::occurredDate)
                .min(LocalDate::compareTo)
                .orElse(null);
    }

    private static long count(
            List<Observation> events,
            Predicate<Observation> predicate) {
        return events.stream().filter(predicate).count();
    }

    private static long distinctSubjects(
            List<Observation> events,
            Predicate<Observation> predicate) {
        return events.stream()
                .filter(predicate)
                .map(Observation::subjectId)
                .distinct()
                .count();
    }

    private static Map<String, DistributionCell> distribution(
            List<Observation> events,
            EventName eventName,
            java.util.function.Function<Observation, String> classifier) {
        return events.stream()
                .filter(event -> event.eventName() == eventName)
                .filter(event -> classifier.apply(event) != null)
                .collect(Collectors.groupingBy(
                        classifier,
                        java.util.TreeMap::new,
                        Collectors.collectingAndThen(
                                Collectors.toList(),
                                cell -> new DistributionCell(
                                        cell.size(),
                                        cell.stream()
                                                .map(Observation::subjectId)
                                                .distinct()
                                                .count()))));
    }

    static Metric metric(long numerator, long denominator) {
        return new Metric(
                numerator,
                denominator,
                denominator == 0
                        ? null
                        : BigDecimal.valueOf(numerator)
                                .divide(BigDecimal.valueOf(denominator), 4, RoundingMode.HALF_UP));
    }

    private static void validateWindow(
            LocalDate cohortStart,
            LocalDate cohortEnd,
            LocalDate asOfDate) {
        if (cohortStart == null || cohortEnd == null || asOfDate == null) {
            throw new IllegalArgumentException("Cohort dates are required");
        }
        if (cohortStart.isAfter(cohortEnd) || cohortEnd.isAfter(asOfDate)) {
            throw new IllegalArgumentException("Cohort window is invalid");
        }
    }

    record Observation(
            long subjectId,
            EventName eventName,
            LocalDate occurredDate,
            String retryCountBucket,
            String latencyBucket,
            String surface,
            String outcome,
            String action,
            Boolean enabled) {
    }

    private record SubjectEvidence(
            List<Observation> events,
            LocalDate activationDate) {

        boolean hasEvent(EventName eventName) {
            return events.stream().anyMatch(event -> event.eventName() == eventName);
        }

        boolean hasEventOn(LocalDate date, Predicate<Observation> predicate) {
            return events.stream()
                    .anyMatch(event -> event.occurredDate().equals(date) && predicate.test(event));
        }

        boolean hasEventBetween(
                LocalDate from,
                LocalDate to,
                Predicate<Observation> predicate) {
            return events.stream().anyMatch(event ->
                    !event.occurredDate().isBefore(from)
                            && !event.occurredDate().isAfter(to)
                            && predicate.test(event));
        }
    }
}
