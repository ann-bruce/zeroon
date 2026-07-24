package ai.zeroon.evidence;

import ai.zeroon.evidence.EvidenceEnums.AccountType;
import ai.zeroon.evidence.EvidenceEnums.ContextClass;
import ai.zeroon.evidence.EvidenceEnums.DataControlReason;
import ai.zeroon.evidence.EvidenceEnums.DurationBucket;
import ai.zeroon.evidence.EvidenceEnums.EntrySource;
import ai.zeroon.evidence.EvidenceEnums.ErrorClass;
import ai.zeroon.evidence.EvidenceEnums.EventName;
import ai.zeroon.evidence.EvidenceEnums.ItemCountBucket;
import ai.zeroon.evidence.EvidenceEnums.LatencyBucket;
import ai.zeroon.evidence.EvidenceEnums.MemoryControlAction;
import ai.zeroon.evidence.EvidenceEnums.NetworkStatus;
import ai.zeroon.evidence.EvidenceEnums.Outcome;
import ai.zeroon.evidence.EvidenceEnums.Platform;
import ai.zeroon.evidence.EvidenceEnums.RecordAgeBucket;
import ai.zeroon.evidence.EvidenceEnums.RetryCountBucket;
import ai.zeroon.evidence.EvidenceEnums.SourceType;
import ai.zeroon.evidence.EvidenceEnums.Surface;
import ai.zeroon.state.StateSource;
import ai.zeroon.user.UserState;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.time.LocalDate;
import java.util.EnumSet;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Set;
import java.util.UUID;

public final class EvidenceDtos {

    private EvidenceDtos() {
    }

    public record EvidencePreferenceRequest(
            @NotNull Boolean enabled,
            @NotNull Boolean adultConfirmed,
            @NotNull @Pattern(regexp = "^[A-Za-z0-9._-]{1,40}$") String noticeVersion) {

        @JsonAnySetter
        void rejectUnknown(String name, Object value) {
            throw new IllegalArgumentException("Unknown evidence preference property: " + name);
        }
    }

    public record EvidencePreferenceResponse(
            boolean available,
            boolean enabled,
            boolean adultConfirmed,
            String requiredNoticeVersion,
            String acceptedNoticeVersion,
            Instant choiceChangedAt) {
    }

    public static final class EvidenceEventRequest {

        @NotNull
        private UUID clientEventId;

        @NotNull
        private EventName eventName;

        @NotNull
        @Min(1)
        @Max(1)
        private Integer schemaVersion;

        @NotNull
        private LocalDate occurredDate;

        private AccountType accountType;
        private Platform platform;

        @Size(max = 40)
        @Pattern(regexp = "^[A-Za-z0-9._+-]+$")
        private String appVersion;

        private EntrySource entrySource;
        private DurationBucket durationBucket;
        private RetryCountBucket retryCountBucket;
        private UserState state;
        private StateSource source;
        private Boolean activeStatePresent;
        private Boolean hasGoal;
        private Boolean hasContent;
        private LatencyBucket latencyBucket;
        private ErrorClass errorClass;
        private Boolean retryable;
        private NetworkStatus networkStatus;
        private ItemCountBucket itemCountBucket;
        private RecordAgeBucket recordAgeBucket;
        private SourceType sourceType;
        private Surface surface;

        @Size(max = 2)
        private Set<ContextClass> contextClasses;

        private Outcome outcome;

        @Size(max = 40)
        @Pattern(regexp = "^[A-Za-z0-9._:-]+$")
        private String promptVersion;

        @Size(max = 40)
        @Pattern(regexp = "^[A-Za-z0-9._:-]+$")
        private String modelAlias;

        private MemoryControlAction action;
        private Boolean enabled;
        private DataControlReason reasonCategory;

        @JsonIgnore
        private final Map<String, Object> unknownProperties = new LinkedHashMap<>();

