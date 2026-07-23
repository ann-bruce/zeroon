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
@Table(name = "support_messages")
public class SupportMessageEntity {

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
    @Column(name = "actor_type", nullable = false, length = 20)
    private SupportActorType actorType;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private SupportMessageVisibility visibility;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String body;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected SupportMessageEntity() {
    }

    public SupportMessageEntity(
            SupportRequestEntity request,
            UserEntity actorUser,
            SupportActorType actorType,
            SupportMessageVisibility visibility,
            String body,
            Instant createdAt) {
        this.request = request;
        this.actorUser = actorUser;
        this.actorType = actorType;
        this.visibility = visibility;
        this.body = body;
        this.createdAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public SupportActorType getActorType() {
        return actorType;
    }

    public String getActorUid() {
        return actorUser == null ? null : actorUser.getUid();
    }

    public SupportMessageVisibility getVisibility() {
        return visibility;
    }

    public String getBody() {
        return body;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
