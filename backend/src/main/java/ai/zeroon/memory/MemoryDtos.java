package ai.zeroon.memory;

import java.time.Instant;
import java.util.List;

public final class MemoryDtos {

    private MemoryDtos() {
    }

    public record MemoryEntry(
            Long id,
            MemoryEntryType type,
            String title,
            String summary,
            int importance,
            String sourceType,
            Long sourceId,
            Instant expiresAt,
            boolean enabled,
            boolean aiContextEnabled,
            Instant createdAt,
            Instant updatedAt) {

        static MemoryEntry from(MemoryEntryEntity entry) {
            return new MemoryEntry(
                    entry.getId(),
                    entry.getType(),
                    entry.getTitle(),
                    entry.getSummary(),
                    entry.getImportance(),
                    entry.getSourceType(),
                    entry.getSourceId(),
                    entry.getExpiresAt(),
                    entry.isEnabled(),
                    entry.isAiContextEnabled(),
                    entry.getCreatedAt(),
                    entry.getUpdatedAt());
        }
    }

    public record MemoryPage(
            List<MemoryEntry> items,
            int page,
            int size,
            long totalElements) {
    }
}
