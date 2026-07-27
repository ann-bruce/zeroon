package ai.zeroon.companion;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import java.util.List;

public final class CompanionDtos {

    private CompanionDtos() {
    }

    public record ChatRequest(
            Long conversationId,
            CompanionPurpose purpose,
            @NotBlank @Size(max = 4000) String message) {

        public CompanionPurpose resolvedPurpose() {
            return purpose == null ? CompanionPurpose.COMPANION_CHAT : purpose;
        }
    }

    public record ChatResponse(
            Long conversationId,
            Long messageId,
            String reply,
            String safetyNotice,
            String outcome,
            String latencyBucket,
            String promptVersion,
            String modelAlias,
            List<String> contextClasses) {
    }
}
