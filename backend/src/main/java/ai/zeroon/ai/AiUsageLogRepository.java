package ai.zeroon.ai;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface AiUsageLogRepository extends JpaRepository<AiUsageLogEntity, Long> {

    List<AiUsageLogEntity> findByUserIdOrderByCreatedAtDesc(Long userId);
}
