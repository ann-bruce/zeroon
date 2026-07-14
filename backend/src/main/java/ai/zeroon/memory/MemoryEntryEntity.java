package ai.zeroon.memory;

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
@Table(name = "memory_entries")
public class MemoryEntryEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(nullable = false, length = 30)
    @Enumerated(EnumType.STRING)
    private MemoryEntryType type;

    @Column(length = 255)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String summary;

    @Column(nullable = false)
    private short importance = 1;

    @Column(name = "source_type", length = 30)
    private String sourceType;

    @Column(name = "source_id")
    private Long sourceId;

    @Column(name = "expires_at")
    private Instant expiresAt;

    @Column(nullable = false)
    private boolean enabled = true;

    @Column(name = "ai_context_enabled", nullable = false)
    private boolean aiContextEnabled;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    protected MemoryEntryEntity() {
    }

    public MemoryEntryEntity(
            UserEntity user,
            MemoryEntryType type,
            String title,
            String summary,
            short importance,
            String sourceType,
            Long sourceId,
            Instant createdAt) {
        this(user, type, title, summary, importance, sourceType, sourceId, null, createdAt);
    }

    public MemoryEntryEntity(
            UserEntity user,
            MemoryEntryType type,
            String title,
            String summary,
            short importance,
            String sourceType,
            Long sourceId,
            Instant expiresAt,
            Instant createdAt) {
        this.user = user;
        this.type = type;
        this.title = title;
        this.summary = summary;
        this.importance = importance;
        this.sourceType = sourceType;
        this.sourceId = sourceId;
        this.expiresAt = expiresAt;
        this.createdAt = createdAt;
        this.updatedAt = createdAt;
    }

    public Long getId() {
        return id;
    }

    public MemoryEntryType getType() {
        return type;
    }

    public String getTitle() {
        return title;
    }

    public String getSummary() {
        return summary;
    }

    public short getImportance() {
        return importance;
    }

    public String getSourceType() {
        return sourceType;
    }

    public Long getSourceId() {
        return sourceId;
    }

    public Instant getExpiresAt() {
        return expiresAt;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public boolean isAiContextEnabled() {
        return aiContextEnabled;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }
}
