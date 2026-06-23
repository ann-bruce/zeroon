package ai.zeroon.profile;

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
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;

@Entity
@Table(name = "user_profiles")
public class UserProfileEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private UserEntity user;

    @Column(length = 30)
    private String nickname;

    @Column(name = "avatar_preset", length = 30)
    @Enumerated(EnumType.STRING)
    private AvatarPreset avatarPreset;

    @Column(name = "age_range", length = 20)
    @Enumerated(EnumType.STRING)
    private AgeRange ageRange;

    @Column(length = 40)
    private String occupation;

    @Column(name = "self_description", length = 120)
    private String selfDescription;

    @Column(name = "ai_profile_context_enabled", nullable = false)
    private boolean aiProfileContextEnabled;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    protected UserProfileEntity() {
    }

    public UserProfileEntity(UserEntity user) {
        this.user = user;
    }

    public String getNickname() {
        return nickname;
    }

    public AvatarPreset getAvatarPreset() {
        return avatarPreset;
    }

    public AgeRange getAgeRange() {
        return ageRange;
    }

    public String getOccupation() {
        return occupation;
    }

    public String getSelfDescription() {
        return selfDescription;
    }

    public boolean isAiProfileContextEnabled() {
        return aiProfileContextEnabled;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public void update(
            String nickname,
            AvatarPreset avatarPreset,
            AgeRange ageRange,
            String occupation,
            String selfDescription,
            boolean aiProfileContextEnabled) {
        this.nickname = nickname;
        this.avatarPreset = avatarPreset;
        this.ageRange = ageRange;
        this.occupation = occupation;
        this.selfDescription = selfDescription;
        this.aiProfileContextEnabled = aiProfileContextEnabled;
        this.updatedAt = Instant.now();
    }
}
