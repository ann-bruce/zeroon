package ai.zeroon.ai;

import ai.zeroon.companion.ConversationEntity;
import ai.zeroon.user.UserEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "ai_usage_logs")
public class AiUsageLogEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private UserEntity user;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "conversation_id")
    private ConversationEntity conversation;

    @Column(nullable = false, length = 50)
    private String provider;

    @Column(length = 100)
    private String model;

    @Column(nullable = false, length = 50)
    private String operation;

    @Column(nullable = false, length = 30)
    @Enumerated(EnumType.STRING)
    private AiUsageOutcome outcome;

    @Column(name = "fallback_used", nullable = false)
    private boolean fallbackUsed;

    @Column(name = "duration_ms", nullable = false)
    private int durationMs;

    @Column(name = "prompt_template_code", length = 100)
    private String promptTemplateCode;

    @Column(name = "prompt_template_version")
    private Integer promptTemplateVersion;

    @Column(name = "input_chars", nullable = false)
    private int inputChars;

    @Column(name = "output_chars", nullable = false)
    private int outputChars;

    @Column(name = "input_tokens")
    private Integer inputTokens;

    @Column(name = "output_tokens")
    private Integer outputTokens;

    @Column(name = "error_code", length = 100)
    private String errorCode;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    protected AiUsageLogEntity() {
    }

    public AiUsageLogEntity(
            UserEntity user,
            ConversationEntity conversation,
            String provider,
            String model,
            String operation,
            AiUsageOutcome outcome,
            boolean fallbackUsed,
            int durationMs,
            String promptTemplateCode,
            Integer promptTemplateVersion,
            int inputChars,
            int outputChars,
            Integer inputTokens,
            Integer outputTokens,
            String errorCode) {
        this.user = user;
        this.conversation = conversation;
        this.provider = provider;
        this.model = model;
        this.operation = operation;
        this.outcome = outcome;
        this.fallbackUsed = fallbackUsed;
        this.durationMs = durationMs;
        this.promptTemplateCode = promptTemplateCode;
        this.promptTemplateVersion = promptTemplateVersion;
        this.inputChars = inputChars;
        this.outputChars = outputChars;
        this.inputTokens = inputTokens;
        this.outputTokens = outputTokens;
        this.errorCode = errorCode;
    }

    public String getProvider() {
        return provider;
    }

    public AiUsageOutcome getOutcome() {
        return outcome;
    }

    public boolean isFallbackUsed() {
        return fallbackUsed;
    }

    public int getInputChars() {
        return inputChars;
    }

    public int getOutputChars() {
        return outputChars;
    }

    public String getModel() {
        return model;
    }

    public int getDurationMs() {
        return durationMs;
    }

    public String getPromptTemplateCode() {
        return promptTemplateCode;
    }

    public Integer getPromptTemplateVersion() {
        return promptTemplateVersion;
    }

    public Integer getInputTokens() {
        return inputTokens;
    }

    public Integer getOutputTokens() {
        return outputTokens;
    }

    public String getErrorCode() {
        return errorCode;
    }
}
