package ai.zeroon.support;

import ai.zeroon.auth.RateLimitExceededException;
import ai.zeroon.support.SupportDtos.AddSupportMessageRequest;
import ai.zeroon.support.SupportDtos.CreateResult;
import ai.zeroon.support.SupportDtos.CreateSupportRequest;
import ai.zeroon.support.SupportDtos.DiagnosticEnvelope;
import ai.zeroon.support.SupportDtos.SupportMessageResponse;
import ai.zeroon.support.SupportDtos.SupportRequestDetail;
import ai.zeroon.support.SupportDtos.SupportRequestPage;
import ai.zeroon.support.SupportDtos.SupportRequestSummary;
import ai.zeroon.support.SupportDtos.SupportStatusHistoryResponse;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.Clock;
import java.time.Duration;
import java.time.Instant;
import java.util.HexFormat;
import java.util.List;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class SupportRequestService {

    private static final Duration RATE_WINDOW = Duration.ofHours(1);

    private final UserRepository userRepository;
    private final SupportRequestRepository requestRepository;
    private final SupportMessageRepository messageRepository;
    private final SupportStatusHistoryRepository historyRepository;
    private final Clock clock;
    private final int requestHourlyLimit;
    private final int messageHourlyLimit;

    public SupportRequestService(
            UserRepository userRepository,
            SupportRequestRepository requestRepository,
            SupportMessageRepository messageRepository,
            SupportStatusHistoryRepository historyRepository,
            Clock clock,
            @Value("${zeroon.support.request-hourly-limit:5}") int requestHourlyLimit,
            @Value("${zeroon.support.message-hourly-limit:20}") int messageHourlyLimit) {
        this.userRepository = userRepository;
        this.requestRepository = requestRepository;
        this.messageRepository = messageRepository;
        this.historyRepository = historyRepository;
        this.clock = clock;
        this.requestHourlyLimit = requestHourlyLimit;
        this.messageHourlyLimit = messageHourlyLimit;
    }

    @Transactional
    public CreateResult create(Long userId, CreateSupportRequest request) {
        UserEntity user = userRepository.findByIdForUpdate(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        String submissionId = request.clientSubmissionId().toString();
        String fingerprint = fingerprint(request);
        var existing = requestRepository.findByUser_IdAndClientSubmissionId(userId, submissionId);
        if (existing.isPresent()) {
            if (!existing.get().getRequestFingerprint().equals(fingerprint)) {
                throw new SupportConflictException(
                        "clientSubmissionId is already used for different support content");
            }
            return new CreateResult(toDetail(existing.get()), false);
        }

        Instant now = clock.instant();
        enforceRequestRateLimit(userId, now);
        SupportRequestEntity entity = new SupportRequestEntity(
                user,
                generateReference(),
                submissionId,
                fingerprint,
                request.category(),
                request.subject(),
                request.description(),
                request.replyContact(),
                request.diagnostics() == null ? null : request.diagnostics().toEnvelope(),
                now);
        requestRepository.save(entity);
        historyRepository.save(new SupportStatusHistoryEntity(
                entity,
                null,
                SupportRequestStatus.RECEIVED,
                SupportActorType.SYSTEM,
                null,
                "REQUEST_CREATED",
                now));
        return new CreateResult(toDetail(entity), true);
    }

    @Transactional(readOnly = true)
    public SupportRequestPage list(Long userId, int page, int size) {
        validatePage(page, size);
        Page<SupportRequestEntity> result = requestRepository.findByUser_IdOrderByCreatedAtDesc(
                userId, PageRequest.of(page, size));
        return new SupportRequestPage(
                result.getContent().stream().map(this::toSummary).toList(),
                page,
                size,
                result.getTotalElements());
    }

    @Transactional(readOnly = true)
    public SupportRequestDetail get(Long userId, String reference) {
        return toDetail(requireOwned(userId, reference));
    }

    @Transactional
    public SupportMessageResponse addMessage(
            Long userId, String reference, AddSupportMessageRequest request) {
        UserEntity user = userRepository.findByIdForUpdate(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        SupportRequestEntity supportRequest = requestRepository.findOwnedForUpdate(reference, userId)
                .orElseThrow(() -> new EntityNotFoundException("Support request not found"));
        if (supportRequest.getStatus() == SupportRequestStatus.CLOSED) {
            throw new SupportConflictException("Closed support requests do not accept follow-up messages");
        }
        Instant now = clock.instant();
        long recentMessages = messageRepository.countByRequest_User_IdAndActorTypeAndCreatedAtAfter(
                userId, SupportActorType.USER, now.minus(RATE_WINDOW));
        if (recentMessages >= messageHourlyLimit) {
            throw new RateLimitExceededException(
                    "support_rate_limited",
                    "Too many support follow-up messages; try again later",
                    RATE_WINDOW.toSeconds());
        }
        SupportMessageEntity message = messageRepository.save(new SupportMessageEntity(
                supportRequest,
                user,
                SupportActorType.USER,
                SupportMessageVisibility.USER_VISIBLE,
                request.body(),
                now));
        SupportRequestStatus previousStatus = supportRequest.getStatus();
        supportRequest.recordUserFollowUp(now);
        if (previousStatus != supportRequest.getStatus()) {
            historyRepository.save(new SupportStatusHistoryEntity(
                    supportRequest,
                    previousStatus,
                    supportRequest.getStatus(),
                    SupportActorType.USER,
                    user,
                    "USER_FOLLOW_UP",
                    now));
        }
        return toMessage(message);
    }

    private void enforceRequestRateLimit(Long userId, Instant now) {
        long recentRequests = requestRepository.countByUser_IdAndCreatedAtAfter(
                userId, now.minus(RATE_WINDOW));
        if (recentRequests >= requestHourlyLimit) {
            throw new RateLimitExceededException(
                    "support_rate_limited",
                    "Too many support requests; try again later",
                    RATE_WINDOW.toSeconds());
        }
    }

    private SupportRequestEntity requireOwned(Long userId, String reference) {
        return requestRepository.findByPublicReferenceAndUser_Id(reference, userId)
                .orElseThrow(() -> new EntityNotFoundException("Support request not found"));
    }

    private SupportRequestSummary toSummary(SupportRequestEntity request) {
        return new SupportRequestSummary(
                request.getPublicReference(),
                request.getCategory(),
                request.getStatus(),
                request.getSubject(),
                request.getCreatedAt(),
                request.getUpdatedAt());
    }

    private SupportRequestDetail toDetail(SupportRequestEntity request) {
        List<SupportMessageResponse> messages = request.getId() == null
                ? List.of()
                : messageRepository.findByRequest_IdAndVisibilityOrderByCreatedAt(
                                request.getId(), SupportMessageVisibility.USER_VISIBLE)
                        .stream()
                        .map(this::toMessage)
                        .toList();
        List<SupportStatusHistoryResponse> history = request.getId() == null
                ? List.of()
                : historyRepository.findByRequest_IdOrderByCreatedAt(request.getId())
                        .stream()
                        .map(item -> new SupportStatusHistoryResponse(
                                item.getFromStatus(),
                                item.getToStatus(),
                                item.getActorType(),
                                item.getCreatedAt()))
                        .toList();
        return new SupportRequestDetail(
                request.getPublicReference(),
                request.getCategory(),
                request.getStatus(),
                request.getSubject(),
                request.getDescription(),
                request.getReplyContact(),
                request.getDiagnostics(),
                messages,
                history,
                request.getCreatedAt(),
                request.getUpdatedAt(),
                request.getClosedAt());
    }

    private SupportMessageResponse toMessage(SupportMessageEntity message) {
        return new SupportMessageResponse(
                message.getId(), message.getActorType(), message.getBody(), message.getCreatedAt());
    }

    private String generateReference() {
        for (int attempt = 0; attempt < 8; attempt++) {
            String random = UUID.randomUUID().toString().replace("-", "").substring(0, 20).toUpperCase();
            String reference = "ZS-" + random;
            if (!requestRepository.existsByPublicReference(reference)) {
                return reference;
            }
        }
        throw new IllegalStateException("Unable to generate support reference");
    }

    private String fingerprint(CreateSupportRequest request) {
        DiagnosticEnvelope diagnostics = request.diagnostics() == null
                ? null
                : request.diagnostics().toEnvelope();
        String canonical = String.join("\u0000",
                request.category().name(),
                request.subject(),
                request.description(),
                nullable(request.replyContact()),
                Boolean.toString(request.diagnosticConsent()),
                diagnostics == null ? "" : nullable(diagnostics.appVersion()),
                diagnostics == null ? "" : nullable(diagnostics.build()),
                diagnostics == null ? "" : nullable(diagnostics.platform()),
                diagnostics == null ? "" : nullable(diagnostics.osFamily()),
                diagnostics == null ? "" : nullable(diagnostics.locale()),
                diagnostics == null ? "" : nullable(diagnostics.errorCode()),
                diagnostics == null || diagnostics.timestamp() == null
                        ? ""
                        : diagnostics.timestamp().toString());
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(canonical.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is unavailable", exception);
        }
    }

    private String nullable(String value) {
        return value == null ? "" : value;
    }

    private void validatePage(int page, int size) {
        if (page < 0 || size < 1 || size > 50) {
            throw new IllegalArgumentException("page must be non-negative and size must be between 1 and 50");
        }
    }
}
