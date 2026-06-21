package ai.zeroon.record;

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
@Table(name = "zero_records")
public class ZeroRecordEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private UserState state;

    @Column(columnDefinition = "TEXT")
    private String goal;

    @Column(columnDefinition = "TEXT")
    private String content;

    @Column(name = "ai_summary", columnDefinition = "TEXT")
    private String aiSummary;

    @Column(name = "state_session_id")
    private Long stateSessionId;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    protected ZeroRecordEntity() {
    }

    public ZeroRecordEntity(UserEntity user, UserState state, String goal, String content, Long stateSessionId) {
        this.user = user;
        this.state = state;
        this.goal = goal;
        this.content = content;
        this.stateSessionId = stateSessionId;
    }

    public ZeroRecordEntity(UserEntity user, UserState state, String goal, String content) {
        this(user, state, goal, content, (Long) null);
    }

    public ZeroRecordEntity(
            UserEntity user,
            UserState state,
            String goal,
            String content,
            Instant createdAt) {
        this(user, state, goal, content);
        this.createdAt = createdAt;
        this.updatedAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public UserState getState() {
        return state;
    }

    public String getGoal() {
        return goal;
    }

    public String getContent() {
        return content;
    }

    public String getAiSummary() {
        return aiSummary;
    }

    public Long getStateSessionId() {
        return stateSessionId;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }
}
