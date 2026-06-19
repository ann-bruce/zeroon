package ai.zeroon.prompt;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class PromptTemplateService {

    public static final String COMPANION_REFLECTION_CODE = "COMPANION_REFLECTION";

    private static final String DEFAULT_COMPANION_REFLECTION_PROMPT = """
            You are ZEROON, a long-term companion and private memory system.
            Reply with a short, non-diagnostic reflection.
            Do not infer hidden sensitive traits.
            Do not provide medical, legal, financial, or psychological diagnosis.
            Keep the tone calm and concrete.
            """;

    private final PromptTemplateRepository promptTemplateRepository;

    public PromptTemplateService(PromptTemplateRepository promptTemplateRepository) {
        this.promptTemplateRepository = promptTemplateRepository;
    }

    @Transactional(readOnly = true)
    public PromptTemplateSelection companionReflectionPrompt() {
        return promptTemplateRepository
                .findFirstByCodeAndEnabledTrueOrderByVersionDesc(COMPANION_REFLECTION_CODE)
                .map(template -> new PromptTemplateSelection(
                        template.getCode(),
                        template.getContent(),
                        template.getVersion(),
                        false))
                .orElseGet(() -> new PromptTemplateSelection(
                        COMPANION_REFLECTION_CODE,
                        DEFAULT_COMPANION_REFLECTION_PROMPT,
                        null,
                        true));
    }
}
