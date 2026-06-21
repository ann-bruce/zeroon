package ai.zeroon.state;

import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface StateSessionRepository extends JpaRepository<StateSessionEntity, Long> {

    Optional<StateSessionEntity> findFirstByUserIdAndEndedAtIsNull(Long userId);
}
