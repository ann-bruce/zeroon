package ai.zeroon.memory;

import ai.zeroon.record.ZeroRecordEntity;
import ai.zeroon.record.ZeroRecordRepository;
import ai.zeroon.user.UserRepository;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemoryProductionService {

    static final String ZERO_RECORD_SOURCE = "ZERO_RECORD";
    private static final int TITLE_LIMIT = 120;
    private static final int SUMMARY_LIMIT = 1000;

    private final MemoryEntryRepository memoryEntryRepository;
    private final ZeroRecordRepository zeroRecordRepository;
    private final UserRepository userRepository;

    public MemoryProductionService(
            MemoryEntryRepository memoryEntryRepository,
            ZeroRecordRepository zeroRecordRepository,
            UserRepository userRepository) {
        this.memoryEntryRepository = memoryEntryRepository;
        this.zeroRecordRepository = zeroRecordRepository;
        this.userRepository = userRepository;
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public void ensureForRecord(Long userId, Long recordId) {
        if (memoryEntryRepository.existsByUserIdAndTypeAndSourceTypeAndSourceId(
                userId, MemoryEntryType.ZERO_RECORD, ZERO_RECORD_SOURCE, recordId)) {
            return;
        }

        ZeroRecordEntity record = zeroRecordRepository.findByIdAndUserId(recordId, userId)
                .orElseThrow(() -> new EntityNotFoundException("Record not found"));
        var user = userRepository.findById(userId)
                .orElseThrow(() -> new EntityNotFoundException("User not found"));

        memoryEntryRepository.save(new MemoryEntryEntity(
                user,
                MemoryEntryType.ZERO_RECORD,
                truncate(record.getGoal(), TITLE_LIMIT),
                memorySummary(record),
                (short) 1,
                ZERO_RECORD_SOURCE,
                record.getId(),
                record.getCreatedAt()));
    }

    private String memorySummary(ZeroRecordEntity record) {
        String sourceText = hasText(record.getContent()) ? record.getContent() : record.getGoal();
        return truncate(sourceText, SUMMARY_LIMIT);
    }

    private String truncate(String value, int maxLength) {
        if (!hasText(value)) {
            return null;
        }
        String normalized = value.trim();
        int codePoints = normalized.codePointCount(0, normalized.length());
        if (codePoints <= maxLength) {
            return normalized;
        }
        return normalized.substring(0, normalized.offsetByCodePoints(0, maxLength));
    }

    private boolean hasText(String value) {
        return value != null && !value.isBlank();
    }
}
