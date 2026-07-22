package ai.zeroon.ai;

public record LlmResponse(
        String content,
        String provider,
        String model,
        String finishReason,
        Integer inputTokens,
        Integer outputTokens) {

    public LlmResponse(String content, String provider, String model, String finishReason) {
        this(content, provider, model, finishReason, null, null);
    }
}
