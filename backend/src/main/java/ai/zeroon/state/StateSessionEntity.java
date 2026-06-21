package ai.zeroon.state;

import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserState;
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
@Table(name = "state_sessions")
public class StateSessionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private UserState state;

    @Column(nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private StateSource source;

    @Column(name = "started_at", nullable = false)
    private Instant startedAt;

    @Column(name = "ended_at")
    private Instant endedAt;

    @Column(name = "ended_by_record_id")
    private Long endedByRecordId;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    protected StateSessionEntity() {
    }

    public StateSessionEntity(UserEntity user, UserState state, StateSource source, Instant startedAt) {
        this.user = user;
        this.state = state;
        this.source = source;
        this.startedAt = startedAt;
    }

    public Long getId() {
        return id;
    }

    public UserEntity getUser() {
        return user;
    }

    public UserState getState() {
        return state;
    }

    public StateSource getSource() {
        return source;
    }

    public Instant getStartedAt() {
        return startedAt;
    }

    public Instant getEndedAt() {
        return endedAt;
    }

    public Long getEndedByRecordId() {
        return endedByRecordId;
    }

    public void end(Instant endedAt, Long endedByRecordId) {
        this.endedAt = endedAt;
        this.endedByRecordId = endedByRecordId;
        this.updatedAt = endedAt;
    }
}
