package ai.zeroon.evidence;

public final class EvidenceEnums {

    private EvidenceEnums() {
    }

    public enum EventName {
        AUTH_COMPLETED,
        ZEROON_ENCOUNTER_VIEWED,
        ZEROON_ENCOUNTER_COMPLETED,
        STATE_STARTED,
        RESET_STARTED,
        RECORD_SAVED,
        RECORD_SAVE_FAILED,
        ARCHIVE_VIEWED,
        RECORD_DETAIL_VIEWED,
        REFLECTION_REQUESTED,
        REFLECTION_COMPLETED,
        MEMORY_CONTROL_CHANGED,
        PROFILE_AI_CONTEXT_CHANGED,
        PROFILE_AI_CONTEXT_CONTROL_VIEWED,
        DATA_EXPORT_REQUESTED,
        ACCOUNT_DELETE_REQUESTED
    }

    public enum AccountType {
        NEW,
        EXISTING
    }

    public enum Platform {
        IOS,
        ANDROID,
        WEB,
        UNKNOWN
    }

    public enum EntrySource {
        LOGIN,
        NOW,
        RESET,
        ARCHIVE,
        RECORD_DETAIL,
        SETTINGS,
        PROFILE,
        COMPANION,
        UNKNOWN
    }

    public enum DurationBucket {
        UNDER_10_SECONDS,
        FROM_10_TO_29_SECONDS,
        FROM_30_TO_59_SECONDS,
        FROM_1_TO_2_MINUTES,
        OVER_2_MINUTES
    }

    public enum RetryCountBucket {
        ZERO,
        ONE,
        TWO_OR_MORE
    }

    public enum LatencyBucket {
        UNDER_500_MS,
        FROM_500_TO_1499_MS,
        FROM_1500_TO_4999_MS,
        FROM_5_TO_14_SECONDS,
        OVER_15_SECONDS
    }

    public enum ErrorClass {
        NETWORK,
        TIMEOUT,
        VALIDATION,
        AUTHORIZATION,
        CONFLICT,
        SERVER,
        UNKNOWN
    }

    public enum NetworkStatus {
        ONLINE,
        OFFLINE,
        TIMEOUT,
        UNKNOWN
    }

    public enum ItemCountBucket {
        EMPTY,
        ONE,
        TWO_TO_FIVE,
        SIX_TO_TWENTY,
        OVER_TWENTY
    }

    public enum RecordAgeBucket {
        SAME_DAY,
        ONE_TO_SIX_DAYS,
        ONE_TO_FOUR_WEEKS,
        OVER_FOUR_WEEKS
    }

    public enum SourceType {
        ZERO_RECORD,
        MEMORY
    }

    public enum Surface {
        LOGIN,
        NOW,
        RESET,
        ARCHIVE,
        RECORD_DETAIL,
        SETTINGS,
        PROFILE,
        COMPANION,
        DATA_CONTROL
    }

    public enum ContextClass {
        PROFILE,
        MEMORY
    }

    public enum Outcome {
        STARTED,
        COMPLETED,
        SUCCESS,
        FALLBACK,
        REFUSAL,
        FAILED,
        CANCELLED
    }

    public enum MemoryControlAction {
        ENABLE,
        DISABLE,
        ALLOW_AI,
        DISALLOW_AI,
        DELETE
    }

    public enum DataControlReason {
        NO_LONGER_NEEDED,
        PRIVACY_CONCERN,
        NOT_USEFUL,
        TOO_DIFFICULT,
        OTHER,
        PREFER_NOT_TO_SAY
    }
}
