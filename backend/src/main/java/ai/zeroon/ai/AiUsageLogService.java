package ai.zeroon.ai;

import ai.zeroon.companion.ConversationEntity;
import ai.zeroon.user.UserEntity;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AiUsageLogService {

    private final AiUsageLogRepository aiUsageLogRepository;

    public AiUsageLogService(AiUsageLogRepository aiUsageLogRepository) {
        this.aiUsageLogRepository = aiUsageLogRepository;
    }

    @Transactional(propagation = Propagation.MANDATORY)
    public void record(
            UserEntity user,
            ConversationEntity conversation,
            AiUsageDetails usage) {
        aiUsageLogRepository.save(new AiUsageLogEntity(
                user,
                conversation,
                usage.provider(),
                usage.model(),
                "COMPANION_REFLECTION",
                usage.outcome(),
                usage.fallbackUsed(),
                safeDuration(usage.durationMs()),
                usage.promptTemplateCode(),
                usage.promptTemplateVersion(),
                Math.max(usage.inputChars(), 0),
                Math.max(usage.outputChars(), 0),
                safeTokens(usage.inputTokens()),
                safeTokens(usage.outputTokens()),
                usage.errorCode()));
    }

    private int safeDuration(long durationMs) {
        if (durationMs > Integer.MAX_VALUE) {
            return Integer.MAX_VALUE;
        }
        return (int) Math.max(durationMs, 0);
    }

    private Integer safeTokens(Integer value) {
        return value == null ? null : Math.max(value, 0);
    }
}
