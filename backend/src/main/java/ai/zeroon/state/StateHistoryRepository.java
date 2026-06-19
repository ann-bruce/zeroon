package ai.zeroon.state;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StateHistoryRepository extends JpaRepository<StateHistoryEntity, Long> {

    Optional<StateHistoryEntity> findFirstByUserIdOrderByCreatedAtDesc(Long userId);
}
