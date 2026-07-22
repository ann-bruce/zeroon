package ai.zeroon.ai;

public record AiUsageDetails(
        String provider,
        String model,
        AiUsageOutcome outcome,
        boolean fallbackUsed,
        long durationMs,
        String promptTemplateCode,
        Integer promptTemplateVersion,
        int inputChars,
        int outputChars,
        Integer inputTokens,
        Integer outputTokens,
        String errorCode) {
}
