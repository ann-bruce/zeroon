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
@Table(name = "state_history")
public class StateHistoryEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(name = "previous_state", length = 20)
    @Enumerated(EnumType.STRING)
    private UserState previousState;

    @Column(name = "current_state", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private UserState currentState;

    @Column(nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private StateSource source;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    protected StateHistoryEntity() {
    }

    public StateHistoryEntity(
            UserEntity user,
            UserState previousState,
            UserState currentState,
            StateSource source) {
        this.user = user;
        this.previousState = previousState;
        this.currentState = currentState;
        this.source = source;
    }

    public StateHistoryEntity(
            UserEntity user,
            UserState previousState,
            UserState currentState,
            StateSource source,
            Instant createdAt) {
        this(user, previousState, currentState, source);
        this.createdAt = createdAt;
    }

    public UserState getCurrentState() {
        return currentState;
    }

    public StateSource getSource() {
        return source;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
