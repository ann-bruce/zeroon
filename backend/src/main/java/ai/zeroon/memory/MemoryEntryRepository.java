package ai.zeroon.memory;

import java.util.Optional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

public interface MemoryEntryRepository extends JpaRepository<MemoryEntryEntity, Long> {

    Page<MemoryEntryEntity> findByUserIdAndExpiresAtIsNullOrderByCreatedAtDesc(Long userId, Pageable pageable);

    Optional<MemoryEntryEntity> findByIdAndUserIdAndExpiresAtIsNull(Long id, Long userId);
}
