package ai.zeroon.memory;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

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

    @Query("""
            select e from MemoryEntryEntity e
            where e.user.id = :userId
              and e.enabled = true
              and e.aiContextEnabled = true
              and (e.expiresAt is null or e.expiresAt > :now)
            order by e.createdAt desc
            """)
    List<MemoryEntryEntity> findEligibleForAiContext(
            @Param("userId") Long userId,
            @Param("now") Instant now,
            Pageable pageable);
}
