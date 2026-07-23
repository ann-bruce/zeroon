package ai.zeroon.support;

import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.validation.constraints.AssertTrue;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import java.time.Instant;
import java.util.List;

public final class SupportAdminDtos {

    private SupportAdminDtos() {
    }

    public record AdminSupportUpdateRequest(
            SupportCategory category,
            SupportRequestStatus status,
            Boolean assignToMe,
            Boolean escalated,
            SupportEscalationCode escalationCode,
            @NotBlank
            @Pattern(regexp = "^[A-Z0-9_]{2,40}$")
            String reasonCode) {

        @AssertTrue(message = "At least one support mutation is required")
        @JsonIgnore
        public boolean hasMutation() {
            return category != null || status != null || assignToMe != null || escalated != null;
        }

        @AssertTrue(message = "Escalation code must match escalation state")
        @JsonIgnore
        public boolean hasConsistentEscalation() {
            if (escalated == null) {
                return escalationCode == null;
            }
            return escalated ? escalationCode != null : escalationCode == null;
        }

        @JsonAnySetter
        void rejectUnknown(String name, Object value) {
            throw new IllegalArgumentException("Unknown admin support update property: " + name);
        }
    }

    public record AdminSupportMessageRequest(
            @NotBlank @Size(max = 2000) String body,
            @NotNull SupportMessageVisibility visibility,
            SupportRequestStatus nextStatus,
            @NotBlank
            @Pattern(regexp = "^[A-Z0-9_]{2,40}$")
            String reasonCode) {

        @AssertTrue(message = "User-visible replies require a next status; internal notes cannot change status")
        @JsonIgnore
        public boolean hasConsistentVisibility() {
            return visibility == SupportMessageVisibility.USER_VISIBLE
                    ? nextStatus != null
                    : nextStatus == null;
        }

        @AssertTrue(message = "Support text contains an unsupported null character")
        @JsonIgnore
        public boolean hasSupportedText() {
            return body == null || body.indexOf('\0') < 0;
        }

        @JsonAnySetter
        void rejectUnknown(String name, Object value) {
            throw new IllegalArgumentException("Unknown admin support message property: " + name);
        }
    }

    public record AdminSupportRequestSummary(
            String reference,
            String ownerUid,
            SupportCategory category,
            SupportRequestStatus status,
            String subject,
            String descriptionPreview,
            String assignedAdminUid,
            boolean escalated,
            SupportEscalationCode escalationCode,
            Instant createdAt,
            Instant updatedAt) {
    }

    public record AdminSupportRequestPage(
            List<AdminSupportRequestSummary> items,
            int page,
            int size,
            long totalElements) {
    }

    public record AdminSupportMessageResponse(
            Long id,
            SupportActorType actorType,
            SupportMessageVisibility visibility,
            String actorUid,
            String body,
            Instant createdAt) {
    }

    public record AdminSupportStatusHistoryResponse(
            SupportRequestStatus fromStatus,
            SupportRequestStatus toStatus,
            SupportActorType actorType,
            String actorUid,
            String reasonCode,
            Instant createdAt) {
    }

    public record AdminSupportAuditResponse(
            SupportAdminAuditAction actionType,
            String actorUid,
            String fromValue,
            String toValue,
            Long messageId,
            String reasonCode,
            Instant createdAt) {
    }

    public record AdminSupportRequestDetail(
            String reference,
            String ownerUid,
            SupportCategory category,
            SupportRequestStatus status,
            String subject,
            String description,
            String replyContact,
            SupportDtos.DiagnosticEnvelope diagnostics,
            String assignedAdminUid,
            boolean escalated,
            SupportEscalationCode escalationCode,
            List<AdminSupportMessageResponse> messages,
            List<AdminSupportStatusHistoryResponse> statusHistory,
            List<AdminSupportAuditResponse> audit,
            Instant createdAt,
            Instant updatedAt,
            Instant closedAt) {
    }
}
