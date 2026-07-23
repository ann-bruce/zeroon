package ai.zeroon.evidence;

import ai.zeroon.user.UserEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "evidence_subjects")
public class EvidenceSubjectEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false, unique = true)
    private UserEntity user;

    @Column(name = "subject_uuid", nullable = false, unique = true)
    private UUID subjectUuid;

    @Column(name = "collection_enabled", nullable = false)
    private boolean collectionEnabled;

    @Column(name = "accepted_notice_version", nullable = false, length = 40)
    private String acceptedNoticeVersion;

    @Column(name = "choice_changed_at", nullable = false)
    private Instant choiceChangedAt;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    protected EvidenceSubjectEntity() {
    }

    public EvidenceSubjectEntity(
            UserEntity user,
            UUID subjectUuid,
            boolean collectionEnabled,
            String acceptedNoticeVersion,
            Instant now) {
        this.user = user;
        this.subjectUuid = subjectUuid;
        this.collectionEnabled = collectionEnabled;
        this.acceptedNoticeVersion = acceptedNoticeVersion;
        this.choiceChangedAt = now;
        this.createdAt = now;
    }

    public Long getId() {
        return id;
    }

    public boolean isCollectionEnabled() {
        return collectionEnabled;
    }

    public String getAcceptedNoticeVersion() {
        return acceptedNoticeVersion;
    }

    public Instant getChoiceChangedAt() {
        return choiceChangedAt;
    }

    public void changeCollectionChoice(
            boolean enabled,
            String noticeVersion,
            Instant now) {
        collectionEnabled = enabled;
        acceptedNoticeVersion = noticeVersion;
        choiceChangedAt = now;
    }
}
