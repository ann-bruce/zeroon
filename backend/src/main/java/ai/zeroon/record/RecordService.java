package ai.zeroon.record;

import ai.zeroon.record.RecordDtos.CreateRecordRequest;
import ai.zeroon.record.RecordDtos.RecordPage;
import ai.zeroon.record.RecordDtos.ZeroRecord;
import ai.zeroon.user.UserEntity;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import java.time.Duration;
import java.time.Instant;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class RecordService {

    private static final Duration DUPLICATE_SAVE_WINDOW = Duration.ofSeconds(10);

    private final UserRepository userRepository;
    private final ZeroRecordRepository zeroRecordRepository;

    public RecordService(UserRepository userRepository, ZeroRecordRepository zeroRecordRepository) {
        this.userRepository = userRepository;
        this.zeroRecordRepository = zeroRecordRepository;
    }

    @Transactional
    public ZeroRecord create(Long userId, CreateRecordRequest request) {
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        return zeroRecordRepository
                .findFirstByUserIdAndStateAndMoodAndGoalAndContentOrderByCreatedAtDesc(
                        userId,
                        request.state(),
                        normalize(request.mood()),
                        normalize(request.goal()),
                        normalize(request.content()))
                .filter(this::isRecentDuplicate)
                .map(this::toDto)
                .orElseGet(() -> toDto(zeroRecordRepository.save(new ZeroRecordEntity(
                        user,
                        request.state(),
                        normalize(request.mood()),
                        normalize(request.goal()),
                        normalize(request.content())))));
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

    private ZeroRecord toDto(ZeroRecordEntity record) {
        return new ZeroRecord(
                record.getId(),
                record.getState(),
                record.getMood(),
                record.getGoal(),
                record.getContent(),
                record.getAiSummary(),
                record.getCreatedAt());
    }

    private String normalize(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
