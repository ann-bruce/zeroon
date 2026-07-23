package ai.zeroon.support;

import java.util.List;
import org.springframework.data.jpa.repository.JpaRepository;

public interface SupportAdminAuditRepository extends JpaRepository<SupportAdminAuditEntity, Long> {

    List<SupportAdminAuditEntity> findByRequest_IdOrderByCreatedAt(Long requestId);
}
