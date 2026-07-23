package ai.zeroon.support;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SupportStatusHistoryRepository extends JpaRepository<SupportStatusHistoryEntity, Long> {

    List<SupportStatusHistoryEntity> findByRequest_IdOrderByCreatedAt(Long requestId);
}
