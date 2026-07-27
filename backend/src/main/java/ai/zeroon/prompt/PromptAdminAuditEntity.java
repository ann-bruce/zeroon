package ai.zeroon.prompt;

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
@Table(name = "prompt_admin_audit")
public class PromptAdminAuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String code;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "prompt_template_id", nullable = false)
    private PromptTemplateEntity promptTemplate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_user_id")
    private UserEntity actorUser;

    @Enumerated(EnumType.STRING)
    @Column(name = "action_type", nullable = false, length = 30)
    private PromptAuditAction actionType;

    @Column(name = "from_version")
    private Integer fromVersion;

    @Column(name = "to_version")
    private Integer toVersion;

    @Column(name = "reason_code", nullable = false, length = 60)
    private String reasonCode;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected PromptAdminAuditEntity() {
    }

    public PromptAdminAuditEntity(
            PromptTemplateEntity promptTemplate,
            UserEntity actorUser,
            PromptAuditAction actionType,
            Integer fromVersion,
            Integer toVersion,
            String reasonCode,
            Instant createdAt) {
        this.code = promptTemplate.getCode();
        this.promptTemplate = promptTemplate;
        this.actorUser = actorUser;
        this.actionType = actionType;
        this.fromVersion = fromVersion;
        this.toVersion = toVersion;
        this.reasonCode = reasonCode;
        this.createdAt = createdAt;
    }

    public PromptAuditAction getActionType() {
        return actionType;
    }

    public String getActorUid() {
        return actorUser == null ? null : actorUser.getUid();
    }

    public Integer getFromVersion() {
        return fromVersion;
    }

    public Integer getToVersion() {
        return toVersion;
    }

    public String getReasonCode() {
        return reasonCode;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
