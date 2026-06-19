package ai.zeroon.ai;

import jakarta.validation.constraints.NotBlank;
import java.time.Duration;

public record LlmRequest(
        @NotBlank String systemPrompt,
        @NotBlank String userPrompt,
        Duration timeout) {
}
