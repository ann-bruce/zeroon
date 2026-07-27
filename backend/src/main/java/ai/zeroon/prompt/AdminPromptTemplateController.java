package ai.zeroon.prompt;

import ai.zeroon.prompt.PromptTemplateDtos.PromptActivationRequest;
import ai.zeroon.prompt.PromptTemplateDtos.PromptCreateRequest;
import ai.zeroon.prompt.PromptTemplateDtos.PromptEvaluationRequest;
import ai.zeroon.prompt.PromptTemplateDtos.PromptReviewRequest;
import ai.zeroon.prompt.PromptTemplateDtos.PromptTemplateDetailResponse;
import ai.zeroon.prompt.PromptTemplateDtos.PromptTemplateListResponse;
import ai.zeroon.security.UserPrincipal;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1/admin/prompts")
public class AdminPromptTemplateController {

    private final PromptGovernanceService promptGovernanceService;

    public AdminPromptTemplateController(PromptGovernanceService promptGovernanceService) {
        this.promptGovernanceService = promptGovernanceService;
    }

    @GetMapping
    PromptTemplateListResponse listPrompts() {
        return promptGovernanceService.list();
    }

    @GetMapping("/{promptId}")
    PromptTemplateDetailResponse getPrompt(@PathVariable Long promptId) {
        return promptGovernanceService.get(promptId);
    }

    @PostMapping
    ResponseEntity<PromptTemplateDetailResponse> createPrompt(
            @AuthenticationPrincipal UserPrincipal principal,
            @Valid @RequestBody PromptCreateRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(promptGovernanceService.create(principal.userId(), request));
    }

    @PostMapping("/{promptId}/review")
    PromptTemplateDetailResponse reviewPrompt(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long promptId,
            @Valid @RequestBody PromptReviewRequest request) {
        return promptGovernanceService.review(principal.userId(), promptId, request);
    }

    @PostMapping("/{promptId}/activate")
    PromptTemplateDetailResponse activatePrompt(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long promptId,
            @Valid @RequestBody PromptActivationRequest request) {
        return promptGovernanceService.activate(principal.userId(), promptId, request);
    }

    @PostMapping("/{promptId}/evaluations")
    PromptTemplateDetailResponse recordEvaluation(
            @AuthenticationPrincipal UserPrincipal principal,
            @PathVariable Long promptId,
            @Valid @RequestBody PromptEvaluationRequest request) {
        return promptGovernanceService.recordEvaluation(
                principal.userId(), promptId, request);
    }
}
