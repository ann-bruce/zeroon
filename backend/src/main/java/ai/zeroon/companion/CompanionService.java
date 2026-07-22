package ai.zeroon.companion;

import ai.zeroon.ai.LlmProvider;
import ai.zeroon.ai.LlmProviderUnavailableException;
import ai.zeroon.ai.LlmRequest;
import ai.zeroon.ai.LlmResponse;
import ai.zeroon.ai.AiUsageDetails;
import ai.zeroon.ai.AiUsageOutcome;
import ai.zeroon.companion.CompanionDtos.ChatResponse;
import ai.zeroon.companion.CompanionTurnPersistenceService.StartedTurn;
import ai.zeroon.prompt.PromptTemplateSelection;
import ai.zeroon.prompt.PromptTemplateService;
import java.time.Duration;
import org.springframework.stereotype.Service;

@Service
public class CompanionService {

    private static final String SAFETY_NOTICE =
            "ZEROON 只能提供非诊断性的陪伴式反思，不能替代医疗、法律、财务或心理咨询。";
    private static final String FALLBACK_REPLY =
            "你正在把一些还没有完全成形的感受，慢慢放进可以回看的地方。"
                    + "这些记录里已经有了状态、感受和小进展的线索，"
                    + "ZEROON 会先安静保存它们，再陪你一点一点看清楚。";

    private final LlmProvider llmProvider;
    private final PromptTemplateService promptTemplateService;
    private final SafetyBoundaryService safetyBoundaryService;
    private final CompanionTurnPersistenceService turnPersistenceService;

    public CompanionService(
            LlmProvider llmProvider,
            PromptTemplateService promptTemplateService,
            SafetyBoundaryService safetyBoundaryService,
            CompanionTurnPersistenceService turnPersistenceService) {
        this.llmProvider = llmProvider;
        this.promptTemplateService = promptTemplateService;
        this.safetyBoundaryService = safetyBoundaryService;
        this.turnPersistenceService = turnPersistenceService;
    }

    public ChatResponse sendMessage(Long userId, Long conversationId, String message) {
        String normalizedMessage = message.trim();
        StartedTurn turn = turnPersistenceService.begin(userId, conversationId, normalizedMessage);
        long startedAt = System.nanoTime();
        SafetyBoundaryResult boundary = safetyBoundaryService.evaluate(normalizedMessage);
        if (boundary.blocked()) {
            return turnPersistenceService.complete(
                    turn,
                    boundary.reply(),
                    SAFETY_NOTICE,
                    new AiUsageDetails(
                            "safety-boundary",
                            null,
                            AiUsageOutcome.REFUSAL,
                            true,
                            elapsedMillis(startedAt),
                            null,
                            null,
                            normalizedMessage.length(),
                            boundary.reply().length(),
                            null,
                            null,
                            boundary.label()));
        }

        PromptTemplateSelection prompt = promptTemplateService.companionReflectionPrompt();
        String userPrompt = turnPersistenceService.assembleUserPrompt(userId, normalizedMessage);
        long providerStartedAt = System.nanoTime();
        try {
            LlmResponse response = llmProvider.generate(new LlmRequest(
                    prompt.content(),
                    userPrompt,
                    Duration.ofSeconds(8)));
            return turnPersistenceService.complete(
                    turn,
                    response.content(),
                    SAFETY_NOTICE,
                    new AiUsageDetails(
                            response.provider(),
                            response.model(),
                            AiUsageOutcome.SUCCESS,
                            false,
                            elapsedMillis(providerStartedAt),
                            prompt.code(),
                            prompt.version(),
                            userPrompt.length(),
                            safeLength(response.content()),
                            response.inputTokens(),
                            response.outputTokens(),
                            null));
        } catch (LlmProviderUnavailableException ex) {
            return turnPersistenceService.complete(
                    turn,
                    FALLBACK_REPLY,
                    SAFETY_NOTICE,
                    new AiUsageDetails(
                            "openai-compatible",
                            null,
                            AiUsageOutcome.FALLBACK,
                            true,
                            elapsedMillis(providerStartedAt),
                            prompt.code(),
                            prompt.version(),
                            userPrompt.length(),
                            FALLBACK_REPLY.length(),
                            null,
                            null,
                            ex.getClass().getSimpleName()));
        }
    }

    private long elapsedMillis(long startedAt) {
        return (System.nanoTime() - startedAt) / 1_000_000;
    }

    private int safeLength(String value) {
        return value == null ? 0 : value.length();
    }
}
