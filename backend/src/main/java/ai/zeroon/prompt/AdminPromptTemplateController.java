package ai.zeroon.prompt;

import ai.zeroon.prompt.PromptTemplateDtos.PromptTemplateDetailResponse;
import ai.zeroon.prompt.PromptTemplateDtos.PromptTemplateListResponse;
import ai.zeroon.prompt.PromptTemplateDtos.PromptTemplateSummaryResponse;
import jakarta.persistence.EntityNotFoundException;
import java.util.List;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/prompts")
public class AdminPromptTemplateController {

    private final PromptTemplateRepository promptTemplateRepository;

    public AdminPromptTemplateController(PromptTemplateRepository promptTemplateRepository) {
        this.promptTemplateRepository = promptTemplateRepository;
    }

    @GetMapping
    public PromptTemplateListResponse listPrompts() {
        List<PromptTemplateSummaryResponse> items = promptTemplateRepository
                .findAllByOrderByCodeAscVersionDesc()
                .stream()
                .map(PromptTemplateSummaryResponse::from)
                .toList();
        return new PromptTemplateListResponse(items);
    }

    @GetMapping("/{promptId}")
    public PromptTemplateDetailResponse getPrompt(@PathVariable Long promptId) {
        return promptTemplateRepository.findById(promptId)
                .map(PromptTemplateDetailResponse::from)
                .orElseThrow(() -> new EntityNotFoundException("Prompt template not found"));
    }
}
