package ai.zeroon.support;

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
@Table(name = "support_requests")
public class SupportRequestEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    @Column(name = "public_reference", nullable = false, unique = true, length = 32)
    private String publicReference;

    @Column(name = "client_submission_id", nullable = false, length = 36)
    private String clientSubmissionId;

    @Column(name = "request_fingerprint", nullable = false, length = 64)
    private String requestFingerprint;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private SupportCategory category;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 30)
    private SupportRequestStatus status = SupportRequestStatus.RECEIVED;

    @Column(nullable = false, length = 120)
    private String subject;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String description;

    @Column(name = "reply_contact", length = 200)
    private String replyContact;

    @Column(name = "diagnostic_app_version", length = 40)
    private String diagnosticAppVersion;

    @Column(name = "diagnostic_build", length = 40)
    private String diagnosticBuild;

    @Column(name = "diagnostic_platform", length = 30)
    private String diagnosticPlatform;

    @Column(name = "diagnostic_os_family", length = 40)
    private String diagnosticOsFamily;

    @Column(name = "diagnostic_locale", length = 10)
    private String diagnosticLocale;

    @Column(name = "diagnostic_error_code", length = 80)
    private String diagnosticErrorCode;

    @Column(name = "diagnostic_timestamp")
    private Instant diagnosticTimestamp;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_admin_user_id")
    private UserEntity assignedAdmin;

    @Column(nullable = false)
    private boolean escalated;

    @Enumerated(EnumType.STRING)
    @Column(name = "escalation_code", length = 40)
    private SupportEscalationCode escalationCode;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @Column(name = "closed_at")
    private Instant closedAt;

    protected SupportRequestEntity() {
    }

    public SupportRequestEntity(
            UserEntity user,
            String publicReference,
            String clientSubmissionId,
            String requestFingerprint,
            SupportCategory category,
            String subject,
            String description,
            String replyContact,
            SupportDtos.DiagnosticEnvelope diagnostics,
            Instant now) {
        this.user = user;
        this.publicReference = publicReference;
        this.clientSubmissionId = clientSubmissionId;
        this.requestFingerprint = requestFingerprint;
        this.category = category;
        this.subject = subject;
        this.description = description;
        this.replyContact = replyContact;
        if (diagnostics != null) {
            diagnosticAppVersion = diagnostics.appVersion();
            diagnosticBuild = diagnostics.build();
            diagnosticPlatform = diagnostics.platform();
            diagnosticOsFamily = diagnostics.osFamily();
            diagnosticLocale = diagnostics.locale();
            diagnosticErrorCode = diagnostics.errorCode();
            diagnosticTimestamp = diagnostics.timestamp();
        }
        createdAt = now;
        updatedAt = now;
    }

    public Long getId() {
        return id;
    }

    public Long getUserId() {
        return user.getId();
    }

    public String getPublicReference() {
        return publicReference;
    }

    public String getRequestFingerprint() {
        return requestFingerprint;
    }

    public SupportCategory getCategory() {
        return category;
    }

    public SupportRequestStatus getStatus() {
        return status;
    }

    public String getSubject() {
        return subject;
    }

    public String getDescription() {
        return description;
    }

    public String getReplyContact() {
        return replyContact;
    }

    public SupportDtos.DiagnosticEnvelope getDiagnostics() {
        if (diagnosticAppVersion == null
                && diagnosticBuild == null
                && diagnosticPlatform == null
                && diagnosticOsFamily == null
                && diagnosticLocale == null
                && diagnosticErrorCode == null
                && diagnosticTimestamp == null) {
            return null;
        }
        return new SupportDtos.DiagnosticEnvelope(
                diagnosticAppVersion,
                diagnosticBuild,
                diagnosticPlatform,
                diagnosticOsFamily,
                diagnosticLocale,
                diagnosticErrorCode,
                diagnosticTimestamp);
    }

    public Instant getCreatedAt() {
        return createdAt;
    }

    public Instant getUpdatedAt() {
        return updatedAt;
    }

    public Instant getClosedAt() {
        return closedAt;
    }

    public String getOwnerUid() {
        return user.getUid();
    }

    public UserEntity getAssignedAdmin() {
        return assignedAdmin;
    }

    public boolean isEscalated() {
        return escalated;
    }

    public SupportEscalationCode getEscalationCode() {
        return escalationCode;
    }

    public void changeCategory(SupportCategory category, Instant now) {
        this.category = category;
        updatedAt = now;
    }

    public void assignTo(UserEntity admin, Instant now) {
        assignedAdmin = admin;
        updatedAt = now;
    }

    public void changeEscalation(boolean escalated, SupportEscalationCode escalationCode, Instant now) {
        this.escalated = escalated;
        this.escalationCode = escalated ? escalationCode : null;
        updatedAt = now;
    }

    public void transitionTo(SupportRequestStatus nextStatus, Instant now) {
        status = nextStatus;
        closedAt = nextStatus == SupportRequestStatus.CLOSED ? now : null;
        updatedAt = now;
    }

    public void recordUserFollowUp(Instant now) {
        if (status == SupportRequestStatus.WAITING_FOR_USER || status == SupportRequestStatus.REPLIED) {
            status = SupportRequestStatus.IN_REVIEW;
        }
        updatedAt = now;
    }
}
