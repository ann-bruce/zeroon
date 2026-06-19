package ai.zeroon.record;

import ai.zeroon.user.UserState;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;

public final class RecordDtos {

    private RecordDtos() {
    }

    public record CreateRecordRequest(
            @NotNull UserState state,
            @Size(max = 200) String mood,
            @Size(max = 1000) String goal,
            @Size(max = 5000) String content) {

        @AssertTrue(message = "At least one of mood, goal, or content is required")
        public boolean hasRecordContent() {
            return hasText(mood) || hasText(goal) || hasText(content);
        }
    }

    public record ZeroRecord(
            Long id,
            UserState state,
            String mood,
            String goal,
            String content,
            String aiSummary,
            Instant createdAt) {
    }

    public record RecordPage(
            List<ZeroRecord> items,
            int page,
            int size,
            long totalElements) {
    }

    private static boolean hasText(String value) {
        return value != null && !value.isBlank();
    }
}
