package ai.zeroon.evidence;

import ai.zeroon.auth.RateLimitExceededException;
import ai.zeroon.evidence.EvidenceDtos.EvidenceEventExport;
import ai.zeroon.evidence.EvidenceDtos.EvidenceEventRequest;
import ai.zeroon.evidence.EvidenceDtos.EvidenceEventResponse;
import ai.zeroon.evidence.EvidenceDtos.EvidencePreferenceExport;
import ai.zeroon.evidence.EvidenceDtos.EvidencePreferenceRequest;
import ai.zeroon.evidence.EvidenceDtos.EvidencePreferenceResponse;
import ai.zeroon.evidence.EvidenceEnums.EventName;
import ai.zeroon.evidence.EvidenceEnums.Outcome;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.HexFormat;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class EvidenceService {

    private static final ZoneId EVIDENCE_ZONE = ZoneId.of("Asia/Shanghai");
    private static final int MAX_QUEUED_EVENT_AGE_DAYS = 7;

    private static final Map<EventName, EventSpec> EVENT_SPECS = java.util.stream.Stream.of(
            spec(EventName.AUTH_COMPLETED,
                    required("accountType", "platform", "appVersion")),
            spec(EventName.ZEROON_ENCOUNTER_VIEWED,
                    required("entrySource", "appVersion")),
            spec(EventName.ZEROON_ENCOUNTER_COMPLETED,
                    required("durationBucket", "retryCountBucket")),
            spec(EventName.STATE_STARTED,
                    required("state", "source")),
            spec(EventName.RESET_STARTED,
                    required("entrySource", "activeStatePresent")),
            spec(EventName.RECORD_SAVED,
                    required("state", "hasGoal", "hasContent", "latencyBucket", "retryCountBucket")),
            spec(EventName.RECORD_SAVE_FAILED,
                    required("errorClass", "retryable", "networkStatus")),
            spec(EventName.ARCHIVE_VIEWED,
                    required("entrySource", "itemCountBucket")),
            spec(EventName.RECORD_DETAIL_VIEWED,
                    required("recordAgeBucket", "sourceType")),
            spec(EventName.REFLECTION_REQUESTED,
                    required("surface", "contextClasses")),
            spec(EventName.REFLECTION_COMPLETED,
                    required("outcome", "latencyBucket", "promptVersion", "modelAlias")),
            spec(EventName.MEMORY_CONTROL_CHANGED,
                    required("action", "sourceType")),
            spec(EventName.PROFILE_AI_CONTEXT_CHANGED,
                    required("enabled", "surface")),
            spec(EventName.DATA_EXPORT_REQUESTED,
                    required("surface", "outcome")),
            new EventSpec(
                    EventName.ACCOUNT_DELETE_REQUESTED,
                    Set.of("surface", "outcome", "reasonCategory"),
                    Set.of("surface", "outcome")))
            .collect(java.util.stream.Collectors.toUnmodifiableMap(
                    EventSpec::eventName,
                    java.util.function.Function.identity()));

    private final UserRepository userRepository;
    private final EvidenceSubjectRepository subjectRepository;
    private final EvidenceEventRepository eventRepository;
    private final Clock clock;
    private final boolean ingestionAvailable;
    private final String noticeVersion;
    private final int hourlyLimit;

    public EvidenceService(
            UserRepository userRepository,
            EvidenceSubjectRepository subjectRepository,
            EvidenceEventRepository eventRepository,
            Clock clock,
            @Value("${zeroon.evidence.ingestion-enabled:false}") boolean ingestionAvailable,
            @Value("${zeroon.evidence.notice-version:beta-evidence-v1}") String noticeVersion,
            @Value("${zeroon.evidence.event-hourly-limit:200}") int hourlyLimit) {
        if (noticeVersion == null || !noticeVersion.matches("^[A-Za-z0-9._-]{1,40}$")) {
            throw new IllegalArgumentException("Evidence notice version is invalid");
        }
        if (hourlyLimit < 1) {
            throw new IllegalArgumentException("Evidence hourly limit must be positive");
        }
        this.userRepository = userRepository;
        this.subjectRepository = subjectRepository;
        this.eventRepository = eventRepository;
        this.clock = clock;
        this.ingestionAvailable = ingestionAvailable;
        this.noticeVersion = noticeVersion;
        this.hourlyLimit = hourlyLimit;
    }

    @Transactional(readOnly = true)
    public EvidencePreferenceResponse preference(Long userId) {
        requireUser(userId);
        return subjectRepository.findByUser_Id(userId)
                .map(this::toPreference)
                .orElseGet(() -> new EvidencePreferenceResponse(
                        ingestionAvailable, false, noticeVersion, null, null));
    }

    @Transactional
    public EvidencePreferenceResponse updatePreference(
            Long userId,
            EvidencePreferenceRequest request) {
        if (!noticeVersion.equals(request.noticeVersion())) {
            throw new IllegalArgumentException("Evidence notice version is not current");
        }
        Instant now = clock.instant();
        EvidenceSubjectEntity subject = subjectRepository.findByUserIdForUpdate(userId)
                .orElseGet(() -> new EvidenceSubjectEntity(
                        requireUser(userId),
                        UUID.randomUUID(),
                        request.enabled(),
                        request.noticeVersion(),
                        now));
        if (subject.getId() == null) {
            subjectRepository.save(subject);
        } else {
            subject.changeCollectionChoice(request.enabled(), request.noticeVersion(), now);
        }
        return toPreference(subject);
    }

    @Transactional
    public IngestResult ingest(Long userId, EvidenceEventRequest request) {
        validateContract(request);
        EvidenceSubjectEntity subject = subjectRepository.findByUserIdForUpdate(userId)
                .orElse(null);
        if (!ingestionAvailable || subject == null || !subject.isCollectionEnabled()) {
            return new IngestResult(
                    new EvidenceEventResponse(
                            false, false, request.getClientEventId(), request.getEventName()),
                    false);
        }

        String fingerprint = fingerprint(request);
        EvidenceEventEntity existing = eventRepository
                .findBySubject_IdAndClientEventId(subject.getId(), request.getClientEventId())
                .orElse(null);
        if (existing != null) {
            if (!existing.getEventFingerprint().equals(fingerprint)) {
                throw new EvidenceConflictException(
                        "Client event id was already used with different evidence");
            }
            return new IngestResult(
                    new EvidenceEventResponse(
                            true, true, existing.getClientEventId(), existing.getEventName()),
                    false);
        }

        Instant now = clock.instant();
        long recent = eventRepository.countBySubject_IdAndReceivedAtAfter(
                subject.getId(), now.minus(Duration.ofHours(1)));
        if (recent >= hourlyLimit) {
            throw new RateLimitExceededException(
                    "evidence_event_rate_limited",
                    "Evidence event limit reached",
                    3600);
        }

        eventRepository.save(new EvidenceEventEntity(subject, request, fingerprint, now));
        return new IngestResult(
                new EvidenceEventResponse(
                        true, false, request.getClientEventId(), request.getEventName()),
                true);
    }

    @Transactional(readOnly = true)
    public EvidencePreferenceExport preferenceExport(Long userId) {
        return subjectRepository.findByUser_Id(userId)
                .map(subject -> new EvidencePreferenceExport(
                        subject.isCollectionEnabled(),
                        subject.getAcceptedNoticeVersion(),
                        subject.getChoiceChangedAt()))
                .orElseGet(() -> new EvidencePreferenceExport(false, null, null));
    }

    @Transactional(readOnly = true)
    public List<EvidenceEventExport> eventExports(Long userId) {
        return subjectRepository.findByUser_Id(userId)
                .map(subject -> eventRepository
                        .findBySubject_IdOrderByOccurredDateAscReceivedAtAsc(subject.getId())
                        .stream()
                        .map(event -> new EvidenceEventExport(
                                event.getEventName(),
                                event.getSchemaVersion(),
                                event.getOccurredDate(),
                                event.exportProperties()))
                        .toList())
                .orElseGet(List::of);
    }

    private EvidencePreferenceResponse toPreference(EvidenceSubjectEntity subject) {
        return new EvidencePreferenceResponse(
                ingestionAvailable,
                subject.isCollectionEnabled(),
                noticeVersion,
                subject.getAcceptedNoticeVersion(),
                subject.getChoiceChangedAt());
    }

    private UserEntity requireUser(Long userId) {
        return userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
    }

    private void validateContract(EvidenceEventRequest request) {
        EventSpec spec = EVENT_SPECS.get(request.getEventName());
        if (spec == null) {
            throw new IllegalArgumentException("Unsupported evidence event");
        }
        Set<String> provided = request.providedPropertyNames();
        if (!spec.allowed().containsAll(provided)) {
            throw new IllegalArgumentException("Evidence event contains properties not allowed for its type");
        }
        if (!provided.containsAll(spec.required())) {
            throw new IllegalArgumentException("Evidence event is missing required properties");
        }

        LocalDate today = LocalDate.now(clock.withZone(EVIDENCE_ZONE));
        if (request.getOccurredDate().isBefore(today.minusDays(MAX_QUEUED_EVENT_AGE_DAYS))
                || request.getOccurredDate().isAfter(today.plusDays(1))) {
            throw new IllegalArgumentException("Evidence occurrence date is outside the accepted window");
        }

        if (request.getEventName() == EventName.REFLECTION_COMPLETED
                && !Set.of(Outcome.SUCCESS, Outcome.FALLBACK, Outcome.REFUSAL, Outcome.FAILED)
                        .contains(request.getOutcome())) {
            throw new IllegalArgumentException("Reflection outcome is not allowed");
        }
        if ((request.getEventName() == EventName.DATA_EXPORT_REQUESTED
                        || request.getEventName() == EventName.ACCOUNT_DELETE_REQUESTED)
                && !Set.of(Outcome.STARTED, Outcome.COMPLETED, Outcome.FAILED, Outcome.CANCELLED)
                        .contains(request.getOutcome())) {
            throw new IllegalArgumentException("Data-control outcome is not allowed");
        }
    }

    private String fingerprint(EvidenceEventRequest request) {
        Map<String, Object> values = approvedValues(request);
        StringBuilder canonical = new StringBuilder()
                .append(request.getEventName()).append('|')
                .append(request.getSchemaVersion()).append('|')
                .append(request.getOccurredDate());
        values.forEach((key, value) -> canonical
                .append('|')
                .append(key)
                .append('=')
                .append(value));
        try {
            return HexFormat.of().formatHex(MessageDigest.getInstance("SHA-256")
                    .digest(canonical.toString().getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException ex) {
            throw new IllegalStateException("SHA-256 is unavailable", ex);
        }
    }

    private Map<String, Object> approvedValues(EvidenceEventRequest request) {
        Map<String, Object> values = new TreeMap<>();
        put(values, "accountType", request.getAccountType());
        put(values, "platform", request.getPlatform());
        put(values, "appVersion", request.getAppVersion());
        put(values, "entrySource", request.getEntrySource());
        put(values, "durationBucket", request.getDurationBucket());
        put(values, "retryCountBucket", request.getRetryCountBucket());
        put(values, "state", request.getState());
        put(values, "source", request.getSource());
        put(values, "activeStatePresent", request.getActiveStatePresent());
        put(values, "hasGoal", request.getHasGoal());
        put(values, "hasContent", request.getHasContent());
        put(values, "latencyBucket", request.getLatencyBucket());
        put(values, "errorClass", request.getErrorClass());
        put(values, "retryable", request.getRetryable());
        put(values, "networkStatus", request.getNetworkStatus());
        put(values, "itemCountBucket", request.getItemCountBucket());
        put(values, "recordAgeBucket", request.getRecordAgeBucket());
        put(values, "sourceType", request.getSourceType());
        put(values, "surface", request.getSurface());
        if (request.getContextClasses() != null) {
            values.put("contextClasses", request.normalizedContextClasses().stream()
                    .map(Enum::name)
                    .sorted()
                    .toList());
        }
        put(values, "outcome", request.getOutcome());
        put(values, "promptVersion", request.getPromptVersion());
        put(values, "modelAlias", request.getModelAlias());
        put(values, "action", request.getAction());
        put(values, "enabled", request.getEnabled());
        put(values, "reasonCategory", request.getReasonCategory());
        return new LinkedHashMap<>(values);
    }

    private static void put(Map<String, Object> values, String name, Object value) {
        if (value != null) {
            values.put(name, value instanceof Enum<?> enumValue ? enumValue.name() : value);
        }
    }

    private static EventSpec spec(EventName eventName, Set<String> properties) {
        return new EventSpec(eventName, properties, properties);
    }

    private static Set<String> required(String... properties) {
        return Set.of(properties);
    }

    public record IngestResult(EvidenceEventResponse response, boolean created) {
    }

    private record EventSpec(
            EventName eventName,
            Set<String> allowed,
            Set<String> required) {
    }
}
