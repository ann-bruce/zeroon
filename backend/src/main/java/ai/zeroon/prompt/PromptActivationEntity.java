package ai.zeroon.prompt;

import ai.zeroon.user.UserEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "prompt_activations")
public class PromptActivationEntity {

    @Id
    @Column(length = 100)
    private String code;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "prompt_template_id", nullable = false, unique = true)
    private PromptTemplateEntity promptTemplate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "activated_by")
    private UserEntity activatedBy;

    @Column(name = "activated_at", nullable = false)
    private Instant activatedAt;

    protected PromptActivationEntity() {
    }

    public PromptActivationEntity(
            PromptTemplateEntity promptTemplate,
            UserEntity activatedBy,
            Instant activatedAt) {
        this.code = promptTemplate.getCode();
        this.promptTemplate = promptTemplate;
        this.activatedBy = activatedBy;
        this.activatedAt = activatedAt;
    }

    public PromptTemplateEntity getPromptTemplate() {
        return promptTemplate;
    }

    public void activate(
            PromptTemplateEntity promptTemplate,
            UserEntity activatedBy,
            Instant activatedAt) {
        if (!code.equals(promptTemplate.getCode())) {
            throw new IllegalArgumentException("Prompt activation code mismatch");
        }
        this.promptTemplate = promptTemplate;
        this.activatedBy = activatedBy;
        this.activatedAt = activatedAt;
    }
}
