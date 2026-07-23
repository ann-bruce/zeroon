package ai.zeroon.companion;

import ai.zeroon.ai.LlmProvider;
import ai.zeroon.ai.LlmProviderUnavailableException;
import ai.zeroon.ai.LlmRequest;
import ai.zeroon.ai.LlmResponse;
import ai.zeroon.ai.AiUsageDetails;
import ai.zeroon.ai.AiUsageOutcome;
import ai.zeroon.companion.CompanionDtos.ChatResponse;
import ai.zeroon.companion.CompanionTurnPersistenceService.AssembledUserPrompt;
import ai.zeroon.companion.CompanionTurnPersistenceService.StartedTurn;
import ai.zeroon.prompt.PromptTemplateSelection;
import ai.zeroon.prompt.PromptTemplateService;
import java.time.Duration;
import org.springframework.stereotype.Service;

@Service
public class CompanionService {

    private final LlmProvider llmProvider;
    private final PromptTemplateService promptTemplateService;
    private final SafetyBoundaryService safetyBoundaryService;
    private final CompanionTurnPersistenceService turnPersistenceService;
    private final CompanionLanguageResolver languageResolver;

    public CompanionService(
            LlmProvider llmProvider,
            PromptTemplateService promptTemplateService,
            SafetyBoundaryService safetyBoundaryService,
            CompanionTurnPersistenceService turnPersistenceService,
            CompanionLanguageResolver languageResolver) {
        this.llmProvider = llmProvider;
        this.promptTemplateService = promptTemplateService;
        this.safetyBoundaryService = safetyBoundaryService;
        this.turnPersistenceService = turnPersistenceService;
        this.languageResolver = languageResolver;
    }

    public ChatResponse sendMessage(
            Long userId, Long conversationId, String message, String acceptLanguage) {
        String normalizedMessage = message.trim();
        CompanionLanguage language = languageResolver.resolve(userId, acceptLanguage);
        StartedTurn turn = turnPersistenceService.begin(userId, conversationId, normalizedMessage);
        long startedAt = System.nanoTime();
        SafetyBoundaryResult boundary = safetyBoundaryService.evaluate(normalizedMessage, language);
        if (boundary.blocked()) {
            return turnPersistenceService.complete(
                    turn,
                    boundary.reply(),
                    language.safetyNotice(),
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
                            boundary.label()),
                    AssembledUserPrompt.none());
        }

        PromptTemplateSelection prompt = promptTemplateService.companionReflectionPrompt();
        AssembledUserPrompt assembledPrompt =
                turnPersistenceService.assembleUserPrompt(userId, normalizedMessage);
        String userPrompt = assembledPrompt.prompt();
        String systemPrompt = prompt.content().stripTrailing()
                + "\n\n"
                + language.providerInstruction().strip();
        long providerStartedAt = System.nanoTime();
        try {
            LlmResponse response = llmProvider.generate(new LlmRequest(
                    systemPrompt,
                    userPrompt,
                    Duration.ofSeconds(8)));
            return turnPersistenceService.complete(
                    turn,
                    response.content(),
                    language.safetyNotice(),
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
                            null),
                    assembledPrompt);
        } catch (LlmProviderUnavailableException ex) {
            return turnPersistenceService.complete(
                    turn,
                    language.fallbackReply(),
                    language.safetyNotice(),
                    new AiUsageDetails(
                            "openai-compatible",
                            null,
                            AiUsageOutcome.FALLBACK,
                            true,
                            elapsedMillis(providerStartedAt),
                            prompt.code(),
                            prompt.version(),
                            userPrompt.length(),
                            language.fallbackReply().length(),
                            null,
                            null,
                            ex.getClass().getSimpleName()),
                    assembledPrompt);
        }
    }

    private long elapsedMillis(long startedAt) {
        return (System.nanoTime() - startedAt) / 1_000_000;
    }

    private int safeLength(String value) {
        return value == null ? 0 : value.length();
    }
}
