package ai.zeroon.state;

import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StateHistoryRepository extends JpaRepository<StateHistoryEntity, Long> {

    Optional<StateHistoryEntity> findFirstByUserIdOrderByCreatedAtDesc(Long userId);

    List<StateHistoryEntity> findByUserIdAndCreatedAtGreaterThanEqualOrderByCreatedAtDesc(Long userId, Instant since);
}
