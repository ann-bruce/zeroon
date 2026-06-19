package ai.zeroon.prompt;

public record PromptTemplateSelection(
        String code,
        String content,
        Integer version,
        boolean fallback) {
}
