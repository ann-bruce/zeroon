package ai.zeroon.user;

import jakarta.persistence.Column;
import jakarta.persistence.CollectionTable;
import jakarta.persistence.ElementCollection;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.HashSet;
import java.util.Set;

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

    @Column(unique = true, length = 100)
    private String email;

    @Column(name = "current_state", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private UserState currentState = UserState.CALM;

    @Column(nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private UserStatus status = UserStatus.ACTIVE;

    @Column(name = "language_preference", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private LanguagePreference languagePreference = LanguagePreference.FOLLOW_SYSTEM;

    @ElementCollection(fetch = FetchType.EAGER)
    @CollectionTable(name = "user_roles", joinColumns = @JoinColumn(name = "user_id"))
    @Column(name = "role", nullable = false, length = 20)
    @Enumerated(EnumType.STRING)
    private Set<UserRole> roles = new HashSet<>(Set.of(UserRole.USER));

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

    public UserEntity(String uid, String mobile, String email) {
        this.uid = uid;
        this.mobile = mobile;
        this.email = email;
    }

    public UserEntity(String uid, String mobile, Instant createdAt) {
        this(uid, mobile);
        this.createdAt = createdAt;
        this.updatedAt = createdAt;
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

    public String getEmail() {
        return email;
    }

    public UserState getCurrentState() {
        return currentState;
    }

    public UserStatus getStatus() {
        return status;
    }

    public LanguagePreference getLanguagePreference() {
        return languagePreference;
    }

    public Set<UserRole> getRoles() {
        return Set.copyOf(roles);
    }

    public void grantRole(UserRole role) {
        roles.add(role);
        updatedAt = Instant.now();
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public void changeState(UserState state) {
        this.currentState = state;
        this.updatedAt = Instant.now();
    }

    public void changeLanguagePreference(LanguagePreference languagePreference) {
        this.languagePreference = languagePreference;
        this.updatedAt = Instant.now();
    }
}
