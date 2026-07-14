package ai.zeroon.myzeroon;

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
@Table(name = "user_zeroon_companions")
public class UserZeroonCompanionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private UserEntity user;

    @Column(name = "companion_key", nullable = false, length = 30)
    @Enumerated(EnumType.STRING)
    private ZeroonCompanionKey companionKey;

    @Column(name = "display_name", length = 30)
    private String displayName;

    @Column(name = "nameplate_serial", nullable = false, unique = true, length = 20)
    private String nameplateSerial;

    @Column(name = "met_at", nullable = false)
    private Instant metAt = Instant.now();

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    protected UserZeroonCompanionEntity() {
    }

    public UserZeroonCompanionEntity(
            UserEntity user,
            ZeroonCompanionKey companionKey,
            String nameplateSerial) {
        this.user = user;
        this.companionKey = companionKey;
        this.nameplateSerial = nameplateSerial;
    }

    public ZeroonCompanionKey getCompanionKey() {
        return companionKey;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getNameplateSerial() {
        return nameplateSerial;
    }

    public Instant getMetAt() {
        return metAt;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
