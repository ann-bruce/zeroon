package ai.zeroon.memory;

import ai.zeroon.memory.MemoryDtos.MemoryEntry;
import ai.zeroon.memory.MemoryDtos.MemoryPage;
import ai.zeroon.memory.MemoryDtos.UpdateMemoryControlsRequest;
import jakarta.persistence.EntityNotFoundException;
import java.time.Clock;
import java.time.Instant;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class MemoryService {

    private final MemoryEntryRepository memoryEntryRepository;
    private final Clock clock;

    public MemoryService(MemoryEntryRepository memoryEntryRepository, Clock clock) {
        this.memoryEntryRepository = memoryEntryRepository;
        this.clock = clock;
    }

    @Transactional(readOnly = true)
    public MemoryPage list(Long userId, int page, int size) {
        PageRequest pageRequest = PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100));
        var result = memoryEntryRepository.findByUserIdAndExpiresAtIsNullOrderByCreatedAtDesc(userId, pageRequest);
        return new MemoryPage(
                result.getContent().stream().map(MemoryEntry::from).toList(),
                result.getNumber(),
                result.getSize(),
                result.getTotalElements());
    }

    @Transactional(readOnly = true)
    public MemoryEntry get(Long userId, Long memoryId) {
        return MemoryEntry.from(findOwnedVisible(userId, memoryId));
    }

    @Transactional
    public MemoryEntry updateControls(
            Long userId,
            Long memoryId,
            UpdateMemoryControlsRequest request) {
        var entry = findOwnedVisible(userId, memoryId);
        entry.updateControls(request.enabled(), request.aiContextEnabled(), Instant.now(clock));
        return MemoryEntry.from(entry);
    }

    @Transactional
    public void delete(Long userId, Long memoryId) {
        memoryEntryRepository.delete(findOwnedVisible(userId, memoryId));
    }

    private MemoryEntryEntity findOwnedVisible(Long userId, Long memoryId) {
        return memoryEntryRepository.findByIdAndUserIdAndExpiresAtIsNull(memoryId, userId)
                .orElseThrow(() -> new EntityNotFoundException("Memory entry not found"));
    }
}
