package ai.zeroon.user;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "users")
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 32)
    private String uid;

    @Column(unique = true, length = 20)
    private String mobile;

    @Column(name = "current_state", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private UserState currentState = UserState.CALM;

    @Column(nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private UserStatus status = UserStatus.ACTIVE;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    protected UserEntity() {
    }

    public UserEntity(String uid, String mobile) {
        this.uid = uid;
        this.mobile = mobile;
    }

    public Long getId() {
        return id;
    }

    public String getUid() {
        return uid;
    }

    public String getMobile() {
        return mobile;
    }

    public UserState getCurrentState() {
        return currentState;
    }

    public UserStatus getStatus() {
        return status;
    }

    public void changeState(UserState state) {
        this.currentState = state;
        this.updatedAt = Instant.now();
    }
}