        @JsonAnySetter
        void captureUnknown(String name, Object value) {
            unknownProperties.put(name, value);
        }

        @AssertTrue(message = "Unknown evidence event properties are not allowed")
        @JsonIgnore
        public boolean isAllowlisted() {
            return unknownProperties.isEmpty();
        }

        @JsonIgnore
        public Set<String> providedPropertyNames() {
            Set<String> names = new java.util.HashSet<>();
            add(names, "accountType", accountType);
            add(names, "platform", platform);
            add(names, "appVersion", appVersion);
            add(names, "entrySource", entrySource);
            add(names, "durationBucket", durationBucket);
            add(names, "retryCountBucket", retryCountBucket);
            add(names, "state", state);
            add(names, "source", source);
            add(names, "activeStatePresent", activeStatePresent);
            add(names, "hasGoal", hasGoal);
            add(names, "hasContent", hasContent);
            add(names, "latencyBucket", latencyBucket);
            add(names, "errorClass", errorClass);
            add(names, "retryable", retryable);
            add(names, "networkStatus", networkStatus);
            add(names, "itemCountBucket", itemCountBucket);
            add(names, "recordAgeBucket", recordAgeBucket);
            add(names, "sourceType", sourceType);
            add(names, "surface", surface);
            add(names, "contextClasses", contextClasses);
            add(names, "outcome", outcome);
            add(names, "promptVersion", promptVersion);
            add(names, "modelAlias", modelAlias);
            add(names, "action", action);
            add(names, "enabled", enabled);
            add(names, "reasonCategory", reasonCategory);
            return Set.copyOf(names);
        }

        @JsonIgnore
        public int contextClassMask() {
            if (contextClasses == null) {
                return 0;
            }
            int mask = 0;
            for (ContextClass contextClass : contextClasses) {
                mask |= 1 << contextClass.ordinal();
            }
            return mask;
        }

        @JsonIgnore
        public Set<ContextClass> normalizedContextClasses() {
            return contextClasses == null || contextClasses.isEmpty()
                    ? Set.of()
                    : Set.copyOf(EnumSet.copyOf(contextClasses));
        }

        private static void add(Set<String> names, String name, Object value) {
            if (value != null) {
                names.add(name);
            }
        }

        public UUID getClientEventId() {
            return clientEventId;
        }

        public void setClientEventId(UUID clientEventId) {
            this.clientEventId = clientEventId;
        }

        public EventName getEventName() {
            return eventName;
        }

        public void setEventName(EventName eventName) {
            this.eventName = eventName;
        }

        public Integer getSchemaVersion() {
            return schemaVersion;
        }

        public void setSchemaVersion(Integer schemaVersion) {
            this.schemaVersion = schemaVersion;
        }

        public LocalDate getOccurredDate() {
            return occurredDate;
        }

        public void setOccurredDate(LocalDate occurredDate) {
            this.occurredDate = occurredDate;
        }

        public AccountType getAccountType() {
            return accountType;
        }

        public void setAccountType(AccountType accountType) {
            this.accountType = accountType;
        }

        public Platform getPlatform() {
            return platform;
        }

        public void setPlatform(Platform platform) {
            this.platform = platform;
        }

        public String getAppVersion() {
            return appVersion;
        }

        public void setAppVersion(String appVersion) {
            this.appVersion = appVersion;
        }

        public EntrySource getEntrySource() {
            return entrySource;
        }

        public void setEntrySource(EntrySource entrySource) {
            this.entrySource = entrySource;
        }

        public DurationBucket getDurationBucket() {
            return durationBucket;
        }

        public void setDurationBucket(DurationBucket durationBucket) {
            this.durationBucket = durationBucket;
        }

        public RetryCountBucket getRetryCountBucket() {
            return retryCountBucket;
        }

        public void setRetryCountBucket(RetryCountBucket retryCountBucket) {
            this.retryCountBucket = retryCountBucket;
        }

