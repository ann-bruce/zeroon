package ai.zeroon.prompt;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.DecimalMax;
import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.math.BigDecimal;
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
            PromptReviewStatus reviewStatus,
            boolean active,
            String createdByUid,
            String reviewedByUid,
            Instant reviewedAt,
            Instant createdAt) {
    }

    public record PromptTemplateDetailResponse(
            Long id,
            String code,
            String name,
            int version,
            boolean enabled,
            PromptReviewStatus reviewStatus,
            boolean active,
            String createdByUid,
            String reviewedByUid,
            Instant reviewedAt,
            Instant createdAt,
            String content,
            PromptEvaluationResponse latestEvaluation,
            List<PromptAuditResponse> audit) {
    }

    public record PromptEvaluationResponse(
            Long id,
            String evaluatorUid,
            String corpusVersion,
            String modelAlias,
            int hardFailureCount,
            int safetyScore,
            int consentScore,
            int privacyScore,
            int minimumDimensionScore,
            BigDecimal averageScore,
            boolean bilingualReviewed,
            String productReviewer,
            String engineeringReviewer,
            String defectCategories,
            boolean passed,
            Instant createdAt) {
    }

    public record PromptAuditResponse(
            PromptAuditAction action,
            String actorUid,
            Integer fromVersion,
            Integer toVersion,
            String reasonCode,
            Instant createdAt) {
    }

    public record PromptCreateRequest(
            @NotBlank
            @Pattern(regexp = "^[A-Z0-9_]{3,100}$")
            String code,
            @NotBlank
            @Size(max = 100)
            String name,
            @NotBlank
            @Size(max = 20000)
            String content,
            @NotBlank
            @Pattern(regexp = "^[A-Z0-9_]{3,60}$")
            String reasonCode) {
    }

    public record PromptReviewRequest(
            @NotNull
            PromptReviewDecision decision,
            @NotBlank
            @Pattern(regexp = "^[A-Z0-9_]{3,60}$")
            String reasonCode) {
    }

    public record PromptActivationRequest(
            @NotBlank
            @Pattern(regexp = "^[A-Z0-9_]{3,60}$")
            String reasonCode) {
    }

    public record PromptEvaluationRequest(
            @NotBlank @Pattern(regexp = "^[A-Z0-9_.-]{2,40}$")
            String corpusVersion,
            @NotBlank @Pattern(regexp = "^[A-Z0-9_.-]{2,40}$")
            String modelAlias,
            @Min(0)
            int hardFailureCount,
            @Min(0) @Max(2)
            int safetyScore,
            @Min(0) @Max(2)
            int consentScore,
            @Min(0) @Max(2)
            int privacyScore,
            @Min(0) @Max(2)
            int minimumDimensionScore,
            @NotNull @DecimalMin("0.00") @DecimalMax("2.00")
            BigDecimal averageScore,
            boolean bilingualReviewed,
            @NotBlank @Size(max = 100)
            String productReviewer,
            @NotBlank @Size(max = 100)
            String engineeringReviewer,
            @Size(max = 500)
            String defectCategories,
            @NotBlank @Pattern(regexp = "^[A-Z0-9_]{3,60}$")
            String reasonCode) {
    }
}
