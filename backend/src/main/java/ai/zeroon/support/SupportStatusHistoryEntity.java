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
@Table(name = "support_status_history")
public class SupportStatusHistoryEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "request_id", nullable = false)
    private SupportRequestEntity request;

    @Enumerated(EnumType.STRING)
    @Column(name = "from_status", length = 30)
    private SupportRequestStatus fromStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "to_status", nullable = false, length = 30)
    private SupportRequestStatus toStatus;

    @Enumerated(EnumType.STRING)
    @Column(name = "actor_type", nullable = false, length = 20)
    private SupportActorType actorType;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actor_user_id")
    private UserEntity actorUser;

    @Column(name = "reason_code", nullable = false, length = 40)
    private String reasonCode;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected SupportStatusHistoryEntity() {
    }

    public SupportStatusHistoryEntity(
            SupportRequestEntity request,
            SupportRequestStatus fromStatus,
            SupportRequestStatus toStatus,
            SupportActorType actorType,
            UserEntity actorUser,
            String reasonCode,
            Instant createdAt) {
        this.request = request;
        this.fromStatus = fromStatus;
        this.toStatus = toStatus;
        this.actorType = actorType;
        this.actorUser = actorUser;
        this.reasonCode = reasonCode;
        this.createdAt = createdAt;
    }

    public SupportRequestStatus getFromStatus() {
        return fromStatus;
    }

    public SupportRequestStatus getToStatus() {
        return toStatus;
    }

    public SupportActorType getActorType() {
        return actorType;
    }

    public String getActorUid() {
        return actorUser == null ? null : actorUser.getUid();
    }

    public String getReasonCode() {
        return reasonCode;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
