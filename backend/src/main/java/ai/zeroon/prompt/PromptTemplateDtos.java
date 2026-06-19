package ai.zeroon.prompt;

import java.time.Instant;
import java.util.List;

public final class PromptTemplateDtos {

    private PromptTemplateDtos() {
    }

    public record PromptTemplateListResponse(
            List<PromptTemplateSummaryResponse> items) {
    }

    public record PromptTemplateSummaryResponse(
            Long id,
            String code,
            String name,
            int version,
            boolean enabled,
            Instant createdAt) {

        static PromptTemplateSummaryResponse from(PromptTemplateEntity template) {
            return new PromptTemplateSummaryResponse(
                    template.getId(),
                    template.getCode(),
                    template.getName(),
                    template.getVersion(),
                    template.isEnabled(),
                    template.getCreatedAt());
        }
    }

    public record PromptTemplateDetailResponse(
            Long id,
            String code,
            String name,
            int version,
            boolean enabled,
            String content,
            Instant createdAt) {

        static PromptTemplateDetailResponse from(PromptTemplateEntity template) {
            return new PromptTemplateDetailResponse(
                    template.getId(),
                    template.getCode(),
                    template.getName(),
                    template.getVersion(),
                    template.isEnabled(),
                    template.getContent(),
                    template.getCreatedAt());
        }
    }
}
