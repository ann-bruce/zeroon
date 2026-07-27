package ai.zeroon.prompt;

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
import jakarta.persistence.UniqueConstraint;
import java.time.Instant;

@Entity
@Table(
        name = "prompt_templates",
        uniqueConstraints = @UniqueConstraint(columnNames = {"code", "version"}))
public class PromptTemplateEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String code;

    @Column(nullable = false, length = 100)
    private String name;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Column(nullable = false)
    private boolean enabled = true;

    @Column(nullable = false)
    private int version;

    @Enumerated(EnumType.STRING)
    @Column(name = "review_status", nullable = false, length = 20)
    private PromptReviewStatus reviewStatus = PromptReviewStatus.PENDING;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    private UserEntity createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "reviewed_by")
    private UserEntity reviewedBy;

    @Column(name = "reviewed_at")
    private Instant reviewedAt;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    protected PromptTemplateEntity() {
    }

    public PromptTemplateEntity(String code, String name, String content, boolean enabled, int version) {
        this.code = code;
        this.name = name;
        this.content = content;
        this.enabled = enabled;
        this.version = version;
        this.reviewStatus = enabled ? PromptReviewStatus.APPROVED : PromptReviewStatus.PENDING;
    }

    public PromptTemplateEntity(
            String code,
            String name,
            String content,
            int version,
            UserEntity createdBy,
            Instant createdAt) {
        this.code = code;
        this.name = name;
        this.content = content;
        this.enabled = false;
        this.version = version;
        this.reviewStatus = PromptReviewStatus.PENDING;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
    }

    public String getCode() {
        return code;
    }

    public String getName() {
        return name;
    }

    public String getContent() {
        return content;
    }

    public int getVersion() {
        return version;
    }

    public Long getId() {
        return id;
    }

    public boolean isEnabled() {
        return enabled;
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public PromptReviewStatus getReviewStatus() {
        return reviewStatus;
    }

    public String getCreatedByUid() {
        return createdBy == null ? null : createdBy.getUid();
    }

    public Long getCreatedById() {
        return createdBy == null ? null : createdBy.getId();
    }

    public String getReviewedByUid() {
        return reviewedBy == null ? null : reviewedBy.getUid();
    }

    public Instant getReviewedAt() {
        return reviewedAt;
    }

    public void review(PromptReviewStatus status, UserEntity reviewer, Instant reviewedAt) {
        if (status == PromptReviewStatus.PENDING) {
            throw new IllegalArgumentException("Prompt review must approve or reject");
        }
        this.reviewStatus = status;
        this.enabled = status == PromptReviewStatus.APPROVED;
        this.reviewedBy = reviewer;
        this.reviewedAt = reviewedAt;
    }
}
