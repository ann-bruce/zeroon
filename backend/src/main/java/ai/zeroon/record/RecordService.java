package ai.zeroon.record;

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
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

@Service
public class RecordService {

    private static final Duration DUPLICATE_SAVE_WINDOW = Duration.ofSeconds(10);

    private final UserRepository userRepository;
    private final ZeroRecordRepository zeroRecordRepository;
    private final StateSessionRepository stateSessionRepository;
    private final StateService stateService;
    private final ApplicationEventPublisher eventPublisher;

    public RecordService(
            UserRepository userRepository,
            ZeroRecordRepository zeroRecordRepository,
            StateSessionRepository stateSessionRepository,
            StateService stateService,
            ApplicationEventPublisher eventPublisher) {
        this.userRepository = userRepository;
        this.zeroRecordRepository = zeroRecordRepository;
        this.stateSessionRepository = stateSessionRepository;
        this.stateService = stateService;
        this.eventPublisher = eventPublisher;
    }

    @Transactional
    public ZeroRecord create(Long userId, CreateRecordRequest request) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));
        var activeSession = stateSessionRepository.findFirstByUserIdAndEndedAtIsNull(userId);
        UserState recordState = activeSession
                .map(session -> session.getState())
                .orElse(request.state());
        if (recordState == null) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Choose a current state before saving a zero record");
        }

        var duplicatedRecord = zeroRecordRepository
                .findFirstByUserIdAndStateAndGoalAndContentOrderByCreatedAtDesc(
                        userId,
                        recordState,
                        normalize(request.goal()),
                        normalize(request.content()))
                .filter(this::isRecentDuplicate);
        if (duplicatedRecord.isPresent()) {
            var record = duplicatedRecord.get();
            activeSession.ifPresent(session -> stateService.endSessionWithRecord(session, record.getId()));
            publishCommittedRecord(userId, record.getId());
            return toDto(record);
        }

        var record = zeroRecordRepository.save(new ZeroRecordEntity(
                user,
                recordState,
                normalize(request.goal()),
                normalize(request.content()),
                activeSession.map(session -> session.getId()).orElse(null)));
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

    private boolean isRecentDuplicate(ZeroRecordEntity record) {
        return record.getCreatedAt().isAfter(Instant.now().minus(DUPLICATE_SAVE_WINDOW));
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
}
