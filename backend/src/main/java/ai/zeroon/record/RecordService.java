package ai.zeroon.record;

import ai.zeroon.memory.MemoryEntryRepository;
import ai.zeroon.record.RecordDtos.CreateRecordRequest;
import ai.zeroon.record.RecordDtos.RecordPage;
import ai.zeroon.record.RecordDtos.ZeroRecord;
import ai.zeroon.state.StateService;
import ai.zeroon.state.StateSessionRepository;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import ai.zeroon.user.UserState;
import jakarta.persistence.EntityNotFoundException;
import java.time.Duration;
import java.time.Instant;
import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class RecordService {

    private final UserRepository userRepository;
    private final ZeroRecordRepository zeroRecordRepository;
    private final StateSessionRepository stateSessionRepository;
    private final StateService stateService;
    private final ApplicationEventPublisher eventPublisher;
    private final MemoryEntryRepository memoryEntryRepository;

    public RecordService(
            UserRepository userRepository,
            ZeroRecordRepository zeroRecordRepository,
            StateSessionRepository stateSessionRepository,
            StateService stateService,
            ApplicationEventPublisher eventPublisher,
            MemoryEntryRepository memoryEntryRepository) {
        this.userRepository = userRepository;
        this.zeroRecordRepository = zeroRecordRepository;
        this.stateSessionRepository = stateSessionRepository;
        this.stateService = stateService;
        this.eventPublisher = eventPublisher;
        this.memoryEntryRepository = memoryEntryRepository;
    }

    @Transactional
    public ZeroRecord create(Long userId, CreateRecordRequest request, String rawIdempotencyKey) {
        String idempotencyKey = normalizeIdempotencyKey(rawIdempotencyKey);
        String fingerprint = idempotencyKey == null ? null : fingerprint(request);
        UserEntity user = userRepository.findByIdForUpdate(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        if (idempotencyKey != null) {
            var existing = zeroRecordRepository.findByUserIdAndIdempotencyKey(userId, idempotencyKey);
            if (existing.isPresent()) {
                if (!fingerprint.equals(existing.get().getIdempotencyFingerprint())) {
                    throw new ResponseStatusException(
                            HttpStatus.CONFLICT,
                            "Idempotency-Key was already used for a different record payload");
                }
                return toDto(existing.get());
            }
        }

        var activeSession = stateSessionRepository.findFirstByUserIdAndEndedAtIsNull(userId);
        UserState recordState = activeSession
                .map(session -> session.getState())
                .orElse(request.state());
        if (recordState == null) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Choose a current state before saving a zero record");
        }

        var record = zeroRecordRepository.save(new ZeroRecordEntity(
                user,
                recordState,
                normalize(request.goal()),
                normalize(request.content()),
                activeSession.map(session -> session.getId()).orElse(null),
                idempotencyKey,
                fingerprint));
        activeSession.ifPresent(session -> stateService.endSessionWithRecord(session, record.getId()));
        publishCommittedRecord(userId, record.getId());
        return toDto(record);
    }

    @Transactional(readOnly = true)
    public RecordPage list(Long userId, int page, int size) {
        int normalizedPage = Math.max(page, 0);
        int normalizedSize = Math.max(1, Math.min(size, 100));
        var pageable = PageRequest.of(normalizedPage, normalizedSize, Sort.by(Sort.Direction.DESC, "createdAt"));
        var records = zeroRecordRepository.findByUserIdOrderByCreatedAtDesc(userId, pageable);
        return new RecordPage(
                records.getContent().stream().map(this::toDto).toList(),
                normalizedPage,
                normalizedSize,
                records.getTotalElements());
    }

    @Transactional(readOnly = true)
    public ZeroRecord get(Long userId, Long recordId) {
        return zeroRecordRepository.findByIdAndUserId(recordId, userId)
                .map(this::toDto)
                .orElseThrow(() -> new EntityNotFoundException("Record not found"));
    }

    @Transactional
    public void delete(Long userId, Long recordId) {
        var record = zeroRecordRepository.findByIdAndUserId(recordId, userId)
                .orElseThrow(() -> new EntityNotFoundException("Record not found"));
        memoryEntryRepository.deleteByOwnedSource(userId, "ZERO_RECORD", recordId);
        stateSessionRepository.detachOwnedRecord(userId, recordId);
        zeroRecordRepository.delete(record);
        zeroRecordRepository.flush();
    }

    private void publishCommittedRecord(Long userId, Long recordId) {
        eventPublisher.publishEvent(new RecordCommittedEvent(userId, recordId));
    }

    private ZeroRecord toDto(ZeroRecordEntity record) {
        var stateSession = record.getStateSessionId() == null
                ? OptionalStateSession.empty()
                : stateSessionRepository.findById(record.getStateSessionId())
                        .map(session -> new OptionalStateSession(
                                session.getStartedAt(),
                                session.getEndedAt(),
                                stateDurationSeconds(session.getStartedAt(), session.getEndedAt())))
                        .orElseGet(OptionalStateSession::empty);
        return new ZeroRecord(
                record.getId(),
                record.getState(),
                record.getGoal(),
                record.getContent(),
                record.getAiSummary(),
                record.getStateSessionId(),
                stateSession.startedAt(),
                stateSession.endedAt(),
                stateSession.durationSeconds(),
                record.getCreatedAt());
    }

    private Long stateDurationSeconds(Instant startedAt, Instant endedAt) {
        if (startedAt == null || endedAt == null) {
            return null;
        }
        return Duration.between(startedAt, endedAt).toSeconds();
    }

    private record OptionalStateSession(
            Instant startedAt,
            Instant endedAt,
            Long durationSeconds) {

        private static OptionalStateSession empty() {
            return new OptionalStateSession(null, null, null);
        }
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }

    private String normalizeIdempotencyKey(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        String normalized = value.trim();
        if (normalized.length() > 64 || !normalized.matches("[A-Za-z0-9._~-]+")) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Idempotency-Key must contain 1-64 URL-safe opaque characters");
        }
        return normalized;
    }

    private String fingerprint(CreateRecordRequest request) {
        String canonical = component(request.state() == null ? null : request.state().name())
                + component(normalize(request.goal()))
                + component(normalize(request.content()));
        try {
            byte[] digest = MessageDigest.getInstance("SHA-256")
                    .digest(canonical.getBytes(StandardCharsets.UTF_8));
            return java.util.HexFormat.of().formatHex(digest);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 is unavailable", exception);
        }
    }

    private String component(String value) {
        return value == null ? "-1:" : value.length() + ":" + value;
    }
}
