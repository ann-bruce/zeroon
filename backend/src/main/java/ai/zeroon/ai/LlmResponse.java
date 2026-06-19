package ai.zeroon.ai;

public record LlmResponse(
        String content,
        String provider,
        String model,
        String finishReason) {
}