        public UserState getState() {
            return state;
        }

        public void setState(UserState state) {
            this.state = state;
        }

        public StateSource getSource() {
            return source;
        }

        public void setSource(StateSource source) {
            this.source = source;
        }

        public Boolean getActiveStatePresent() {
            return activeStatePresent;
        }

        public void setActiveStatePresent(Boolean activeStatePresent) {
            this.activeStatePresent = activeStatePresent;
        }

        public Boolean getHasGoal() {
            return hasGoal;
        }

        public void setHasGoal(Boolean hasGoal) {
            this.hasGoal = hasGoal;
        }

        public Boolean getHasContent() {
            return hasContent;
        }

        public void setHasContent(Boolean hasContent) {
            this.hasContent = hasContent;
        }

        public LatencyBucket getLatencyBucket() {
            return latencyBucket;
        }

        public void setLatencyBucket(LatencyBucket latencyBucket) {
            this.latencyBucket = latencyBucket;
        }

        public ErrorClass getErrorClass() {
            return errorClass;
        }

        public void setErrorClass(ErrorClass errorClass) {
            this.errorClass = errorClass;
        }

        public Boolean getRetryable() {
            return retryable;
        }

        public void setRetryable(Boolean retryable) {
            this.retryable = retryable;
        }

        public NetworkStatus getNetworkStatus() {
            return networkStatus;
        }

        public void setNetworkStatus(NetworkStatus networkStatus) {
            this.networkStatus = networkStatus;
        }

        public ItemCountBucket getItemCountBucket() {
            return itemCountBucket;
        }

        public void setItemCountBucket(ItemCountBucket itemCountBucket) {
            this.itemCountBucket = itemCountBucket;
        }

        public RecordAgeBucket getRecordAgeBucket() {
            return recordAgeBucket;
        }

        public void setRecordAgeBucket(RecordAgeBucket recordAgeBucket) {
            this.recordAgeBucket = recordAgeBucket;
        }

        public SourceType getSourceType() {
            return sourceType;
        }

        public void setSourceType(SourceType sourceType) {
            this.sourceType = sourceType;
        }

        public Surface getSurface() {
            return surface;
        }

        public void setSurface(Surface surface) {
            this.surface = surface;
        }

        public Set<ContextClass> getContextClasses() {
            return contextClasses;
        }

        public void setContextClasses(Set<ContextClass> contextClasses) {
            this.contextClasses = contextClasses;
        }

        public Outcome getOutcome() {
            return outcome;
        }

        public void setOutcome(Outcome outcome) {
            this.outcome = outcome;
        }

        public String getPromptVersion() {
            return promptVersion;
        }

        public void setPromptVersion(String promptVersion) {
            this.promptVersion = promptVersion;
        }

        public String getModelAlias() {
            return modelAlias;
        }

        public void setModelAlias(String modelAlias) {
            this.modelAlias = modelAlias;
        }

        public MemoryControlAction getAction() {
            return action;
        }

        public void setAction(MemoryControlAction action) {
            this.action = action;
        }

        public Boolean getEnabled() {
            return enabled;
        }

        public void setEnabled(Boolean enabled) {
            this.enabled = enabled;
        }

        public DataControlReason getReasonCategory() {
            return reasonCategory;
        }

        public void setReasonCategory(DataControlReason reasonCategory) {
            this.reasonCategory = reasonCategory;
        }
    }

    public record EvidenceEventResponse(
            boolean stored,
            boolean duplicate,
            UUID clientEventId,
            EventName eventName) {
    }

    public record EvidencePreferenceExport(
            boolean enabled,
            boolean adultConfirmed,
            String acceptedNoticeVersion,
            Instant choiceChangedAt) {
    }

    public record EvidenceEventExport(
            EventName eventName,
            int schemaVersion,
            LocalDate occurredDate,
            Map<String, Object> properties) {
    }
}
