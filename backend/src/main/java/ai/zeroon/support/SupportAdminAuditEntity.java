package ai.zeroon.support;

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
@Table(name = "support_admin_audit")
public class SupportAdminAuditEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "request_id", nullable = false)
    private SupportRequestEntity request;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_user_id")
    private UserEntity actorUser;

    @Enumerated(EnumType.STRING)
    @Column(name = "action_type", nullable = false, length = 30)
    private SupportAdminAuditAction actionType;

    @Column(name = "from_value", length = 100)
    private String fromValue;

    @Column(name = "to_value", length = 100)
    private String toValue;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "message_id")
    private SupportMessageEntity message;

    @Column(name = "reason_code", nullable = false, length = 40)
    private String reasonCode;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected SupportAdminAuditEntity() {
    }

    public SupportAdminAuditEntity(
            SupportRequestEntity request,
            UserEntity actorUser,
            SupportAdminAuditAction actionType,
            String fromValue,
            String toValue,
            SupportMessageEntity message,
            String reasonCode,
            Instant createdAt) {
        this.request = request;
        this.actorUser = actorUser;
        this.actionType = actionType;
        this.fromValue = fromValue;
        this.toValue = toValue;
        this.message = message;
        this.reasonCode = reasonCode;
        this.createdAt = createdAt;
    }

    public SupportAdminAuditAction getActionType() {
        return actionType;
    }

    public String getActorUid() {
        return actorUser == null ? null : actorUser.getUid();
    }

    public String getFromValue() {
        return fromValue;
    }

    public String getToValue() {
        return toValue;
    }

    public Long getMessageId() {
        return message == null ? null : message.getId();
    }

    public String getReasonCode() {
        return reasonCode;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
