package ai.zeroon.support;

import ai.zeroon.support.SupportAdminDtos.AdminSupportAuditResponse;
import ai.zeroon.support.SupportAdminDtos.AdminSupportMessageRequest;
import ai.zeroon.support.SupportAdminDtos.AdminSupportMessageResponse;
import ai.zeroon.support.SupportAdminDtos.AdminSupportRequestDetail;
import ai.zeroon.support.SupportAdminDtos.AdminSupportRequestPage;
import ai.zeroon.support.SupportAdminDtos.AdminSupportRequestSummary;
import ai.zeroon.support.SupportAdminDtos.AdminSupportStatusHistoryResponse;
import ai.zeroon.support.SupportAdminDtos.AdminSupportUpdateRequest;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.time.Clock;
import java.time.Instant;
import java.util.List;
import java.util.Objects;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SupportAdminService {

    private final UserRepository userRepository;
    private final SupportRequestRepository requestRepository;
    private final SupportMessageRepository messageRepository;
    private final SupportStatusHistoryRepository historyRepository;
    private final SupportAdminAuditRepository auditRepository;
    private final Clock clock;

    public SupportAdminService(
            UserRepository userRepository,
            SupportRequestRepository requestRepository,
            SupportMessageRepository messageRepository,
            SupportStatusHistoryRepository historyRepository,
            SupportAdminAuditRepository auditRepository,
            Clock clock) {
        this.userRepository = userRepository;
        this.requestRepository = requestRepository;
        this.messageRepository = messageRepository;
        this.historyRepository = historyRepository;
        this.auditRepository = auditRepository;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public AdminSupportRequestPage list(
            SupportRequestStatus status,
            SupportCategory category,
            Boolean escalated,
            int page,
            int size) {
        validatePage(page, size);
        Page<SupportRequestEntity> result = requestRepository.findAdminQueue(
                status, category, escalated, PageRequest.of(page, size));
        return new AdminSupportRequestPage(
                result.getContent().stream().map(this::toSummary).toList(),
                page,
                size,
                result.getTotalElements());
    }

    @Transactional(readOnly = true)
    public AdminSupportRequestDetail get(String reference) {
        SupportRequestEntity request = requestRepository.findByPublicReference(reference)
                .orElseThrow(() -> new EntityNotFoundException("Support request not found"));
        return toDetail(request);
    }

    @Transactional
    public AdminSupportRequestDetail update(
            Long adminUserId,
            String reference,
            AdminSupportUpdateRequest update) {
        UserEntity admin = requireAdmin(adminUserId);
        SupportRequestEntity request = requireOpenForUpdate(reference);
        Instant now = clock.instant();
        int mutationCount = 0;

        if (update.category() != null && update.category() != request.getCategory()) {
            SupportCategory previous = request.getCategory();
            request.changeCategory(update.category(), now);
            audit(request, admin, SupportAdminAuditAction.CATEGORY_CHANGE,
                    previous.name(), update.category().name(), null, update.reasonCode(), now);
            mutationCount++;
        }

        if (update.assignToMe() != null) {
            UserEntity currentAssignee = request.getAssignedAdmin();
            if (currentAssignee != null && !currentAssignee.getId().equals(admin.getId())) {
                throw new SupportConflictException(
                        "Support request is assigned to another administrator");
            }
            UserEntity nextAssignee = update.assignToMe() ? admin : null;
            String previousUid = uid(currentAssignee);
            String nextUid = uid(nextAssignee);
            if (!Objects.equals(previousUid, nextUid)) {
                request.assignTo(nextAssignee, now);
                audit(request, admin, SupportAdminAuditAction.ASSIGNMENT_CHANGE,
                        value(previousUid), value(nextUid), null, update.reasonCode(), now);
                mutationCount++;
            }
        }

        if (update.escalated() != null
                && (update.escalated() != request.isEscalated()
                        || update.escalationCode() != request.getEscalationCode())) {
            String previous = escalationValue(request.isEscalated(), request.getEscalationCode());
            request.changeEscalation(update.escalated(), update.escalationCode(), now);
            audit(request, admin, SupportAdminAuditAction.ESCALATION_CHANGE,
                    previous,
                    escalationValue(update.escalated(), update.escalationCode()),
                    null,
                    update.reasonCode(),
                    now);
            mutationCount++;
        }

        if (update.status() != null && update.status() != request.getStatus()) {
            if (request.getStatus() != SupportRequestStatus.RECEIVED
                    || update.status() != SupportRequestStatus.IN_REVIEW) {
                throw new SupportConflictException(
                        "Admin status-only updates are limited to RECEIVED -> IN_REVIEW");
            }
            transition(request, admin, update.status(), update.reasonCode(), now);
            mutationCount++;
        }

        if (mutationCount == 0) {
            throw new SupportConflictException("Support update has no effective changes");
        }
        return toDetail(request);
    }

    @Transactional
    public AdminSupportRequestDetail addMessage(
            Long adminUserId,
            String reference,
            AdminSupportMessageRequest input) {
        UserEntity admin = requireAdmin(adminUserId);
        SupportRequestEntity request = requireOpenForUpdate(reference);
        Instant now = clock.instant();

        if (input.visibility() == SupportMessageVisibility.INTERNAL) {
            SupportMessageEntity note = messageRepository.save(new SupportMessageEntity(
                    request,
                    admin,
                    SupportActorType.ADMIN,
                    SupportMessageVisibility.INTERNAL,
                    input.body(),
                    now));
            audit(request, admin, SupportAdminAuditAction.INTERNAL_NOTE,
                    null, null, note, input.reasonCode(), now);
            return toDetail(request);
        }

        assertReplyTransition(request.getStatus(), input.nextStatus());
        SupportMessageEntity reply = messageRepository.save(new SupportMessageEntity(
                request,
                admin,
                SupportActorType.ADMIN,
                SupportMessageVisibility.USER_VISIBLE,
                input.body(),
                now));
        audit(request, admin, SupportAdminAuditAction.USER_VISIBLE_REPLY,
                null, null, reply, input.reasonCode(), now);
        transition(request, admin, input.nextStatus(), input.reasonCode(), now);
        return toDetail(request);
    }

    private UserEntity requireAdmin(Long adminUserId) {
        return userRepository.findById(adminUserId)
                .orElseThrow(() -> new EntityNotFoundException("Admin user not found"));
    }

    private SupportRequestEntity requireOpenForUpdate(String reference) {
        SupportRequestEntity request = requestRepository.findAdminForUpdate(reference)
                .orElseThrow(() -> new EntityNotFoundException("Support request not found"));
        if (request.getStatus() == SupportRequestStatus.CLOSED) {
            throw new SupportConflictException("Closed support requests cannot be mutated");
        }
        return request;
    }

    private void assertReplyTransition(
            SupportRequestStatus current,
            SupportRequestStatus next) {
        boolean allowed = switch (current) {
            case RECEIVED -> next == SupportRequestStatus.CLOSED;
            case IN_REVIEW -> next == SupportRequestStatus.WAITING_FOR_USER
                    || next == SupportRequestStatus.REPLIED
                    || next == SupportRequestStatus.CLOSED;
            case WAITING_FOR_USER, REPLIED -> next == SupportRequestStatus.CLOSED;
            case CLOSED -> false;
        };
        if (!allowed) {
            throw new SupportConflictException(
                    "User-visible reply does not match an allowed support transition");
        }
    }

    private void transition(
            SupportRequestEntity request,
            UserEntity admin,
            SupportRequestStatus next,
            String reasonCode,
            Instant now) {
        SupportRequestStatus previous = request.getStatus();
        request.transitionTo(next, now);
        historyRepository.save(new SupportStatusHistoryEntity(
                request,
                previous,
                next,
                SupportActorType.ADMIN,
                admin,
                reasonCode,
                now));
        audit(request, admin, SupportAdminAuditAction.STATUS_CHANGE,
                previous.name(), next.name(), null, reasonCode, now);
    }

    private void audit(
            SupportRequestEntity request,
            UserEntity admin,
            SupportAdminAuditAction action,
            String fromValue,
            String toValue,
            SupportMessageEntity message,
            String reasonCode,
            Instant now) {
        auditRepository.save(new SupportAdminAuditEntity(
                request,
                admin,
                action,
                fromValue,
                toValue,
                message,
                reasonCode,
                now));
    }

    private AdminSupportRequestSummary toSummary(SupportRequestEntity request) {
        return new AdminSupportRequestSummary(
                request.getPublicReference(),
                request.getOwnerUid(),
                request.getCategory(),
                request.getStatus(),
                request.getSubject(),
                preview(request.getDescription()),
                uid(request.getAssignedAdmin()),
                request.isEscalated(),
                request.getEscalationCode(),
                request.getCreatedAt(),
                request.getUpdatedAt());
    }

    private AdminSupportRequestDetail toDetail(SupportRequestEntity request) {
        List<AdminSupportMessageResponse> messages = request.getId() == null
                ? List.of()
                : messageRepository.findByRequest_IdOrderByCreatedAt(request.getId())
                        .stream()
                        .map(item -> new AdminSupportMessageResponse(
                                item.getId(),
                                item.getActorType(),
                                item.getVisibility(),
                                item.getActorUid(),
                                item.getBody(),
                                item.getCreatedAt()))
                        .toList();
        List<AdminSupportStatusHistoryResponse> history = request.getId() == null
                ? List.of()
                : historyRepository.findByRequest_IdOrderByCreatedAt(request.getId())
                        .stream()
                        .map(item -> new AdminSupportStatusHistoryResponse(
                                item.getFromStatus(),
                                item.getToStatus(),
                                item.getActorType(),
                                item.getActorUid(),
                                item.getReasonCode(),
                                item.getCreatedAt()))
                        .toList();
        List<AdminSupportAuditResponse> audit = request.getId() == null
                ? List.of()
                : auditRepository.findByRequest_IdOrderByCreatedAt(request.getId())
                        .stream()
                        .map(item -> new AdminSupportAuditResponse(
                                item.getActionType(),
                                item.getActorUid(),
                                item.getFromValue(),
                                item.getToValue(),
                                item.getMessageId(),
                                item.getReasonCode(),
                                item.getCreatedAt()))
                        .toList();
        return new AdminSupportRequestDetail(
                request.getPublicReference(),
                request.getOwnerUid(),
                request.getCategory(),
                request.getStatus(),
                request.getSubject(),
                request.getDescription(),
                request.getReplyContact(),
                request.getDiagnostics(),
                uid(request.getAssignedAdmin()),
                request.isEscalated(),
                request.getEscalationCode(),
                messages,
                history,
                audit,
                request.getCreatedAt(),
                request.getUpdatedAt(),
                request.getClosedAt());
    }

    private String preview(String description) {
        return description.codePoints()
                .limit(160)
                .collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append)
                .toString();
    }

    private String uid(UserEntity user) {
        return user == null ? null : user.getUid();
    }

    private String value(String uid) {
        return uid == null ? "UNASSIGNED" : uid;
    }

    private String escalationValue(boolean escalated, SupportEscalationCode code) {
        return escalated ? code.name() : "NONE";
    }

    private void validatePage(int page, int size) {
        if (page < 0 || size < 1 || size > 50) {
            throw new IllegalArgumentException(
                    "page must be non-negative and size must be between 1 and 50");
        }
    }
}
