package ai.zeroon.memory;

import ai.zeroon.memory.MemoryDtos.MemoryEntry;
import ai.zeroon.memory.MemoryDtos.MemoryPage;
import jakarta.persistence.EntityNotFoundException;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
public class MemoryService {

    private final MemoryEntryRepository memoryEntryRepository;

    public MemoryService(MemoryEntryRepository memoryEntryRepository) {
        this.memoryEntryRepository = memoryEntryRepository;
    }

    public MemoryPage list(Long userId, int page, int size) {
        PageRequest pageRequest = PageRequest.of(Math.max(page, 0), Math.min(Math.max(size, 1), 100));
        var result = memoryEntryRepository.findByUserIdAndExpiresAtIsNullOrderByCreatedAtDesc(userId, pageRequest);
        return new MemoryPage(
                result.getContent().stream().map(MemoryEntry::from).toList(),
                result.getNumber(),
                result.getSize(),
                result.getTotalElements());
    }

    public MemoryEntry get(Long userId, Long memoryId) {
        return memoryEntryRepository.findByIdAndUserIdAndExpiresAtIsNull(memoryId, userId)
                .map(MemoryEntry::from)
                .orElseThrow(() -> new EntityNotFoundException("Memory entry not found"));
    }
}
