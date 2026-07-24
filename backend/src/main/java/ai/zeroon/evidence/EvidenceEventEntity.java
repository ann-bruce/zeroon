package ai.zeroon.evidence;

import ai.zeroon.evidence.EvidenceDtos.EvidenceEventRequest;
import ai.zeroon.evidence.EvidenceEnums.ContextClass;
import ai.zeroon.evidence.EvidenceEnums.EventName;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.time.LocalDate;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

@Entity
@Table(name = "evidence_events")
public class EvidenceEventEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "subject_id", nullable = false)
    private EvidenceSubjectEntity subject;

    @Column(name = "client_event_id", nullable = false)
    private UUID clientEventId;

    @Enumerated(EnumType.STRING)
    @Column(name = "event_name", nullable = false, length = 40)
    private EventName eventName;

    @Column(name = "schema_version", nullable = false)
    private int schemaVersion;

    @Column(name = "occurred_date", nullable = false)
    private LocalDate occurredDate;

    @Column(name = "event_fingerprint", nullable = false, length = 64)
    private String eventFingerprint;

    @Column(name = "account_type", length = 20)
    private String accountType;

    @Column(length = 20)
    private String platform;

    @Column(name = "app_version", length = 40)
    private String appVersion;

    @Column(name = "entry_source", length = 30)
    private String entrySource;

    @Column(name = "duration_bucket", length = 30)
    private String durationBucket;

    @Column(name = "retry_count_bucket", length = 20)
    private String retryCountBucket;

    @Column(length = 20)
    private String state;

    @Column(length = 20)
    private String source;

    @Column(name = "active_state_present")
    private Boolean activeStatePresent;

    @Column(name = "has_goal")
    private Boolean hasGoal;

    @Column(name = "has_content")
    private Boolean hasContent;

    @Column(name = "latency_bucket", length = 30)
    private String latencyBucket;

    @Column(name = "error_class", length = 30)
    private String errorClass;

    private Boolean retryable;

    @Column(name = "network_status", length = 20)
    private String networkStatus;

    @Column(name = "item_count_bucket", length = 30)
    private String itemCountBucket;

    @Column(name = "record_age_bucket", length = 30)
    private String recordAgeBucket;

    @Column(name = "source_type", length = 30)
    private String sourceType;

    @Column(length = 30)
    private String surface;

    @Column(name = "context_class_mask")
    private Integer contextClassMask;

    @Column(length = 20)
    private String outcome;

    @Column(name = "prompt_version", length = 40)
    private String promptVersion;

    @Column(name = "model_alias", length = 40)
    private String modelAlias;

    @Column(length = 30)
    private String action;

    private Boolean enabled;

    @Column(name = "reason_category", length = 30)
    private String reasonCategory;

    @Column(name = "received_at", nullable = false)
    private Instant receivedAt;

    protected EvidenceEventEntity() {
    }

    public EvidenceEventEntity(
            EvidenceSubjectEntity subject,
            EvidenceEventRequest request,
            String eventFingerprint,
            Instant receivedAt) {
        this.subject = subject;
        clientEventId = request.getClientEventId();
        eventName = request.getEventName();
        schemaVersion = request.getSchemaVersion();
        occurredDate = request.getOccurredDate();
        this.eventFingerprint = eventFingerprint;
        accountType = name(request.getAccountType());
        platform = name(request.getPlatform());
        appVersion = request.getAppVersion();
        entrySource = name(request.getEntrySource());
        durationBucket = name(request.getDurationBucket());
        retryCountBucket = name(request.getRetryCountBucket());
        state = name(request.getState());
        source = name(request.getSource());
        activeStatePresent = request.getActiveStatePresent();
        hasGoal = request.getHasGoal();
        hasContent = request.getHasContent();
        latencyBucket = name(request.getLatencyBucket());
        errorClass = name(request.getErrorClass());
        retryable = request.getRetryable();
        networkStatus = name(request.getNetworkStatus());
        itemCountBucket = name(request.getItemCountBucket());
        recordAgeBucket = name(request.getRecordAgeBucket());
        sourceType = name(request.getSourceType());
        surface = name(request.getSurface());
        contextClassMask = request.getContextClasses() == null
                ? null
                : request.contextClassMask();
        outcome = name(request.getOutcome());
        promptVersion = request.getPromptVersion();
        modelAlias = request.getModelAlias();
        action = name(request.getAction());
        enabled = request.getEnabled();
        reasonCategory = name(request.getReasonCategory());
        this.receivedAt = receivedAt;
    }

    public UUID getClientEventId() {
        return clientEventId;
    }

    public EventName getEventName() {
        return eventName;
    }

    public Long getSubjectId() {
        return subject.getId();
    }

    public int getSchemaVersion() {
        return schemaVersion;
    }

    public LocalDate getOccurredDate() {
        return occurredDate;
    }

    public String getEventFingerprint() {
        return eventFingerprint;
    }

    String getRetryCountBucket() {
        return retryCountBucket;
    }

    String getLatencyBucket() {
        return latencyBucket;
    }

    String getSurface() {
        return surface;
    }

    String getOutcome() {
        return outcome;
    }

    String getAction() {
        return action;
    }

    Boolean getEnabled() {
        return enabled;
    }

    public Map<String, Object> exportProperties() {
        Map<String, Object> properties = new LinkedHashMap<>();
        put(properties, "accountType", accountType);
        put(properties, "platform", platform);
        put(properties, "appVersion", appVersion);
        put(properties, "entrySource", entrySource);
        put(properties, "durationBucket", durationBucket);
        put(properties, "retryCountBucket", retryCountBucket);
        put(properties, "state", state);
        put(properties, "source", source);
        put(properties, "activeStatePresent", activeStatePresent);
        put(properties, "hasGoal", hasGoal);
        put(properties, "hasContent", hasContent);
        put(properties, "latencyBucket", latencyBucket);
        put(properties, "errorClass", errorClass);
        put(properties, "retryable", retryable);
        put(properties, "networkStatus", networkStatus);
        put(properties, "itemCountBucket", itemCountBucket);
        put(properties, "recordAgeBucket", recordAgeBucket);
        put(properties, "sourceType", sourceType);
        put(properties, "surface", surface);
        if (contextClassMask != null) {
            properties.put("contextClasses", java.util.Arrays.stream(ContextClass.values())
                    .filter(value -> (contextClassMask & (1 << value.ordinal())) != 0)
                    .map(Enum::name)
                    .toList());
        }
        put(properties, "outcome", outcome);
        put(properties, "promptVersion", promptVersion);
        put(properties, "modelAlias", modelAlias);
        put(properties, "action", action);
        put(properties, "enabled", enabled);
        put(properties, "reasonCategory", reasonCategory);
        return Map.copyOf(properties);
    }

    private static String name(Enum<?> value) {
        return value == null ? null : value.name();
    }

    private static void put(Map<String, Object> properties, String name, Object value) {
        if (value != null) {
            properties.put(name, value);
        }
    }
}
