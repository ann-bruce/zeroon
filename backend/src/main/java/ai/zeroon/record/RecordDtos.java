package ai.zeroon.record;

import ai.zeroon.user.UserState;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;

public final class RecordDtos {

    private RecordDtos() {
    }

    public record CreateRecordRequest(
            UserState state,
            @Size(max = 1000) String goal,
            @Size(max = 5000) String content) {

        @AssertTrue(message = "At least one of goal or content is required")
        public boolean hasRecordContent() {
            return hasText(goal) || hasText(content);
        }
    }

    public record ZeroRecord(
            Long id,
            UserState state,
            String goal,
            String content,
            String aiSummary,
            Long stateSessionId,
            Instant stateStartedAt,
            Instant stateEndedAt,
            Long stateDurationSeconds,
            Instant createdAt) {
    }

    public record RecordPage(
            List<ZeroRecord> items,
            int page,
            int size,
            long totalElements) {
    }

    /**
     * A minimal, user-owned record representation for the optional Now continuity cue.
     * This is selected only by ownership and time; no record text is interpreted or ranked.
     */
    public record ContinuityCue(
            Long recordId,
            UserState state,
            String preview,
            Instant createdAt) {
    }

    public record ContinuityCueResponse(ContinuityCue cue) {
    }

    private static boolean hasText(String value) {
        return value != null && !value.isBlank();
    }
}
