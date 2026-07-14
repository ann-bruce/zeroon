package ai.zeroon.memory;

import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemoryEntryRepository extends JpaRepository<MemoryEntryEntity, Long> {

    boolean existsByUserIdAndTypeAndSourceTypeAndSourceId(
            Long userId,
            MemoryEntryType type,
            String sourceType,
            Long sourceId);

    Optional<MemoryEntryEntity> findByUserIdAndTypeAndSourceTypeAndSourceId(
            Long userId,
            MemoryEntryType type,
            String sourceType,
            Long sourceId);

    long countByUserIdAndTypeAndSourceTypeAndSourceId(
            Long userId,
            MemoryEntryType type,
            String sourceType,
            Long sourceId);

    Page<MemoryEntryEntity> findByUserIdAndExpiresAtIsNullOrderByCreatedAtDesc(Long userId, Pageable pageable);

    Optional<MemoryEntryEntity> findByIdAndUserIdAndExpiresAtIsNull(Long id, Long userId);
}
