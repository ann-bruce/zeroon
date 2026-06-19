package ai.zeroon.companion;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public final class CompanionDtos {

    private CompanionDtos() {
    }

    public record ChatRequest(
            Long conversationId,
            @NotBlank @Size(max = 4000) String message) {
    }

    public record ChatResponse(
            Long conversationId,
            Long messageId,
            String reply,
            String safetyNotice) {
    }
}
