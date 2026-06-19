package ai.zeroon.ai;

import ai.zeroon.companion.ConversationEntity;
import ai.zeroon.prompt.PromptTemplateSelection;
import ai.zeroon.user.UserEntity;
import org.springframework.stereotype.Service;

@Service
public class AiUsageLogService {

    private final AiUsageLogRepository aiUsageLogRepository;

    public AiUsageLogService(AiUsageLogRepository aiUsageLogRepository) {
        this.aiUsageLogRepository = aiUsageLogRepository;
    }

    public void logSuccess(
            UserEntity user,
            ConversationEntity conversation,
            LlmResponse response,
            PromptTemplateSelection prompt,
            int inputChars,
            long durationMs) {
        aiUsageLogRepository.save(new AiUsageLogEntity(
                user,
                conversation,
                response.provider(),
                response.model(),
                "COMPANION_REFLECTION",
                AiUsageOutcome.SUCCESS,
                false,
                safeDuration(durationMs),
                prompt.code(),
                prompt.version(),
                Math.max(inputChars, 0),
                safeLength(response.content()),
                null));
    }

    public void logFallback(
            UserEntity user,
            ConversationEntity conversation,
            PromptTemplateSelection prompt,
            int inputChars,
            int outputChars,
            long durationMs,
            String errorCode) {
        aiUsageLogRepository.save(new AiUsageLogEntity(
                user,
                conversation,
                "openai-compatible",
                null,
                "COMPANION_REFLECTION",
                AiUsageOutcome.FALLBACK,
                true,
                safeDuration(durationMs),
                prompt.code(),
                prompt.version(),
                Math.max(inputChars, 0),
                Math.max(outputChars, 0),
                errorCode));
    }

    public void logRefusal(
            UserEntity user,
            ConversationEntity conversation,
            String safetyLabel,
            int inputChars,
            int outputChars,
            long durationMs) {
        aiUsageLogRepository.save(new AiUsageLogEntity(
                user,
                conversation,
                "safety-boundary",
                null,
                "COMPANION_REFLECTION",
                AiUsageOutcome.REFUSAL,
                true,
                safeDuration(durationMs),
                null,
                null,
                Math.max(inputChars, 0),
                Math.max(outputChars, 0),
                safetyLabel));
    }

    private int safeDuration(long durationMs) {
        if (durationMs > Integer.MAX_VALUE) {
            return Integer.MAX_VALUE;
        }
        return (int) Math.max(durationMs, 0);
    }

    private int safeLength(String value) {
        return value == null ? 0 : value.length();
    }
}
